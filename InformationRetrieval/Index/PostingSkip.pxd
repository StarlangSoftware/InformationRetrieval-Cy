from InformationRetrieval.Index.Posting cimport Posting

cdef class PostingSkip(Posting):

    cdef bint __skip_available
    cdef PostingSkip __skip
    cdef PostingSkip __next

    cpdef bint hasSkip(self)
    cpdef addSkip(self, PostingSkip skip)
    cpdef setNext(self, PostingSkip _next)
    cpdef PostingSkip next(self)
    cpdef PostingSkip getSkip(self)
