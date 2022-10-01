from Dictionary.Word cimport Word

cdef class Query:

    def __init__(self, query: str):
        self.__terms = []
        terms = query.split(" ")
        for term in terms:
            self.__terms.append(Word(term))

    cpdef Word getTerm(self, int index):
        return self.__terms[index]

    cpdef int size(self):
        return len(self.__terms)
