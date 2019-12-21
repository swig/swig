/* -------------------------------------------------------------------------
 * std_vector.i
 *
 * SWIG typemaps for std::vector.
 *
 * Since Fortran doesn't allow overloading of operator() for array access, we
 * add `get` and `set` member functions for accessing the data. Note that by
 * default these use typemaps which translate C indexing into Fortran indexing
 * (element '1' is the first item, rather than '0'). (By setting a typemap
 * yourself before instantiating std::vector, you can change this behavior.)
 * Additionally, native Fortran integers are used by default for sizes and
 * indexes.
 *
 * See the documentation for more details.
 * ------------------------------------------------------------------------- */

%include "std_common.i"

%{
#include <vector>
%}

%define %swig_std_vector(CTYPE, CREF_TYPE)
  public:
    // Typedefs
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef CTYPE value_type;
    typedef CTYPE &reference;
    typedef CTYPE *pointer;
    typedef CTYPE const *const_pointer;
    typedef CREF_TYPE const_reference;

    // Typemaps for making std::vector feel more like native Fortran:
    // - Use Fortran 1-offset indexing
    %apply int FORTRAN_INDEX {size_type index,
                              size_type start_index,
                              size_type stop_index};
    // - Use native Fortran integers in proxy code
    %apply int FORTRAN_INT {size_type};

    // Constructors
    vector();
    vector(const vector<CTYPE>& other);
    vector(size_type count);
    vector(size_type count, CREF_TYPE v);

    // Accessors
    size_type size() const;
    size_type capacity() const;
    bool empty() const;

    CREF_TYPE front() const;
    CREF_TYPE back() const;

    // Modify
    void reserve(size_type count);
    void resize(size_type count);
    void resize(size_type count, CREF_TYPE v);
    void push_back(CREF_TYPE v);
    void pop_back();
    void clear();

    // Instantiate proxy code

    %extend {
      %fragment("SWIG_check_range");

      void set(size_type index, CREF_TYPE v) {
        SWIG_check_range(index, $self->size(),
                         "std::vector<" #CTYPE ">::set",
                         return);
        (*$self)[index] = v;
      }

      CREF_TYPE get(size_type index) {
        SWIG_check_range(index, $self->size(),
                         "std::vector<" #CTYPE ">::get",
                         return $self->front());
        return (*$self)[index];
      }

      void insert(size_type index, CREF_TYPE v)
      {
        SWIG_check_range(index, $self->size() + 1,
                         "std::vector<" #CTYPE ">::insert",
                         return);
        $self->insert($self->begin() + index, v);
      }

      void erase(size_type index)
      {
        SWIG_check_range(index, $self->size(),
                         "std::vector<" #CTYPE ">::remove",
                         return);
        $self->erase($self->begin() + index);
      }

      void erase(size_type start_index, size_type stop_index)
      {
        SWIG_check_range(start_index, stop_index + 1,
                         "std::vector<" #CTYPE ">::remove_range",
                         return);
        SWIG_check_range(stop_index, $self->size() + 1,
                         "std::vector<" #CTYPE ">::remove_range",
                         return);
        $self->erase($self->begin() + start_index, $self->begin() + stop_index);
      }
    }
%enddef

%define %swig_std_vector_extend_ref(CTYPE)
  %extend {
    CTYPE& front_ref() {
      return (*$self).front();
    }
    CTYPE& back_ref() {
      return (*$self).back();
    }
    CTYPE& get_ref(size_type index) {
      SWIG_check_range(index, $self->size(),
                       "std::vector<" #CTYPE ">::get_ref",
                       return $self->front());
      return (*$self)[index];
    }
  }
%enddef

namespace std {
  template<class T> class vector {
    %swig_std_vector(T, const T&)
    %swig_std_vector_extend_ref(T)
  };

  // bool specialization
  template<> class vector<bool> {
    %swig_std_vector(bool, bool)
  };
} // end namespace std

