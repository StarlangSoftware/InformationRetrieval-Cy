from MorphologicalAnalysis.FsmMorphologicalAnalyzer import FsmMorphologicalAnalyzer
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator

from InformationRetrieval.Document.DocumentType import DocumentType
from InformationRetrieval.Document.IndexType import IndexType
from InformationRetrieval.Index.TermOccurrence import TermOccurrence

cdef class Parameter:

    def __init__(self):
        """
        Empty constructor for the general query search.
        """
        self.__index_type = IndexType.INVERTED_INDEX
        self.__load_indexes_from_file = False
        self.__normalize_document = False
        self.__phrase_index = True
        self.__positional_index = True
        self.__construct_n_gram_index = True
        self.__limit_number_of_documents_loaded = False
        self.__document_limit = 1000
        self.__word_limit = 10000
        self.__word_comparator = TermOccurrence.ignoreCaseComparator
        self.__document_type = DocumentType.NORMAL
        self.__representative_count = 10

    cpdef object getIndexType(self):
        """
        Accessor for the index type search parameter. Index can be inverted index or incidence matrix.
        :return: Index type search parameter
        """
        return self.__index_type

    cpdef object getWordComparator(self):
        """
        Accessor for the word comparator. Word comparator is a function to compare terms.
        :return: Word comparator
        """
        return self.__word_comparator

    cpdef bint loadIndexesFromFile(self):
        """
        Accessor for the loadIndexesFromFile search parameter. If loadIndexesFromFile is true, all the indexes will be
        read from the file, otherwise they will be reconstructed.
        :return: loadIndexesFromFile search parameter
        """
        return self.__load_indexes_from_file

    cpdef MorphologicalDisambiguator getDisambiguator(self):
        """
        Accessor for the disambiguator search parameter. The disambiguator is used for morphological disambiguation for
        the terms in Turkish.
        :return: disambiguator search parameter
        """
        return self.__disambiguator

    cpdef FsmMorphologicalAnalyzer getFsm(self):
        """
        Accessor for the fsm search parameter. The fsm is used for morphological analysis for  the terms in Turkish.
        :return: fsm search parameter
        """
        return self.__fsm

    cpdef bint constructPhraseIndex(self):
        """
        Accessor for the constructPhraseIndex search parameter. If constructPhraseIndex is true, phrase indexes will be
        reconstructed or used in query processing.
        :return: constructPhraseIndex search parameter
        """
        return self.__phrase_index

    cpdef bint normalizeDocument(self):
        """
        Accessor for the normalizeDocument search parameter. If normalizeDocument is true, the terms in the document will
        be preprocessed by morphological anaylysis and some preprocessing techniques.
        :return: normalizeDocument search parameter
        """
        return self.__normalize_document

    cpdef bint constructPositionalIndex(self):
        """
        Accessor for the positionalIndex search parameter. If positionalIndex is true, positional indexes will be
        reconstructed or used in query processing.
        :return: positionalIndex search parameter
        """
        return self.__positional_index

    cpdef bint constructNGramIndex(self):
        """
        Accessor for the constructNGramIndex search parameter. If constructNGramIndex is true, N-Gram indexes will be
        reconstructed or used in query processing.
        :return: constructNGramIndex search parameter
        """
        return self.__construct_n_gram_index

    cpdef bint limitNumberOfDocumentsLoaded(self):
        """
        Accessor for the limitNumberOfDocumentsLoaded search parameter. If limitNumberOfDocumentsLoaded is true,
        the query result will be filtered according to the documentLimit search parameter.
        :return: limitNumberOfDocumentsLoaded search parameter
        """
        return self.__limit_number_of_documents_loaded

    cpdef int getDocumentLimit(self):
        """
        Accessor for the documentLimit search parameter. If limitNumberOfDocumentsLoaded is true,  the query result will
        be filtered according to the documentLimit search parameter.
        :return: limitNumberOfDocumentsLoaded search parameter
        """
        return self.__document_limit

    cpdef int getWordLimit(self):
        """
        Accessor for the wordLimit search parameter. wordLimit is the limit on the partial term dictionary size. For
        large collections, we term dictionaries are divided into multiple files, this parameter sets the number of terms
        in those separate dictionaries.
        :return: wordLimit search parameter
        """
        return self.__word_limit

    cpdef int getRepresentativeCount(self):
        """
        Accessor for the representativeCount search parameter. representativeCount is the maximum number of representative
        words in the category based query search.
        :return: representativeCount search parameter
        """
        return self.__representative_count

    cpdef setIndexType(self, object indexType):
        """
        Mutator for the index type search parameter. Index can be inverted index or incidence matrix.
        :param indexType: Index type search parameter
        """
        self.__index_type = indexType

    cpdef setWordComparator(self, object wordComparator):
        """
        Mutator for the word comparator. Word comparator is a function to compare terms.
        :param wordComparator: Word comparator
        """
        self.__word_comparator = wordComparator

    cpdef setLoadIndexesFromFile(self, bint loadIndexesFromFile):
        """
        Mutator for the loadIndexesFromFile search parameter. If loadIndexesFromFile is true, all the indexes will be
        read from the file, otherwise they will be reconstructed.
        :param loadIndexesFromFile: loadIndexesFromFile search parameter
        """
        self.__load_indexes_from_file = loadIndexesFromFile

    cpdef setDisambiguator(self, MorphologicalDisambiguator disambiguator):
        """
        Mutator for the disambiguator search parameter. The disambiguator is used for morphological disambiguation for
        the terms in Turkish.
        :param disambiguator: disambiguator search parameter
        """
        self.__disambiguator = disambiguator

    cpdef setFsm(self, FsmMorphologicalAnalyzer fsm):
        """
        Mutator for the fsm search parameter. The fsm is used for morphological analysis for the terms in Turkish.
        :param fsm: fsm search parameter
        """
        self.__fsm = fsm

    cpdef setNormalizeDocument(self, bint normalizeDocument):
        """
        Mutator for the normalizeDocument search parameter. If normalizeDocument is true, the terms in the document will
        be preprocessed by morphological anaylysis and some preprocessing techniques.
        :param normalizeDocument: normalizeDocument search parameter
        """
        self.__normalize_document = normalizeDocument

    cpdef setPhraseIndex(self, bint phraseIndex):
        """
        Mutator for the constructPhraseIndex search parameter. If constructPhraseIndex is true, phrase indexes will be
        reconstructed or used in query processing.
        :param phraseIndex: constructPhraseIndex search parameter
        """
        self.__phrase_index = phraseIndex

    cpdef setPositionalIndex(self, bint positionalIndex):
        """
        Mutator for the positionalIndex search parameter. If positionalIndex is true, positional indexes will be
        reconstructed or used in query processing.
        :param positionalIndex: positionalIndex search parameter
        """
        self.__positional_index = positionalIndex

    cpdef setNGramIndex(self, bint nGramIndex):
        """
        Mutator for the constructNGramIndex search parameter. If constructNGramIndex is true, N-Gram indexes will be
        reconstructed or used in query processing.
        :param nGramIndex: constructNGramIndex search parameter
        """
        self.__construct_n_gram_index = nGramIndex

    cpdef setLimitNumberOfDocumentsLoaded(self, bint limitNumberOfDocumentsLoaded):
        """
        Mutator for the limitNumberOfDocumentsLoaded search parameter. If limitNumberOfDocumentsLoaded is true,
        the query result will be filtered according to the documentLimit search parameter.
        :param limitNumberOfDocumentsLoaded: limitNumberOfDocumentsLoaded search parameter
        """
        self.__limit_number_of_documents_loaded = limitNumberOfDocumentsLoaded

    cpdef setDocumentLimit(self, int documentLimit):
        """
        Mutator for the documentLimit search parameter. If limitNumberOfDocumentsLoaded is true,  the query result will
        be filtered according to the documentLimit search parameter.
        :param documentLimit: documentLimit search parameter
        """
        self.__document_limit = documentLimit

    cpdef setWordLimit(self, int wordLimit):
        """
        Mutator for the documentLimit search parameter. If limitNumberOfDocumentsLoaded is true,  the query result will
        be filtered according to the documentLimit search parameter.
        :param wordLimit: wordLimit search parameter
        """
        self.__word_limit = wordLimit

    cpdef setRepresentativeCount(self, int representativeCount):
        """
        Mutator for the representativeCount search parameter. representativeCount is the maximum number of representative
        words in the category based query search.
        :param representativeCount: representativeCount search parameter
        """
        self.__representative_count = representativeCount

    cpdef object getDocumentType(self):
        """
        Accessor for the document type search parameter. Document can be normal or a categorical document.
        :return: Document type search parameter
        """
        return self.__document_type

    cpdef setDocumentType(self, object documentType):
        """
        Mutator for the document type search parameter. Document can be normal or a categorical document.
        :param documentType: Document type search parameter
        """
        self.__document_type = documentType
