from collections import OrderedDict

from InformationRetrieval.Document.Document cimport Document
from InformationRetrieval.Index.PositionalPosting cimport PositionalPosting
from InformationRetrieval.Index.PositionalPostingList cimport PositionalPostingList
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Query.VectorSpaceModel cimport VectorSpaceModel

cdef class PositionalIndex:

    def __init__(self,
                 dictionaryOrfileName: object = None,
                 terms: [TermOccurrence] = None):
        cdef TermDictionary dictionary
        cdef TermOccurrence term, previous_term
        cdef int i, term_id, prev_doc_id
        self.__positional_index = OrderedDict()
        if dictionaryOrfileName is not None:
            if isinstance(dictionaryOrfileName, TermDictionary):
                dictionary = dictionaryOrfileName
                if len(terms) > 0:
                    term = terms[0]
                    i = 1
                    previous_term = term
                    term_id = dictionary.getWordIndex(term.getTerm().getName())
                    self.addPosition(term_id, term.getDocId(), term.getPosition())
                    prev_doc_id = term.getDocId()
                    while i < len(terms):
                        term = terms[i]
                        term_id = dictionary.getWordIndex(term.getTerm().getName())
                        if term_id != -1:
                            if term.isDifferent(previous_term):
                                self.addPosition(term_id, term.getDocId(), term.getPosition())
                                prev_doc_id = term.getDocId()
                            elif prev_doc_id != term.getDocId():
                                self.addPosition(term_id, term.getDocId(), term.getPosition())
                                prev_doc_id = term.getDocId()
                            else:
                                self.addPosition(term_id, term.getDocId(), term.getPosition())
                        i = i + 1
                        previous_term = term
            elif isinstance(dictionaryOrfileName, str):
                self.readPositionalPostingList(dictionaryOrfileName)

    cpdef readPositionalPostingList(self, str fileName):
        cdef str line
        cdef list items
        cdef int word_id
        input_file = open(fileName + "-positionalPostings.txt", mode="r", encoding="utf-8")
        line = input_file.readline().strip()
        while line != "":
            items = line.split(" ")
            word_id = int(items[0])
            self.__positional_index[word_id] = PositionalPostingList(input_file, int(items[1]))
            line = input_file.readline().strip()
        input_file.close()

    cpdef saveSorted(self, str fileName):
        cdef list items
        cdef int key
        items = []
        for key in self.__positional_index.keys():
            items.append([key, self.__positional_index[key]])
        items.sort()
        output_file = open(fileName + "-positionalPostings.txt", mode="w", encoding="utf-8")
        for item in items:
            item[1].writeToFile(output_file, item[0])
        output_file.close()

    cpdef save(self, str fileName):
        cdef int key
        output_file = open(fileName + "-positionalPostings.txt", mode="w", encoding="utf-8")
        for key in self.__positional_index.keys():
            self.__positional_index[key].writeToFile(output_file, key)
        output_file.close()

    cpdef addPosition(self,
                      int termId,
                      int docId,
                      int position):
        cdef PositionalPostingList positional_posting_list
        if termId in self.__positional_index:
            positional_posting_list = self.__positional_index[termId]
        else:
            positional_posting_list = PositionalPostingList()
        positional_posting_list.add(docId, position)
        self.__positional_index[termId] = positional_posting_list

    cpdef QueryResult positionalSearch(self,
                                       Query query,
                                       TermDictionary dictionary):
        cdef PositionalPostingList posting_result
        cdef int i, term
        posting_result  = None
        for i in range(query.size()):
            term = dictionary.getWordIndex(query.getTerm(i).getName())
            if term != -1:
                if i == 0:
                    posting_result = self.__positional_index[term]
                elif posting_result is not None:
                    posting_result = posting_result.intersection(self.__positional_index[term])
                else:
                    return QueryResult()
            else:
                return QueryResult()
        if posting_result is not None:
            return posting_result.toQueryResult()
        else:
            return QueryResult()

    cpdef list getTermFrequencies(self, int docId):
        cdef list tf
        cdef int i, key, index
        cdef PositionalPostingList positional_posting_list
        tf = []
        i = 0
        for key in self.__positional_index.keys():
            positional_posting_list = self.__positional_index[key]
            index = positional_posting_list.getIndex(docId)
            if index != -1:
                tf.append(positional_posting_list.get(index).size())
            else:
                tf.append(0)
            i = i + 1
        return tf

    cpdef list getDocumentFrequencies(self):
        cdef list df
        cdef int i, key
        df = []
        i = 0
        for key in self.__positional_index.keys():
            df.append(self.__positional_index[key].size())
            i = i + 1
        return df

    cpdef setDocumentSizes(self, list documents):
        cdef list sizes
        cdef int i, doc_id
        cdef PositionalPostingList positional_posting_list
        cdef PositionalPosting positional_posting
        cdef Document doc
        sizes = []
        for i in range(len(documents)):
            sizes.append(0)
        for key in self.__positional_index.keys():
            positional_posting_list = self.__positional_index[key]
            for i in range(positional_posting_list.size()):
                positional_posting = positional_posting_list.get(i)
                doc_id = positional_posting.getDocId()
                sizes[doc_id] = sizes[doc_id] + positional_posting.size()
        for doc in documents:
            doc.setSize(sizes[doc.getDocId()])

    cpdef QueryResult rankedSearch(self,
                     Query query,
                     TermDictionary dictionary,
                     list documents,
                     object termWeighting,
                     object documentWeighting):
        cdef int N, i, term, j, doc_id
        cdef float tf, df
        cdef QueryResult result
        cdef list scores
        cdef PositionalPostingList positional_posting_list
        cdef PositionalPosting positional_posting
        N = len(documents)
        result = QueryResult()
        scores = [0 for _ in range(N)]
        for i in range(query.size()):
            term = dictionary.getWordIndex(query.getTerm(i).getName())
            if term != -1:
                positional_posting_list = self.__positional_index[term]
                for j in range(positional_posting_list.size()):
                    positional_posting = positional_posting_list.get(j)
                    doc_id = positional_posting.getDocId()
                    tf = positional_posting.size()
                    df = self.__positional_index[term].size()
                    if tf > 0 and df > 0:
                        scores[doc_id] = scores[doc_id] + VectorSpaceModel.weighting(tf, df, N, termWeighting, documentWeighting)
        for i in range(N):
            scores[i] = scores[i] / documents[i].getSize()
            if scores[i] > 0:
                result.add(i, scores[i])
        result.sort()
        return result
