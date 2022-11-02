from InformationRetrieval.Index.CategoryNode cimport CategoryNode
from InformationRetrieval.Index.TermDictionary cimport TermDictionary

cdef class CategoryTree:

    cdef CategoryNode __root

    cpdef CategoryNode addCategoryHierarchy(self, str hierarchy)
    cpdef str topNString(self, TermDictionary dictionary, int N)
