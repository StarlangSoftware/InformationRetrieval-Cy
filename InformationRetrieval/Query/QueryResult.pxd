cdef class QueryResult:

    cdef list __items

    cpdef add(self, int docId, float score = *)
    cpdef list getItems(self)
    cpdef int size(self)
    cpdef QueryResult intersectionFastSearch(self, QueryResult queryResult)
    cpdef QueryResult intersectionBinarySearch(self, QueryResult queryResult)
    cpdef QueryResult intersectionLinearSearch(self, QueryResult queryResult)
