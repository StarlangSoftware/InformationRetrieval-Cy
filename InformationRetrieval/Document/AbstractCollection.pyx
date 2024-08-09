import os

from InformationRetrieval.Document.Document cimport Document
from InformationRetrieval.Document.DocumentType import DocumentType

cdef class AbstractCollection:

    def __init__(self,
                 directory: str,
                 parameter: Parameter):
        """
        Constructor for the AbstractCollection class. All collections, disk, memory, large, medium are extended from this
        basic class. Loads the attribute list from attribute file if required. Loads the names of the documents from
        the document collection. If the collection is a categorical collection, also loads the category tree.
        :param directory: Directory where the document collection resides.
        :param parameter: Search parameter
        """
        cdef int file_limit, j
        cdef list files
        cdef str file_name
        cdef Document document
        self.name = directory
        self.comparator = parameter.getWordComparator()
        self.parameter = parameter
        if self.parameter.getDocumentType() == DocumentType.CATEGORICAL:
            self.loadAttributeList()
        self.documents = []
        for root, dirs, files in os.walk(directory):
            file_limit = len(files)
            if parameter.limitNumberOfDocumentsLoaded():
                file_limit = parameter.getDocumentLimit()
            j = 0
            files.sort()
            for file in files:
                if j >= file_limit:
                    break
                file_name = os.path.join(root, file)
                if file.endswith(".txt"):
                    document = Document(parameter.getDocumentType(), file_name, file, j)
                    self.documents.append(document)
                    j = j + 1
        if parameter.getDocumentType() == DocumentType.CATEGORICAL:
            self.loadCategories()

    cpdef loadCategories(self):
        """
        Loads the category tree for the categorical collections from category index file. Each line of the category index
        file stores the index of the category and the category name with its hierarchy. Hierarchy string is obtained by
        concatenating the names of all nodes in the path from root node to a leaf node separated with '%'.
        """
        cdef int doc_id
        cdef list items
        cdef str line
        self.category_tree = CategoryTree(self.name)
        input_file = open(self.name + "-categories.txt", mode="r", encoding="utf-8")
        line = input_file.readline().strip()
        while line != "":
            items = line.split("\t")
            if len(items) > 0:
                doc_id = int(items[0])
                if len(items) > 1:
                    self.documents[doc_id].setCategory(self.category_tree, items[1])
            line = input_file.readline()
        input_file.close()

    cpdef loadAttributeList(self):
        """
        Loads the attribute list from attribute index file. Attributes are single or bi-word phrases representing the
        important features of products in the collection. Each line of the attribute file contains either single or a two
        word expression.
        """
        cdef str line
        self.attribute_list = set()
        input_file = open(self.name + "-attributelist.txt", mode="r", encoding="utf-8")
        line = input_file.readline().strip()
        while line != "":
            self.attribute_list.add(line)
            line = input_file.readline().strip()
        input_file.close()

    cpdef int size(self):
        """
        Returns size of the document collection.
        :return: Size of the document collection.
        """
        return len(self.documents)

    cpdef int vocabularySize(self):
        """
        Returns size of the term dictionary.
        :return: Size of the term dictionary.
        """
        return self.dictionary.size()

    cpdef constructNGramIndex(self):
        """
        Constructs bi-gram and tri-gram indexes in memory.
        """
        cdef list terms
        terms = self.dictionary.constructTermsFromDictionary(2)
        self.bi_gram_dictionary = TermDictionary(self.comparator, terms)
        self.bi_gram_index = NGramIndex(self.bi_gram_dictionary, terms)
        terms = self.dictionary.constructTermsFromDictionary(3)
        self.tri_gram_dictionary = TermDictionary(self.comparator, terms)
        self.tri_gram_index = NGramIndex(self.tri_gram_dictionary, terms)
