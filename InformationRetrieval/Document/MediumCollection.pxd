from InformationRetrieval.Document.DiskCollection cimport DiskCollection
from InformationRetrieval.Index.TermDictionary cimport TermDictionary

cdef class MediumCollection(DiskCollection):

    cpdef set constructDistinctWordList(self, object termType)
    cpdef constructIndexesInDisk(self)
    cpdef constructInvertedIndexInDisk(self,
                                     TermDictionary dictionary,
                                     object termType)
    cpdef constructPositionalIndexInDisk(self,
                                         TermDictionary dictionary,
                                         object termType)
