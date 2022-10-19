import unittest

from InformationRetrieval.Document.Collection import Collection
from InformationRetrieval.Document.DocumentType import DocumentType
from InformationRetrieval.Document.IndexType import IndexType
from InformationRetrieval.Document.Parameter import Parameter
from InformationRetrieval.Query.Query import Query
from InformationRetrieval.Query.RetrievalType import RetrievalType
from InformationRetrieval.Query.SearchParameter import SearchParameter


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
        searchParameter = SearchParameter()
        searchParameter.setRetrievalType(RetrievalType.BOOLEAN)
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(2, len(result.getItems()))
        query = Query("Brutus Caesar")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(2, len(result.getItems()))
        query = Query("enact")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(1, len(result.getItems()))
        query = Query("noble")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(0, len(result.getItems()))

    def testInvertedIndexBooleanQuery(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        collection = Collection("../testCollection2", parameter)
        query = Query("Brutus")
        searchParameter = SearchParameter()
        searchParameter.setRetrievalType(RetrievalType.BOOLEAN)
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(2, len(result.getItems()))
        query = Query("Brutus Caesar")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(2, len(result.getItems()))
        query = Query("enact")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(1, len(result.getItems()))
        query = Query("noble")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(0, len(result.getItems()))

    def testPositionalIndexBooleanQuery(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        collection = Collection("../testCollection2", parameter)
        query = Query("Julius Caesar")
        searchParameter = SearchParameter()
        searchParameter.setRetrievalType(RetrievalType.POSITIONAL)
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(2, len(result.getItems()))
        query = Query("I was killed")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(1, len(result.getItems()))
        query = Query("The noble Brutus")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(0, len(result.getItems()))

    def testPositionalIndexRankedQuery(self):
        parameter = Parameter()
        parameter.setLoadIndexesFromFile(True)
        collection = Collection("../testCollection2", parameter)
        query = Query("Caesar")
        searchParameter = SearchParameter()
        searchParameter.setRetrievalType(RetrievalType.RANKED)
        searchParameter.setDocumentsRetrieved(2)
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(2, len(result.getItems()))
        self.assertEqual(1, result.getItems()[0].getDocId())
        query = Query("Caesar was killed")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(2, len(result.getItems()))
        self.assertEqual(0, result.getItems()[0].getDocId())
        query = Query("in the Capitol")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(1, len(result.getItems()))
        query = Query("a")
        result = collection.searchCollection(query, searchParameter)
        self.assertEqual(0, len(result.getItems()))

    def testLoadIndexesFromFileSmall(self):
        parameter = Parameter()
        parameter.setNGramIndex(True)
        parameter.setLoadIndexesFromFile(True)
        collection = Collection("../testCollection2", parameter)
        self.assertEqual(2, collection.size())
        self.assertEqual(26, collection.vocabularySize())

    def testLimitNumberOfDocumentsSmall(self):
        parameter = Parameter()
        parameter.setNGramIndex(False)
        parameter.setLimitNumberOfDocumentsLoaded(True)
        parameter.setDocumentLimit(1)
        collection = Collection("../testCollection2", parameter)
        self.assertEqual(1, collection.size())
        self.assertEqual(15, collection.vocabularySize())

    def testCategoricalCollection(self):
        parameter = Parameter()
        parameter.setDocumentType(DocumentType.CATEGORICAL)
        parameter.setLoadIndexesFromFile(True)
        parameter.setPhraseIndex(False)
        parameter.setNGramIndex(False)
        collection = Collection("../testCollection3", parameter)
        self.assertEqual(1000, collection.size())
        self.assertEqual(2283, collection.vocabularySize())


if __name__ == '__main__':
    unittest.main()
