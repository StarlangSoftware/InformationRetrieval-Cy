from typing import Optional

from DataStructure.CounterHashMap cimport CounterHashMap

from InformationRetrieval.Index.Term cimport Term
from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Query.Query import Query

cdef class CategoryNode:

    def __init__(self, name: str, parent: Optional[CategoryNode]):
        """
        Constructor for the category node. Each category is represented as a tree node in the category tree. Category
        words are constructed by splitting the name of the category w.r.t. space. Sets the parent node and adds this
        node as a child to parent node.
        :param name: Name of the category.
        :param parent: Parent node of this node.
        """
        self.__category_words = name.split()
        self.__parent = parent
        self.__counts = CounterHashMap()
        self.__children = []
        if parent is not None:
            parent.addChild(self)

    cpdef addChild(self, CategoryNode child):
        """
        Adds the given child node to this node.
        :param child: New child node
        """
        self.__children.append(child)

    cpdef getName(self):
        """
        Constructs the category name from the category words. Basically combines all category words separated with space.
        :param child:Category name.
        :return:
        """
        cdef int i
        cdef str result
        result = self.__category_words[0]
        for i in range(1, len(self.__category_words)):
            result += " " + self.__category_words[i]
        return result

    cpdef CategoryNode getChild(self, str childName):
        """
        Searches the children of this node for a specific category name.
        :param childName: Category name of the child.
        """
        for child in self.__children:
            if child.getName() == childName:
                return child
        return None

    cpdef addCounts(self, int termId, int count):
        """
        Adds frequency count of the term to the counts hash map of all ascendants of this node.
        :param termId: ID of the occurring term.
        :param count: Frequency of the term.
        """
        cdef CategoryNode current
        current = self
        while current.__parent is not None:
            current.__counts.putNTimes(termId, count)
            current = current.__parent

    cpdef bint isDescendant(self, CategoryNode ancestor):
        """
        Checks if the given node is an ancestor of the current node.
        :param ancestor: Node for which ancestor check will be done
        :return: True, if the given node is an ancestor of the current node.
        """
        if self == ancestor:
            return True
        if self.__parent is None:
            return False
        return self.__parent.isDescendant(ancestor)

    cpdef list getChildren(self):
        """
        Accessor of the children attribute
        :return: Children of the node
        """
        return self.__children

    def __str__(self) -> str:
        """
        Recursive method that returns the hierarchy string of the node. Hierarchy string is obtained by concatenating the
        names of all ancestor nodes separated with '%'.
        :return: Hierarchy string of this node
        """
        if self.__parent is not None:
            if self.__parent.__parent is not None:
                return self.__parent.__str__() + "%" + self.getName()
            else:
                return self.getName()
        return ""

    cpdef setRepresentativeCount(self, int representativeCount):
        """
        Recursive method that sets the representative count. The representative count filters the most N frequent words.
        :param representativeCount: Number of representatives.
        """
        cdef list top_list
        if representativeCount <= len(self.__counts):
            top_list = self.__counts.topN(representativeCount)
            self.__counts = CounterHashMap()
            for item in top_list:
                self.__counts.putNTimes(item[0], item[1])

    cpdef getCategoriesWithKeyword(self,
                                 Query query,
                                 list result):
        """
        Recursive method that checks the query words in the category words of all descendants of this node and
        accumulates the nodes that satisfies the condition. If any word  in the query appears in any category word, the
        node will be accumulated.
        :param query: Query string
        :param result: Accumulator array
        """
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
        """
        Recursive method that checks the query words in the category words of all descendants of this node and
        accumulates the nodes that satisfies the condition. If any word  in the query appears in any category word, the
        node will be accumulated.
        :param query: Query string
        :param dictionary: Term dictionary
        :param result: Accumulator array
        """
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
