cdef class SearchParameter:

    cdef object __retrieval_type
    cdef object __document_weighting
    cdef object __term_weighting
    cdef int __documents_retrieved

    cpdef object getRetrievalType(self)
    cpdef object getDocumentWeighting(self)
    cpdef object getTermWeighting(self)
    cpdef int getDocumentsRetrieved(self)
    cpdef setRetrievalType(self, object retrievalType)
    cpdef setDocumentWeighting(self, object documentWeighting)
    cpdef setTermWeighting(self, object termWeighting)
    cpdef setDocumentsRetrieved(self, int documentsRetrieved)
