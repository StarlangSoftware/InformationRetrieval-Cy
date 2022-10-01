from MorphologicalAnalysis.FsmMorphologicalAnalyzer import FsmMorphologicalAnalyzer
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator

from InformationRetrieval.Document.IndexType import IndexType
from InformationRetrieval.Index.TermOccurrence import TermOccurrence

cdef class Parameter:

    def __init__(self):
        self.__index_type = IndexType.INVERTED_INDEX
        self.__load_indexes_from_file = False
        self.__normalize_document = False
        self.__phrase_index = True
        self.__positional_index = True
        self.__construct_n_gram_index = True
        self.__construct_index_in_disk = False
        self.__construct_dictionary_in_disk = False
        self.__limit_number_of_documents_loaded = False
        self.__document_limit = 1000
        self.__word_limit = 10000
        self.__word_comparator = TermOccurrence.ignoreCaseComparator

    cpdef object getIndexType(self):
        return self.__index_type

    cpdef object getWordComparator(self):
        return self.__word_comparator

    cpdef bint loadIndexesFromFile(self):
        return self.__load_indexes_from_file

    cpdef MorphologicalDisambiguator getDisambiguator(self):
        return self.__disambiguator

    cpdef FsmMorphologicalAnalyzer getFsm(self):
        return self.__fsm

    cpdef bint constructPhraseIndex(self):
        return self.__phrase_index

    cpdef bint normalizeDocument(self):
        return self.__normalize_document

    cpdef bint constructPositionalIndex(self):
        return self.__positional_index

    cpdef bint constructNGramIndex(self):
        return self.__construct_n_gram_index

    cpdef bint constructIndexInDisk(self):
        return self.__construct_index_in_disk

    cpdef bint limitNumberOfDocumentsLoaded(self):
        return self.__limit_number_of_documents_loaded

    cpdef int getDocumentLimit(self):
        return self.__document_limit

    cpdef bint constructDictionaryInDisk(self):
        return self.__construct_dictionary_in_disk

    cpdef int getWordLimit(self):
        return self.__word_limit

    cpdef setIndexType(self, object indexType):
        self.__index_type = indexType

    cpdef setWordComparator(self, object wordComparator):
        self.__word_comparator = wordComparator

    cpdef setLoadIndexesFromFile(self, bint loadIndexesFromFile):
        self.__load_indexes_from_file = loadIndexesFromFile

    cpdef setDisambiguator(self, MorphologicalDisambiguator disambiguator):
        self.__disambiguator = disambiguator

    cpdef setFsm(self, FsmMorphologicalAnalyzer fsm):
        self.__fsm = fsm

    cpdef setNormalizeDocument(self, bint normalizeDocument):
        self.__normalize_document = normalizeDocument

    cpdef setPhraseIndex(self, bint phraseIndex):
        self.__phrase_index = phraseIndex

    cpdef setPositionalIndex(self, bint positionalIndex):
        self.__positional_index = positionalIndex

    cpdef setNGramIndex(self, bint nGramIndex):
        self.__construct_n_gram_index = nGramIndex

    cpdef setConstructIndexInDisk(self, bint constructIndexInDisk):
        self.__construct_index_in_disk = constructIndexInDisk

    cpdef setLimitNumberOfDocumentsLoaded(self, bint limitNumberOfDocumentsLoaded):
        self.__limit_number_of_documents_loaded = limitNumberOfDocumentsLoaded

    cpdef setDocumentLimit(self, int documentLimit):
        self.__document_limit = documentLimit

    cpdef setConstructDictionaryInDisk(self, bint constructDictionaryInDisk):
        self.__construct_dictionary_in_disk = constructDictionaryInDisk
        if self.__construct_dictionary_in_disk:
            self.__construct_index_in_disk = True

    cpdef setWordLimit(self, int wordLimit):
        self.__word_limit = wordLimit
