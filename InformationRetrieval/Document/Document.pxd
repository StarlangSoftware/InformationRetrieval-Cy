from InformationRetrieval.Document.DocumentText cimport DocumentText
from InformationRetrieval.Index.CategoryNode cimport CategoryNode
from InformationRetrieval.Index.CategoryTree cimport CategoryTree

cdef class Document:

    cdef str __absolute_file_name
    cdef str __file_name
    cdef int __doc_id
    cdef int __size
    cdef object __document_type
    cdef CategoryNode __category

    cpdef DocumentText loadDocument(self)
    cpdef int getDocId(self)
    cpdef str getFileName(self)
    cpdef str getAbsoluteFileName(self)
    cpdef int getSize(self)
    cpdef setSize(self, int size)
    cpdef loadCategory(self, CategoryTree categoryTree)
    cpdef setCategory(self, CategoryTree categoryTree, str category)
    cpdef str getCategory(self)
    cpdef CategoryNode getCategoryNode(self)
