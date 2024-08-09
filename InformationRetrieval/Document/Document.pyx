from Corpus.Corpus cimport Corpus
from Corpus.Sentence cimport Sentence
from Corpus.TurkishSplitter cimport TurkishSplitter
from Dictionary.Word cimport Word

from InformationRetrieval.Document.DocumentType import DocumentType

cdef class Document:

    def __init__(self, documentType: DocumentType, absoluteFileName: str, fileName: str, docId: int):
        """
        Constructor for the Document class. Sets the attributes.
        :param documentType: Type of the document. Can be normal for normal documents, categorical for categorical
                             documents.
        :param absoluteFileName: Absolute file name of the document
        :param fileName: Relative file name of the document.
        :param docId: Id of the document
        """
        self.__size = 0
        self.__absolute_file_name = absoluteFileName
        self.__file_name = fileName
        self.__doc_id = docId
        self.__document_type = documentType

    cpdef DocumentText loadDocument(self):
        """
        Loads the document from input stream. For normal documents, it reads as a corpus. For categorical documents, the
        first line contains categorical information, second line contains name of the product, third line contains
        detailed info about the product.
        :return: Loaded document text.
        """
        cdef Corpus corpus
        if self.__document_type == DocumentType.NORMAL:
            document_text = DocumentText(self.__absolute_file_name, TurkishSplitter())
            self.__size = document_text.numberOfWords()
        elif self.__document_type == DocumentType.CATEGORICAL:
            corpus = Corpus(self.__absolute_file_name)
            if corpus.sentenceCount() >= 2:
                document_text = DocumentText()
                sentences = TurkishSplitter().split(corpus.getSentence(1).__str__())
                for sentence in sentences:
                    document_text.addSentence(sentence)
                    self.__size = document_text.numberOfWords()
            else:
                return None
        return document_text

    cpdef loadCategory(self, CategoryTree categoryTree):
        """
        Loads the category of the document and adds it to the category tree. Category information is stored in the first
        line of the document.
        :param categoryTree: Category tree to which new product will be added.
        """
        cdef Corpus corpus
        if self.__document_type == DocumentType.CATEGORICAL:
            corpus = Corpus(self.__absolute_file_name)
            if corpus.sentenceCount() >= 2:
                self.__category = categoryTree.addCategoryHierarchy(corpus.getSentence(0).__str__())

    cpdef int getDocId(self):
        """
        Accessor for the docId attribute.
        :return: docId attribute.
        """
        return self.__doc_id

    cpdef str getFileName(self):
        """
        Accessor for the fileName attribute.
        :return: fileName attribute.
        """
        return self.__file_name

    cpdef str getAbsoluteFileName(self):
        """
        Accessor for the absoluteFileName attribute.
        :return: absoluteFileName attribute.
        """
        return self.__absolute_file_name

    cpdef int getSize(self):
        """
        Accessor for the size attribute.
        :return: size attribute.
        """
        return self.__size

    cpdef setSize(self, int size):
        """
        Mutator for the size attribute.
        :param size: New size attribute.
        """
        self.__size = size

    cpdef setCategory(self, CategoryTree categoryTree, str category):
        """
        Mutator for the category attribute.
        :param categoryTree: Category tree to which new category will be added.
        :param category: New category that will be added
        """
        self.__category = categoryTree.addCategoryHierarchy(category)

    cpdef str getCategory(self):
        """
        Accessor for the category attribute.
        :return:Category attribute as a String
        """
        return self.__category.__str__()

    cpdef CategoryNode getCategoryNode(self):
        """
        Accessor for the category attribute.
        :return: Category attribute as a CategoryNode
        """
        return self.__category
