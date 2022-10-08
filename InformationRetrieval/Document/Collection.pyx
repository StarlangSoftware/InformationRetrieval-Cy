import os
from functools import cmp_to_key

from Dictionary.Word cimport Word

from InformationRetrieval.Document.Document cimport Document
from InformationRetrieval.Document.DocumentText cimport DocumentText
from InformationRetrieval.Document.DocumentWeighting import DocumentWeighting
from InformationRetrieval.Document.IndexType import IndexType
from InformationRetrieval.Index.PositionalPostingList cimport PositionalPostingList
from InformationRetrieval.Index.PostingList cimport PostingList
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Index.TermType import TermType
from InformationRetrieval.Index.TermWeighting import TermWeighting
from InformationRetrieval.Query.RetrievalType import RetrievalType

cdef class Collection:

    def __init__(self,
                 directory: str,
                 parameter: Parameter):
        cdef int file_limit, j
        cdef list files
        cdef str file_name
        cdef Document document
        self.__name = directory
        self.__index_type = parameter.getIndexType()
        self.__comparator = parameter.getWordComparator()
        self.__parameter = parameter
        self.__documents = []
        for root, dirs, files in os.walk(directory):
            file_limit = len(files)
            if parameter.limitNumberOfDocumentsLoaded():
                file_limit = parameter.getDocumentLimit()
            j = 0
            files.sort()
            for file in files:
                if j >= file_limit:
                    break
                file_name = os.path.join(root, file)
                if file.endswith(".txt"):
                    document = Document(file_name, file, j)
                    self.__documents.append(document)
                    j = j + 1
        if parameter.loadIndexesFromFile():
            self.__dictionary = TermDictionary(self.__comparator, directory)
            self.__inverted_index = InvertedIndex(directory)
            if parameter.constructPositionalIndex():
                self.__positional_index = PositionalIndex(directory)
                self.__positional_index.setDocumentSizes(self.__documents)
            if parameter.constructPhraseIndex():
                self.__phrase_dictionary = TermDictionary(self.__comparator, directory + "-phrase")
                self.__phrase_index = InvertedIndex(directory + "-phrase")
                if parameter.constructPositionalIndex():
                    self.__phrase_positional_index = PositionalIndex(directory + "-phrase")
            if parameter.constructNGramIndex():
                self.__bi_gram_dictionary = TermDictionary(self.__comparator, directory + "-biGram")
                self.__tri_gram_dictionary = TermDictionary(self.__comparator, directory + "-triGram")
                self.__bi_gram_index = NGramIndex(directory + "-biGram")
                self.__tri_gram_index = NGramIndex(directory + "-triGram")
        elif parameter.constructDictionaryInDisk():
            self.constructDictionaryInDisk()
        elif parameter.constructIndexInDisk():
            self.constructIndexesInDisk()
        else:
            self.constructIndexesInMemory()

    cpdef int size(self):
        return len(self.__documents)

    cpdef int vocabularySize(self):
        return self.__dictionary.size()

    cpdef save(self):
        if self.__index_type == IndexType.INVERTED_INDEX:
            self.__dictionary.save(self.__name)
            self.__inverted_index.save(self.__name)
            if self.__parameter.constructPositionalIndex():
                self.__positional_index.save(self.__name)
            if self.__parameter.constructPhraseIndex():
                self.__phrase_dictionary.save(self.__name + "-phrase")
                self.__phrase_index.save(self.__name + "-phrase")
                if self.__parameter.constructPositionalIndex():
                    self.__phrase_positional_index.save(self.__name + "-phrase")
            if self.__parameter.constructNGramIndex():
                self.__bi_gram_dictionary.save(self.__name + "-biGram")
                self.__tri_gram_dictionary.save(self.__name + "-triGram")
                self.__bi_gram_index.save(self.__name + "-biGram")
                self.__tri_gram_index.save(self.__name + "-triGram")

    cpdef constructDictionaryInDisk(self):
        self.constructDictionaryAndInvertedIndexInDisk(TermType.TOKEN)
        if self.__parameter.constructPositionalIndex():
            self.constructDictionaryAndPositionalIndexInDisk(TermType.TOKEN)
        if self.__parameter.constructPhraseIndex():
            self.constructDictionaryAndInvertedIndexInDisk(TermType.PHRASE)
            if self.__parameter.constructPositionalIndex():
                self.constructDictionaryAndPositionalIndexInDisk(TermType.PHRASE)
        if self.__parameter.constructNGramIndex():
            self.constructNGramDictionaryAndIndexInDisk()

    cpdef constructIndexesInDisk(self):
        cdef set word_list
        word_list = self.constructDistinctWordList(TermType.TOKEN)
        self.__dictionary = TermDictionary(self.__comparator, word_list)
        self.constructInvertedIndexInDisk(self.__dictionary, TermType.TOKEN)
        if self.__parameter.constructPositionalIndex():
            self.constructPositionalIndexInDisk(self.__dictionary, TermType.TOKEN)
        if self.__parameter.constructPhraseIndex():
            word_list = self.constructDistinctWordList(TermType.PHRASE)
            self.__phrase_dictionary = TermDictionary(self.__comparator, word_list)
            self.constructInvertedIndexInDisk(self.__phrase_dictionary, TermType.PHRASE)
            if self.__parameter.constructPositionalIndex():
                self.constructPositionalIndexInDisk(self.__phrase_dictionary, TermType.PHRASE)
        if self.__parameter.constructNGramIndex():
            self.constructNGramIndex()

    cpdef constructIndexesInMemory(self):
        cdef list terms
        terms = self.constructTerms(TermType.TOKEN)
        self.__dictionary = TermDictionary(self.__comparator, terms)
        if self.__index_type == IndexType.INCIDENCE_MATRIX:
            self.__incidence_matrix = IncidenceMatrix(terms, self.__dictionary, len(self.__documents))
        elif self.__index_type == IndexType.INVERTED_INDEX:
            self.__inverted_index = InvertedIndex(self.__dictionary, terms)
            if self.__parameter.constructPositionalIndex():
                self.__positional_index = PositionalIndex(self.__dictionary, terms)
            if self.__parameter.constructPhraseIndex():
                terms = self.constructTerms(TermType.PHRASE)
                self.__phrase_dictionary = TermDictionary(self.__comparator, terms)
                self.__phrase_index = InvertedIndex(self.__phrase_dictionary, terms)
                if self.__parameter.constructPositionalIndex():
                    self.__phrase_positional_index = PositionalIndex(self.__phrase_dictionary, terms)
            if self.__parameter.constructNGramIndex():
                self.constructNGramIndex()

    cpdef list constructTerms(self, object termType):
        cdef list terms
        cdef Document doc
        cdef DocumentText document_text
        cdef list doc_terms
        terms = []
        for doc in self.__documents:
            document_text = doc.loadDocument()
            doc_terms = document_text.constructTermList(doc.getDocId(), termType)
            terms.extend(doc_terms)
        terms.sort(key=cmp_to_key(TermOccurrence.termOccurrenceComparator))
        return terms

    cpdef set constructDistinctWordList(self, object termType):
        cdef set words, doc_words
        cdef Document doc
        cdef DocumentText document_text
        words = set()
        for doc in self.__documents:
            document_text = doc.loadDocument()
            doc_words = document_text.constructDistinctWordList(termType)
            words = words.union(doc_words)
        return words

    cpdef bint notCombinedAllIndexes(self, list currentIdList):
        cdef int _id
        for _id in currentIdList:
            if _id != -1:
                return True
        return False

    cpdef bint notCombinedAllDictionaries(self, list currentWords):
        cdef str word
        for word in currentWords:
            if word is not None:
                return True
        return False

    cpdef list selectIndexesWithMinimumTermIds(self, list currentIdList):
        cdef list result
        cdef int _id
        cdef float _min
        result = []
        _min = float('inf')
        for _id in currentIdList:
            if _id != -1 and _id < _min:
                _min = _id
        for i in range(len(currentIdList)):
            if currentIdList[i] == _min:
                result.append(i)
        return result

    cpdef list selectDictionariesWithMinimumWords(self, list currentWords):
        cdef list result
        cdef str _min, word
        cdef int i
        result = []
        _min = None
        for word in currentWords:
            if word is not None and (_min is None or self.__comparator(Word(word), Word(_min)) < 0):
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
        bi_gram_dictionary = TermDictionary(self.__comparator)
        tri_gram_dictionary = TermDictionary(self.__comparator)
        bi_gram_index = NGramIndex()
        tri_gram_index = NGramIndex()
        input_file = open(self.__name + "-dictionary.txt")
        line = input_file.readline().strip()
        while line:
            if i < self.__parameter.getWordLimit():
                i = i + 1
            else:
                bi_gram_dictionary.save("tmp-biGram-" + block_count.__str__())
                tri_gram_dictionary.save("tmp-triGram-" + block_count.__str__())
                bi_gram_dictionary = TermDictionary(self.__comparator)
                tri_gram_dictionary = TermDictionary(self.__comparator)
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
        if len(self.__documents) != 0:
            bi_gram_dictionary.save("tmp-biGram-" + block_count.__str__())
            tri_gram_dictionary.save("tmp-triGram-" + block_count.__str__())
            bi_gram_index.save("tmp-biGram-" + block_count.__str__())
            tri_gram_index.save("tmp-triGram-" + block_count.__str__())
            block_count = block_count + 1
        self.combineMultipleDictionariesInDisk(self.__name + "-biGram", "biGram-", block_count)
        self.combineMultipleDictionariesInDisk(self.__name + "-triGram", "triGram-", block_count)
        self.combineMultipleInvertedIndexesInDisk(self.__name + "-biGram", "biGram-", block_count)
        self.combineMultipleInvertedIndexesInDisk(self.__name + "-triGram", "triGram-", block_count)

    cpdef combineMultipleInvertedIndexesInDisk(self,
                                             str name,
                                             str tmpName,
                                             int blockCount):
        cdef list current_id_list, current_posting_lists, files, items, indexes_to_combine
        cdef PostingList merged_posting_list
        cdef int i
        cdef str line
        current_id_list = []
        current_posting_lists = []
        files = []
        output_file = open(name + "-postings.txt", mode="w", encoding="utf-8")
        for i in range(blockCount):
            files.append(open("tmp-" + tmpName + i.__str__() + "-postings.txt", mode="r", encoding="utf-8"))
            line = files[i].readline().strip()
            items = line.split(" ")
            current_id_list.append(int(items[0]))
            line = files[i].readline().strip()
            current_posting_lists.append(PostingList(line))
        while self.notCombinedAllIndexes(current_id_list):
            indexes_to_combine = self.selectIndexesWithMinimumTermIds(current_id_list)
            merged_posting_list = current_posting_lists[indexes_to_combine[0]]
            for i in range(1, len(indexes_to_combine)):
                merged_posting_list = merged_posting_list.union(current_posting_lists[indexes_to_combine[i]])
            merged_posting_list.writeToFile(output_file, current_id_list[indexes_to_combine[0]])
            for i in indexes_to_combine:
                line = files[i].readline().strip()
                if line != "":
                    items = line.split(" ")
                    current_id_list[i] = int(items[0])
                    line = files[i].readline().strip()
                    current_posting_lists[i] = PostingList(line)
                else:
                    current_id_list[i] = -1
        for i in range(blockCount):
            files[i].close()
        output_file.close()

    cpdef constructInvertedIndexInDisk(self,
                                     TermDictionary dictionary,
                                     object termType):
        cdef int i, block_count, term_id
        cdef InvertedIndex inverted_index
        cdef Document doc
        cdef DocumentText document_text
        cdef set word_list
        cdef str word
        i = 0
        block_count = 0
        inverted_index = InvertedIndex()
        for doc in self.__documents:
            if i < self.__parameter.getDocumentLimit():
                i = i + 1
            else:
                inverted_index.saveSorted("tmp-" + block_count.__str__())
                inverted_index = InvertedIndex()
                block_count = block_count + 1
                i = 0
            document_text = doc.loadDocument()
            word_list = document_text.constructDistinctWordList(termType)
            for word in word_list:
                term_id = dictionary.getWordIndex(word)
                inverted_index.add(term_id, doc.getDocId())
        if len(self.__documents) != 0:
            inverted_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultipleInvertedIndexesInDisk(self.__name, "", block_count)
        else:
            self.combineMultipleInvertedIndexesInDisk(self.__name + "-phrase", "", block_count)

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
        dictionary = TermDictionary(self.__comparator)
        for doc in self.__documents:
            if i < self.__parameter.getDocumentLimit():
                i = i + 1
            else:
                dictionary.save("tmp-" + block_count.__str__())
                dictionary = TermDictionary(self.__comparator)
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
        if len(self.__documents) != 0:
            dictionary.save("tmp-" + block_count.__str__())
            inverted_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultipleDictionariesInDisk(self.__name, "", block_count)
            self.combineMultipleInvertedIndexesInDisk(self.__name, "", block_count)
        else:
            self.combineMultipleDictionariesInDisk(self.__name + "-phrase", "", block_count)
            self.combineMultipleInvertedIndexesInDisk(self.__name + "-phrase", "", block_count)

    cpdef combineMultiplePositionalIndexesInDisk(self,
                                                 str name,
                                                 int blockCount):
        cdef list current_id_list, current_posting_lists, files, items, indexes_to_combine
        cdef int i
        cdef str line
        cdef PositionalPostingList merged_posting_list
        current_id_list = []
        current_posting_lists = []
        files = []
        output_file = open(name + "-positionalPostings.txt", mode="w", encoding="utf-8")
        for i in range(blockCount):
            files.append(open("tmp-" + i.__str__() + "-positionalPostings.txt", mode="r", encoding="utf-8"))
            line = files[i].readline().strip()
            items = line.split(" ")
            current_id_list.append(int(items[0]))
            current_posting_lists.append(PositionalPostingList(files[i], int(items[1])))
        while self.notCombinedAllIndexes(current_id_list):
            indexes_to_combine = self.selectIndexesWithMinimumTermIds(current_id_list)
            merged_posting_list = current_posting_lists[indexes_to_combine[0]]
            for i in range(1, len(indexes_to_combine)):
                merged_posting_list = merged_posting_list.union(current_posting_lists[indexes_to_combine[i]])
            merged_posting_list.writeToFile(output_file, current_id_list[indexes_to_combine[0]])
            for i in indexes_to_combine:
                line = files[i].readline().strip()
                if line != "":
                    items = line.split(" ")
                    current_id_list[i] = int(items[0])
                    current_posting_lists[i] = PositionalPostingList(files[i], int(items[1]))
                else:
                    current_id_list[i] = -1
        for i in range(blockCount):
            files[i].close()
        output_file.close()

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
        dictionary = TermDictionary(self.__comparator)
        for doc in self.__documents:
            if i < self.__parameter.getDocumentLimit():
                i = i + 1
            else:
                dictionary.save("tmp-" + block_count.__str__())
                dictionary = TermDictionary(self.__comparator)
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
        if len(self.__documents) != 0:
            dictionary.save("tmp-" + block_count.__str__())
            positional_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultipleDictionariesInDisk(self.__name, "", block_count)
            self.combineMultiplePositionalIndexesInDisk(self.__name, block_count)
        else:
            self.combineMultipleDictionariesInDisk(self.__name + "-phrase", "", block_count)
            self.combineMultiplePositionalIndexesInDisk(self.__name + "-phrase", block_count)

    cpdef constructPositionalIndexInDisk(self,
                                         TermDictionary dictionary,
                                         object termType):
        cdef int i, block_count, term_id
        cdef PositionalIndex positional_index
        cdef Document doc
        cdef DocumentText document_text
        cdef list terms
        cdef TermOccurrence term_occurrence
        i = 0
        block_count = 0
        positional_index = PositionalIndex()
        for doc in self.__documents:
            if i < self.__parameter.getDocumentLimit():
                i = i + 1
            else:
                positional_index.saveSorted("tmp-" + block_count.__str__())
                positional_index = PositionalIndex()
                block_count = block_count + 1
                i = 0
            document_text = doc.loadDocument()
            terms = document_text.constructTermList(doc.getDocId(), termType)
            for term_occurrence in terms:
                termId = dictionary.getWordIndex(term_occurrence.getTerm().getName())
                positional_index.addPosition(termId, term_occurrence.getDocId(), term_occurrence.getPosition())
        if len(self.__documents) != 0:
            positional_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultiplePositionalIndexesInDisk(self.__name, block_count)
        else:
            self.combineMultiplePositionalIndexesInDisk(self.__name + "-phrase", block_count)

    cpdef constructNGramIndex(self):
        cdef list terms
        terms = self.__dictionary.constructTermsFromDictionary(2)
        self.__bi_gram_dictionary = TermDictionary(self.__comparator, terms)
        self.__bi_gram_index = NGramIndex(self.__bi_gram_dictionary, terms)
        terms = self.__dictionary.constructTermsFromDictionary(3)
        self.__tri_gram_dictionary = TermDictionary(self.__comparator, terms)
        self.__tri_gram_index = NGramIndex(self.__tri_gram_dictionary, terms)

    cpdef searchCollection(self,
                         Query query,
                         object retrievalType,
                         object termWeighting = TermWeighting.NATURAL,
                         object documentWeighting = DocumentWeighting.NO_IDF):
        if self.__index_type == IndexType.INCIDENCE_MATRIX:
            return self.__incidence_matrix.search(query, self.__dictionary)
        else:
            if retrievalType == RetrievalType.BOOLEAN:
                return self.__inverted_index.search(query, self.__dictionary)
            elif retrievalType == RetrievalType.POSITIONAL:
                return self.__positional_index.positionalSearch(query, self.__dictionary)
            else:
                return self.__positional_index.rankedSearch(query,
                                                            self.__dictionary,
                                                            self.__documents,
                                                            termWeighting,
                                                            documentWeighting)
