cdef class Posting:

    def __init__(self, Id: int):
        """
        Constructor for the Posting class. Sets the document id attribute.
        :param Id: Document id.
        """
        self.__id = Id

    cpdef int getId(self):
        """
        Accessor for the document id attribute.
        :return: Document id.
        """
        return self.__id
