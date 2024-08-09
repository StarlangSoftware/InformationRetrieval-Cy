cdef class PositionalPosting(Posting):

    def __init__(self, docId: int):
        """
        Constructor for the PositionalPosting class. Sets the document id and initializes the position array.
        :param docId: document id of the posting.
        """
        self.__positions = []
        self.__doc_id = docId

    cpdef add(self, int position):
        """
        Adds a position to the position list.
        :param position: Position added to the position list.
        """
        self.__positions.append(Posting(position))

    cpdef int getDocId(self):
        """
        Accessor for the document id attribute.
        :return: Document id.
        """
        return self.__doc_id

    cpdef list getPositions(self):
        """
        Accessor for the positions attribute.
        :return: Position list.
        """
        return self.__positions

    cpdef int size(self):
        """
        Returns size of the position list.
        :return: Size of the position list.
        """
        return len(self.__positions)

    def __str__(self) -> str:
        """
        Converts the positional posting to a string. String is of the form, document id, number of positions, and all
        positions separated via space.
        :return: String form of the positional posting.
        """
        cdef str result
        cdef Posting posting
        result = self.__doc_id.__str__() + " " + len(self.__positions).__str__()
        for posting in self.__positions:
            result = result + " " + posting.getId().__str__()
        return result
