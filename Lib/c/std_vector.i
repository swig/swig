/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_vector.i
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
#include <vector>
#include <stdexcept>
%}

namespace std {
    
    template<class T> class vector {      
      public:
        typedef size_t size_type;
        typedef T value_type;
        typedef const value_type& const_reference;
        vector();
        vector(size_type n);
        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        bool empty() const;
        void clear();
        void push_back(const value_type& x);
        const_reference at(size_type i);
    };
    
    %define specialize_std_vector(T)
    template<> class vector<T> {
      public:
        typedef size_t size_type;
        typedef T value_type;
        vector();
        vector(size_type n);
        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        bool empty() const;
        void clear();
        void push_back(T x) { this->push_back(x); }
        T at(size_type i) { return this->at(i); }
    };
    %enddef
    
    specialize_std_vector(int);
    specialize_std_vector(bool);
    /*specialize_std_vector(long);
    specialize_std_vector(char);
    specialize_std_vector(double);
    specialize_std_vector(int*);
    specialize_std_vector(char*);*/
}

