from InformationRetrieval.Document.DocumentWeighting import DocumentWeighting
from InformationRetrieval.Index.TermWeighting import TermWeighting
from InformationRetrieval.Query.RetrievalType import RetrievalType

cdef class SearchParameter:

    def __init__(self):
        self.__retrieval_type = RetrievalType.RANKED
        self.__document_weighting = DocumentWeighting.NO_IDF
        self.__term_weighting = TermWeighting.NATURAL
        self.__documents_retrieved = 1

    cpdef object getRetrievalType(self):
        return self.__retrieval_type

    cpdef object getDocumentWeighting(self):
        return self.__document_weighting

    cpdef object getTermWeighting(self):
        return self.__term_weighting

    cpdef int getDocumentsRetrieved(self):
        return self.__documents_retrieved

    cpdef setRetrievalType(self, object retrievalType):
        self.__retrieval_type = retrievalType

    cpdef setDocumentWeighting(self, object documentWeighting):
        self.__document_weighting = documentWeighting

    cpdef setTermWeighting(self, object termWeighting):
        self.__term_weighting = termWeighting

    cpdef setDocumentsRetrieved(self, int documentsRetrieved):
        self.__documents_retrieved = documentsRetrieved
