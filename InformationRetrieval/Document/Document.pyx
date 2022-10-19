from Corpus.Corpus cimport Corpus
from Corpus.Sentence cimport Sentence
from Corpus.TurkishSplitter cimport TurkishSplitter
from Dictionary.Word cimport Word
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from MorphologicalAnalysis.FsmParse cimport FsmParse
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator

from InformationRetrieval.Document.DocumentType import DocumentType

cdef class Document:

    def __init__(self, documentType: DocumentType, absoluteFileName: str, fileName: str, docId: int):
        self.__size = 0
        self.__absolute_file_name = absoluteFileName
        self.__file_name = fileName
        self.__doc_id = docId
        self.__document_type = documentType

    cpdef DocumentText loadDocument(self):
        if self.__document_type == DocumentType.NORMAL:
            document_text = DocumentText(self.__absolute_file_name, TurkishSplitter())
            self.__size = document_text.numberOfWords()
        elif self.__document_type == DocumentType.CATEGORICAL:
            corpus = Corpus(self.__absolute_file_name)
            if corpus.sentenceCount() >= 2:
                self.__category_hierarchy = CategoryHierarchy(corpus.getSentence(0).__str__())
                document_text = DocumentText()
                sentences = TurkishSplitter().split(corpus.getSentence(1).__str__())
                for sentence in sentences:
                    document_text.addSentence(sentence)
                    self.__size = document_text.numberOfWords()
            else:
                return None
        return document_text

    cpdef int getDocId(self):
        return self.__doc_id

    cpdef str getFileName(self):
        return self.__file_name

    cpdef str getAbsoluteFileName(self):
        return self.__absolute_file_name

    cpdef int getSize(self):
        return self.__size

    cpdef setSize(self, int size):
        self.__size = size

    cpdef setCategoryHierarchy(self, str categoryHierarchy):
        self.__category_hierarchy = CategoryHierarchy(categoryHierarchy)

    cpdef CategoryHierarchy getCategoryHierarchy(self):
        return self.__category_hierarchy
