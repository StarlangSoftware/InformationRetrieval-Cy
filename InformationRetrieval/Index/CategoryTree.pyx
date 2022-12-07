from InformationRetrieval.Query.CategoryDeterminationType import CategoryDeterminationType
from InformationRetrieval.Query.Query cimport Query

cdef class CategoryTree:

    def __init__(self, rootName: str):
        self.__root = CategoryNode(rootName, None)

    cpdef CategoryNode addCategoryHierarchy(self, str hierarchy):
        cdef list categories
        cdef CategoryNode current, node
        categories = hierarchy.split("%")
        current = self.__root
        for category in categories:
            node = current.getChild(category)
            if node is None:
                node = CategoryNode(category, current)
            current = node
        return current

    cpdef list getCategories(self,
                      Query query,
                      TermDictionary dictionary,
                      object categoryDeterminationType):
        cdef list result
        result = []
        if categoryDeterminationType == CategoryDeterminationType.KEYWORD:
            self.__root.getCategoriesWithKeyword(query, result)
        elif categoryDeterminationType == CategoryDeterminationType.COSINE:
            self.__root.getCategoriesWithCosine(query, dictionary, result)
        return result

    cpdef setRepresentativeCount(self, int representativeCount):
        self.__root.setRepresentativeCount(representativeCount)

    def __repr__(self):
        return self.__root.__repr__()
