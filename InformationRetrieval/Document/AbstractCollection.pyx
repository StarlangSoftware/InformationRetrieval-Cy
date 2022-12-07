import os

from InformationRetrieval.Document.Document cimport Document
from InformationRetrieval.Document.DocumentType import DocumentType

cdef class AbstractCollection:

    def __init__(self,
                 directory: str,
                 parameter: Parameter):
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
        cdef int doc_id
        cdef list items
        cdef str line
        self.category_tree = CategoryTree(self.name)
        input_file = open(self.name + "-categories.txt", mode="r", encoding="utf-8")
        line = input_file.readline().strip()
        while line != "":
            items = line.split("\t")
            doc_id = int(items[0])
            self.documents[doc_id].setCategory(self.category_tree, items[1])
            line = input_file.readline()
        input_file.close()

    cpdef loadAttributeList(self):
        cdef str line
        self.attribute_list = set()
        input_file = open(self.name + "-attributelist.txt", mode="r", encoding="utf-8")
        line = input_file.readline().strip()
        while line != "":
            self.attribute_list.add(line)
            line = input_file.readline().strip()
        input_file.close()

    cpdef int size(self):
        return len(self.documents)

    cpdef int vocabularySize(self):
        return self.dictionary.size()

    cpdef constructNGramIndex(self):
        cdef list terms
        terms = self.dictionary.constructTermsFromDictionary(2)
        self.bi_gram_dictionary = TermDictionary(self.comparator, terms)
        self.bi_gram_index = NGramIndex(self.bi_gram_dictionary, terms)
        terms = self.dictionary.constructTermsFromDictionary(3)
        self.tri_gram_dictionary = TermDictionary(self.comparator, terms)
        self.tri_gram_index = NGramIndex(self.tri_gram_dictionary, terms)
