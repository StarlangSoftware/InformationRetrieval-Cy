from collections import OrderedDict
from functools import cmp_to_key

from InformationRetrieval.Index.PostingList cimport PostingList
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence

cdef class InvertedIndex:

    cpdef constructor1(self, str fileName):
        """
        Reads the inverted index from an input file.
        :param fileName: Input file name for the inverted index.
        """
        self.readPostingList(fileName)

    cpdef constructor2(self, dictionaryOrfileName: object, terms: [TermOccurrence]):
        """
        Constructs an inverted index from a list of sorted tokens. The terms array should be sorted before calling this
        method. Multiple occurrences of the same term from the same document are merged in the index. Instances of the
        same term are then grouped, and the result is split into a postings list.
        :param dictionary: Term dictionary
        :param terms: Sorted list of tokens in the memory collection.
        """
        cdef TermDictionary dictionary
        cdef int i, term_id, prev_doc_id
        cdef TermOccurrence term, previous_term
        dictionary = dictionaryOrfileName
        if len(terms) > 0:
            term = terms[0]
            i = 1
            previous_term = term
            term_id = dictionary.getWordIndex(term.getTerm().getName())
            self.add(term_id, term.getDocId())
            prev_doc_id = term.getDocId()
            while i < len(terms):
                term = terms[i]
                term_id = dictionary.getWordIndex(term.getTerm().getName())
                if term_id != -1:
                    if term.isDifferent(previous_term):
                        self.add(term_id, term.getDocId())
                        prev_doc_id = term.getDocId()
                    else:
                        if prev_doc_id != term.getDocId():
                            self.add(term_id, term.getDocId())
                            prev_doc_id = term.getDocId()
                i = i + 1
                previous_term = term

    def __init__(self,
                 dictionaryOrfileName: object = None,
                 terms: [TermOccurrence] = None):
        self.__index = OrderedDict()
        if dictionaryOrfileName is not None:
            if isinstance(dictionaryOrfileName, TermDictionary):
                self.constructor2(dictionaryOrfileName, terms)
            elif isinstance(dictionaryOrfileName, str):
                self.constructor1(dictionaryOrfileName)

    cpdef readPostingList(self, str fileName):
        """
        Reads the postings list of the inverted index from an input file. The postings are stored in two lines. The first
        line contains the term id and the number of postings for that term. The second line contains the postings
        list for that term.
        :param fileName: Inverted index file.
        """
        cdef str line
        cdef list items
        cdef int word_id
        input_file = open(fileName + "-postings.txt", mode="r", encoding="utf-8")
        line = input_file.readline().strip()
        while line != "":
            items = line.split(" ")
            word_id = int(items[0])
            line = input_file.readline().strip()
            self.__index[word_id] = PostingList(line)
            line = input_file.readline()
        input_file.close()

    cpdef saveSorted(self, str fileName):
        """
        Save inverted index sorted w.r.t. index to the given output file.
        :param fileName:  Output file name.
        """
        cdef list items
        cdef int key
        items = []
        for key in self.__index.keys():
            items.append([key, self.__index[key]])
        items.sort()
        output_file = open(fileName + "-postings.txt", mode="w", encoding="utf-8")
        for item in items:
            item[1].writeToFile(output_file, item[0])
        output_file.close()

    cpdef save(self, str fileName):
        """
        Saves the inverted index into the index file. The postings are stored in two lines. The first
        line contains the term id and the number of postings for that term. The second line contains the postings
        list for that term.
        :param fileName: Index file name. Real index file name is created by attaching -postings.txt to this
                         file name
        """
        cdef int key
        output_file = open(fileName + "-postings.txt", mode="w", encoding="utf-8")
        for key in self.__index.keys():
            self.__index[key].writeToFile(output_file, key)
        output_file.close()

    cpdef add(self,
              int termId,
              int docId):
        """
        Adds a possible new term with a document id to the inverted index. First the term is searched in the hash map,
        then the document id is put into the correct postings list.
        :param termId: Id of the term
        :param docId: Document id in which the term exists
        """
        cdef PostingList posting_list
        if termId in self.__index:
            posting_list = self.__index[termId]
        else:
            posting_list = PostingList()
        posting_list.add(docId)
        self.__index[termId] = posting_list

    cpdef autoCompleteWord(self,
                         list wordList,
                         TermDictionary dictionary):
        """
        Constructs a sorted array list of frequency counts for a word list and also sorts the word list according to
        those frequencies.
        :param wordList: Word list for which frequency array is constructed.
        :param dictionary: Term dictionary
        """
        cdef list counts
        cdef str word
        cdef int i, j
        counts = []
        for word in wordList:
            counts.append(self.__index[dictionary.getWordIndex(word)].size())
        for i in range(len(wordList) - 1):
            for j in range(i + 1, len(wordList)):
                if counts[i] < counts[j]:
                    counts[i], counts[j] = counts[j], counts[i]
                    wordList[i], wordList[j] = wordList[j], wordList[i]

    cpdef QueryResult search(self,
                             Query query,
                             TermDictionary dictionary):
        """
        Searches a given query in the document collection using inverted index boolean search.
        :param query: Query string
        :param dictionary: Term dictionary
        :return: The result of the query obtained by doing inverted index boolean search in the collection.
        """
        cdef list query_terms
        cdef int i, term_index
        cdef PostingList result
        query_terms = []
        for i in range(query.size()):
            term_index = dictionary.getWordIndex(query.getTerm(i).getName())
            if term_index != -1:
                query_terms.append(self.__index[term_index])
            else:
                return QueryResult()
        query_terms.sort(key=cmp_to_key(PostingList.postingListComparator))
        result = query_terms[0]
        for i in range(1, len(query_terms)):
            result = result.intersection(query_terms[i])
        return result.toQueryResult()
