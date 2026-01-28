/* -----------------------------------------------------------------------------
 * std_vector.i
 *
 * SWIG typemaps for std::vector
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
#include <vector>
#include <stdexcept>
%}

%inline %{
namespace swig {

// Minimal iterator-like implementation just sufficient to support range-based
// for loops.
//
// Note that we still provide postfix increment and operator==() for
// consistency with prefix increment and operator!=(), even though they are not
// needed, strictly speaking.
template <class T>
class vector_citer {
public:
    using vector = std::vector<T>;

    vector_citer(const vector* v, size_t idx) : v_{v}, idx_{idx} {}

    const T& operator*() const  { return v_->at(idx_); }

    vector_citer& operator++() { ++idx_; return *this; }
    vector_citer operator++(int) { vector_citer tmp = *this; ++idx_; return tmp; }

    bool operator==(const vector_citer& other) const { return idx_ == other.idx_ && v_ == other.v_; }
    bool operator!=(const vector_citer& other) const { return !(*this == other); }

private:
    const vector* v_;
    size_t idx_;
};

} // namespace swig
%}

// Rename operators to wrap them.
%rename(equal) swig::vector_citer::operator==;
%rename(not_equal) swig::vector_citer::operator!=;
%rename(pre_inc) swig::vector_citer::operator++();
%rename(post_inc) swig::vector_citer::operator++(int);

namespace std {

    template<class T> class vector {
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef T value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;

        vector();
        vector(const vector& other);

        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        bool empty() const;
        void clear();
        void push_back(const value_type& x);
        %extend {
            const_reference get(int i) const throw (std::out_of_range) {
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

            swig::vector_citer<T> begin() const { return swig::vector_citer<T>(self, 0); }
            swig::vector_citer<T> end() const { return swig::vector_citer<T>(self, self->size()); }
            swig::vector_citer<T> cbegin() const { return swig::vector_citer<T>(self, 0); }
            swig::vector_citer<T> cend() const { return swig::vector_citer<T>(self, self->size()); }
        }
    };

    // bool specialization
    template<> class vector<bool> {
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef bool value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef bool const_reference;

        vector();
        vector(size_type n);
        vector(const vector& other);

        size_type size() const;
        size_type capacity() const;
        void reserve(size_type n);
        bool empty() const;
        void clear();
        void push_back(bool x);
        %extend {
            bool get(int i) const throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            void set(int i, bool val) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    (*self)[i] = val;
                else
                    throw std::out_of_range("vector index out of range");
            }
        }
    };
}

// Macro to allow iterating over wrapped std::vector using range-based for loops.
%define SWIG_STD_VECTOR_ITERATOR(CTYPE)
    %template(vector_citer_ ## #@CTYPE) swig::vector_citer<CTYPE>;
%enddef
