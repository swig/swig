// -*- C++ -*-
// SWIG typemaps for std::vector types
// Art Yerkes
// Modified from: Luigi Ballabio
// Apr 8, 2002
//
// Ocaml implementation

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
    };
    
    
    // Partial specialization for vectors of pointers.  [ beazley ]
    
    template<class T> class vector<T*> {
    };

}
