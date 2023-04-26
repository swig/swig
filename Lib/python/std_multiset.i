/*
  Multisets
*/

%include <std_set.i>

%fragment("StdMultisetTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class T>
    struct traits_asptr<std::multiset<T> >  {
      static int asptr(PyObject *obj, std::multiset<T> **m) {
	return traits_asptr_stdseq<std::multiset<T> >::asptr(obj, m);
      }
    };

    template <class T>
    struct traits_from<std::multiset<T> > {
      static PyObject *from(const std::multiset<T>& vec) {
	return traits_from_stdseq<std::multiset<T> >::from(vec);
      }
    };
  }
%}

#define %swig_multiset_methods(Set...) %swig_set_methods(Set)



%include <std/std_multiset.i>
