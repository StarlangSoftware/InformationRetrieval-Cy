from InformationRetrieval.Document.DiskCollection cimport DiskCollection
from InformationRetrieval.Index.NGramIndex cimport NGramIndex
from InformationRetrieval.Index.TermDictionary cimport TermDictionary

cdef class LargeCollection(DiskCollection):

    cpdef constructDictionaryAndIndexesInDisk(self)
    cpdef bint notCombinedAllDictionaries(self, list currentWords)
    cpdef list selectDictionariesWithMinimumWords(self, list currentWords)
    cpdef combineMultipleDictionariesInDisk(self,
                                          str name,
                                          str tmpName,
                                          int blockCount)
    cpdef constructDictionaryAndInvertedIndexInDisk(self, object termType)
    cpdef constructDictionaryAndPositionalIndexInDisk(self, object termType)
    cpdef addNGramsToDictionaryAndIndex(self,
                                      str line,
                                      int k,
                                      TermDictionary nGramDictionary,
                                      NGramIndex nGramIndex)
    cpdef constructNGramDictionaryAndIndexInDisk(self)
