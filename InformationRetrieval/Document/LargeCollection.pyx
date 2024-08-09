from Dictionary.Word cimport Word

from InformationRetrieval.Document.DiskCollection cimport DiskCollection
from InformationRetrieval.Document.Document cimport Document
from InformationRetrieval.Document.DocumentText cimport DocumentText
from InformationRetrieval.Document.Parameter cimport Parameter
from InformationRetrieval.Index.InvertedIndex cimport InvertedIndex
from InformationRetrieval.Index.NGramIndex cimport NGramIndex
from InformationRetrieval.Index.PositionalIndex cimport PositionalIndex
from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Index.TermType import TermType

cdef class LargeCollection(DiskCollection):

    def __init__(self,
                 directory: str,
                 parameter: Parameter):
        """
        Constructor for the LargeCollection class. In large collections, both dictionary and indexes are stored in the
        disk and don't fit in memory in their construction phase and usage phase. For that reason, in their construction
        phase, multiple disk reads and optimizations are needed.
        :param directory: Directory where the document collection resides.
        :param parameter: Search parameter
        """
        super().__init__(directory, parameter)
        self.constructDictionaryAndIndexesInDisk()

    cpdef constructDictionaryAndIndexesInDisk(self):
        """
        The method constructs the term dictionary and all indexes on disk.
        """
        self.constructDictionaryAndInvertedIndexInDisk(TermType.TOKEN)
        if self.parameter.constructPositionalIndex():
            self.constructDictionaryAndPositionalIndexInDisk(TermType.TOKEN)
        if self.parameter.constructPhraseIndex():
            self.constructDictionaryAndInvertedIndexInDisk(TermType.PHRASE)
            if self.parameter.constructPositionalIndex():
                self.constructDictionaryAndPositionalIndexInDisk(TermType.PHRASE)
        if self.parameter.constructNGramIndex():
            self.constructNGramDictionaryAndIndexInDisk()

    cpdef bint notCombinedAllDictionaries(self, list currentWords):
        """
        In single pass in memory indexing, the dictionary files are merged to get the final dictionary file. This method
        checks if all parallel dictionaries are combined or not.
        :param currentWords: Current pointers for the words in parallel dictionaries. currentWords[0] is the current word
                             in the first dictionary to be combined, currentWords[2] is the current word in the second
                             dictionary to be combined etc.
        :return: True, if all merge operation is completed, false otherwise.
        """
        cdef str word
        for word in currentWords:
            if word is not None:
                return True
        return False

    cpdef list selectDictionariesWithMinimumWords(self, list currentWords):
        """
        In single pass in memory indexing, the dictionary files are merged to get the final dictionary file. This method
        identifies the dictionaries whose words to be merged are lexicographically the first. They will be selected and
        combined in the next phase.
        :param currentWords: Current pointers for the words in parallel dictionaries. currentWords[0] is the current word
                             in the first dictionary to be combined, currentWords[2] is the current word in the second
                             dictionary to be combined etc.
        :return: An array list of indexes for the dictionaries, whose words to be merged are lexicographically the first.
        """
        cdef list result
        cdef str _min, word
        cdef int i
        result = []
        _min = None
        for word in currentWords:
            if word is not None and (_min is None or self.comparator(Word(word), Word(_min)) < 0):
                _min = word
        for i in range(len(currentWords)):
            if currentWords[i] is not None and currentWords[i] == _min:
                result.append(i)
        return result

    cpdef combineMultipleDictionariesInDisk(self,
                                          str name,
                                          str tmpName,
                                          int blockCount):
        """
        In single pass in memory indexing, the dictionary files are merged to get the final dictionary file. This method
        implements the merging algorithm. Reads the dictionary files in parallel and at each iteration puts the smallest
        word to the final dictionary. Updates the pointers of the dictionaries accordingly.
        :param name: Name of the collection.
        :param tmpName: Temporary name of the dictionary files.
        :param blockCount: Number of dictionaries to be merged.
        """
        cdef list current_id_list
        cdef list current_words
        cdef list indexes_to_combine
        cdef int i
        cdef str line
        current_id_list = []
        current_words = []
        files = []
        out_file = open(name + "-dictionary.txt", mode="w", encoding="utf-8")
        for i in range(blockCount):
            files.append(open("tmp-" + tmpName + i.__str__() + "-dictionary.txt", mode="r", encoding="utf-8"))
            line = files[i].readline().strip()
            current_id_list.append(int(line[0:line.index(" ")]))
            current_words.append(line[line.index(" ") + 1:])
        while self.notCombinedAllDictionaries(current_words):
            indexes_to_combine = self.selectDictionariesWithMinimumWords(current_words)
            out_file.write(current_id_list[indexes_to_combine[0]].__str__() + " " + current_words[indexes_to_combine[0]] + "\n")
            for i in indexes_to_combine:
                line = files[i].readline().strip()
                if line != "":
                    current_id_list[i] = int(line[0:line.index(" ")])
                    current_words[i] = line[line.index(" ") + 1:]
                else:
                    current_words[i] = None
        for i in range(blockCount):
            files[i].close()
        out_file.close()

    cpdef constructDictionaryAndInvertedIndexInDisk(self, object termType):
        """
        In single pass in memory indexing, the dictionaries and inverted indexes are created in a block wise manner. They
        do not fit in memory, therefore documents are read one by one. For each document, the terms are added to the
        current dictionary and inverted index. If the number of documents read are above the limit, current partial
        dictionary and inverted index file are saved and new dictionary and inverted index file are open. After reading
        all  documents, we combine the dictionary and inverted index files to get the final dictionary and inverted index
        file.
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        """
        cdef int i, block_count, term_id, word_index
        cdef InvertedIndex inverted_index
        cdef TermDictionary dictionary
        cdef Document doc
        cdef DocumentText document_text
        cdef set word_list
        cdef str word
        i = 0
        block_count = 0
        inverted_index = InvertedIndex()
        dictionary = TermDictionary(self.comparator)
        for doc in self.documents:
            if i < self.parameter.getDocumentLimit():
                i = i + 1
            else:
                dictionary.save("tmp-" + block_count.__str__())
                dictionary = TermDictionary(self.comparator)
                inverted_index.saveSorted("tmp-" + block_count.__str__())
                inverted_index = InvertedIndex()
                block_count = block_count + 1
                i = 0
            document_text = doc.loadDocument()
            word_list = document_text.constructDistinctWordList(termType)
            for word in word_list:
                word_index = dictionary.getWordIndex(word)
                if word_index != -1:
                    term_id = dictionary.getWordWithIndex(word_index).getTermId()
                else:
                    term_id = word.__hash__() % (2 ** 24)
                    dictionary.addTerm(word, term_id)
                inverted_index.add(term_id, doc.getDocId())
        if len(self.documents) != 0:
            dictionary.save("tmp-" + block_count.__str__())
            inverted_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultipleDictionariesInDisk(self.name, "", block_count)
            self.combineMultipleInvertedIndexesInDisk(self.name, "", block_count)
        else:
            self.combineMultipleDictionariesInDisk(self.name + "-phrase", "", block_count)
            self.combineMultipleInvertedIndexesInDisk(self.name + "-phrase", "", block_count)

    cpdef constructDictionaryAndPositionalIndexInDisk(self, object termType):
        """
        In single pass in memory indexing, the dictionaries and positional indexes are created in a block wise manner.
        They do not fit in memory, therefore documents are read one by one. For each document, the terms are added to the
        current dictionary and positional index. If the number of documents read are above the limit, current partial
        dictionary and positional index file are saved and new dictionary and positional index file are open. After
        reading all documents, we combine the dictionary and positional index files to get the final dictionary and
        positional index file.
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        """
        cdef int i, block_count, word_index, term_id
        cdef PositionalIndex positional_index
        cdef TermDictionary term_dictionary
        cdef Document doc
        cdef DocumentText document_text
        cdef list terms
        cdef TermOccurrence term_occurrence
        i = 0
        block_count = 0
        positional_index = PositionalIndex()
        dictionary = TermDictionary(self.comparator)
        for doc in self.documents:
            if i < self.parameter.getDocumentLimit():
                i = i + 1
            else:
                dictionary.save("tmp-" + block_count.__str__())
                dictionary = TermDictionary(self.comparator)
                positional_index.saveSorted("tmp-" + block_count.__str__())
                positional_index = PositionalIndex()
                block_count = block_count + 1
                i = 0
            document_text = doc.loadDocument()
            terms = document_text.constructTermList(doc.getDocId(), termType)
            for term_occurrence in terms:
                word_index = dictionary.getWordIndex(term_occurrence.getTerm().getName())
                if word_index != -1:
                    term_id = dictionary.getWordWithIndex(word_index).getTermId()
                else:
                    term_id = term_occurrence.getTerm().getName().__hash__() % (2 ** 24)
                    dictionary.addTerm(term_occurrence.getTerm().getName(), term_id)
                positional_index.addPosition(term_id, term_occurrence.getDocId(), term_occurrence.getPosition())
        if len(self.documents) != 0:
            dictionary.save("tmp-" + block_count.__str__())
            positional_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultipleDictionariesInDisk(self.name, "", block_count)
            self.combineMultiplePositionalIndexesInDisk(self.name, block_count)
        else:
            self.combineMultipleDictionariesInDisk(self.name + "-phrase", "", block_count)
            self.combineMultiplePositionalIndexesInDisk(self.name + "-phrase", block_count)

    cpdef addNGramsToDictionaryAndIndex(self,
                                        str line,
                                        int k,
                                        TermDictionary nGramDictionary,
                                        NGramIndex nGramIndex):
        """
        The method constructs the N-Grams from the given tokens in a string. The method first identifies the tokens in
        the line by splitting from space, then constructs N-Grams for those tokens and adds N-Grams to the N-Gram
        dictionary and N-Gram index.
        :param line: String containing the tokens.
        :param k: N in N-Gram.
        :param nGramDictionary: N-Gram term dictionary
        :param nGramIndex: N-Gram inverted index
        """
        cdef int word_id, word_index, term_id
        cdef str word
        cdef list bi_grams
        cdef TermOccurrence term
        word_id = int(line[0:line.index(" ")])
        word = line[line.index(" ") + 1:]
        bi_grams = TermDictionary.constructNGrams(word, word_id, k)
        for term in bi_grams:
            word_index = nGramDictionary.getWordIndex(term.getTerm().getName())
            if word_index != -1:
                term_id = nGramDictionary.getWordWithIndex(word_index).getTermId()
            else:
                term_id = term.getTerm().getName().__hash__() % (2 ** 24)
                nGramDictionary.addTerm(term.getTerm().getName(), term_id)
            nGramIndex.add(term_id, word_id)

    cpdef constructNGramDictionaryAndIndexInDisk(self):
        """
        In single pass in memory indexing, the dictionaries and N-gram indexes are created in a block wise manner.
        They do not fit in memory, therefore documents are read one by one. For each document, the terms are added to the
        current dictionary and N-gram index. If the number of documents read are above the limit, current partial
        dictionary and N-gram index file are saved and new dictionary and N-gram index file are open. After
        reading all documents, we combine the dictionary and N-gram index files to get the final dictionary and
        N-gram index file.
        """
        cdef int i, block_count
        cdef TermDictionary bi_gram_dictionary, tri_gram_dictionary
        cdef NGramIndex bi_gram_index, tri_gram_index
        cdef str line
        i = 0
        block_count = 0
        bi_gram_dictionary = TermDictionary(self.comparator)
        tri_gram_dictionary = TermDictionary(self.comparator)
        bi_gram_index = NGramIndex()
        tri_gram_index = NGramIndex()
        input_file = open(self.name + "-dictionary.txt")
        line = input_file.readline().strip()
        while line:
            if i < self.parameter.getWordLimit():
                i = i + 1
            else:
                bi_gram_dictionary.save("tmp-biGram-" + block_count.__str__())
                tri_gram_dictionary.save("tmp-triGram-" + block_count.__str__())
                bi_gram_dictionary = TermDictionary(self.comparator)
                tri_gram_dictionary = TermDictionary(self.comparator)
                bi_gram_index.save("tmp-biGram-" + block_count.__str__())
                bi_gram_index = NGramIndex()
                tri_gram_index.save("tmp-triGram-" + block_count.__str__())
                tri_gram_index = NGramIndex()
                block_count = block_count + 1
                i = 0
            self.addNGramsToDictionaryAndIndex(line, 2, bi_gram_dictionary, bi_gram_index)
            self.addNGramsToDictionaryAndIndex(line, 3, tri_gram_dictionary, tri_gram_index)
            line = input_file.readline().strip()
        input_file.close()
        if len(self.documents) != 0:
            bi_gram_dictionary.save("tmp-biGram-" + block_count.__str__())
            tri_gram_dictionary.save("tmp-triGram-" + block_count.__str__())
            bi_gram_index.save("tmp-biGram-" + block_count.__str__())
            tri_gram_index.save("tmp-triGram-" + block_count.__str__())
            block_count = block_count + 1
        self.combineMultipleDictionariesInDisk(self.name + "-biGram", "biGram-", block_count)
        self.combineMultipleDictionariesInDisk(self.name + "-triGram", "triGram-", block_count)
        self.combineMultipleInvertedIndexesInDisk(self.name + "-biGram", "biGram-", block_count)
        self.combineMultipleInvertedIndexesInDisk(self.name + "-triGram", "triGram-", block_count)
