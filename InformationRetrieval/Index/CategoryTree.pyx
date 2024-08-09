from InformationRetrieval.Query.CategoryDeterminationType import CategoryDeterminationType
from InformationRetrieval.Query.Query cimport Query

cdef class CategoryTree:

    def __init__(self, rootName: str):
        """
        Simple constructor of the tree. Sets the root node of the tree.
        :param rootName: Category name of the root node.
        """
        self.__root = CategoryNode(rootName, None)

    cpdef CategoryNode addCategoryHierarchy(self, str hierarchy):
        """
        Adds a path (and if required nodes in the path) to the category tree according to the hierarchy string. Hierarchy
        string is obtained by concatenating the names of all nodes in the path from root node to a leaf node separated
        with '%'.
        :param hierarchy: Hierarchy string
        :return: The leaf node added when the hierarchy string is processed.
        """
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
        """
        The method checks the query words in the category words of all nodes in the tree and returns the nodes that
        satisfies the condition. If any word in the query appears in any category word, the node will be returned.
        :param query: Query string
        :param dictionary: Term dictionary
        :param categoryDeterminationType: Category determination type
        :return: The category nodes whose names contain at least one word from the query string
        """
        cdef list result
        result = []
        if categoryDeterminationType == CategoryDeterminationType.KEYWORD:
            self.__root.getCategoriesWithKeyword(query, result)
        elif categoryDeterminationType == CategoryDeterminationType.COSINE:
            self.__root.getCategoriesWithCosine(query, dictionary, result)
        return result

    cpdef setRepresentativeCount(self, int representativeCount):
        """
        The method sets the representative count. The representative count filters the most N frequent words.
        :param representativeCount: Number of representatives.
        """
        self.__root.setRepresentativeCount(representativeCount)

    def __repr__(self):
        return self.__root.__repr__()
