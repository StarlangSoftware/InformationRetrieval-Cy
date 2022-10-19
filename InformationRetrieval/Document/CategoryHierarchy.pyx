cdef class CategoryHierarchy:

    def __init__(self, list: str):
        self.__category_list = list.split("%")

    def __str__(self):
        result = self.__category_list[0]
        for i in range(1, len(self.__category_list)):
            result = result + "%" + self.__category_list[i]
        return result
