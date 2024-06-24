/* -----------------------------------------------------------------------------
 * std_vector.i
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
#include <vector>
#include <stdexcept>
%}


%define SWIG_STD_VECTOR_INTERNAL(CTYPE, CONST_REFERENCE)
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef CTYPE value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef CTYPE& reference;
        typedef CONST_REFERENCE const_reference;

        vector();
        vector(size_type n);
        vector(const vector& other);

        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();
        %rename(add) push_back;
        void push_back(const value_type& x);
        %extend {
            CONST_REFERENCE get(int i) throw (std::out_of_range) {
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
        SWIG_STD_VECTOR_INTERNAL(T, const value_type&)
    };

    // bool specialization
    template<> class vector<bool> {
        SWIG_STD_VECTOR_INTERNAL(bool, bool)
    };
}

%define specialize_std_vector(T)
#warning "specialize_std_vector - specialization for type T no longer needed"
%enddef

