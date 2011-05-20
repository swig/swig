%fragment(SWIG_AsVal_frag(std::vector< int >), "header") {
#define SWIG_AsPtr_std_vector(scilabValue, stringPointer) SwigScilabStringToString(pvApiCtx, scilabValue, stringPointer, fname)
}

//#define %swig_vector_methods(Type...) %swig_sequence_methods(Type)
//#define %swig_vector_methods_val(Type...) %swig_sequence_methods_val(Type);

%include <std/std_vector.i>
