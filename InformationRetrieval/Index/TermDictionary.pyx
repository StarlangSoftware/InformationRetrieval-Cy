from functools import cmp_to_key

from Dictionary.Dictionary cimport Dictionary
from Dictionary.Word cimport Word

from InformationRetrieval.Index.Term cimport Term
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence

cdef class TermDictionary(Dictionary):

    def __init__(self,
                 comparator: object,
                 fileNameOrTerms = None):
        cdef str file_name, line, word
        cdef int term_id
        cdef list terms
        cdef TermOccurrence term, previous_term
        cdef int i
        cdef list word_list
        cdef Word term_word
        super().__init__(comparator)
        if fileNameOrTerms is not None:
            if isinstance(fileNameOrTerms, str):
                file_name = fileNameOrTerms
                input_file = open(file_name + "-dictionary.txt", mode='r', encoding='utf-8')
                line = input_file.readline().strip()
                while line != "":
                    term_id = int(line[0:line.index(" ")])
                    self.words.append(Term(line[line.index(" ") + 1:], term_id))
                    line = input_file.readline().strip()
                input_file.close()
            else:
                if isinstance(fileNameOrTerms, list):
                    term_id = 0
                    terms = fileNameOrTerms
                    if len(terms) > 0:
                        term = terms[0]
                        self.addTerm(term.getTerm().getName(), term_id)
                        term_id = term_id + 1
                        previous_term = term
                        i = 1
                        while i < len(terms):
                            term = terms[i]
                            if term.isDifferent(previous_term):
                                self.addTerm(term.getTerm().getName(), term_id)
                                term_id = term_id + 1
                            i = i + 1
                            previous_term = term
                else:
                    word_list = []
                    for word in fileNameOrTerms:
                        word_list.append(Word(word))
                    word_list.sort(key=cmp_to_key(comparator))
                    term_id = 0
                    for term_word in word_list:
                        self.addTerm(term_word.getName(), term_id)
                        term_id = term_id + 1

    cpdef int __getPosition(self, Word word):
        cdef int lo, hi, mid
        lo = 0
        hi = len(self.words) - 1
        while lo <= hi:
            mid = (lo + hi) // 2
            if self.comparator(self.words[mid], word) < 0:
                lo = mid + 1
            elif self.comparator(self.words[mid], word) > 0:
                hi = mid - 1
            else:
                return mid
        return -(lo + 1)

    cpdef addTerm(self,
                  str name,
                  int termId):
        cdef int middle
        middle = self.__getPosition(Word(name))
        if middle < 0:
            self.words.insert(-middle - 1, Term(name, termId))

    cpdef save(self, str fileName):
        cdef Word word
        cdef Term term
        output_file = open(fileName + "-dictionary.txt", mode='w', encoding='utf-8')
        for word in self.words:
            term = word
            output_file.write(term.getTermId().__str__() + " " + term.getName() + "\n")
        output_file.close()

    @staticmethod
    def constructNGrams(word: str,
                        termId: int,
                        k: int) -> [TermOccurrence]:
        cdef list n_grams
        cdef int j
        cdef str term
        n_grams = []
        if len(word) >= k - 1:
            for j in range(-1, len(word) - k + 2):
                if j == -1:
                    term = "$" + word[0:k - 1]
                elif j == len(word) - k + 1:
                    term = word[j: j + k - 1] + "$"
                else:
                    term = word[j: j + k]
                n_grams.append(TermOccurrence(Word(term), termId, j))
        return n_grams

    cpdef list constructTermsFromDictionary(self, int k):
        cdef list terms
        cdef int i
        cdef str word
        terms = []
        for i in range(self.size()):
            word = self.getWordWithIndex(i).getName()
            terms.extend(TermDictionary.constructNGrams(word, i, k))
        terms.sort(key=cmp_to_key(TermOccurrence.termOccurrenceComparator))
        return terms
