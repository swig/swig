/* -----------------------------------------------------------------------------
 * std_vector.i
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
#include <vector>
#include <stdexcept>
%}

%define SWIG_STD_VECTOR_MINIMUM_INTERNAL(CTYPE, CREF_TYPE)
%typemap(javabase) std::vector<CTYPE> "java.util.AbstractList<$typemap(jboxtype, CTYPE)>"
%typemap(javainterfaces) std::vector<CTYPE> "java.util.RandomAccess"
%typemap(javacode) std::vector<CTYPE> %{
  public $javaclassname($typemap(jstype, CTYPE)[] initialElements) {
    this();
    for ($typemap(jstype, CTYPE) element : initialElements) {
      add(element);
    }
  }

  public $javaclassname(Iterable<$typemap(jboxtype, CTYPE)> initialElements) {
    this();
    for ($typemap(jstype, CTYPE) element : initialElements) {
      add(element);
    }
  }

  public $typemap(jboxtype, CTYPE) get(int index) {
    return doGet(index);
  }

  public $typemap(jboxtype, CTYPE) set(int index, $typemap(jboxtype, CTYPE) e) {
    return doSet(index, e);
  }

  public boolean add($typemap(jboxtype, CTYPE) e) {
    modCount++;
    doAdd(e);
    return true;
  }

  public void add(int index, $typemap(jboxtype, CTYPE) e) {
    modCount++;
    doAdd(index, e);
  }

  public $typemap(jboxtype, CTYPE) remove(int index) {
    modCount++;
    return doRemove(index);
  }

  protected void removeRange(int fromIndex, int toIndex) {
    modCount++;
    doRemoveRange(fromIndex, toIndex);
  }
%}

    public:
        typedef size_t size_type;
        typedef CTYPE value_type;
        typedef CREF_TYPE const_reference;
        vector();
        vector(size_type n);
        // Note that it returns int, and not size_type, for compatibility with
        // the signature of size() in Java interface.
        int size() const;
        size_type capacity() const;
        void reserve(size_type n);
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();
        %extend {
            void doAdd(const value_type& value) {
                self->push_back(value);
            }

            void doAdd(int index, const value_type& value) throw (std::out_of_range) {
                const int size = int(self->size());
                if (0 <= index && index <= size) {
                    self->insert(self->begin() + index, value);
                } else {
                    throw std::out_of_range("vector index out of range");
                }
            }
            value_type doRemove(int index) throw (std::out_of_range) {
                const int size = int(self->size());
                if (0 <= index && index < size) {
                    CTYPE const old_value = (*self)[index];
                    self->erase(self->begin() + index);
                    return old_value;
                } else {
                    throw std::out_of_range("vector index out of range");
                }
            }
            CREF_TYPE doGet(int i) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            value_type doSet(int i, const value_type& val) throw (std::out_of_range) {
                int size = int(self->size());
                if (i>=0 && i<size) {
                    CTYPE const old_value = (*self)[i];
                    (*self)[i] = val;
                    return old_value;
                }
                else
                    throw std::out_of_range("vector index out of range");
            }
            void doRemoveRange(int fromIndex, int toIndex) throw (std::out_of_range) {
                const int size = int(self->size());
                if (0 <= fromIndex && fromIndex <= toIndex && toIndex <= size) {
                    self->erase(self->begin() + fromIndex, self->begin() + toIndex);
                } else {
                    throw std::out_of_range("vector index out of range");
                }
            }
        }
%enddef

%javamethodmodifiers std::vector::doAdd         "private";
%javamethodmodifiers std::vector::doGet         "private";
%javamethodmodifiers std::vector::doSet         "private";
%javamethodmodifiers std::vector::doRemove      "private";
%javamethodmodifiers std::vector::doRemoveRange "private";

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

