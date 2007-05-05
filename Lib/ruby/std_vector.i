/*
  Vectors
*/

%fragment("StdVectorTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class T>
    struct traits_asptr<std::vector<T> >  {
      static int asptr(VALUE obj, std::vector<T> **vec) {
	return traits_asptr_stdseq<std::vector<T> >::asptr(obj, vec);
      }
    };
    
    template <class T>
    struct traits_from<std::vector<T> > {
      static VALUE from(const std::vector<T>& vec) {
	return traits_from_stdseq<std::vector<T> >::from(vec);
      }
    };
  }
%}



%define %swig_vector_methods(Type...) 
  %swig_sequence_methods(Type)
  %swig_sequence_front_inserters(Type);
%enddef

%define %swig_vector_methods_val(Type...) 
  %swig_sequence_methods_val(Type);
  %swig_sequence_front_inserters(Type);
%enddef


%mixin std::vector "Enumerable";
%ignore std::vector::push_back;
%ignore std::vector::pop_back;

%include <std/std_vector.i>

