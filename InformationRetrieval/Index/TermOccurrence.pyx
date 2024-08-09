from Dictionary.Word cimport Word

cdef class TermOccurrence:

    def __init__(self,
                 term: Word,
                 docID: int,
                 position: int):
        """
        Constructor for the TermOccurrence class. Sets the attributes.
        :param term: Term for this occurrence.
        :param docID: Document id of the term occurrence.
        :param position: Position of the term in the document for this occurrence.
        """
        self.__term = term
        self.__doc_id = docID
        self.__position = position

    @staticmethod
    def ignoreCaseComparator(wordA: Word,
                             wordB: Word):
        cdef int i, first, second
        cdef str first_char, second_char
        IGNORE_CASE_LETTERS = "aAbBcCçÇdDeEfFgGğĞhHıIiİjJkKlLmMnNoOöÖpPqQrRsSşŞtTuUüÜvVwWxXyYzZ"
        for i in range(min(len(wordA.getName()), len(wordB.getName()))):
            first_char = wordA.getName()[i:i + 1]
            second_char = wordB.getName()[i:i + 1]
            if first_char != second_char:
                if first_char in IGNORE_CASE_LETTERS and second_char not in IGNORE_CASE_LETTERS:
                    return -1
                elif first_char not in IGNORE_CASE_LETTERS and second_char in IGNORE_CASE_LETTERS:
                    return 1
                elif first_char in IGNORE_CASE_LETTERS and second_char in IGNORE_CASE_LETTERS:
                    first = IGNORE_CASE_LETTERS.index(first_char)
                    second = IGNORE_CASE_LETTERS.index(second_char)
                    if first < second:
                        return -1
                    elif first > second:
                        return 1
                else:
                    if first_char < second_char:
                        return -1
                    else:
                        return 1
        if len(wordA.getName()) < len(wordB.getName()):
            return -1
        elif len(wordA.getName()) > len(wordB.getName()):
            return 1
        else:
            return 0

    @staticmethod
    def termOccurrenceComparator(termA: TermOccurrence,
                                 termB: TermOccurrence):
        """
        Compares two term occurrences.
        :param termA: the first term occurrence to be compared.
        :param termB: the second term occurrence to be compared.
        :return: If the term of the first term occurrence is different from the term of the second term occurrence then
        the method returns the comparison result between those two terms lexicographically. If the term of the first term
        occurrence is same as the term of the second term occurrence then the term occurrences are compared with respect
        to their document ids. If the first has smaller document id, the method returns -1; if the second has smaller
        document id, the method returns +1.  As the third comparison criteria, if also the document ids are the same,
        the method compares term occurrences with respect to the position. If the first has smaller position, the method
        returns -1; if the second has smaller position id, the method returns +1, and if all three features are the same,
        the method returns 0.
        """
        if termA.getTerm().getName() != termB.getTerm().getName():
            return TermOccurrence.ignoreCaseComparator(termA.getTerm(), termB.getTerm())
        elif termA.getDocId() == termB.getDocId():
            if termA.getPosition() == termB.getPosition():
                return 0
            elif termA.getPosition() < termB.getPosition():
                return -1
            else:
                return 1
        elif termA.getDocId() < termB.getDocId():
            return -1
        else:
            return 1

    cpdef Word getTerm(self):
        """
        Accessor for the term.
        :return: Term
        """
        return self.__term

    cpdef int getDocId(self):
        """
        Accessor for the document id.
        :return: Document id.
        """
        return self.__doc_id

    cpdef int getPosition(self):
        """
        Accessor for the position of the term.
        :return: Position of the term.
        """
        return self.__position

    cpdef bint isDifferent(self, TermOccurrence currentTerm):
        """
        Checks if the current occurrence is different from the other occurrence.
        :param currentTerm: Term occurrence to be compared.
        :return: True, if two terms are different; false if they are the same.
        """
        return self.__term.getName() != currentTerm.getTerm().getName()
