from InformationRetrieval.Document.Parameter cimport Parameter
from InformationRetrieval.Index.CategoryTree cimport CategoryTree
from InformationRetrieval.Index.IncidenceMatrix cimport IncidenceMatrix
from InformationRetrieval.Index.InvertedIndex cimport InvertedIndex
from InformationRetrieval.Index.NGramIndex cimport NGramIndex
from InformationRetrieval.Index.PositionalIndex cimport PositionalIndex
from InformationRetrieval.Index.TermDictionary cimport TermDictionary

cdef class AbstractCollection:

    cdef TermDictionary dictionary
    cdef TermDictionary phrase_dictionary
    cdef TermDictionary bi_gram_dictionary
    cdef TermDictionary tri_gram_dictionary
    cdef list documents
    cdef IncidenceMatrix incidence_matrix
    cdef InvertedIndex inverted_index
    cdef NGramIndex bi_gram_index
    cdef NGramIndex tri_gram_index
    cdef PositionalIndex positional_index
    cdef InvertedIndex phrase_index
    cdef PositionalIndex phrase_positional_index
    cdef object comparator
    cdef str name
    cdef Parameter parameter
    cdef CategoryTree category_tree
    cdef set attribute_list

    cpdef loadCategories(self)
    cpdef loadAttributeList(self)
    cpdef int size(self)
    cpdef int vocabularySize(self)
    cpdef constructNGramIndex(self)

