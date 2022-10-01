from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence

cdef class IncidenceMatrix:

    def __init__(self,
                 terms: [TermOccurrence],
                 dictionary: TermDictionary,
                 documentSize: int):
        cdef int i
        cdef TermOccurrence term
        self.__dictionary_size = dictionary.size()
        self.__document_size = documentSize
        self.__incidence_matrix = [[False for _ in range(self.__document_size)] for _ in range(self.__dictionary_size)]
        if len(terms) > 0:
            term = terms[0]
            i = 1
            self.set(dictionary.getWordIndex(term.getTerm().getName()), term.getDocId())
            while i < len(terms):
                term = terms[i]
                self.set(dictionary.getWordIndex(term.getTerm().getName()), term.getDocId())
                i = i + 1

    cpdef set(self,
              int row,
              int col):
        self.__incidence_matrix[row][col] = True

    cpdef QueryResult search(self,
                             Query query,
                             TermDictionary dictionary):
        cdef QueryResult result
        cdef list result_row
        cdef int i, j, term_index
        result = QueryResult()
        result_row = [True for _ in range(self.__document_size)]
        for i in range(query.size()):
            term_index = dictionary.getWordIndex(query.getTerm(i).getName())
            if term_index != -1:
                for j in range(self.__document_size):
                    result_row[j] = result_row[j] and self.__incidence_matrix[term_index][j]
            else:
                return result
        for i in range(self.__document_size):
            if result_row[i]:
                result.add(i)
        return result
