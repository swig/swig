/*
  Maps
*/

%fragment("StdMapTraits","header",fragment="StdSequenceTraits")
{
  namespace swig {
    template <class PySeq, class K, class T >
    inline void
    assign(const PySeq& pyseq, std::map<K,T > *map) {
      typedef typename std::map<K,T>::value_type value_type;
      typename PySeq::const_iterator it = pyseq.begin();
      for (;it != pyseq.end(); ++it) {
	map->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T>
    struct traits_asptr<std::map<K,T> >  {
      typedef std::map<K,T> map_type;
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
	int pysize = (size <= (size_type) INT_MAX) ? (int) size : -1;
	if (pysize < 0) {
	  PyErr_SetString(PyExc_OverflowError,
			  "map size not valid in python");
	  return NULL;
	}
	PyObject *obj = PyDict_New();
	for (const_iterator i= map.begin(); i!= map.end(); ++i) {
	  swig::PyObject_var key = swig::from(i->first);
	  swig::PyObject_var val = swig::from(i->second);
	  PyDict_SetItem(obj, key, val);
	}
	return obj;
      }
    };
  }
}

%define %swig_map_methods(Map...)
  %swig_sequence_iterator(Map);
  %swig_container_methods(Map)

  %extend {
    mapped_type __getitem__(const key_type& key) const throw (std::out_of_range) {
      Map::const_iterator i = self->find(key);
      if (i != self->end())
	return i->second;
      else
	throw std::out_of_range("key not found");
    }
    
    void __setitem__(const key_type& key, const mapped_type& x) throw (std::out_of_range) {
      self->insert(Map::value_type(key,x));
    }
    
    void __delitem__(const key_type& key) throw (std::out_of_range) {
      Map::iterator i = self->find(key);
      if (i != self->end())
	self->erase(i);
      else
	throw std::out_of_range("key not found");
    }
    
    bool has_key(const key_type& key) const {
      Map::const_iterator i = self->find(key);
      return i != self->end();
    }
    
    PyObject* keys() {
      Map::size_type size = self->size();
      int pysize = (size <= (Map::size_type) INT_MAX) ? (int) size : -1;
      if (pysize < 0) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	return NULL;
      }
      PyObject* keyList = PyList_New(pysize);
      Map::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyList_SetItem(keyList, j, swig::from(i->first));
      }
      return keyList;
    }
    
    PyObject* values() {
      Map::size_type size = self->size();
      int pysize = (size <= (Map::size_type) INT_MAX) ? (int) size : -1;
      if (pysize < 0) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	return NULL;
      }
      PyObject* valList = PyTuple_New(pysize);
      Map::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyTuple_SetItem(valList, j, swig::from(i->second));
      }
      return valList;
    }
    
    PyObject* items() {
      Map::size_type size = self->size();
      int pysize = (size <= (Map::size_type) INT_MAX) ? (int) size : -1;
      if (pysize < 0) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	return NULL;
      }    
      PyObject* itemList = PyTuple_New(pysize);
      Map::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyTuple_SetItem(itemList, j, swig::from(*i));
      }
      return itemList;
    }
    
    // Python 2.2 methods
    bool __contains__(const key_type& key) {
      return self->find(key) != self->end();
    }

    PyObject* key_iterator() {
      Map::size_type size = self->size();
      int pysize = (size <= (Map::size_type) INT_MAX) ? (int) size : -1;
      if (pysize < 0) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	return NULL;
      }
      PyObject* keyTuple = PyTuple_New(pysize);
      Map::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyTuple_SetItem(keyTuple, j, swig::from(i->first));
      }
%#if PY_VERSION_HEX >= 0x02020000
      PyObject* iter = PyObject_GetIter(keyTuple);
      Py_DECREF(keyTuple);
      return iter;
%#else
      return keyTuple;
%#endif
    }
#if !defined(SWIG_USE_STD_MAP_ITERATOR)
    %pythoncode {
      def __iter__(self):
        return self.key_iterator()
    }    
#endif
  }
%enddef


%include <std/std_map.i>
