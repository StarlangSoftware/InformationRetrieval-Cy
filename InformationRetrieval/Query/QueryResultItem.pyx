cdef class QueryResultItem:

    def __init__(self, docId: int, score: float):
        self.__doc_id = docId
        self.__score = score

    cpdef int getDocId(self):
        return self.__doc_id

    cpdef float getScore(self):
        return self.__score
