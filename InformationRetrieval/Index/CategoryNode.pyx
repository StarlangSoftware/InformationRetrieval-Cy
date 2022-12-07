from DataStructure.CounterHashMap cimport CounterHashMap

from InformationRetrieval.Index.Term cimport Term
from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Query.Query import Query

cdef class CategoryNode:

    def __init__(self, name: str, parent: CategoryNode):
        self.__category_words = name.split()
        self.__parent = parent
        self.__counts = CounterHashMap()
        self.__children = []
        if parent is not None:
            parent.addChild(self)

    cpdef addChild(self, CategoryNode child):
        self.__children.append(child)

    cpdef getName(self):
        cdef int i
        cdef str result
        result = self.__category_words[0]
        for i in range(1, len(self.__category_words)):
            result += " " + self.__category_words[i]
        return result

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

    cpdef bint isDescendant(self, CategoryNode ancestor):
        if self == ancestor:
            return True
        if self.__parent is None:
            return False
        return self.__parent.isDescendant(ancestor)

    cpdef list getChildren(self):
        return self.__children

    def __str__(self) -> str:
        if self.__parent is not None:
            if self.__parent.__parent is not None:
                return self.__parent.__str__() + "%" + self.getName()
            else:
                return self.getName()
        return ""

    cpdef setRepresentativeCount(self, int representativeCount):
        cdef list top_list
        if representativeCount <= len(self.__counts):
            top_list = self.__counts.topN(representativeCount)
            self.__counts = CounterHashMap()
            for item in top_list:
                self.__counts.putNTimes(item[0], item[1])

    cpdef getCategoriesWithKeyword(self,
                                 Query query,
                                 list result):
        cdef double category_score
        cdef int i
        cdef CategoryNode child
        category_score = 0
        for i in range(query.size()):
            if query.getTerm(i).getName() in self.__category_words:
                category_score = category_score + 1
        if category_score > 0:
            result.append(self)
        for child in self.__children:
            child.getCategoriesWithKeyword(query, result)

    cpdef getCategoriesWithCosine(self,
                                Query query,
                                TermDictionary dictionary,
                                list result):
        cdef double category_score
        cdef int i
        cdef CategoryNode child
        cdef Term term
        category_score = 0
        for i in range(query.size()):
            term = dictionary.getWord(query.getTerm(i).getName())
            if term is not None and isinstance(term, Term):
                category_score = category_score + self.__counts.count(term.getTermId())
        if category_score > 0:
            result.append(self)
        for child in self.__children:
            child.getCategoriesWithCosine(query, dictionary, result)

    def __repr__(self):
        return self.getName() + "(" + self.__children.__repr__() + ")"
