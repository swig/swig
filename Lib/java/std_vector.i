/* -----------------------------------------------------------------------------
 * std_vector.i
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
#include <vector>
#include <stdexcept>
%}

%define SWIG_STD_VECTOR_MINIMUM_INTERNAL(CTYPE, CREF_TYPE)
    public:
        typedef size_t size_type;
        typedef CTYPE value_type;
        typedef CREF_TYPE const_reference;
        vector();
        vector(size_type n);
        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();
        %rename(add) push_back;
        void push_back(const value_type& x);
        %extend {
            CREF_TYPE get(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, const value_type& val) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = val;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
%enddef

namespace std {
    
    template<class T> class vector {
        SWIG_STD_VECTOR_MINIMUM_INTERNAL(T, const T&)
    };

    // bool specialization
    template<> class vector<bool> {
        SWIG_STD_VECTOR_MINIMUM_INTERNAL(bool, bool)
    };
}

%define specialize_std_vector(T)
#warning "specialize_std_vector - specialization for type T no longer needed"
%enddef

