from Dictionary.Word cimport Word

cdef class TermOccurrence:

    cdef Word __term
    cdef int __doc_id
    cdef int __position

    cpdef Word getTerm(self)
    cpdef int getDocId(self)
    cpdef int getPosition(self)
    cpdef bint isDifferent(self, TermOccurrence currentTerm)
