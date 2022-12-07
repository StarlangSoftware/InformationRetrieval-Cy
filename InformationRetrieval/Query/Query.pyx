from Dictionary.Word cimport Word

cdef class Query:

    def __init__(self, query: str = None):
        self.__terms = []
        if query is not None:
            terms = query.split(" ")
            for term in terms:
                self.__terms.append(Word(term))

    cpdef Word getTerm(self, int index):
        return self.__terms[index]

    cpdef int size(self):
        return len(self.__terms)

    cpdef filterAttributes(self,
                         set attributeList,
                         Query termAttributes,
                         Query phraseAttributes):
        cdef int i
        cdef str pair
        i = 0
        while i < self.size():
            if i < self.size() - 1:
                pair = self.__terms[i].getName() + " " + self.__terms[i + 1].getName()
                if pair in attributeList:
                    phraseAttributes.__terms.append(Word(pair))
                    i = i + 2
                    continue
            if self.__terms[i].getName() in attributeList:
                termAttributes.__terms.append(self.__terms[i])
            i = i + 1
