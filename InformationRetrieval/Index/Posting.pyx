cdef class Posting:

    def __init__(self, Id: int):
        self.__id = Id

    cpdef int getId(self):
        return self.__id
