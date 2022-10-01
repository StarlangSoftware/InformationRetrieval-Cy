from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Query.Query cimport Query
from InformationRetrieval.Query.QueryResult cimport QueryResult

cdef class IncidenceMatrix:

    cdef list __incidence_matrix
    cdef int __dictionary_size
    cdef int __document_size

    cpdef set(self, int row, int col)
    cpdef QueryResult search(self, Query query, TermDictionary dictionary)
