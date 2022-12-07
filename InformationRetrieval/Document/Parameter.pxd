from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator

cdef class Parameter:

    cdef object __index_type
    cdef object __word_comparator
    cdef bint __load_indexes_from_file
    cdef MorphologicalDisambiguator __disambiguator
    cdef FsmMorphologicalAnalyzer __fsm
    cdef bint __normalize_document
    cdef bint __phrase_index
    cdef bint __positional_index
    cdef bint __construct_n_gram_index
    cdef bint __limit_number_of_documents_loaded
    cdef int __document_limit
    cdef int __word_limit
    cdef object __document_type
    cdef int __representative_count


    cpdef object getIndexType(self)
    cpdef object getWordComparator(self)
    cpdef bint loadIndexesFromFile(self)
    cpdef MorphologicalDisambiguator getDisambiguator(self)
    cpdef FsmMorphologicalAnalyzer getFsm(self)
    cpdef bint constructPhraseIndex(self)
    cpdef bint normalizeDocument(self)
    cpdef bint constructPositionalIndex(self)
    cpdef bint constructNGramIndex(self)
    cpdef bint limitNumberOfDocumentsLoaded(self)
    cpdef int getDocumentLimit(self)
    cpdef int getWordLimit(self)
    cpdef int getRepresentativeCount(self)
    cpdef setIndexType(self, object indexType)
    cpdef setWordComparator(self, object wordComparator)
    cpdef setLoadIndexesFromFile(self, bint loadIndexesFromFile)
    cpdef setDisambiguator(self, MorphologicalDisambiguator disambiguator)
    cpdef setFsm(self, FsmMorphologicalAnalyzer fsm)
    cpdef setNormalizeDocument(self, bint normalizeDocument)
    cpdef setPhraseIndex(self, bint phraseIndex)
    cpdef setPositionalIndex(self, bint positionalIndex)
    cpdef setNGramIndex(self, bint nGramIndex)
    cpdef setLimitNumberOfDocumentsLoaded(self, bint limitNumberOfDocumentsLoaded)
    cpdef setDocumentLimit(self, int documentLimit)
    cpdef setWordLimit(self, int wordLimit)
    cpdef setRepresentativeCount(self, int representativeCount)
    cpdef object getDocumentType(self)
    cpdef setDocumentType(self, object documentType)
