//
// std::set
// Python implementation

%include <std_set.i>

// Multiset

%define %std_multiset_methods(multiset)
  %std_set_methods_common(multiset);
  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  pair<iterator,bool> insert(iterator pos);
  #endif
%enddef


// ------------------------------------------------------------------------
// std::multiset
// 
// The aim of all that follows would be to integrate std::multiset with 
// Python as much as possible, namely, to allow the user to pass and 
// be returned Python tuples or sets.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::multiset<T>), f(const std::multiset<T>&):
//      the parameter being read-only, either a Python sequence or a
//      previously wrapped std::multiset<T> can be passed.
//   -- f(std::multiset<T>&), f(std::multiset<T>*):
//      the parameter may be modified; therefore, only a wrapped std::multiset
//      can be passed.
//   -- std::multiset<T> f(), const std::multiset<T>& f():
//      the set is returned by copy; therefore, a Python sequence of T:s 
//      is returned which is most easily used in other Python functions
//   -- std::multiset<T>& f(), std::multiset<T>* f():
//      the set is returned by reference; therefore, a wrapped std::multiset
//      is returned
//   -- const std::multiset<T>* f(), f(const std::multiset<T>*):
//      for consistency, they expect and return a plain set pointer.
// ------------------------------------------------------------------------

%fragment("StdMultisetTraits","header",fragment="StdSequenceTraits")
%{
  namespace swigpy {
    template <class PySeq, class T> 
    void assign(const PySeq& pyseq, std::multiset<T>* seq) {
#ifdef SWIG_STD_NOINSERT_TEMPLATE_STL
      typedef typename PySeq::value_type value_type;
      typename PySeq::const_iterator it = pyseq.begin();
      for (;it != pyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
#else
      seq->insert(pyseq.begin(), pyseq.end());
#endif
    }

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

// exported classes

namespace std {

  //multiset

  template<class T > class multiset {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T value_type;
    typedef T key_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::multiset<T >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdMultisetTraits") {
      namespace swigpy {
	template <>  struct traits<std::multiset<T > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::multiset<" #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_CCode(MULTISET), std::multiset<T >);
  
    %std_multiset_methods(multiset);
    %pycontainer_methods(std::multiset<T >);
  };

}

%define %std_multiset_ptypen(...) 
  %std_extcomp(multiset, __VA_ARGS__);
  %std_definst(multiset, __VA_ARGS__);
%enddef

#if defined(SWIG_STD_EXTEND_COMPARISON)  || defined(SWIG_STD_DEFAULT_INSTANTIATION)
%apply_cpptypes(%std_multiset_ptypen);
#endif
