//
// SWIG typemaps for std::vector types
// Luigi Ballabio
// Apr 8, 2002
//
// Python implementation

%include std_common.i
%include exception.i

// __getitem__ is required to raise an IndexError for for-loops to work
// other methods which can raise are made to throw an IndexError as well
%exception std::vector::__getitem__ {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::__setitem__ {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::__delitem__  {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::pop  {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}


// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// Python as much as possible, namely, to allow the user to pass and 
// be returned Python tuples or lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&), f(const std::vector<T>*):
//      the parameter being read-only, either a Python sequence or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter must be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f():
//      the vector is returned by copy; therefore, a Python sequence of T:s 
//      is returned which is most easily used in other Python functions
//   -- std::vector<T>& f(), std::vector<T>* f(), const std::vector<T>& f(),
//      const std::vector<T>* f():
//      the vector is returned by reference; therefore, a wrapped std::vector
//      is returned
// ------------------------------------------------------------------------

%{
#include <vector>
#include <algorithm>
#include <stdexcept>
%}

// exported class

namespace std {
    
    template<class T> class vector {
        %typemap(in) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $1.reserve(size);
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1) {
                        (($1_type &)$1).push_back(*x);
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        SWIG_fail;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&1_descriptor,0) != -1) {
                $1 = *v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(outv) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $result.reserve(size);
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1) {
                        (($type &)$result).push_back(*x);
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        throw SWIG_DIRECTOR_TYPE_MISMATCH(
                                                  "vector<" #T "> expected");
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&descriptor,1) != -1){
                $result = *v;
            } else {
                throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp.reserve(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1) {
                        temp.push_back(*x);
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        SWIG_fail;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $1_descriptor,0) != -1) {
                $1 = v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(outv) const vector<T>& (std::vector<T> temp,
                                         std::vector<T>* v),
                       const vector<T>* (std::vector<T> temp,
                                         std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp.reserve(size);
                $result = &temp;
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1) {
                        temp.push_back(*x);
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
	        	throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $descriptor,1) != -1){
                $result = v;
            } else {
                throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
            }
        }
        %typemap(out) vector<T> {
            $result = PyTuple_New($1.size());
            for (unsigned int i=0; i<$1.size(); i++) {
                T* ptr = new T((($1_type &)$1)[i]);
                PyTuple_SetItem($result,i,
                                SWIG_NewPointerObj((void *) ptr, 
                                                   $descriptor(T *), 1));
            }
        }
        %typemap(inv) vector<T> {
            $input = PyTuple_New($1.size());
            for (unsigned int i=0; i<$1.size(); i++) {
                T* ptr = new T((($1_type &)$1)[i]);
                PyTuple_SetItem($input,i,
                                SWIG_NewPointerObj((void *) ptr, 
                                                   $descriptor(T *), 1));
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            /* native sequence? */
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    PyObject* o = PySequence_GetItem($input,0);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(o);
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            /* native sequence? */
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T* x;
                    PyObject* o = PySequence_GetItem($input,0);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(o);
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, const T& value);
        vector(const vector<T> &);

        %rename(__len__) size;
        unsigned int size() const;
        void clear();
        %rename(append) push_back;
        void push_back(const T& x);
        %extend {
            bool __nonzero__() {
                return !(self->empty());
            }
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T& __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            std::vector<T> __getslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                std::vector<T > tmp;
                tmp.reserve(j-i);
                tmp.insert(tmp.begin(),self->begin()+i,self->begin()+j);
                return tmp;
            }
            void __setitem__(int i, const T& x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setslice__(int i, int j, const std::vector<T>& v) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                if (int(v.size()) == j-i) {
                    std::copy(v.begin(),v.end(),self->begin()+i);
                } else {
                    self->erase(self->begin()+i,self->begin()+j);
                    if (i+1 <= int(self->size())) {
                        self->insert(self->begin()+i,v.begin(),v.end());
                    } else {
                        self->insert(self->end(),v.begin(),v.end());
	            }
                }
            }
            void __delitem__(int i) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    self->erase(self->begin()+i);
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __delslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                self->erase(self->begin()+i,self->begin()+j);
            }
        }
    };


    // Partial specialization for vectors of pointers.  [ beazley ]

    template<class T> class vector<T*> {
        %typemap(in) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $1 = std::vector<T >(size);
                for (unsigned int i=0; i<size; i++) {
                    T x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T),0)) != -1) {
                        (($1_type &)$1)[i] = x;
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        SWIG_fail;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&1_descriptor,0) != -1) {
                $1 = *v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(outv) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $result = std::vector<T >(size);
                for (unsigned int i=0; i<size; i++) {
                    T x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T),0)) != -1) {
                        (($type &)$result)[i] = x;
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&descriptor,1) != -1){
                $result = *v;
            } else {
                throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp = std::vector<T >(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    T x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T),0)) != -1) {
                        temp[i] = x;
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        SWIG_fail;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $1_descriptor,0) != -1) {
                $1 = v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(outv) const vector<T>& (std::vector<T> temp,
                                         std::vector<T>* v),
                       const vector<T>* (std::vector<T> temp,
                                         std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp = std::vector<T >(size);
                $result = &temp;
                for (unsigned int i=0; i<size; i++) {
                    T x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T),0)) != -1) {
                        temp[i] = x;
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $descriptor,1) != -1){
                $result = v;
            } else {
                throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
            }
        }
        %typemap(out) vector<T> {
            $result = PyTuple_New($1.size());
            for (unsigned int i=0; i<$1.size(); i++) {
                T ptr = (($1_type &)$1)[i];
                PyTuple_SetItem($result,i,
                                SWIG_NewPointerObj((void *) ptr, 
                                                   $descriptor(T), 0));
            }
        }
        %typemap(inv) vector<T> {
            $input = PyTuple_New($1_name.size());
            for (unsigned int i=0; i<$1_name.size(); i++) {
                T ptr = (($1_type &)$1)[i];
                PyTuple_SetItem($input,i,
                                SWIG_NewPointerObj((void *) ptr, 
                                                   $descriptor(T), 0));
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            /* native sequence? */
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T x;
                    PyObject* o = PySequence_GetItem($input,0);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(o);
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            /* native sequence? */
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    T x;
                    PyObject* o = PySequence_GetItem($input,0);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T),0)) != -1)
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(o);
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, const T& value);
        vector(const vector<T> &);

        %rename(__len__) size;
        unsigned int size() const;
        void clear();
        %rename(append) push_back;
        void push_back(T x);
        %extend {
            bool __nonzero__() {
                return !(self->empty());
            }
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T  __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            std::vector<T> __getslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                std::vector<T > tmp(j-i);
                std::copy(self->begin()+i,self->begin()+j,tmp.begin());
                return tmp;
            }
            void __setitem__(int i, const T& x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setslice__(int i, int j, const std::vector<T>& v) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                if (int(v.size()) == j-i) {
                    std::copy(v.begin(),v.end(),self->begin()+i);
                } else {
                    self->erase(self->begin()+i,self->begin()+j);
                    if (i+1 <= int(self->size()))
                        self->insert(self->begin()+i,v.begin(),v.end());
                    else
                        self->insert(self->end(),v.begin(),v.end());
                }
            }
            void __delitem__(int i) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    self->erase(self->begin()+i);
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __delslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                self->erase(self->begin()+i,self->begin()+j);
            }
        }
    };

    // specializations for built-ins

    %define specialize_std_vector(T,CHECK,CONVERT_FROM,CONVERT_TO)
    template<> class vector<T> {
        %typemap(in) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $1 = std::vector<T >(size);
                for (unsigned int i=0; i<size; i++) {
                    PyObject* o = PySequence_GetItem($input,i);
                    if (CHECK(o)) {
                        (($1_type &)$1)[i] = (T)(CONVERT_FROM(o));
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        SWIG_fail;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&1_descriptor,1) != -1){
                $1 = *v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(outv) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $result = std::vector<T >(size);
                for (unsigned int i=0; i<size; i++) {
                    PyObject* o = PySequence_GetItem($input,i);
                    if (CHECK(o)) {
                        (($type &)$result)[i] = (T)(CONVERT_FROM(o));
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&descriptor,1) != -1){
                $result = *v;
            } else {
                throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp = std::vector<T >(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    PyObject* o = PySequence_GetItem($input,i);
                    if (CHECK(o)) {
                        temp[i] = (T)(CONVERT_FROM(o));
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        SWIG_fail;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $1_descriptor,1) != -1){
                $1 = v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                SWIG_fail;
            }
        }
        %typemap(outv) const vector<T>& (std::vector<T> temp,
                                         std::vector<T>* v),
                       const vector<T>* (std::vector<T> temp,
                                         std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp = std::vector<T >(size);
                $result = &temp;
                for (unsigned int i=0; i<size; i++) {
                    PyObject* o = PySequence_GetItem($input,i);
                    if (CHECK(o)) {
                        temp[i] = (T)(CONVERT_FROM(o));
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                	throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $descriptor,1) != -1){
                $result = v;
            } else {
                throw SWIG_DIRECTOR_TYPE_MISMATCH("vector<" #T "> expected");
            }
        }
        %typemap(out) vector<T> {
            $result = PyTuple_New($1.size());
            for (unsigned int i=0; i<$1.size(); i++)
                PyTuple_SetItem($result,i,
                                CONVERT_TO((($1_type &)$1)[i]));
        }
        %typemap(inv) vector<T> {
            $input = PyTuple_New($1_name.size());
            for (unsigned int i=0; i<$1_name.size(); i++)
                PyTuple_SetItem($input,i,
                                CONVERT_TO((($1_type &)$1_name)[i]));
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) vector<T> {
            /* native sequence? */
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    PyObject* o = PySequence_GetItem($input,0);
                    if (CHECK(o))
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(o);
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_VECTOR) const vector<T>&,
                                          const vector<T>* {
            /* native sequence? */
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                if (size == 0) {
                    /* an empty sequence can be of any type */
                    $1 = 1;
                } else {
                    /* check the first element only */
                    PyObject* o = PySequence_GetItem($input,0);
                    if (CHECK(o))
                        $1 = 1;
                    else
                        $1 = 0;
                    Py_DECREF(o);
                }
            } else {
                /* wrapped vector? */
                std::vector<T >* v;
                if (SWIG_ConvertPtr($input,(void **) &v, 
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
      public:
        vector(unsigned int size = 0);
        vector(unsigned int size, const T& value);
        vector(const vector<T> &);
        %rename(__len__) size;
        unsigned int size() const;
        %rename(__nonzero__) empty;
        bool empty() const;
        void clear();
        %rename(append) push_back;
        void push_back(T x);
        %extend {
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            std::vector<T> __getslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                std::vector<T > tmp(j-i);
                std::copy(self->begin()+i,self->begin()+j,tmp.begin());
                return tmp;
            }
            void __setitem__(int i, T x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setslice__(int i, int j, const std::vector<T>& v) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                if (int(v.size()) == j-i) {
                    std::copy(v.begin(),v.end(),self->begin()+i);
                } else {
                    self->erase(self->begin()+i,self->begin()+j);
                    if (i+1 <= int(self->size()))
                        self->insert(self->begin()+i,v.begin(),v.end());
                    else
                        self->insert(self->end(),v.begin(),v.end());
                }
            }
            void __delitem__(int i) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    self->erase(self->begin()+i);
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __delslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                self->erase(self->begin()+i,self->begin()+j);
            }
        }
    };
    %enddef

    specialize_std_vector(bool,PyInt_Check,PyInt_AsLong,SwigInt_FromBool);
    specialize_std_vector(int,PyInt_Check,PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(short,PyInt_Check,PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(long,PyLong_Check,PyLong_AsLong,PyLong_FromLong);
    specialize_std_vector(unsigned int,PyInt_Check,\
                          PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(unsigned short,PyInt_Check,\
                          PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(unsigned long,PyLong_Check,\
                          PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_vector(double,SwigNumber_Check,\
                          SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_vector(float,SwigNumber_Check,\
                          SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_vector(std::string,PyString_Check,\
                          SwigString_AsString,SwigString_FromString);

}

