from Dictionary.Word cimport Word

cdef class TermOccurrence:

    def __init__(self,
                 term: Word,
                 docID: int,
                 position: int):
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
        return self.__term

    cpdef int getDocId(self):
        return self.__doc_id

    cpdef int getPosition(self):
        return self.__position

    cpdef bint isDifferent(self, TermOccurrence currentTerm):
        return self.__term.getName() != currentTerm.getTerm().getName()
