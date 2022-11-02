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

    cpdef str topNString(self, TermDictionary dictionary, int N):
        cdef list queue
        cdef str result
        cdef CategoryNode node
        queue = [self.__root]
        result = ""
        while len(queue) > 0:
            node = queue.pop(0)
            if node != self.__root:
                result = result + node.topNString(dictionary, N) + "\n"
            queue.extend(node.getChildren())
        return result

    def __repr__(self):
        return self.__root.__repr__()
