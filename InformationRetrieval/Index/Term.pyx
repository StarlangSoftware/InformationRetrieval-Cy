from Dictionary.Word cimport Word

cdef class Term(Word):

    def __init__(self, name: str, termId: int):
        super().__init__(name)
        self.__term_id = termId

    cpdef int getTermId(self):
        return self.__term_id
