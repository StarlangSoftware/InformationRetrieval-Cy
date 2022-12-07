from InformationRetrieval.Index.CategoryNode cimport CategoryNode
from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Query.Query cimport Query

cdef class CategoryTree:

    cdef CategoryNode __root

    cpdef CategoryNode addCategoryHierarchy(self, str hierarchy)
    cpdef list getCategories(self,
                      Query query,
                      TermDictionary dictionary,
                      object categoryDeterminationType)
    cpdef setRepresentativeCount(self, int representativeCount)
