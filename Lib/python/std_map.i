//
// SWIG typemaps for std::map
// Luigi Ballabio
// Jan. 2003
//
// Python implementation

%include std_common.i
%include exception.i

%exception std::map::__getitem__ {
    try {
        $action
    } catch (std::out_of_range& e) {
        PyErr_SetString(PyExc_KeyError,const_cast<char*>(e.what()));
        SWIG_fail;
    }
}

%exception std::map::__delitem__  {
    try {
        $action
    } catch (std::out_of_range& e) {
        PyErr_SetString(PyExc_KeyError,const_cast<char*>(e.what()));
        SWIG_fail;
    }
}

%exception std::map::__iter__  {
    try {
        $action
    } catch (std::runtime_error& e) {
        PyErr_SetString(PyExc_RuntimeError,const_cast<char*>(e.what()));
        SWIG_fail;
    }
}


// ------------------------------------------------------------------------
// std::map
//
// The aim of all that follows would be to integrate std::map with
// Python as much as possible, namely, to allow the user to pass and
// be returned Python dictionaries.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
//
//   -- f(std::map<T>), f(const std::map<T>&), f(const std::map<T>*):
//      the parameter being read-only, either a Python dictionary or a
//      previously wrapped std::map<T> can be passed.
//   -- f(std::map<T>&), f(std::map<T>*):
//      the parameter must be modified; therefore, only a wrapped std::map
//      can be passed.
//   -- std::map<T> f():
//      the map is returned by copy; therefore, a Python dictionary
//      is returned which is most easily used in other Python functions
//   -- std::map<T>& f(), std::map<T>* f(), const std::map<T>& f(),
//      const std::map<T>* f():
//      the map is returned by reference; therefore, a wrapped std::map
//      is returned
// ------------------------------------------------------------------------

%{
#include <map>
#include <algorithm>
#include <stdexcept>
%}

// exported class

namespace std {

    template<class K, class T> class map {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                $1 = std::map<K,T >();
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1) {
                        (($1_type &)$1)[*k] = *x;
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $&1_descriptor,0) != -1) {
                $1 = *m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                temp = std::map<K,T >();
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1) {
                        temp[*k] = *x;
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $1_descriptor,0) != -1) {
                $1 = m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(out) map<K,T> {
            $result = PyDict_New();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                K* key = new K(i->first);
                T* obj = new T(i->second);
                PyDict_SetItem($result,
                               SWIG_NewPointerObj((void *) key,
                                                  $descriptor(K *), 1),
                               SWIG_NewPointerObj((void *) obj,
                                                  $descriptor(T *), 1));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    K* k;
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    K* k;
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        map();
        map(const map<K,T> &);
        
        %rename(__len__) size;
        unsigned int size() const;
        void clear();
        %extend {
            bool __nonzero__() {
                return !(self->empty());
            }
            T& __getitem__(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(const K& key, const T& x) {
                (*self)[key] = x;
            }
            void __delitem__(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    self->erase(i);
                else
                    throw std::out_of_range("key not found");
            }
            bool has_key(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* keys() {
                PyObject* keyList = PyList_New(self->size());
                swig_type_info* type = SWIG_TypeQuery(#K " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* ptr = new K(i->first);
                    PyList_SetItem(keyList,j,
                                   SWIG_NewPointerObj((void *) ptr,type,1));
                }
                return keyList;
            }
            PyObject* values() {
                PyObject* valueList = PyList_New(self->size());
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    T* ptr = new T(i->second);
                    PyList_SetItem(valueList,j,
                                   SWIG_NewPointerObj((void *) ptr,type,1));
                }
                return valueList;
            }
            PyObject* items() {
                PyObject* itemList = PyList_New(self->size());
                swig_type_info* k_type = SWIG_TypeQuery(#K " *");
                swig_type_info* t_type = SWIG_TypeQuery(#T " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* k_ptr = new K(i->first);
                    T* t_ptr = new T(i->second);
                    PyObject* item = PyTuple_New(2);
                    PyTuple_SetItem(item,0,
                                    SWIG_NewPointerObj((void *) k_ptr,
                                                       k_type,1));
                    PyTuple_SetItem(item,1,
                                    SWIG_NewPointerObj((void *) t_ptr,
                                                       t_type,1));
                    PyList_SetItem(itemList,j,item);
                }
                return itemList;
            }
            // Python 2.2 methods
            bool __contains__(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* __iter__() {
                %#if PY_VERSION_HEX >= 0x02020000
                PyObject* keyList = PyList_New(self->size());
                swig_type_info* type = SWIG_TypeQuery(#K " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* ptr = new K(i->first);
                    PyList_SetItem(keyList,j,
                                   SWIG_NewPointerObj((void *) ptr,type,1));
                }
                PyObject* iter = PyObject_GetIter(keyList);
                Py_DECREF(keyList);
                return iter;
                %#else
                throw std::runtime_error("Python 2.2 or later is needed"
                                         " for iterator support");
                %#endif
            }
        }
    };


    // specializations for built-ins

    %define specialize_std_map_on_key(K,CHECK,CONVERT_FROM,CONVERT_TO)
    template<class T> class map<K,T> {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                $1 = std::map<K,T >();
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK(key) &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1) {
                        (($1_type &)$1)[CONVERT_FROM(key)] = *x;
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $&1_descriptor,0) != -1) {
                $1 = *m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                temp = std::map<K,T >();
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK(key) &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1) {
                        temp[CONVERT_FROM(key)] = *x;
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $1_descriptor,0) != -1) {
                $1 = m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(out) map<K,T> {
            $result = PyDict_New();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                T* obj = new T(i->second);
                PyDict_SetItem($result,
                               CONVERT_TO(i->first),
                               SWIG_NewPointerObj((void *) obj,
                                                  $descriptor(T *), 1));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK(key) &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK(key) &&
                        SWIG_ConvertPtr(o,(void **) &x,
                                        $descriptor(T *),0) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        map();
        map(const map<K,T> &);
        
        %rename(__len__) size;
        unsigned int size() const;
        void clear();
        %extend {
            bool __nonzero__() {
                return !(self->empty());
            }
            T& __getitem__(K key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(K key, const T& x) {
                (*self)[key] = x;
            }
            void __delitem__(K key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    self->erase(i);
                else
                    throw std::out_of_range("key not found");
            }
            bool has_key(K key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* keys() {
                PyObject* keyList = PyList_New(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    PyList_SetItem(keyList,j,
                                   CONVERT_TO(i->first));
                }
                return keyList;
            }
            PyObject* values() {
                PyObject* valueList = PyList_New(self->size());
                swig_type_info* type = SWIG_TypeQuery(#T " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    T* ptr = new T(i->second);
                    PyList_SetItem(valueList,j,
                                   SWIG_NewPointerObj((void *) ptr,type,1));
                }
                return valueList;
            }
            PyObject* items() {
                PyObject* itemList = PyList_New(self->size());
                swig_type_info* t_type = SWIG_TypeQuery(#T " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    T* t_ptr = new T(i->second);
                    PyObject* item = PyTuple_New(2);
                    PyTuple_SetItem(item,0,
                                    CONVERT_TO(i->first));
                    PyTuple_SetItem(item,1,
                                    SWIG_NewPointerObj((void *) t_ptr,
                                                       t_type,1));
                    PyList_SetItem(itemList,j,item);
                }
                return itemList;
            }
            // Python 2.2 methods
            bool __contains__(K key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* __iter__() {
                %#if PY_VERSION_HEX >= 0x02020000
                PyObject* keyList = PyList_New(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    PyList_SetItem(keyList,j,
                                   CONVERT_TO(i->first));
                }
                PyObject* iter = PyObject_GetIter(keyList);
                Py_DECREF(keyList);
                return iter;
                %#else
                throw std::runtime_error("Python 2.2 or later is needed"
                                         " for iterator support");
                %#endif
            }
        }
    };
    %enddef

    %define specialize_std_map_on_value(T,CHECK,CONVERT_FROM,CONVERT_TO)
    template<class K> class map<K,T> {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                $1 = std::map<K,T >();
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        CHECK(o)) {
                        (($1_type &)$1)[*k] = CONVERT_FROM(o);
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $&1_descriptor,0) != -1) {
                $1 = *m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                temp = std::map<K,T >();
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    K* k;
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        CHECK(o)) {
                        temp[*k] = CONVERT_FROM(o);
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $1_descriptor,0) != -1) {
                $1 = m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(out) map<K,T> {
            $result = PyDict_New();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                K* key = new K(i->first);
                PyDict_SetItem($result,
                               SWIG_NewPointerObj((void *) key,
                                                  $descriptor(K *), 1),
                               CONVERT_TO(i->second));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    K* k;
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        CHECK(o))
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    K* k;
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (SWIG_ConvertPtr(key,(void **) &k,
                                        $descriptor(K *),0) != -1 &&
                        CHECK(o))
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        map();
        map(const map<K,T> &);
        
        %rename(__len__) size;
        unsigned int size() const;
        void clear();
        %extend {
            bool __nonzero__() {
                return !(self->empty());
            }
            T __getitem__(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(const K& key, T x) {
                (*self)[key] = x;
            }
            void __delitem__(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    self->erase(i);
                else
                    throw std::out_of_range("key not found");
            }
            bool has_key(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* keys() {
                PyObject* keyList = PyList_New(self->size());
                swig_type_info* type = SWIG_TypeQuery(#K " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* ptr = new K(i->first);
                    PyList_SetItem(keyList,j,
                                   SWIG_NewPointerObj((void *) ptr,type,1));
                }
                return keyList;
            }
            PyObject* values() {
                PyObject* valueList = PyList_New(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    PyList_SetItem(valueList,j,
                                   CONVERT_TO(i->second));
                }
                return valueList;
            }
            PyObject* items() {
                PyObject* itemList = PyList_New(self->size());
                swig_type_info* k_type = SWIG_TypeQuery(#K " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* k_ptr = new K(i->first);
                    PyObject* item = PyTuple_New(2);
                    PyTuple_SetItem(item,0,
                                    SWIG_NewPointerObj((void *) k_ptr,
                                                       k_type,1));
                    PyTuple_SetItem(item,1,
                                    CONVERT_TO(i->second));
                    PyList_SetItem(itemList,j,item);
                }
                return itemList;
            }
            // Python 2.2 methods
            bool __contains__(const K& key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* __iter__() {
                %#if PY_VERSION_HEX >= 0x02020000
                PyObject* keyList = PyList_New(self->size());
                swig_type_info* type = SWIG_TypeQuery(#K " *");
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    K* ptr = new K(i->first);
                    PyList_SetItem(keyList,j,
                                   SWIG_NewPointerObj((void *) ptr,type,1));
                }
                PyObject* iter = PyObject_GetIter(keyList);
                Py_DECREF(keyList);
                return iter;
                %#else
                throw std::runtime_error("Python 2.2 or later is needed"
                                         " for iterator support");
                %#endif
            }
        }
    };
    %enddef

    %define specialize_std_map_on_both(K,CHECK_K,CONVERT_K_FROM,CONVERT_K_TO,
                                       T,CHECK_T,CONVERT_T_FROM,CONVERT_T_TO)
    template<> class map<K,T> {
        %typemap(in) map<K,T> (std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                $1 = std::map<K,T >();
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                for (unsigned int i=0; i<size; i++) {
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK_K(key) && CHECK_T(o)) {
                        (($1_type &)$1)[CONVERT_K_FROM(key)] = 
                            CONVERT_T_FROM(o);
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $&1_descriptor,0) != -1) {
                $1 = *m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(in) const map<K,T>& (std::map<K,T> temp,
                                      std::map<K,T>* m),
                     const map<K,T>* (std::map<K,T> temp,
                                      std::map<K,T>* m) {
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                temp = std::map<K,T >();
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    PyObject* pair = PySequence_GetItem(items,i);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK_K(key) && CHECK_T(o)) {
                        temp[CONVERT_K_FROM(key)] = CONVERT_T_FROM(o);
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                    } else {
                        Py_DECREF(key);
                        Py_DECREF(o);
                        Py_DECREF(pair);
                        Py_DECREF(items);
                        PyErr_SetString(PyExc_TypeError,
                                        "map<" #K "," #T "> expected");
                        SWIG_fail;
                    }
                }
                Py_DECREF(items);
            } else if (SWIG_ConvertPtr($input,(void **) &m,
                                       $1_descriptor,0) != -1) {
                $1 = m;
            } else {
                PyErr_SetString(PyExc_TypeError,
                                "map<" #K "," #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(out) map<K,T> {
            $result = PyDict_New();
            for (std::map<K,T >::iterator i=$1.begin(); i!=$1.end(); ++i) {
                PyDict_SetItem($result,
                               CONVERT_K_TO(i->first),
                               CONVERT_T_TO(i->second));
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) map<K,T> {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK_K(key) && CHECK_T(o))
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_MAP) const map<K,T>&,
                                       const map<K,T>* {
            /* native sequence? */
            if (PyDict_Check($input)) {
                PyObject* items = PyMapping_Items($input);
                unsigned int size = PyList_Size(items);
                if (size == 0) {
                    /* an empty dictionary can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    PyObject* pair = PySequence_GetItem(items,0);
                    PyObject* key = PySequence_GetItem(pair,0);
                    PyObject* o = PySequence_GetItem(pair,1);
                    if (CHECK_K(key) && CHECK_T(o))
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(key);
                    Py_DECREF(o);
                    Py_DECREF(pair);
                }
                Py_DECREF(items);
            } else {
                /* wrapped map? */
                std::map<K,T >* m;
                if (SWIG_ConvertPtr($input,(void **) &m,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        map();
        map(const map<K,T> &);
        
        %rename(__len__) size;
        unsigned int size() const;
        void clear();
        %extend {
            bool __nonzero__() {
                return !(self->empty());
            }
            T __getitem__(K key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void __setitem__(K key, T x) {
                (*self)[key] = x;
            }
            void __delitem__(K key) {
                std::map<K,T >::iterator i = self->find(key);
                if (i != self->end())
                    self->erase(i);
                else
                    throw std::out_of_range("key not found");
            }
            bool has_key(K key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* keys() {
                PyObject* keyList = PyList_New(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    PyList_SetItem(keyList,j,
                                   CONVERT_K_TO(i->first));
                }
                return keyList;
            }
            PyObject* values() {
                PyObject* valueList = PyList_New(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    PyList_SetItem(valueList,j,
                                   CONVERT_T_TO(i->second));
                }
                return valueList;
            }
            PyObject* items() {
                PyObject* itemList = PyList_New(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    PyObject* item = PyTuple_New(2);
                    PyTuple_SetItem(item,0,
                                    CONVERT_K_TO(i->first));
                    PyTuple_SetItem(item,1,
                                    CONVERT_T_TO(i->second));
                    PyList_SetItem(itemList,j,item);
                }
                return itemList;
            }
             // Python 2.2 methods
            bool __contains__(K key) {
                std::map<K,T >::iterator i = self->find(key);
                return i != self->end();
            }
            PyObject* __iter__() {
                %#if PY_VERSION_HEX >= 0x02020000
                PyObject* keyList = PyList_New(self->size());
                std::map<K,T >::iterator i;
                unsigned int j;
                for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                    PyList_SetItem(keyList,j,
                                   CONVERT_K_TO(i->first));
                }
                PyObject* iter = PyObject_GetIter(keyList);
                Py_DECREF(keyList);
                return iter;
                %#else
                throw std::runtime_error("Python 2.2 or later is needed"
                                         " for iterator support");
                %#endif
            }
        }
    };
    %enddef

    specialize_std_map_on_key(bool,PyInt_Check,
                              PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_key(int,PyInt_Check,
                              PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_key(short,PyInt_Check,
                              PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_key(long,PyLong_Check,
                              PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_key(unsigned int,PyInt_Check,
                              PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_key(unsigned short,PyInt_Check,
                              PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_key(unsigned long,PyLong_Check,
                              PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_key(double,SwigNumber_Check,
                              SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_key(float,SwigNumber_Check,
                              SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_key(std::string,PyString_Check,
                              SwigString_AsString,SwigString_FromString);

    specialize_std_map_on_value(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_value(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_value(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_value(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_value(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_value(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_value(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_value(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_value(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_value(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);

    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               bool,PyInt_Check,
                               PyInt_AsLong,SwigInt_FromBool);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               long,PyLong_Check,
                               PyLong_AsLong,PyLong_FromLong);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               unsigned int,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               unsigned short,PyInt_Check,
                               PyInt_AsLong,PyInt_FromLong);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               unsigned long,PyLong_Check,
                               PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               double,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               float,SwigNumber_Check,
                               SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_map_on_both(std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString,
                               std::string,PyString_Check,
                               SwigString_AsString,SwigString_FromString);

}
