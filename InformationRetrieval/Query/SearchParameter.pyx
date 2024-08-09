from InformationRetrieval.Document.DocumentWeighting import DocumentWeighting
from InformationRetrieval.Index.TermWeighting import TermWeighting
from InformationRetrieval.Query.CategoryDeterminationType import CategoryDeterminationType
from InformationRetrieval.Query.FocusType import FocusType
from InformationRetrieval.Query.RetrievalType import RetrievalType

cdef class SearchParameter:

    def __init__(self):
        """
        Empty constructor for SearchParameter object.
        """
        self.__retrieval_type = RetrievalType.RANKED
        self.__document_weighting = DocumentWeighting.NO_IDF
        self.__term_weighting = TermWeighting.NATURAL
        self.__documents_retrieved = 1
        self.__category_determination_type = CategoryDeterminationType.KEYWORD
        self.__focus_type = FocusType.OVERALL
        self.__search_attributes = False

    cpdef object getRetrievalType(self):
        """
        Accessor for the retrieval type.
        :return: Retrieval type.
        """
        return self.__retrieval_type

    cpdef object getDocumentWeighting(self):
        """
        Accessor for the document weighting scheme in tf-idf search
        :return: Document weighting scheme in tf-idf search
        """
        return self.__document_weighting

    cpdef object getTermWeighting(self):
        """
        Accessor for the term weighting scheme in tf-idf search
        :return: Term weighting scheme in tf-idf search
        """
        return self.__term_weighting

    cpdef int getDocumentsRetrieved(self):
        """
        Accessor for the maximum number of documents retrieved.
        :return: Maximum number of documents retrieved
        """
        return self.__documents_retrieved

    cpdef object getCategoryDeterminationType(self):
        """
        Accessor for the category determination type
        :return: Category determination type
        """
        return self.__category_determination_type

    cpdef object getFocusType(self):
        """
        Accessor for the focus type.
        :return: Focus type
        """
        return self.__focus_type

    cpdef object getSearchAttributes(self):
        """
        Accessor for the search attributes field. The parameter will determine if an attribute search is performed.
        :return: Search attribute
        """
        return self.__search_attributes

    cpdef setRetrievalType(self, object retrievalType):
        """
        Setter for the retrievalType.
        :param retrievalType: New retrieval type
        """
        self.__retrieval_type = retrievalType

    cpdef setDocumentWeighting(self, object documentWeighting):
        """
        Mutator for the documentWeighting scheme used in tf-idf search.
        :param documentWeighting: New document weighting scheme for tf-idf search.
        :return:
        """
        self.__document_weighting = documentWeighting

    cpdef setTermWeighting(self, object termWeighting):
        """
        Mutator for the termWeighting scheme used in tf-idf search.
        :param termWeighting: New term weighting scheme for tf-idf search.
        """
        self.__term_weighting = termWeighting

    cpdef setDocumentsRetrieved(self, int documentsRetrieved):
        """
        Mutator for the maximum number of documents retrieved.
        :param documentsRetrieved: New value for the maximum number of documents retrieved.
        """
        self.__documents_retrieved = documentsRetrieved

    cpdef setCategoryDeterminationType(self, object categoryDeterminationType):
        """
        Mutator for the category determination type.
        :param categoryDeterminationType: New category determination type
        """
        self.__category_determination_type = categoryDeterminationType

    cpdef setFocusType(self, object focusType):
        """
        Mutator for the focus type.
        :param focusType: New focus type
        """
        self.__focus_type = focusType

    cpdef setSearchAttributes(self, object searchAttributes):
        """
        Mutator for the search attributes field. The parameter will determine if an attribute search is performed.
        :param searchAttributes: New search attribute
        """
        self.__search_attributes = searchAttributes
