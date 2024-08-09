cdef class PostingSkip(Posting):

    def __init__(self, Id: int):
        """
        Constructor for the PostingSkip class. Sets the document id.
        :param Id: Document id.
        """
        super().__init__(Id)
        self.__skip_available = False
        self.__skip = None
        self.__next = None

    cpdef bint hasSkip(self):
        """
        Checks if this posting has a skip pointer or not.
        :return: True, if this posting has a skip pointer, false otherwise.
        """
        return self.__skip_available

    cpdef addSkip(self, PostingSkip skip):
        """
        Adds a skip pointer to the next skip posting.
        :param skip: Next posting to jump.
        """
        self.__skip_available = True
        self.__skip = skip

    cpdef setNext(self, PostingSkip _next):
        """
        Updated the skip pointer.
        :param _next: New skip pointer
        """
        self.__next = _next

    cpdef PostingSkip next(self):
        """
        Accessor for the skip pointer.
        :return: Next posting to skip.
        """
        return self.__next

    cpdef PostingSkip getSkip(self):
        """
        Accessor for the skip.
        :return: Skip
        """
        return self.__skip
