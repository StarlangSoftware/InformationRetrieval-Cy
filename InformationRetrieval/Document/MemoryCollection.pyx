from functools import cmp_to_key

from InformationRetrieval.Document.AbstractCollection cimport AbstractCollection
from InformationRetrieval.Document.Document cimport Document
from InformationRetrieval.Document.DocumentText cimport DocumentText
from InformationRetrieval.Document.DocumentType import DocumentType
from InformationRetrieval.Document.IndexType import IndexType
from InformationRetrieval.Document.Parameter cimport Parameter
from InformationRetrieval.Index.CategoryNode cimport CategoryNode
from InformationRetrieval.Index.CategoryTree cimport CategoryTree
from InformationRetrieval.Index.IncidenceMatrix cimport IncidenceMatrix
from InformationRetrieval.Index.InvertedIndex cimport InvertedIndex
from InformationRetrieval.Index.NGramIndex cimport NGramIndex
from InformationRetrieval.Index.PositionalIndex cimport PositionalIndex
from InformationRetrieval.Index.TermDictionary cimport TermDictionary
from InformationRetrieval.Index.TermOccurrence cimport TermOccurrence
from InformationRetrieval.Index.TermType import TermType
from InformationRetrieval.Query.FocusType import FocusType
from InformationRetrieval.Query.QueryResult cimport QueryResult
from InformationRetrieval.Query.QueryResultItem cimport QueryResultItem
from InformationRetrieval.Query.RetrievalType import RetrievalType
from InformationRetrieval.Query.SearchParameter cimport SearchParameter

cdef class MemoryCollection(AbstractCollection):
    def __init__(self,
                 directory: str,
                 parameter: Parameter):
        """
        Constructor for the MemoryCollection class. In small collections, dictionary and indexes are kept in memory.
        Memory collection also supports categorical documents.
        :param directory: Directory where the document collection resides.
        :param parameter: Search parameter
        """
        super().__init__(directory, parameter)
        self.__index_type = parameter.getIndexType()
        if parameter.loadIndexesFromFile():
            self.loadIndexesFromFile(directory)
        else:
            self.constructIndexesInMemory()
        if parameter.getDocumentType() == DocumentType.CATEGORICAL:
            self.positional_index.setCategoryCounts(self.documents)
            self.category_tree.setRepresentativeCount(parameter.getRepresentativeCount())

    cpdef loadIndexesFromFile(self, str directory):
        """
        The method loads the term dictionary, inverted index, positional index, phrase and N-Gram indexes from dictionary
        and index files to the memory.
        :param directory: Directory where the document collection resides.
        """
        self.dictionary = TermDictionary(self.comparator, directory)
        self.inverted_index = InvertedIndex(directory)
        if self.parameter.constructPositionalIndex():
            self.positional_index = PositionalIndex(directory)
            self.positional_index.setDocumentSizes(self.documents)
        if self.parameter.constructPhraseIndex():
            self.phrase_dictionary = TermDictionary(self.comparator, directory + "-phrase")
            self.phrase_index = InvertedIndex(directory + "-phrase")
            if self.parameter.constructPositionalIndex():
                self.phrase_positional_index = PositionalIndex(directory + "-phrase")
        if self.parameter.constructNGramIndex():
            self.bi_gram_dictionary = TermDictionary(self.comparator, directory + "-biGram")
            self.tri_gram_dictionary = TermDictionary(self.comparator, directory + "-triGram")
            self.bi_gram_index = NGramIndex(directory + "-biGram")
            self.tri_gram_index = NGramIndex(directory + "-triGram")

    cpdef save(self):
        """
        The method saves the term dictionary, inverted index, positional index, phrase and N-Gram indexes to the dictionary
        and index files. If the collection is a categorical collection, categories are also saved to the category
        files.
        """
        if self.__index_type == IndexType.INVERTED_INDEX:
            self.dictionary.save(self.name)
            self.inverted_index.save(self.name)
            if self.parameter.constructPositionalIndex():
                self.positional_index.save(self.name)
            if self.parameter.constructPhraseIndex():
                self.phrase_dictionary.save(self.name + "-phrase")
                self.phrase_index.save(self.name + "-phrase")
                if self.parameter.constructPositionalIndex():
                    self.phrase_positional_index.save(self.name + "-phrase")
            if self.parameter.constructNGramIndex():
                self.bi_gram_dictionary.save(self.name + "-biGram")
                self.tri_gram_dictionary.save(self.name + "-triGram")
                self.bi_gram_index.save(self.name + "-biGram")
                self.tri_gram_index.save(self.name + "-triGram")
        if self.parameter.getDocumentType() == DocumentType.CATEGORICAL:
            self.saveCategories()

    cpdef saveCategories(self):
        """
        The method saves the category tree for the categorical collections.
        """
        output_file = open(self.name + "-categories.txt", mode="w", encoding="utf-8")
        for document in self.documents:
            output_file.write(document.getDocId().__str__() + "\t" + document.getCategory().__str__() + "\n")
        output_file.close()

    cpdef constructIndexesInMemory(self):
        """
        The method constructs the term dictionary, inverted index, positional index, phrase and N-Gram indexes in memory.
        """
        cdef list terms
        terms = self.constructTerms(TermType.TOKEN)
        self.dictionary = TermDictionary(self.comparator, terms)
        if self.__index_type == IndexType.INCIDENCE_MATRIX:
            self.incidence_matrix = IncidenceMatrix(terms, self.dictionary, len(self.documents))
        elif self.__index_type == IndexType.INVERTED_INDEX:
            self.inverted_index = InvertedIndex(self.dictionary, terms)
            if self.parameter.constructPositionalIndex():
                self.positional_index = PositionalIndex(self.dictionary, terms)
            if self.parameter.constructPhraseIndex():
                terms = self.constructTerms(TermType.PHRASE)
                self.phrase_dictionary = TermDictionary(self.comparator, terms)
                self.phrase_index = InvertedIndex(self.phrase_dictionary, terms)
                if self.parameter.constructPositionalIndex():
                    self.phrase_positional_index = PositionalIndex(self.phrase_dictionary, terms)
            if self.parameter.constructNGramIndex():
                self.constructNGramIndex()
            if self.parameter.getDocumentType() == DocumentType.CATEGORICAL:
                self.category_tree = CategoryTree(self.name)
                for document in self.documents:
                    document.loadCategory(self.category_tree)

    cpdef list constructTerms(self, object termType):
        """
        Given the document collection, creates an array list of terms. If term type is TOKEN, the terms are single
        word, if the term type is PHRASE, the terms are bi-words. Each document is loaded into memory and
        word list is created. Since the dictionary can be kept in memory, all operations can be done in memory.
        :param termType: If term type is TOKEN, the terms are single word, if the term type is PHRASE, the terms are
                         bi-words.
        :return: Array list of terms occurring in the document collection.
        """
        cdef list terms
        cdef Document doc
        cdef DocumentText document_text
        cdef list doc_terms
        terms = []
        for doc in self.documents:
            document_text = doc.loadDocument()
            doc_terms = document_text.constructTermList(doc.getDocId(), termType)
            terms.extend(doc_terms)
        terms.sort(key=cmp_to_key(TermOccurrence.termOccurrenceComparator))
        return terms

    cpdef QueryResult attributeSearch(self, Query query, SearchParameter parameter):
        """
        The method searches given query string in the document collection using the attribute list according to the
        given search parameter. First, the original query is filtered by removing phrase attributes, shortcuts and single
        word attributes. At this stage, we get the word and phrase attributes in the original query and the remaining
        words in the original query as two separate queries. Second, both single word and phrase attributes in the
        original query are searched in the document collection. Third, these intermediate query results are then
        intersected. Fourth, we put this results into either (i) an inverted index (ii) or a ranked based positional
        filtering with the filtered query to get the end result.
        :param query: Query string
        :param parameter: Search parameter for the query
        :return: The intermediate result of the query obtained by doing attribute list based search in the collection.
        """
        cdef Query term_attributes, phrase_attributes, filtered_query
        cdef QueryResult term_result, phrase_result
        term_attributes = Query()
        phrase_attributes = Query()
        term_result = QueryResult()
        phrase_result = QueryResult()
        filtered_query = query.filterAttributes(self.attribute_list, term_attributes, phrase_attributes)
        if term_attributes.size() > 0:
            term_result = self.inverted_index.search(term_attributes, self.dictionary)
        if phrase_attributes.size() > 0:
            phrase_result = self.phrase_index.search(phrase_attributes, self.phrase_dictionary)
        if term_attributes.size() == 0:
            attribute_result = phrase_result
        elif phrase_attributes.size() == 0:
            attribute_result = term_result
        else:
            attribute_result = term_result.intersectionFastSearch(phrase_result)
        if filtered_query.size() == 0:
            return attribute_result
        else:
            if parameter.getRetrievalType() != RetrievalType.RANKED:
                filtered_result = self.searchWithInvertedIndex(filtered_query, parameter)
                return filtered_result.intersectionFastSearch(attribute_result)
            else:
                filtered_result = self.positional_index.rankedSearch(filtered_query,
                                                                     self.dictionary,
                                                                     self.documents,
                                                                     parameter)
                if attribute_result.size() < 10:
                    filtered_result = filtered_result.intersectionLinearSearch(attribute_result)
                else:
                    filtered_result = filtered_result.intersectionBinarySearch(attribute_result)
                filtered_result.getBest(parameter.getDocumentsRetrieved())
                return filtered_result

    cpdef QueryResult searchWithInvertedIndex(self,
                                              Query query,
                                              SearchParameter searchParameter):
        """
        The method searches given query string in the document collection using the inverted index according to the
        given search parameter. If the search is (i) boolean, inverted index is used (ii) positional, positional
        inverted index is used, (iii) ranked, positional inverted index is used with a ranking algorithm at the end.
        :param query: Query string
        :param searchParameter: Search parameter for the query
        :return: The intermediate result of the query obtained by doing inverted index based search in the collection.
        """
        cdef QueryResult result
        if searchParameter.getRetrievalType() == RetrievalType.BOOLEAN:
            return self.inverted_index.search(query, self.dictionary)
        elif searchParameter.getRetrievalType() == RetrievalType.POSITIONAL:
            return self.positional_index.positionalSearch(query, self.dictionary)
        elif searchParameter.getRetrievalType() == RetrievalType.RANKED:
            result = self.positional_index.rankedSearch(query,
                                                        self.dictionary,
                                                        self.documents,
                                                        searchParameter)
            result.getBest(searchParameter.getDocumentsRetrieved())
            return result
        else:
            return QueryResult()

    cpdef filterAccordingToCategories(self,
                                      QueryResult currentResult,
                                      list categories):
        """
        Filters current search result according to the predicted categories from the query string. For every search
        result, if it is in one of the predicated categories, is added to the filtered end result. Otherwise, it is
        omitted in the end result.
        :param currentResult: Current search result before filtering.
        :param categories: Predicted categories that match the query string.
        :return: Filtered query result
        """
        cdef QueryResult filtered_result
        cdef list items
        cdef QueryResultItem query_result_item
        cdef CategoryNode category_node, possible_ancestor
        filtered_result = QueryResult()
        items = currentResult.getItems()
        for query_result_item in items:
            category_node = self.documents[query_result_item.getDocId()].getCategoryNode()
            for possible_ancestor in categories:
                if category_node.isDescendant(possible_ancestor):
                    filtered_result.add(query_result_item.getDocId(), query_result_item.getScore())
                    break
        return filtered_result

    cpdef list autoCompleteWord(self, str prefix):
        """
        Constructs an auto complete list of product names for a given prefix. THe results are sorted according to
        frequencies.
        :param prefix: Prefix of the name of the product.
        :return: An auto complete list of product names for a given prefix.
        """
        cdef list result
        cdef int i
        result = []
        i = self.dictionary.getWordStartingWith(prefix)
        while i < self.dictionary.size():
            if self.dictionary.getWordWithIndex(i).getName().startswith(prefix):
                result.append(self.dictionary.getWordWithIndex(i).getName())
            else:
                break
            i = i + 1
        self.inverted_index.autoCompleteWord(result, self.dictionary)
        return result

    cpdef searchCollection(self,
                           Query query,
                           SearchParameter searchParameter):
        """
        Searches a document collection for a given query according to the given search parameters. The documents are
        searched using (i) incidence matrix if the index type is incidence matrix, (ii) attribute list if search
        attributes option is selected, (iii) inverted index if the index type is inverted index and no attribute
        search is done. After the initial search, if there is a categorical focus, it filters the results
        according to the predicted categories from the query string.
        :param query: Query string
        :param searchParameter: Search parameter for the query
        :return: The result of the query obtained by doing search in the collection.
        """
        if searchParameter.getFocusType() == FocusType.CATEGORY:
            if searchParameter.getSearchAttributes():
                current_result = self.attributeSearch(query, searchParameter)
            else:
                current_result = self.searchWithInvertedIndex(query, searchParameter)
            categories = self.category_tree.getCategories(query,
                                                          self.dictionary,
                                                          searchParameter.getCategoryDeterminationType())
            return self.filterAccordingToCategories(current_result, categories)
        else:
            if self.__index_type == IndexType.INCIDENCE_MATRIX:
                return self.incidence_matrix.search(query, self.dictionary)
            elif self.__index_type == IndexType.INVERTED_INDEX:
                if searchParameter.getSearchAttributes():
                    return self.attributeSearch(query, searchParameter)
                else:
                    return self.searchWithInvertedIndex(query, searchParameter)
            else:
                return QueryResult()
