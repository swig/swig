//
// std::set
// Python implementation

%include std_container.i

// Set

%define %std_set_methods_common(set)
  %std_container_methods(set);
  
  size_type erase(const key_type& x);
  size_type count(const key_type& x) const;
  
  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(iterator pos, const value_type& x);
  void insert(iterator pos, size_type n, const value_type& x);
  iterator erase(iterator pos);
  iterator erase(iterator first, iterator last);

  iterator find(const key_type& x) const;
  iterator lower_bound(const key_type& x) const;
  iterator upper_bound(const key_type& x) const;
  std::pair<iterator,iterator> equal_range(const key_type& x);
  iterator begin() const;
  iterator end() const;
  #endif
%enddef

%define %std_set_methods(set)
  %std_set_methods_common(set);
  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(iterator pos);
  #endif
%enddef

%define %std_multiset_methods(multiset)
  %std_set_methods_common(multiset);
  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  pair<iterator,bool> insert(iterator pos);
  #endif
%enddef


// ------------------------------------------------------------------------
// std::set
// 
// The aim of all that follows would be to integrate std::set with 
// Python as much as possible, namely, to allow the user to pass and 
// be returned Python tuples or sets.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::set<T>), f(const std::set<T>&):
//      the parameter being read-only, either a Python sequence or a
//      previously wrapped std::set<T> can be passed.
//   -- f(std::set<T>&), f(std::set<T>*):
//      the parameter may be modified; therefore, only a wrapped std::set
//      can be passed.
//   -- std::set<T> f(), const std::set<T>& f():
//      the set is returned by copy; therefore, a Python sequence of T:s 
//      is returned which is most easily used in other Python functions
//   -- std::set<T>& f(), std::set<T>* f():
//      the set is returned by reference; therefore, a wrapped std::set
//      is returned
//   -- const std::set<T>* f(), f(const std::set<T>*):
//      for consistency, they expect and return a plain set pointer.
// ------------------------------------------------------------------------

%{
#include <set>
%}

%fragment("StdSetTraits","header",fragment="StdSequenceTraits")
%{
  namespace swigpy {
    template <class PySeq, class T> 
    void assign(const PySeq& pyseq, std::set<T>* seq) {
      seq->insert(pyseq.begin(), pyseq.end());
    }

    template <class T>
    struct traits_asptr<std::set<T> >  {
      typedef std::set<T> set_type;
      static int asptr(PyObject *obj, set_type **s) {
	return traits_asptr_stdseq<std::set<T> >::asptr(obj, s);
      }
    };

    template <class T>
    struct traits_from<std::set<T> > {
      static PyObject *from(const std::set<T>& vec) {
	return traits_from_stdseq<std::set<T> >::from(vec);
      }
    };
  }
%}

%fragment("StdMultisetTraits","header",fragment="StdSequenceTraits")
%{
  namespace swigpy {
    template <class PySeq, class T> 
    void assign(const PySeq& pyseq, std::multiset<T>* seq) {
      seq->insert(pyseq.begin(), pyseq.end());
    }

    template <class T>
    struct traits_asptr<std::multiset<T> >  {
      typedef std::multiset<T> multiset_type;
      static int asptr(PyObject *obj, multiset_type **m) {
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

  template<class T > class set {
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

    %fragment(SWIG_Traits_frag(std::set<T >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdSetTraits") {
      namespace swigpy {
	template <>  struct traits<std::set<T > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::set<" #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_CCode(SET), std::set<T >);
  
    %std_set_methods(std::set<T >);
    %pycontainer_methods(std::set<T >);
  };

  // Add the order operations <,>,<=,=> as needed
  
  %define %std_order_set(T)
    %std_comp_methods(set<T>);
  %enddef
  
  %apply_otypes(%std_order_set);


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
  
    %std_multiset_methods(std::multiset<T >);
    %pycontainer_methods(std::multiset<T >);
  };

  // Add the order operations <,>,<=,=> as needed
  
  %define %std_order_multiset(T)
    %std_comp_methods(multiset<T>);
  %enddef
  
  %apply_otypes(%std_order_multiset);

}

// set 

%define %std_set_ptypen(...) 
%template() std::set<__VA_ARGS__ >;
%enddef

%apply_cpptypes(%std_set_ptypen);

// multiset

%define %std_multiset_ptypen(...) 
%template() std::multiset<__VA_ARGS__ >;
%enddef

%apply_cpptypes(%std_multiset_ptypen);
