from Corpus.Corpus cimport Corpus
from Corpus.Sentence cimport Sentence
from Corpus.SentenceSplitter cimport SentenceSplitter
from Dictionary.Word cimport Word

from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Index.TermType import TermType

cdef class DocumentText(Corpus):

    def __init__(self,
                 fileName: str = None,
                 sentenceSplitter: SentenceSplitter = None):
        """
        Another constructor for the DocumentText class. Calls super with the given file name and sentence splitter.
        :param fileName: File name of the corpus
        :param sentenceSplitter: Sentence splitter class that separates sentences.
        """
        super().__init__(fileName, sentenceSplitter)

    cpdef set constructDistinctWordList(self, object termType):
        """
        Given the corpus, creates a hash set of distinct terms. If term type is TOKEN, the terms are single word, if
        the term type is PHRASE, the terms are bi-words.
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        :return: Hash set of terms occurring in the document.
        """
        cdef set words
        cdef int i, j
        cdef Sentence sentence
        words = set()
        for i in range(self.sentenceCount()):
            sentence = self.getSentence(i)
            for j in range(sentence.wordCount()):
                if termType == TermType.TOKEN:
                    words.add(sentence.getWord(j).getName())
                elif termType == TermType.PHRASE:
                    if j < sentence.wordCount() - 1:
                        words.add(sentence.getWord(j).getName() + " " + sentence.getWord(j + 1).getName())
        return words

    cpdef list constructTermList(self,
                                 int docId,
                                 object termType):
        """
        Given the corpus, creates an array of terms occurring in the document in that order. If term type is TOKEN, the
        terms are single word, if the term type is PHRASE, the terms are bi-words.
        :param docId: Id of the document
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        :return: Array list of terms occurring in the document.
        """
        cdef list terms
        cdef int size, i, j
        cdef Sentence sentence
        terms = []
        size = 0
        for i in range(self.sentenceCount()):
            sentence = self.getSentence(i)
            for j in range(sentence.wordCount()):
                if termType == TermType.TOKEN:
                    terms.append(TermOccurrence(sentence.getWord(j), docId, size))
                    size = size + 1
                elif termType == TermType.PHRASE:
                    if j < sentence.wordCount() - 1:
                        terms.append(TermOccurrence(Word(sentence.getWord(j).getName() + " " + sentence.getWord(j + 1).getName()), docId, size))
                        size = size + 1
        return terms
