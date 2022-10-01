cdef class VectorSpaceModel:

    cdef list __model

    cpdef float get(self, int index)
    cpdef cosineSimilarity(self, VectorSpaceModel secondModel)
