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
        super().__init__(directory, parameter)
        self.constructIndexesInDisk()

    cpdef set constructDistinctWordList(self, object termType):
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
