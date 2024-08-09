from typing import TextIO

from InformationRetrieval.Index.Posting cimport Posting

cdef class PositionalPostingList:

    def __init__(self,
                 infile: TextIO = None,
                 count: int = None):
        """
        Reads a positional posting list from a file. Reads N lines, where each line stores a positional posting. The
        first item in the line shows document id. The second item in the line shows the number of positional postings.
        Other items show the positional postings.
        :param infile: Input stream to read from.
        :param count: Number of positional postings for this positional posting list.
        """
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
        """
        Returns the number of positional postings in the posting list.
        :return: Number of positional postings in the posting list.
        """
        return len(self.__postings)

    cpdef int getIndex(self, int docId):
        """
        Does a binary search on the positional postings list for a specific document id.
        :param docId: Document id to be searched.
        :return: The position of the document id in the positional posting list. If it does not exist, the method returns
        """
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
        """
        Converts the positional postings list to a query result object. Simply adds all positional postings one by one
        to the result.
        :return: QueryResult object containing the positional postings in this object.
        """
        cdef QueryResult result
        cdef PositionalPosting posting
        result = QueryResult()
        for posting in self.__postings:
            result.add(posting.getDocId())
        return result

    cpdef add(self,
              int docId,
              int position):
        """
        Adds a new positional posting (document id and position) to the posting list.
        :param docId: New document id to be added to the positional posting list.
        :param position: New position to be added to the positional posting list.
        """
        cdef int index
        index = self.getIndex(docId)
        if index == -1:
            self.__postings.append(PositionalPosting(docId))
            self.__postings[len(self.__postings) - 1].add(position)
        else:
            self.__postings[index].add(position)

    cpdef PositionalPosting get(self, int index):
        """
        Gets the positional posting at position index.
        :param index: Position of the positional posting.
        :return: The positional posting at position index.
        """
        return self.__postings[index]

    cpdef PositionalPostingList union(self, PositionalPostingList secondList):
        """
        Returns simple union of two positional postings list p1 and p2. The algorithm assumes the intersection of two
        positional postings list is empty, therefore the union is just concatenation of two positional postings lists.
        :param secondList: p2
        :return: Union of two positional postings lists.
        """
        cdef PositionalPostingList result
        result = PositionalPostingList()
        result.__postings.extend(self.__postings)
        result.__postings.extend(secondList.__postings)
        return result

    cpdef PositionalPostingList intersection(self, PositionalPostingList secondList):
        """
        Algorithm for the intersection of two positional postings lists p1 and p2. We maintain pointers into both lists
        and walk through the two positional postings lists simultaneously, in time linear in the total number of postings
        entries. At each step, we compare the docID pointed to by both pointers. If they are not the same, we advance the
        pointer pointing to the smaller docID. Otherwise, we advance both pointers and do the same intersection search on
        the positional lists of two documents. Similarly, we compare the positions pointed to by both position pointers.
        If they are successive, we add the position to the result and advance both position pointers. Otherwise, we
        advance the pointer pointing to the smaller position.
        :param secondList: p2, second posting list.
        :return: Intersection of two postings lists p1 and p2.
        """
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
        """
        Converts the positional posting list to a string. String is of the form all postings separated via space.
        :return: String form of the positional posting list.
        """
        cdef str result
        cdef PositionalPosting positional_posting
        result = ""
        for positional_posting in self.__postings:
            result = result + "\t" + positional_posting.__str__() + "\n"
        return result

    cpdef writeToFile(self,
                      object outfile,
                      int index):
        """
        Prints this object into a file with the given index.
        :param outfile: Output stream to write the file.
        :param index: Position of this positional posting list in the inverted index.
        """
        if self.size() > 0:
            outfile.write(index.__str__() + " " + self.size().__str__() + "\n")
            outfile.write(self.__str__())
