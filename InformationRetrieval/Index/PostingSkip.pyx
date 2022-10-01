cdef class PostingSkip(Posting):

    def __init__(self, Id: int):
        super().__init__(Id)
        self.__skip_available = False
        self.__skip = None
        self.__next = None

    cpdef bint hasSkip(self):
        return self.__skip_available

    cpdef addSkip(self, PostingSkip skip):
        self.__skip_available = True
        self.__skip = skip

    cpdef setNext(self, PostingSkip _next):
        self.__next = _next

    cpdef PostingSkip next(self):
        return self.__next

    cpdef PostingSkip getSkip(self):
        return self.__skip
