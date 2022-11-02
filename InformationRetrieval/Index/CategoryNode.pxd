from DataStructure.CounterHashMap cimport CounterHashMap

from InformationRetrieval.Index.TermDictionary cimport TermDictionary

cdef class CategoryNode:

    cdef str __name
    cdef list __children
    cdef CategoryNode __parent
    cdef CounterHashMap __counts

    cpdef addChild(self, CategoryNode child)
    cpdef getName(self)
    cpdef CategoryNode getChild(self, str childName)
    cpdef addCounts(self, int termId, int count)
    cpdef list getChildren(self)
    cpdef list topN(self, int N)
    cpdef str topNString(self, TermDictionary dictionary, int N)