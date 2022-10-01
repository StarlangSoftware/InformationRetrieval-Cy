from collections import OrderedDict
from functools import cmp_to_key

from InformationRetrieval.Index.PostingList cimport PostingList
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence

cdef class InvertedIndex:

    def __init__(self,
                 dictionaryOrfileName: object = None,
                 terms: [TermOccurrence] = None):
        cdef TermDictionary dictionary
        cdef int i, term_id, prev_doc_id
        cdef TermOccurrence term, previous_term
        self.__index = OrderedDict()
        if dictionaryOrfileName is not None:
            if isinstance(dictionaryOrfileName, TermDictionary):
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
            elif isinstance(dictionaryOrfileName, str):
                self.readPostingList(dictionaryOrfileName)

    cpdef readPostingList(self, str fileName):
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
        cdef int key
        output_file = open(fileName + "-postings.txt", mode="w", encoding="utf-8")
        for key in self.__index.keys():
            self.__index[key].writeToFile(output_file, key)
        output_file.close()

    cpdef add(self,
              int termId,
              int docId):
        cdef PostingList posting_list
        if termId in self.__index:
            posting_list = self.__index[termId]
        else:
            posting_list = PostingList()
        posting_list.add(docId)
        self.__index[termId] = posting_list

    cpdef QueryResult search(self,
                             Query query,
                             TermDictionary dictionary):
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
