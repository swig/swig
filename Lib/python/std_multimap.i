/*
  Multimaps
*/
%include <std_map.i>

%fragment("StdMultimapTraits","header",fragment="StdSequenceTraits")
{
  namespace swig {
    template <class PySeq, class K, class T >
    static inline void 
    assign(const PySeq& pyseq, std::multimap<K,T > *multimap) {
      typedef typename std::map<K,T>::value_type value_type;
      typename PySeq::const_iterator it = pyseq.begin();
      for (;it != pyseq.end(); ++it) {
	multimap->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T>
    struct traits_asptr<std::multimap<K,T> >  {
      static int asptr(PyObject *obj, std::multimap<K,T> **val) {
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
	int pysize = (size <= (size_type) INT_MAX) ? (int) size : -1;
	if (pysize < 0) {
	  PyErr_SetString(PyExc_OverflowError,
			  "multimap size not valid in python");
	  return NULL;
	}
	PyObject *obj = PyDict_New();
	for (const_iterator i= multimap.begin(); i!= multimap.end(); ++i) {
	  PyDict_SetItem(obj,
			 swig::from(i->first),
			 swig::from(i->second));
	}
	return obj;
      }
    };
  }
}

#define %swig_multimap_methods(Type...) %swig_map_methods(Type)

%include <std/std_multimap.i>

