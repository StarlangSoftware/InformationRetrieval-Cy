from InformationRetrieval.Document.DiskCollection cimport DiskCollection
from InformationRetrieval.Document.Document cimport Document
from InformationRetrieval.Document.DocumentText cimport DocumentText
from InformationRetrieval.Document.Parameter cimport Parameter
from InformationRetrieval.Index.InvertedIndex cimport InvertedIndex
from InformationRetrieval.Index.PositionalIndex cimport PositionalIndex
from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Index.TermType import TermType

cdef class MediumCollection(DiskCollection):

    def __init__(self,
                 directory: str,
                 parameter: Parameter):
        """
        Constructor for the MediumCollection class. In medium collections, dictionary is kept in memory and indexes are
        stored in the disk and don't fit in memory in their construction phase and usage phase. For that reason, in their
        construction phase, multiple disk reads and optimizations are needed.
        :param directory: Directory where the document collection resides.
        :param parameter: Search parameter
        """
        super().__init__(directory, parameter)
        self.constructIndexesInDisk()

    cpdef set constructDistinctWordList(self, object termType):
        """
        Given the document collection, creates a hash set of distinct terms. If term type is TOKEN, the terms are single
        word, if the term type is PHRASE, the terms are bi-words. Each document is loaded into memory and distinct
        word list is created. Since the dictionary can be kept in memory, all operations can be done in memory.
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        :return: Hash set of terms occurring in the document collection.
        """
        cdef set words, doc_words
        cdef Document doc
        cdef DocumentText document_text
        words = set()
        for doc in self.documents:
            document_text = doc.loadDocument()
            doc_words = document_text.constructDistinctWordList(termType)
            words = words.union(doc_words)
        return words

    cpdef constructIndexesInDisk(self):
        """
        In block sort based indexing, the indexes are created in a block wise manner. They do not fit in memory, therefore
        documents are read one by one. According to the search parameter, inverted index, positional index, phrase
        indexes, N-Gram indexes are constructed in disk.
        """
        cdef set word_list
        word_list = self.constructDistinctWordList(TermType.TOKEN)
        self.dictionary = TermDictionary(self.comparator, word_list)
        self.constructInvertedIndexInDisk(self.dictionary, TermType.TOKEN)
        if self.parameter.constructPositionalIndex():
            self.constructPositionalIndexInDisk(self.dictionary, TermType.TOKEN)
        if self.parameter.constructPhraseIndex():
            word_list = self.constructDistinctWordList(TermType.PHRASE)
            self.phrase_dictionary = TermDictionary(self.comparator, word_list)
            self.constructInvertedIndexInDisk(self.phrase_dictionary, TermType.PHRASE)
            if self.parameter.constructPositionalIndex():
                self.constructPositionalIndexInDisk(self.phrase_dictionary, TermType.PHRASE)
        if self.parameter.constructNGramIndex():
            self.constructNGramIndex()

    cpdef constructInvertedIndexInDisk(self,
                                     TermDictionary dictionary,
                                     object termType):
        """
        In block sort based indexing, the inverted index is created in a block wise manner. It does not fit in memory,
        therefore documents are read one by one. For each document, the terms are added to the inverted index. If the
        number of documents read are above the limit, current partial inverted index file is saved and new inverted index
        file is open. After reading all documents, we combine the inverted index files to get the final inverted index
        file.
        :param dictionary: Term dictionary.
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        """
        cdef int i, block_count, term_id
        cdef InvertedIndex inverted_index
        cdef Document doc
        cdef DocumentText document_text
        cdef set word_list
        cdef str word
        i = 0
        block_count = 0
        inverted_index = InvertedIndex()
        for doc in self.documents:
            if i < self.parameter.getDocumentLimit():
                i = i + 1
            else:
                inverted_index.saveSorted("tmp-" + block_count.__str__())
                inverted_index = InvertedIndex()
                block_count = block_count + 1
                i = 0
            document_text = doc.loadDocument()
            word_list = document_text.constructDistinctWordList(termType)
            for word in word_list:
                term_id = dictionary.getWordIndex(word)
                inverted_index.add(term_id, doc.getDocId())
        if len(self.documents) != 0:
            inverted_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultipleInvertedIndexesInDisk(self.name, "", block_count)
        else:
            self.combineMultipleInvertedIndexesInDisk(self.name + "-phrase", "", block_count)

    cpdef constructPositionalIndexInDisk(self,
                                         TermDictionary dictionary,
                                         object termType):
        """
        In block sort based indexing, the positional index is created in a block wise manner. It does not fit in memory,
        therefore documents are read one by one. For each document, the terms are added to the positional index. If the
        number of documents read are above the limit, current partial positional index file is saved and new positional
        index file is open. After reading all documents, we combine the posiitonal index files to get the final
        positional index file.
        :param dictionary: Term dictionary.
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        """
        cdef int i, block_count, term_id
        cdef PositionalIndex positional_index
        cdef Document doc
        cdef DocumentText document_text
        cdef list terms
        cdef TermOccurrence term_occurrence
        i = 0
        block_count = 0
        positional_index = PositionalIndex()
        for doc in self.documents:
            if i < self.parameter.getDocumentLimit():
                i = i + 1
            else:
                positional_index.saveSorted("tmp-" + block_count.__str__())
                positional_index = PositionalIndex()
                block_count = block_count + 1
                i = 0
            document_text = doc.loadDocument()
            terms = document_text.constructTermList(doc.getDocId(), termType)
            for term_occurrence in terms:
                termId = dictionary.getWordIndex(term_occurrence.getTerm().getName())
                positional_index.addPosition(termId, term_occurrence.getDocId(), term_occurrence.getPosition())
        if len(self.documents) != 0:
            positional_index.saveSorted("tmp-" + block_count.__str__())
            block_count = block_count + 1
        if termType == TermType.TOKEN:
            self.combineMultiplePositionalIndexesInDisk(self.name, block_count)
        else:
            self.combineMultiplePositionalIndexesInDisk(self.name + "-phrase", block_count)
