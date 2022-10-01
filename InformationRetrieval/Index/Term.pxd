from Dictionary.Word cimport Word

cdef class Term(Word):

    cdef int __term_id

    cpdef int getTermId(self)
