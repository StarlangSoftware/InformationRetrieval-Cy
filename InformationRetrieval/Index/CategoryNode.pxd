from DataStructure.CounterHashMap cimport CounterHashMap

from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Query.Query cimport Query

cdef class CategoryNode:

    cdef list __children
    cdef CategoryNode __parent
    cdef CounterHashMap __counts
    cdef list __category_words

    cpdef addChild(self, CategoryNode child)
    cpdef getName(self)
    cpdef CategoryNode getChild(self, str childName)
    cpdef addCounts(self, int termId, int count)
    cpdef bint isDescendant(self, CategoryNode ancestor)
    cpdef list getChildren(self)
    cpdef setRepresentativeCount(self, int representativeCount)
    cpdef getCategoriesWithKeyword(self,
                                 Query query,
                                 list result)
    cpdef getCategoriesWithCosine(self,
                                Query query,
                                TermDictionary dictionary,
                                list result)
