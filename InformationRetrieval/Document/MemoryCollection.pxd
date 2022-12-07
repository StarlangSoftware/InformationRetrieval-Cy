from InformationRetrieval.Document.AbstractCollection cimport AbstractCollection
from InformationRetrieval.Query.Query cimport Query
from InformationRetrieval.Query.QueryResult cimport QueryResult
from InformationRetrieval.Query.SearchParameter cimport SearchParameter

cdef class MemoryCollection(AbstractCollection):

    cdef object __index_type

    cpdef loadIndexesFromFile(self, str directory)
    cpdef save(self)
    cpdef saveCategories(self)
    cpdef constructIndexesInMemory(self)
    cpdef list constructTerms(self, object termType)
    cpdef QueryResult attributeSearch(self, Query query)
    cpdef QueryResult searchWithInvertedIndex(self,
                                Query query,
                                SearchParameter searchParameter)
    cpdef filterAccordingToCategories(self,
                                    QueryResult currentResult,
                                    list categories)
    cpdef searchCollection(self, Query query, SearchParameter searchParameter)
