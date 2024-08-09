from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Query.Query cimport Query
from InformationRetrieval.Query.QueryResult cimport QueryResult
from InformationRetrieval.Query.SearchParameter cimport SearchParameter

cdef class PositionalIndex:

    cdef object __positional_index

    cpdef constructor1(self, str fileName)
    cpdef constructor2(self, dictionaryOrfileName: object, terms: [TermOccurrence])
    cpdef readPositionalPostingList(self, str fileName)
    cpdef saveSorted(self, str fileName)
    cpdef save(self, str fileName)
    cpdef addPosition(self, int termId, int docId, int position)
    cpdef QueryResult positionalSearch(self, Query query, TermDictionary dictionary)
    cpdef list getTermFrequencies(self, int docId)
    cpdef list getDocumentFrequencies(self)
    cpdef setDocumentSizes(self, list documents)
    cpdef setCategoryCounts(self, list documents)
    cpdef QueryResult rankedSearch(self,
                     Query query,
                     TermDictionary dictionary,
                     list documents,
                     SearchParameter parameter)
