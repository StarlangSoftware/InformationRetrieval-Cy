from typing import TextIO

from InformationRetrieval.Index.Posting cimport Posting

cdef class PositionalPostingList:

    def __init__(self,
                 infile: TextIO = None,
                 count: int = None):
        cdef int i, j, doc_id, number_of_positional_postings, positional_posting
        cdef list ids
        cdef str, line
        self.__postings = []
        if infile is not None:
            for i in range(count):
                line = infile.readline().strip()
                ids = line.split(" ")
                number_of_positional_postings = int(ids[1])
                if len(ids) == number_of_positional_postings + 2:
                    doc_id = int(ids[0])
                    for j in range(number_of_positional_postings):
                        positional_posting = int(ids[j + 2])
                        self.add(doc_id, positional_posting)

    cpdef int size(self):
        return len(self.__postings)

    cpdef int getIndex(self, int docId):
        cdef int begin, end, middle
        begin = 0
        end = self.size() - 1
        while begin <= end:
            middle = (begin + end) // 2
            if docId == self.__postings[middle].getDocId():
                return middle
            else:
                if docId == self.__postings[middle].getDocId():
                    end = middle - 1
                else:
                    begin = middle + 1
        return -1

    cpdef QueryResult toQueryResult(self):
        cdef QueryResult result
        cdef PositionalPosting posting
        result = QueryResult()
        for posting in self.__postings:
            result.add(posting.getDocId())
        return result

    cpdef add(self,
              int docId,
              int position):
        cdef int index
        index = self.getIndex(docId)
        if index == -1:
            self.__postings.append(PositionalPosting(docId))
            self.__postings[len(self.__postings) - 1].add(position)
        else:
            self.__postings[index].add(position)

    cpdef PositionalPosting get(self, int index):
        return self.__postings[index]

    cpdef PositionalPostingList union(self, PositionalPostingList secondList):
        cdef PositionalPostingList result
        result = PositionalPostingList()
        result.__postings.extend(self.__postings)
        result.__postings.extend(secondList.__postings)
        return result

    cpdef PositionalPostingList intersection(self, PositionalPostingList secondList):
        cdef int i, j, position1, position2
        cdef PositionalPostingList result
        cdef PositionalPosting p1, p2
        cdef list postings1, postings2
        cdef Posting posting1, posting2
        i = 0
        j = 0
        result = PositionalPostingList()
        while i < len(self.__postings) and j < len(secondList.__postings):
            p1 = self.__postings[i]
            p2 = secondList.__postings[j]
            if p1.getDocId() == p2.getDocId():
                position1 = 0
                position2 = 0
                postings1 = p1.getPositions()
                postings2 = p2.getPositions()
                while position1 < len(postings1) and position2 < len(postings2):
                    posting1: Posting = postings1[position1]
                    posting2: Posting = postings2[position2]
                    if posting1.getId() + 1 == posting2.getId():
                        result.add(p1.getDocId(), posting2.getId())
                        position1 = position1 + 1
                        position2 = position2 + 1
                    else:
                        if posting1.getId() + 1 < posting2.getId():
                            position1 = position1 + 1
                        else:
                            position2 = position2 + 1
                i = i + 1
                j = j + 1
            else:
                if p1.getDocId() < p2.getDocId():
                    i = i + 1
                else:
                    j = j + 1
        return result

    def __str__(self) -> str:
        cdef str result
        cdef PositionalPosting positional_posting
        result = ""
        for positional_posting in self.__postings:
            result = result + "\t" + positional_posting.__str__() + "\n"
        return result

    cpdef writeToFile(self,
                      object outfile,
                      int index):
        if self.size() > 0:
            outfile.write(index.__str__() + " " + self.size().__str__() + "\n")
            outfile.write(self.__str__())
