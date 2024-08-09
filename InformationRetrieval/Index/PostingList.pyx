from InformationRetrieval.Index.Posting cimport Posting

cdef class PostingList:

    @staticmethod
    def postingListComparator(listA: PostingList,
                              listB: PostingList):
        """
        Comparator method to compare two posting lists.
        :param listA: the first posting list to be compared.
        :param listB: the second posting list to be compared.
        :return: 1 if the size of the first posting list is larger than the second one, -1 if the size
        of the first posting list is smaller than the second one, 0 if they are the same.
        """
        if listA.size() < listB.size():
            return -1
        else:
            if listA.size() < listB.size():
                return 1
            else:
                return 0

    def __init__(self, line: str = None):
        """
        Constructs a posting list from a line, which contains postings separated with space.
        :param line: A string containing postings separated with space character.
        """
        cdef str _id
        self.__postings = []
        if line is not None:
            ids = line.split(" ")
            for _id in ids:
                self.add(int(_id))

    cpdef add(self, int docId):
        """
        Adds a new posting (document id) to the posting list.
        :param docId: New document id to be added to the posting list.
        """
        self.__postings.append(Posting(docId))

    cpdef int size(self):
        """
        Returns the number of postings in the posting list.
        :return: Number of postings in the posting list.
        """
        return len(self.__postings)

    cpdef PostingList intersection(self, PostingList secondList):
        """
        Algorithm for the intersection of two postings lists p1 and p2. We maintain pointers into both lists and walk
        through the two postings lists simultaneously, in time linear in the total number of postings entries. At each
        step, we compare the docID pointed to by both pointers. If they are the same, we put that docID in the results
        list, and advance both pointers. Otherwise, we advance the pointer pointing to the smaller docID.
        :param secondList: p2, second posting list.
        :return: Intersection of two postings lists p1 and p2.
        """
        cdef int i, j
        cdef PostingList result
        cdef Posting p1, p2
        i = 0
        j = 0
        result = PostingList()
        while i < self.size() and j < secondList.size():
            p1 = self.__postings[i]
            p2 = secondList.__postings[j]
            if p1.getId() == p2.getId():
                result.add(p1.getId())
                i = i + 1
                j = j + 1
            else:
                if p1.getId() < p2.getId():
                    i = i + 1
                else:
                    j = j + 1
        return result

    cpdef PostingList union(self, PostingList secondList):
        """
        Returns simple union of two postings list p1 and p2. The algorithm assumes the intersection of two postings list
        is empty, therefore the union is just concatenation of two postings lists.
        :param secondList: p2
        :return: Union of two postings lists.
        """
        cdef PostingList result
        result = PostingList()
        result.__postings.extend(self.__postings)
        result.__postings.extend(secondList.__postings)
        return result

    cpdef QueryResult toQueryResult(self):
        """
        Converts the postings list to a query result object. Simply adds all postings one by one to the result.
        :return: QueryResult object containing the postings in this object.
        """
        cdef QueryResult result
        cdef Posting posting
        result = QueryResult()
        for posting in self.__postings:
            result.add(posting.getId())
        return result

    cpdef writeToFile(self, object outfile, int index):
        """
        Prints this object into a file with the given index.
        :param outfile: Output stream to write the file.
        :param index: Position of this posting list in the inverted index.
        """
        if self.size() > 0:
            outfile.write(index.__str__() + " " + self.size().__str__() + "\n")
            outfile.write(self.__str__())

    def __str__(self):
        """
        Converts the posting list to a string. String is of the form all postings separated via space.
        :return: String form of the posting list.
        """
        cdef str result
        cdef Posting posting
        result = ""
        for posting in self.__postings:
            result = result + posting.getId().__str__() + " "
        return result.strip() + "\n"
