import unittest

from InformationRetrieval.Document.Collection import Collection
from InformationRetrieval.Document.IndexType import IndexType
from InformationRetrieval.Document.Parameter import Parameter


class CollectionTest(unittest.TestCase):

    def testIncidenceMatrixSmall(self):
        parameter = Parameter()
        parameter.setIndexType(IndexType.INCIDENCE_MATRIX)
        collection = Collection("../testCollection2", parameter)
        self.assertEqual(2, collection.size())
        self.assertEqual(26, collection.vocabularySize())

    def testSaveIndexesToFileSmall(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        collection = Collection("../testCollection2", parameter)
        collection.save()

    def testLoadIndexesFromFileSmall(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        parameter.setLoadIndexesFromFile(True)
        collection = Collection("../testCollection2", parameter)
        self.assertEqual(2, collection.size())
        self.assertEqual(26, collection.vocabularySize())

    def testConstructIndexesInDiskSmall(self):
        parameter = Parameter()
        parameter.setConstructIndexInDisk(True)
        parameter.setNGramIndex(False)
        parameter.setDocumentLimit(1)
        collection = Collection("../testCollection2", parameter)

    def testLimitNumberOfDocumentsSmall(self):
        parameter = Parameter()
        parameter.setNGramIndex(False)
        parameter.setLimitNumberOfDocumentsLoaded(True)
        parameter.setDocumentLimit(1)
        collection = Collection("../testCollection2", parameter)
        self.assertEqual(1, collection.size())
        self.assertEqual(15, collection.vocabularySize())

    def testConstructDictionaryAndIndexesInDiskSmall(self):
        parameter = Parameter()
        parameter.setConstructDictionaryInDisk(True)
        parameter.setDocumentLimit(1)
        parameter.setWordLimit(10)
        collection = Collection("../testCollection2", parameter)


if __name__ == '__main__':
    unittest.main()
