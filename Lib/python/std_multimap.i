//
// std::map
// Python implementation

%include std_map.i


%define %std_multimap_methods(...)
  %std_map_methods_common(SWIG_arg(__VA_ARGS__));

  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  pair<iterator,bool> insert(const value_type& x);
  pair<iterator,iterator> equal_range(const key_type& x);
  pair<const_iterator,const_iterator> equal_range(const key_type& x) const;
  #endif
%enddef

// ------------------------------------------------------------------------
// std::multimap
// 
// The aim of all that follows would be to integrate std::multimap with 
// Python as much as possible, namely, to allow the user to pass and 
// be returned Python tuples or maps.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::multimap<T>), f(const std::multimap<T>&):
//      the parameter being read-only, either a Python sequence or a
//      previously wrapped std::multimap<T> can be passed.
//   -- f(std::multimap<T>&), f(std::multimap<T>*):
//      the parameter may be modified; therefore, only a wrapped std::multimap
//      can be passed.
//   -- std::multimap<T> f(), const std::multimap<T>& f():
//      the map is returned by copy; therefore, a Python sequence of T:s 
//      is returned which is most easily used in other Python functions
//   -- std::multimap<T>& f(), std::multimap<T>* f():
//      the map is returned by reference; therefore, a wrapped std::multimap
//      is returned
//   -- const std::multimap<T>* f(), f(const std::multimap<T>*):
//      for consistency, they expect and return a plain map pointer.
// ------------------------------------------------------------------------


// exported class

%fragment("StdMultimapTraits","header",fragment="StdSequenceTraits")
{
  namespace swigpy {
    template <class PySeq, class K, class T >
    void assign(const PySeq& pyseq, std::multimap<K,T > *multimap) {
      typedef typename std::map<K,T>::value_type value_type;
      typename PySeq::const_iterator it = pyseq.begin();
      for (;it != pyseq.end(); ++it) {
	multimap->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T>
    struct traits_asptr<std::multimap<K,T> >  {
      typedef std::multimap<K,T> multimap_type;
      typedef K key_type;
      
      static int asptr(PyObject *obj, multimap_type **val) {
	if (PyDict_Check(obj)) {
	  PyObject_var items = PyMapping_Items(obj);
	  return traits_asptr_stdseq<std::multimap<K,T>, std::pair<K, T> >
	    ::asptr(items, val);
	}
	if (val) {
	  PyErr_SetString(PyExc_TypeError, "a dictionary is expected");
	}
	return 0;
      }
    };
      
    template <class K, class T >
    struct traits_from<std::multimap<K,T> >  {
      typedef std::multimap<K,T> multimap_type;
      typedef typename multimap_type::const_iterator const_iterator;
      typedef typename multimap_type::size_type size_type;
            
      static PyObject *from(const multimap_type& multimap) {
	size_type size = multimap.size();
	int pysize = size <= INT_MAX ? (int) size : 0;
	if (!pysize) {
	  PyErr_SetString(PyExc_OverflowError,
			  "multimap size not valid in python");
	  Py_INCREF(Py_None);
	  return Py_None;
	}
	PyObject *obj = PyDict_New();
	for (const_iterator i= multimap.begin(); i!= multimap.end(); ++i) {
	  PyDict_SetItem(obj,
			 swigpy::from(i->first),
			 swigpy::from(i->second));
	}
	return obj;
      }
    };
  }
}

namespace std {
  template<class K, class T> class multimap {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef K key_type;
    typedef T mapped_type;
    typedef std::pair<const K, T> value_type;

    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    %traits_swigtype(K);
    %traits_swigtype(T);	    

    %fragment(SWIG_Traits_frag(std::multimap<K, T >), "header",
	      fragment=SWIG_Traits_frag(std::pair<K, T >),
	      fragment="StdMultimapTraits") {
      namespace swigpy {
	
	template <>  struct traits<std::multimap<K, T > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::multimap<" #K "," #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_CCode(MULTIMAP), std::multimap<K, T >);
  
    %std_multimap_methods(std::multimap<K, T >);
    %pydict_methods(SWIG_arg(std::multimap<K, T >));
  };
}

%define %std_multimap_ptypen(...) 
  %std_extcomp_2(multimap, __VA_ARGS__);
  %std_definst_2(multimap, __VA_ARGS__);
%enddef

#if defined(SWIG_STD_EXTEND_COMPARISON) || defined(SWIG_STD_DEFAULT_INSTANTIATION)
%apply_cpptypes_2(%std_multimap_ptypen);
#endif
