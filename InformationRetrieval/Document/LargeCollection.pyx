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
        super().__init__(directory, parameter)
        self.constructDictionaryAndIndexesInDisk()

    cpdef constructDictionaryAndIndexesInDisk(self):
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
        cdef str word
        for word in currentWords:
            if word is not None:
                return True
        return False

    cpdef list selectDictionariesWithMinimumWords(self, list currentWords):
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
