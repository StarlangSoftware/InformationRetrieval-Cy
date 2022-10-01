from Dictionary.Word cimport Word

cdef class Query:

    cdef list __terms

    cpdef Word getTerm(self, int index)
    cpdef int size(self)
