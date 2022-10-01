cdef class PositionalPosting(Posting):

    def __init__(self, docId: int):
        self.__positions = []
        self.__doc_id = docId

    cpdef add(self, int position):
        self.__positions.append(Posting(position))

    cpdef int getDocId(self):
        return self.__doc_id

    cpdef list getPositions(self):
        return self.__positions

    cpdef int size(self):
        return len(self.__positions)

    def __str__(self) -> str:
        cdef str result
        cdef Posting posting
        result = self.__doc_id.__str__() + " " + len(self.__positions).__str__()
        for posting in self.__positions:
            result = result + " " + posting.getId().__str__()
        return result
