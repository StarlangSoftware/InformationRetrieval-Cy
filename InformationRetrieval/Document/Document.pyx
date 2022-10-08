from Corpus.Corpus cimport Corpus
from Corpus.Sentence cimport Sentence
from Corpus.TurkishSplitter cimport TurkishSplitter
from Dictionary.Word cimport Word
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from MorphologicalAnalysis.FsmParse cimport FsmParse
from MorphologicalDisambiguation.MorphologicalDisambiguator cimport MorphologicalDisambiguator

cdef class Document:

    def __init__(self, absoluteFileName: str, fileName: str, docId: int):
        self.__size = 0
        self.__absolute_file_name = absoluteFileName
        self.__file_name = fileName
        self.__doc_id = docId

    cpdef DocumentText loadDocument(self):
        document_text = DocumentText(self.__absolute_file_name, TurkishSplitter())
        self.__size = document_text.numberOfWords()
        return document_text

    cpdef Corpus normalizeDocument(self,
                                   MorphologicalDisambiguator disambiguator,
                                   FsmMorphologicalAnalyzer fsm):
        cdef Corpus corpus
        cdef int i
        cdef Sentence sentence, new_sentence
        cdef FsmParse fsm_parse
        corpus = Corpus(self.__absolute_file_name)
        for i in range(corpus.sentenceCount()):
            sentence = corpus.getSentence(i)
            parses = fsm.robustMorphologicalAnalysis(sentence)
            correct_parses = disambiguator.disambiguate(parses)
            new_sentence = Sentence()
            for fsm_parse in correct_parses:
                new_sentence.addWord(Word(fsm_parse.getWord().getName()))
            corpus.addSentence(new_sentence)
        self.__size = corpus.numberOfWords()
        return corpus

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
