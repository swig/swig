//
// std::map
// Python implementation

%include std_pair.i
%include std_container.i

%define %std_map_methods_common(map)
  %std_container_methods(SWIG_arg(map));

  size_type erase(const key_type& x);
  size_type count(const key_type& x) const;

  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(iterator position, const value_type& x);
  void erase(iterator position);
  void erase(iterator first, iterator last);

  iterator find(const key_type& x);
  const_iterator find(const key_type& x) const;
  iterator lower_bound(const key_type& x);
  const_iterator lower_bound(const key_type& x) const;
  iterator upper_bound(const key_type& x);
  const_iterator upper_bound(const key_type& x) const;
  #endif
%enddef

%define %std_map_methods(...)
  %std_map_methods_common(SWIG_arg(__VA_ARGS__));

  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(const value_type& x);
  #endif
%enddef

%define %std_multimap_methods(...)
  %std_map_methods_common(SWIG_arg(__VA_ARGS__));

  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  pair<iterator,bool> insert(const value_type& x);
  pair<iterator,iterator> equal_range(const key_type& x);
  pair<const_iterator,const_iterator> equal_range(const key_type& x) const;
  #endif
%enddef

// ------------------------------------------------------------------------
// std::map
// 
// The aim of all that follows would be to integrate std::map with 
// Python as much as possible, namely, to allow the user to pass and 
// be returned Python tuples or maps.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::map<T>), f(const std::map<T>&):
//      the parameter being read-only, either a Python sequence or a
//      previously wrapped std::map<T> can be passed.
//   -- f(std::map<T>&), f(std::map<T>*):
//      the parameter may be modified; therefore, only a wrapped std::map
//      can be passed.
//   -- std::map<T> f(), const std::map<T>& f():
//      the map is returned by copy; therefore, a Python sequence of T:s 
//      is returned which is most easily used in other Python functions
//   -- std::map<T>& f(), std::map<T>* f():
//      the map is returned by reference; therefore, a wrapped std::map
//      is returned
//   -- const std::map<T>* f(), f(const std::map<T>*):
//      for consistency, they expect and return a plain map pointer.
// ------------------------------------------------------------------------

%{
#include <map>
#include <algorithm>
#include <stdexcept>
%}

// exported class

%fragment("StdMapTraits","header",fragment="StdSequenceTraits")
{
  namespace swigpy {
    template <class PySeq, class K, class T >
    void assign(const PySeq& pyseq, std::map<K,T > *map) {
      typename PySeq::const_iterator it = pyseq.begin();
      for (;it != pyseq.end(); ++ it) {
	(*map)[it->first] = it->second;
      }
    }

    template <class K, class T>
    struct traits_asptr<std::map<K,T> >  {
      typedef std::map<K,T> map_type;
      typedef K key_type;
      typedef T value_type;
      
      static int asptr(PyObject *obj, map_type **val) {
	if (PyDict_Check(obj)) {
	  PyObject_var items = PyMapping_Items(obj);
	  return traits_asptr_stdseq<std::map<K,T>, std::pair<K, T> >
	    ::asptr(items, val);
	}
	if (val) {
	  PyErr_SetString(PyExc_TypeError, "a dictionary is expected");
	}
	return 0;
      }      
    };
      
    template <class K, class T >
    struct traits_from<std::map<K,T> >  {
      typedef std::map<K,T> map_type;
      typedef typename map_type::const_iterator const_iterator;
      typedef typename map_type::size_type size_type;
            
      static PyObject *from(const map_type& map) {
	size_type size = map.size();
	int pysize = size <= INT_MAX ? (int) size : 0;
	if (!pysize) {
	  PyErr_SetString(PyExc_OverflowError,
			  "map size not valid in python");
	  Py_INCREF(Py_None);
	  return Py_None;
	}
	PyObject *obj = PyDict_New();
	for (const_iterator i= map.begin(); i!= map.end(); ++i) {
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

  template<class K, class T> class map {
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

    %fragment(SWIG_Traits_frag(std::map<K, T >), "header",
	      fragment=SWIG_Traits_frag(std::pair<K, T >),
	      fragment="StdMapTraits") {
      namespace swigpy {
	template <>  struct traits<std::map<K, T > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::map<" #K "," #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_CCode(MAP), std::map<K, T >);
  
    %std_map_methods(std::map<K, T >);
    %pydict_methods(SWIG_arg(std::map<K, T >));
  };

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
	      fragment="StdMapTraits") {
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

// map
%define std_map_ptypen(...)
  %template() std::map< __VA_ARGS__ >;
%enddef

%apply_cpptypes_2(std_map_ptypen);

// multimap
%define std_multimap_ptypen(...)
  %template() std::multimap< __VA_ARGS__ >;
%enddef

%apply_cpptypes_2(std_multimap_ptypen);
