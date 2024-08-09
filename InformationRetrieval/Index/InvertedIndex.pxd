from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Query.Query cimport Query
from InformationRetrieval.Query.QueryResult cimport QueryResult

cdef class InvertedIndex:

    cdef object __index

    cpdef constructor1(self, str fileName)
    cpdef constructor2(self, dictionaryOrfileName: object, terms: [TermOccurrence])
    cpdef readPostingList(self, str fileName)
    cpdef readPostingList(self, str fileName)
    cpdef saveSorted(self, str fileName)
    cpdef save(self, str fileName)
    cpdef add(self, int termId, int docId)
    cpdef autoCompleteWord(self, list wordList, TermDictionary dictionary)
    cpdef QueryResult search(self, Query query, TermDictionary dictionary)
