#include <assert.h>
#include "cpp_basic_std_vector_built_in/cpp_basic_std_vector_built_in_proxy.h"
#include <stdio.h>

int main() {
    Int_Vector *myIntVector = new_Int_Vector_size_t(42);

    assert(Int_Vector_capacity(myIntVector) == 42);
    Int_Vector_push_back(myIntVector, 4711);
    assert(Int_Vector_size(myIntVector) == 43);
    assert(Int_Vector_at(myIntVector, 42) == 4711);
    Int_Vector_clear(myIntVector);
    assert(Int_Vector_empty(myIntVector));
    assert(Int_Vector_size(myIntVector) == 0);
    Int_Vector_push_back(myIntVector, 23);
    assert(Int_Vector_size(myIntVector) == 1);
    
    delete_Int_Vector(myIntVector);
}