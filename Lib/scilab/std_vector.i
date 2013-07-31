/*
 *
 * C++ type : STL vector
 * Scilab type : matrix (for vectors of primitive types) or list (for sets of all other types : pointers...)
 *
*/

%fragment("StdVectorTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class T>
    struct traits_asptr<std::vector<T> >  {
      static int asptr(const SciObject &obj, std::vector<T> **vec) {
        return traits_asptr_stdseq<std::vector<T> >::asptr(obj, vec);
      }
    };

    template <class T>
    struct traits_from<std::vector<T> > {
      static SciObject from(const std::vector<T>& vec) {
	      return traits_from_stdseq<std::vector<T> >::from(vec);
      }
    };
  }
%}


#define %swig_vector_methods(Type...) %swig_sequence_methods(Type)
#define %swig_vector_methods_val(Type...) %swig_sequence_methods_val(Type);

%include <std/std_vector.i>

