from InformationRetrieval.Index.Posting cimport Posting

cdef class PositionalPosting(Posting):

    cdef list __positions
    cdef int __doc_id

    cpdef add(self, int position)
    cpdef int getDocId(self)
    cpdef list getPositions(self)
    cpdef int size(self)
