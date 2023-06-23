import re

from Dictionary.Word cimport Word

cdef class Query:

    __shortcuts: list = ["cc", "cm2", "cm", "gb", "ghz", "gr", "gram", "hz", "inc", "inch", "inç", "kg", "kw", "kva",
                         "litre", "lt", "m2", "m3", "mah", "mb", "metre", "mg", "mhz", "ml", "mm", "mp", "ms",
                         "mt", "mv", "tb", "tl", "va", "volt", "watt", "ah", "hp", "oz", "rpm", "dpi", "ppm", "ohm",
                         "kwh", "kcal", "kbit", "mbit", "gbit", "bit", "byte", "mbps", "gbps", "cm3", "mm2", "mm3",
                         "khz", "ft", "db", "sn", "g", "v", "m", "l", "w", "s"]

    def __init__(self, query: str = None):
        self.__terms = []
        if query is not None:
            terms = query.split(" ")
            for term in terms:
                self.__terms.append(Word(term))

    cpdef Word getTerm(self, int index):
        return self.__terms[index]

    cpdef int size(self):
        return len(self.__terms)

    cpdef Query filterAttributes(self,
                         set attributeList,
                         Query termAttributes,
                         Query phraseAttributes):
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
