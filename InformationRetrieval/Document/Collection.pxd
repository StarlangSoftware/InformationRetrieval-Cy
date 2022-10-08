from InformationRetrieval.Document.Parameter cimport Parameter
from InformationRetrieval.Index.IncidenceMatrix cimport IncidenceMatrix
from InformationRetrieval.Index.InvertedIndex cimport InvertedIndex
from InformationRetrieval.Index.NGramIndex cimport NGramIndex
from InformationRetrieval.Index.PositionalIndex cimport PositionalIndex
from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Query.Query cimport Query

cdef class Collection:

    cdef object __index_type
    cdef TermDictionary __dictionary
    cdef TermDictionary __phrase_dictionary
    cdef TermDictionary __bi_gram_dictionary
    cdef TermDictionary __tri_gram_dictionary
    cdef list __documents
    cdef IncidenceMatrix __incidence_matrix
    cdef InvertedIndex __inverted_index
    cdef NGramIndex __bi_gram_index
    cdef NGramIndex __tri_gram_index
    cdef PositionalIndex __positional_index
    cdef InvertedIndex __phrase_index
    cdef PositionalIndex __phrase_positional_index
    cdef object __comparator
    cdef str __name
    cdef Parameter __parameter

    cpdef int size(self)
    cpdef int vocabularySize(self)
    cpdef save(self)
    cpdef constructDictionaryInDisk(self)
    cpdef constructIndexesInDisk(self)
    cpdef constructIndexesInMemory(self)
    cpdef list constructTerms(self, object termType)
    cpdef set constructDistinctWordList(self, object termType)
    cpdef bint notCombinedAllIndexes(self, list currentIdList)
    cpdef bint notCombinedAllDictionaries(self, list currentWords)
    cpdef list selectIndexesWithMinimumTermIds(self, list currentIdList)
    cpdef list selectDictionariesWithMinimumWords(self, list currentWords)
    cpdef combineMultipleDictionariesInDisk(self,
                                          str name,
                                          str tmpName,
                                          int blockCount)
    cpdef addNGramsToDictionaryAndIndex(self,
                                      str line,
                                      int k,
                                      TermDictionary nGramDictionary,
                                      NGramIndex nGramIndex)
    cpdef constructNGramDictionaryAndIndexInDisk(self)
    cpdef combineMultipleInvertedIndexesInDisk(self,
                                             str name,
                                             str tmpName,
                                             int blockCount)
    cpdef constructInvertedIndexInDisk(self,
                                     TermDictionary dictionary,
                                     object termType)
    cpdef constructDictionaryAndInvertedIndexInDisk(self, object termType)
    cpdef combineMultiplePositionalIndexesInDisk(self, str name, int blockCount)
    cpdef constructDictionaryAndPositionalIndexInDisk(self, object termType)
    cpdef constructPositionalIndexInDisk(self, TermDictionary dictionary, object termType)
    cpdef constructNGramIndex(self)
    cpdef searchCollection(self,
                         Query query,
                         object retrievalType,
                         object termWeighting = ?,
                         object documentWeighting = ?)
