import re

from Dictionary.Word cimport Word

cdef class Query:

    __shortcuts: list = ["cc", "cm2", "cm", "gb", "ghz", "gr", "gram", "hz", "inc", "inch", "inç", "kg", "kw", "kva",
                         "litre", "lt", "m2", "m3", "mah", "mb", "metre", "mg", "mhz", "ml", "mm", "mp", "ms",
                         "mt", "mv", "tb", "tl", "va", "volt", "watt", "ah", "hp", "oz", "rpm", "dpi", "ppm", "ohm",
                         "kwh", "kcal", "kbit", "mbit", "gbit", "bit", "byte", "mbps", "gbps", "cm3", "mm2", "mm3",
                         "khz", "ft", "db", "sn", "g", "v", "m", "l", "w", "s"]

    def __init__(self, query: str = None):
        """
        Another constructor of the Query class. Splits the query into multiple words and put them into the terms array.
        :param query: Query string
        """
        self.__terms = []
        if query is not None:
            terms = query.split(" ")
            for term in terms:
                self.__terms.append(Word(term))

    cpdef Word getTerm(self, int index):
        """
        Accessor for the terms array. Returns the term at position index.
        :param index: Position of the term in the terms array.
        :return: The term at position index.
        """
        return self.__terms[index]

    cpdef int size(self):
        """
        Returns the size of the query, i.e. number of words in the query.
        :return: Size of the query, i.e. number of words in the query.
        """
        return len(self.__terms)

    cpdef Query filterAttributes(self,
                         set attributeList,
                         Query termAttributes,
                         Query phraseAttributes):
        """
        Filters the original query by removing phrase attributes, shortcuts and single word attributes.
        :param attributeList: Hash set containing all attributes (phrase and single word)
        :param termAttributes: New query that will accumulate single word attributes from the original query.
        :param phraseAttributes: New query that will accumulate phrase attributes from the original query.
        :return: Filtered query after removing single word and phrase attributes from the original query.
        """
        cdef int i
        cdef str pair
        cdef Query filtered_query
        filtered_query = Query()
        i = 0
        while i < self.size():
            if i < self.size() - 1:
                pair = self.__terms[i].getName() + " " + self.__terms[i + 1].getName()
                if pair in attributeList:
                    phraseAttributes.__terms.append(Word(pair))
                    i = i + 2
                    continue
                if self.__terms[i + 1].getName() in self.__shortcuts and re.fullmatch(
                            "[+-]?\\d+|[+-]?(\\d+)?\\.\\d*",
                            self.__terms[i].getName()):
                    phraseAttributes.__terms.append(Word(pair))
                    i = i + 2
                    continue
            if self.__terms[i].getName() in attributeList:
                termAttributes.__terms.append(self.__terms[i])
            else:
                filtered_query.__terms.append(self.__terms[i])
            i = i + 1
        return filtered_query
