from Dictionary.Word cimport Word

cdef class Term(Word):

    def __init__(self, name: str, termId: int):
        """
        Constructor for the Term class. Sets the fields.
        :param name: Text of the term
        :param termId: Id of the term
        """
        super().__init__(name)
        self.__term_id = termId

    cpdef int getTermId(self):
        """
        Accessor for the term id attribute.
        :return: Term id attribute
        """
        return self.__term_id
