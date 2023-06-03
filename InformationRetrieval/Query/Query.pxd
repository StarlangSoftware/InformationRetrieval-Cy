from Dictionary.Word cimport Word

cdef class Query:

    cdef list __terms

    cpdef Word getTerm(self, int index)
    cpdef int size(self)
    cpdef Query filterAttributes(self,
                         set attributeList,
                         Query termAttributes,
                         Query phraseAttributes)
