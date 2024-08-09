from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence

cdef class NGramIndex(InvertedIndex):

    def __init__(self,
                 dictionaryOrfileName: object = None,
                 terms: [TermOccurrence] = None):
        """
        Constructs an NGram index from a list of sorted tokens. The terms array should be sorted before calling this
        method. Calls the constructor for the InvertedIndex.
        :param dictionaryOrfileName: Term dictionary
        :param terms: Sorted list of tokens in the memory collection.
        """
        super().__init__(dictionaryOrfileName, terms)
