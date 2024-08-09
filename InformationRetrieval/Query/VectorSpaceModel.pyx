from math import sqrt, log

from InformationRetrieval.Document.DocumentWeighting import DocumentWeighting
from InformationRetrieval.Index.TermWeighting import TermWeighting

cdef class VectorSpaceModel:

    def __init__(self,
                 termFrequencies: [int],
                 documentFrequencies: [int],
                 documentSize: int,
                 termWeighting: TermWeighting,
                 documentWeighting: DocumentWeighting):
        """
        Constructor for the VectorSpaceModel class. Calculates the normalized tf-idf vector of a single document.
        :param termFrequencies: Term frequencies in the document.
        :param documentFrequencies: Document frequencies of terms.
        :param documentSize: Number of documents in the collection
        :param termWeighting: Term weighting scheme applied in term frequency calculation.
        :param documentWeighting: Document weighting scheme applied in document frequency calculation.
        """
        cdef float _sum
        cdef int i
        _sum = 0
        self.__model = []
        for i in range(len(termFrequencies)):
            self.__model.append(self.weighting(termFrequencies[i],
                                               documentFrequencies[i],
                                               documentSize,
                                               termWeighting,
                                               documentWeighting))
            _sum = _sum + self.__model[i] * self.__model[i]
        for i in range(len(termFrequencies)):
            self.__model[i] = self.__model[i] / sqrt(_sum)

    cpdef float get(self, int index):
        """
        Returns the tf-idf value for a column at position index
        :param index: Position of the column
        :return: tf-idf value for a column at position index
        """
        return self.__model[index]

    cpdef cosineSimilarity(self, VectorSpaceModel secondModel):
        """
        Calculates the cosine similarity between this document vector and the given second document vector.
        :param secondModel: Document vector of the second document.
        :return: Cosine similarity between this document vector and the given second document vector.
        """
        cdef float _sum
        cdef int i
        _sum = 0.0
        for i in range(len(self.__model)):
            _sum = _sum + self.__model[i] * secondModel.__model[i]
        return _sum

    @staticmethod
    def weighting(termFrequency: float,
                  documentFrequency: float,
                  documentSize: int,
                  termWeighting: TermWeighting,
                  documentWeighting: DocumentWeighting):
        """
        Calculates tf-idf value of a single word (column) of the document vector.
        :param termFrequency: Term frequency of this word in the document.
        :param documentFrequency: Document frequency of this word.
        :param documentSize: Number of documents in the collection.
        :param termWeighting: Term weighting scheme applied in term frequency calculation.
        :param documentWeighting: Document weighting scheme applied in document frequency calculation.
        :return: tf-idf value of a single word (column) of the document vector.
        """
        cdef float multiplier1, multiplier2
        multiplier1 = 1
        multiplier2 = 1
        if termWeighting == TermWeighting.NATURAL:
            multiplier1 = termFrequency
        elif termWeighting == TermWeighting.LOGARITHM:
            if termFrequency > 0:
                multiplier1 = 1 + log(termFrequency)
            else:
                multiplier1 = 0
        elif termWeighting == TermWeighting.BOOLE:
            if termFrequency > 0:
                multiplier1 = 1
            else:
                multiplier1 = 0
        if documentWeighting == DocumentWeighting.NO_IDF:
            multiplier2 = 1
        elif documentWeighting == DocumentWeighting.IDF:
            multiplier2 = log(documentSize / documentFrequency)
        elif documentWeighting == DocumentWeighting.PROBABILISTIC_IDF:
            if documentSize > 2 * documentFrequency:
                multiplier2 = log((documentSize - documentFrequency) / documentFrequency)
            else:
                multiplier2 = 0
        return multiplier1 * multiplier2
