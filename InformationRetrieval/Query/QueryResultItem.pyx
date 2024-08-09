cdef class QueryResultItem:

    def __init__(self, docId: int, score: float):
        """
        Constructor for the QueryResultItem class. Sets the document id and score of a single query result.
        :param docId: Id of the document that satisfies the query.
        :param score: Score of the document for the query.
        """
        self.__doc_id = docId
        self.__score = score

    cpdef int getDocId(self):
        """
        Accessor for the docID attribute.
        :return: docID attribute
        """
        return self.__doc_id

    cpdef float getScore(self):
        """
        Accessor for the score attribute.
        :return: score attribute.
        """
        return self.__score

    def __repr__(self):
        return f"{self.__doc_id} {self.__score}"
