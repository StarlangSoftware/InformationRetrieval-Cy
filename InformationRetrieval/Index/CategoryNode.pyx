from DataStructure.CounterHashMap cimport CounterHashMap
from Dictionary.Word cimport Word

cdef class CategoryNode:

    def __init__(self, name: str, parent: CategoryNode):
        self.__name = name
        self.__parent = parent
        self.__counts = CounterHashMap()
        self.__children = []
        if parent is not None:
            parent.addChild(self)

    cpdef addChild(self, CategoryNode child):
        self.__children.append(child)

    cpdef getName(self):
        return self.__name

    cpdef CategoryNode getChild(self, str childName):
        for child in self.__children:
            if child.getName() == childName:
                return child
        return None

    cpdef addCounts(self, int termId, int count):
        cdef CategoryNode current
        current = self
        while current.__parent is not None:
            current.__counts.putNTimes(termId, count)
            current = current.__parent

    cpdef list getChildren(self):
        return self.__children

    cpdef list topN(self, int N):
        if N <= len(self.__counts):
            return self.__counts.topN(N)
        else:
            return self.__counts.topN(len(self.__counts))

    cpdef str topNString(self, TermDictionary dictionary, int N):
        cdef list top_n
        cdef str result
        top_n = self.topN(N)
        result = self.__str__()
        for item in top_n:
            if not Word.isPunctuationSymbol(dictionary.getWordWithIndex(item[1]).getName()):
                result = result + "\t" + dictionary.getWordWithIndex(item[1]).getName() + " (" + item[0].__str__() + ")"
        return result

    def __str__(self) -> str:
        if self.__parent is not None:
            if self.__parent.__parent is not None:
                return self.__parent.__str__() + "%" + self.__name
            else:
                return self.__name
        return ""

    def __repr__(self):
        return self.__name + "(" + self.__children.__repr__() + ")"
