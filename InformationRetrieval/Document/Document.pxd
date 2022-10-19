from Corpus.Corpus cimport Corpus
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator

from InformationRetrieval.Document.CategoryHierarchy cimport CategoryHierarchy
from InformationRetrieval.Document.DocumentText cimport DocumentText

cdef class Document:

    cdef str __absolute_file_name
    cdef str __file_name
    cdef int __doc_id
    cdef int __size
    cdef object __document_type
    cdef CategoryHierarchy __category_hierarchy

    cpdef DocumentText loadDocument(self)
    cpdef int getDocId(self)
    cpdef str getFileName(self)
    cpdef str getAbsoluteFileName(self)
    cpdef int getSize(self)
    cpdef setSize(self, int size)
    cpdef setCategoryHierarchy(self, str categoryHierarchy)
    cpdef CategoryHierarchy getCategoryHierarchy(self)
