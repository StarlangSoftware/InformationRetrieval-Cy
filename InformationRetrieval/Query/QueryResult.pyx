from DataStructure.Heap.MinHeap cimport MinHeap
from InformationRetrieval.Query.QueryResultItem cimport QueryResultItem

cdef class QueryResult:

    def __init__(self):
        self.__items = []

    cpdef add(self, int docId, float score = 0.0):
        self.__items.append(QueryResultItem(docId, score))

    cpdef list getItems(self):
        return self.__items

    def getBest(self, K: int):
        minHeap = MinHeap(2 * K, lambda x1, x2: -1 if x1.getScore() > x2.getScore() else (0 if x1.getScore() == x2.getScore() else 1))
        for queryResultItem in self.__items:
            minHeap.insert(queryResultItem)
        self.__items.clear()
        i = 0
        while i < K and not minHeap.isEmpty():
            self.__items.append(minHeap.delete())
            i = i + 1

    def __repr__(self):
        return f"{self.__items}"
