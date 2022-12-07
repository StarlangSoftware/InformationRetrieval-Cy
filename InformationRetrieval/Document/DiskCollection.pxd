from InformationRetrieval.Document.AbstractCollection cimport AbstractCollection

cdef class DiskCollection(AbstractCollection):

    cpdef bint notCombinedAllIndexes(self, list currentIdList)
    cpdef list selectIndexesWithMinimumTermIds(self, list currentIdList)
    cpdef list selectIndexesWithMinimumTermIds(self, list currentIdList)
    cpdef combineMultipleInvertedIndexesInDisk(self,
                                             str name,
                                             str tmpName,
                                             int blockCount)
    cpdef combineMultiplePositionalIndexesInDisk(self, str name, int blockCount)
