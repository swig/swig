// -*- C++ -*-
// SWIG typemaps for std::vector types
// Art Yerkes
// Modified from: Luigi Ballabio
// Apr 8, 2002
//
// Ocaml implementation

%include std_common.i

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
    template <class T> class vector {
    public:
        vector(unsigned int size = 0);
        vector(unsigned int size, const T& value);
        vector(const vector<T>&);
        unsigned int size() const;
        bool empty() const;
        void clear();
        void push_back(const T& x);
	T operator [] ( int f );
	vector <T> &operator = ( vector <T> &other );
	%extend {
	    void set( int i, T x ) {
		(*self)[i] = x;
	    }
	};
    };
};
