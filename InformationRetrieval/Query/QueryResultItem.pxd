cdef class QueryResultItem:

    cdef int __doc_id
    cdef float __score

    cpdef int getDocId(self)
    cpdef float getScore(self)
