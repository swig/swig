//
// SWIG typemaps for std::pair
// Luigi Ballabio
// July 2003
//
// Python implementation

%include std_common.i
%include exception.i


// ------------------------------------------------------------------------
// std::pair
//
// See std_vector.i for the rationale of typemap application
// ------------------------------------------------------------------------

%{
#include <utility>
%}

// exported class

namespace std {

    template<class T, class U> struct pair {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                T* x;
                U* y;
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (SWIG_ConvertPtr(first,(void **) &x,
                                    $descriptor(T *),0) != -1 &&
                    SWIG_ConvertPtr(second,(void **) &y,
                                    $descriptor(U *),0) != -1) {
                    $1 = std::make_pair(x,y);
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $&1_descriptor,0) != -1) {
                $1 = *p;
            } else {
                SWIG_exception(SWIG_TypeError, 
                               "pair<" #T "," #U "> expected");
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                T* x;
                U* y;
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (SWIG_ConvertPtr(first,(void **) &x,
                                    $descriptor(T *),0) != -1 &&
                    SWIG_ConvertPtr(second,(void **) &y,
                                    $descriptor(U *),0) != -1) {
                    temp = std::make_pair(x,y);
                    $1 = &temp;
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $1_descriptor,0) != -1) {
                $1 = p;
            } else {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
            }
        }
        %typemap(out) pair<T,U> {
            $result = PyTuple_New(2);
            T* x = new T($1.first);
            U* y = new U($1.second);
            PyTuple_SetItem($result,0,
                            SWIG_NewPointerObj((void *) x, 
                                               $descriptor(T *), 1));
            PyTuple_SetItem($result,1,
                            SWIG_NewPointerObj((void *) y, 
                                               $descriptor(U *), 1));
        }
        %typecheck(SWIG_TYPECHECK_PAIR) pair<T,U> {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    T* x;
                    U* y;
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_PAIR) const pair<T,U>&,
                                        const pair<T,U>* {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    T* x;
                    U* y;
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        T first;
        U second;
    };


    // specializations for built-ins

    %define specialize_std_pair_on_first(T,CHECK,CONVERT_FROM,CONVERT_TO)
    template<class U> struct pair<T,U> {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                U* y;
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (CHECK(first) &&
                    SWIG_ConvertPtr(second,(void **) &y,
                                    $descriptor(U *),0) != -1) {
                    $1 = std::make_pair(CONVERT_FROM(first),y);
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $&1_descriptor,0) != -1) {
                $1 = *p;
            } else {
                SWIG_exception(SWIG_TypeError, 
                               "pair<" #T "," #U "> expected");
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                U* y;
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (CHECK(first) && 
                    SWIG_ConvertPtr(second,(void **) &y,
                                    $descriptor(U *),0) != -1) {
                    temp = std::make_pair(CONVERT_FROM(first),y);
                    $1 = &temp;
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $1_descriptor,0) != -1) {
                $1 = p;
            } else {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
            }
        }
        %typemap(out) pair<T,U> {
            $result = PyTuple_New(2);
            U* y = new U($1.second);
            PyTuple_SetItem($result,0,CONVERT_TO($1.first));
            PyTuple_SetItem($result,1,
                            SWIG_NewPointerObj((void *) y, 
                                               $descriptor(U *), 1));
        }
        %typecheck(SWIG_TYPECHECK_PAIR) pair<T,U> {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    U* y;
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (CHECK(first) && 
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_PAIR) const pair<T,U>&,
                                        const pair<T,U>* {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    U* y;
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (CHECK(first) && 
                        SWIG_ConvertPtr(second,(void **) &y,
                                        $descriptor(U *),0) != -1) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        T first;
        U second;
    };
    %enddef

    %define specialize_std_pair_on_second(U,CHECK,CONVERT_FROM,CONVERT_TO)
    template<class T> struct pair<T,U> {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                T* x;
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (SWIG_ConvertPtr(first,(void **) &x,
                                    $descriptor(T *),0) != -1 &&
                    CHECK(second)) {
                    $1 = std::make_pair(x,CONVERT_FROM(second));
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $&1_descriptor,0) != -1) {
                $1 = *p;
            } else {
                SWIG_exception(SWIG_TypeError, 
                               "pair<" #T "," #U "> expected");
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                T* x;
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (SWIG_ConvertPtr(first,(void **) &x,
                                    $descriptor(T *),0) != -1 &&
                    CHECK(second)) {
                    temp = std::make_pair(x,CONVERT_FROM(second));
                    $1 = &temp;
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $1_descriptor,0) != -1) {
                $1 = p;
            } else {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
            }
        }
        %typemap(out) pair<T,U> {
            $result = PyTuple_New(2);
            T* x = new T($1.first);
            PyTuple_SetItem($result,0,
                            SWIG_NewPointerObj((void *) x, 
                                               $descriptor(T *), 1));
            PyTuple_SetItem($result,1,CONVERT_TO($1.second));
        }
        %typecheck(SWIG_TYPECHECK_PAIR) pair<T,U> {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    T* x;
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        CHECK(second)) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_PAIR) const pair<T,U>&,
                                        const pair<T,U>* {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    T* x;
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (SWIG_ConvertPtr(first,(void **) &x,
                                        $descriptor(T *),0) != -1 &&
                        CHECK(second)) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        T first;
        U second;
    };
    %enddef

    %define specialize_std_pair_on_both(T,CHECK_T,CONVERT_T_FROM,CONVERT_T_TO,
                                        U,CHECK_U,CONVERT_U_FROM,CONVERT_U_TO)
    template<> struct pair<T,U> {
        %typemap(in) pair<T,U> (std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (CHECK_T(first) && CHECK_U(second)) {
                    $1 = std::make_pair(CONVERT_T_FROM(first),
                                        CONVERT_U_FROM(second));
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $&1_descriptor,0) != -1) {
                $1 = *p;
            } else {
                SWIG_exception(SWIG_TypeError, 
                               "pair<" #T "," #U "> expected");
            }
        }
        %typemap(in) const pair<T,U>& (std::pair<T,U> temp,
                                       std::pair<T,U>* p),
                     const pair<T,U>* (std::pair<T,U> temp,
                                       std::pair<T,U>* p) {
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
                PyObject* first = PySequence_GetItem($input,0);
                PyObject* second = PySequence_GetItem($input,1);
                if (CHECK_T(first) && CHECK_U(second)) {
                    temp = std::make_pair(CONVERT_T_FROM(first),
                                          CONVERT_U_FROM(second));
                    $1 = &temp;
                    Py_DECREF(first);
                    Py_DECREF(second);
                } else {
                    Py_DECREF(first);
                    Py_DECREF(second);
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
                }
            } else if (SWIG_ConvertPtr($input,(void **) &p,
                                       $1_descriptor,0) != -1) {
                $1 = p;
            } else {
                    SWIG_exception(SWIG_TypeError, 
                                   "pair<" #T "," #U "> expected");
            }
        }
        %typemap(out) pair<T,U> {
            $result = PyTuple_New(2);
            PyTuple_SetItem($result,0,CONVERT_T_TO($1.first));
            PyTuple_SetItem($result,1,CONVERT_U_TO($1.second));
        }
        %typecheck(SWIG_TYPECHECK_PAIR) pair<T,U> {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (CHECK_T(first) && CHECK_U(second)) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $&1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        %typecheck(SWIG_TYPECHECK_PAIR) const pair<T,U>&,
                                        const pair<T,U>* {
            /* native sequence? */
            if (PyTuple_Check($input)) {
                if (PyTuple_Size($input) != 2) {
                    /* not a pair anyway */
                    $1 = 0;
                } else {
                    PyObject* first = PySequence_GetItem($input,0);
                    PyObject* second = PySequence_GetItem($input,1);
                    if (CHECK_T(first) && CHECK_U(second)) {
                        $1 = 1;
                    } else {
                        $1 = 0;
                    }
                }
            } else {
                /* wrapped pair? */
                std::pair<T,U >* p;
                if (SWIG_ConvertPtr($input,(void **) &p,
                                    $1_descriptor,0) != -1)
                    $1 = 1;
                else
                    $1 = 0;
            }
        }
        T first;
        U second;
    };
    %enddef

    specialize_std_pair_on_first(bool,PyInt_Check,
                                 PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_first(int,PyInt_Check,
                                 PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_first(short,PyInt_Check,
                                 PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_first(long,PyLong_Check,
                                 PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_first(unsigned int,PyInt_Check,
                                 PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_first(unsigned short,PyInt_Check,
                                 PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_first(unsigned long,PyLong_Check,
                                 PyLong_AsUnsignedLong,
                                 PyLong_FromUnsignedLong);
    specialize_std_pair_on_first(double,SwigNumber_Check,
                                 SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_first(float,SwigNumber_Check,
                                 SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_first(std::string,PyString_Check,
                                 SwigString_AsString,SwigString_FromString);

    specialize_std_pair_on_second(bool,PyInt_Check,
                                  PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_second(int,PyInt_Check,
                                  PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_second(short,PyInt_Check,
                                  PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_second(long,PyLong_Check,
                                  PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_second(unsigned int,PyInt_Check,
                                  PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_second(unsigned short,PyInt_Check,
                                  PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_second(unsigned long,PyLong_Check,
                                  PyLong_AsUnsignedLong,
                                  PyLong_FromUnsignedLong);
    specialize_std_pair_on_second(double,SwigNumber_Check,
                                  SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_second(float,SwigNumber_Check,
                                  SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_second(std::string,PyString_Check,
                                  SwigString_AsString,SwigString_FromString);

    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                bool,PyInt_Check,
                                PyInt_AsLong,SwigInt_FromBool);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                long,PyLong_Check,
                                PyLong_AsLong,PyLong_FromLong);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                unsigned int,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                unsigned short,PyInt_Check,
                                PyInt_AsLong,PyInt_FromLong);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                unsigned long,PyLong_Check,
                                PyLong_AsUnsignedLong,PyLong_FromUnsignedLong);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                double,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                float,SwigNumber_Check,
                                SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_pair_on_both(std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString,
                                std::string,PyString_Check,
                                SwigString_AsString,SwigString_FromString);

}
