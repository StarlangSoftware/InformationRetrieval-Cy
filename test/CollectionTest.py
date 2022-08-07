import unittest

from InformationRetrieval.Document.Collection import Collection
from InformationRetrieval.Document.IndexType import IndexType
from InformationRetrieval.Document.Parameter import Parameter
from InformationRetrieval.Query.Query import Query
from InformationRetrieval.Query.RetrievalType import RetrievalType


class CollectionTest(unittest.TestCase):

    def testIncidenceMatrixSmall(self):
        parameter = Parameter()
        parameter.setIndexType(IndexType.INCIDENCE_MATRIX)
        collection = Collection("../testCollection2", parameter)
        self.assertEqual(2, collection.size())
        self.assertEqual(26, collection.vocabularySize())

    def testIncidenceMatrixQuery(self):
        parameter = Parameter()
        parameter.setIndexType(IndexType.INCIDENCE_MATRIX)
        collection = Collection("../testCollection2", parameter)
        query = Query("Brutus")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(2, len(result.getItems()))
        query = Query("Brutus Caesar")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(2, len(result.getItems()))
        query = Query("enact")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(1, len(result.getItems()))
        query = Query("noble")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(0, len(result.getItems()))

    def testInvertedIndexBooleanQuery(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        collection = Collection("../testCollection2", parameter)
        query = Query("Brutus")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(2, len(result.getItems()))
        query = Query("Brutus Caesar")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(2, len(result.getItems()))
        query = Query("enact")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(1, len(result.getItems()))
        query = Query("noble")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, RetrievalType.BOOLEAN)
        self.assertEqual(0, len(result.getItems()))

    def testPositionalIndexBooleanQuery(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        collection = Collection("../testCollection2", parameter)
        query = Query("Julius Caesar")
        result = collection.searchCollection(query, RetrievalType.POSITIONAL)
        self.assertEqual(2, len(result.getItems()))
        query = Query("I was killed")
        result = collection.searchCollection(query, RetrievalType.POSITIONAL)
        self.assertEqual(1, len(result.getItems()))
        query = Query("The noble Brutus")
        result = collection.searchCollection(query, RetrievalType.POSITIONAL)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, RetrievalType.POSITIONAL)
        self.assertEqual(0, len(result.getItems()))

    def testPositionalIndexRankedQuery(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        collection = Collection("../testCollection2", parameter)
        query = Query("Caesar")
        result = collection.searchCollection(query, RetrievalType.RANKED)
        self.assertEqual(2, len(result.getItems()))
        self.assertEqual(1, result.getItems()[0].getDocId())
        query = Query("Caesar was killed")
        result = collection.searchCollection(query, RetrievalType.RANKED)
        self.assertEqual(2, len(result.getItems()))
        self.assertEqual(0, result.getItems()[0].getDocId())
        query = Query("in the Capitol")
        result = collection.searchCollection(query, RetrievalType.RANKED)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, RetrievalType.RANKED)
        self.assertEqual(0, len(result.getItems()))

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
