/* -----------------------------------------------------------------------------
 * std_vector.i
 *
 * SWIG typemaps for std::vector.
 * The Java proxy class extends java.util.AbstractList and implements
 * java.util.RandomAccess. The std::vector container looks and feels much like a
 * java.util.ArrayList from Java.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
#include <vector>
#include <stdexcept>
%}

%fragment("SWIG_VectorSize", "header", fragment="SWIG_JavaIntFromSize_t") {
SWIGINTERN jint SWIG_VectorSize(size_t size) {
  jint sz = SWIG_JavaIntFromSize_t(size);
  if (sz == -1)
    throw std::out_of_range("vector size is too large to fit into a Java int");
  return sz;
}
}

%define SWIG_STD_VECTOR_MINIMUM_INTERNAL(CTYPE, CONST_REFERENCE)
%typemap(kbase) std::vector< CTYPE > "java.util.AbstractList<$typemap(kboxtype, CTYPE)>"
%typemap(kinterfaces) std::vector< CTYPE > "java.util.RandomAccess"
// The kbody typemap is overridden as the base class needs an explicit super() call
// from the secondary constructor.
%typemap(kbody) std::vector< CTYPE > %{
  private var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  internal constructor(cPtr: Long, cMemoryOwn: Boolean) : super() {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}
%proxycode %{
  constructor(initialElements: Array<$typemap(kboxtype, CTYPE)>) : this() {
    doReserve(initialElements.size)

    for (element in initialElements) {
      doAdd(element)
    }
  }

  constructor(initialElements: Iterable<$typemap(kboxtype, CTYPE)>) : this() {
    for (element in initialElements) {
      doAdd(element)
    }
  }

  override fun get(index: Int): $typemap(kboxtype, CTYPE) {
    return doGet(index)
  }

  override fun set(index: Int, element: $typemap(kboxtype, CTYPE)): $typemap(kboxtype, CTYPE) {
    return doSet(index, element)
  }

  override fun add(element: $typemap(kboxtype, CTYPE)): Boolean {
    modCount++
    doAdd(element)
    return true
  }

  override fun add(index: Int, element: $typemap(kboxtype, CTYPE)) {
    modCount++
    doAdd(index, element)
  }

  override fun removeAt(index: Int): $typemap(kboxtype, CTYPE) {
    modCount++
    return doRemove(index)
  }

  override fun removeRange(fromIndex: Int, toIndex: Int) {
    modCount++
    doRemoveRange(fromIndex, toIndex)
  }

  override val size: Int
    get() = doSize()

  fun capacity(): Int {
    return doCapacity()
  }

  fun reserve(n: Int) {
    doReserve(n)
  }
%}

  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef CTYPE value_type;
    typedef CTYPE *pointer;
    typedef CTYPE const *const_pointer;
    typedef CTYPE &reference;
    typedef CONST_REFERENCE const_reference;

    vector();
    vector(const vector &other);

    %rename(isEmpty) empty;
    bool empty() const;
    void clear();
    %extend {
      %fragment("SWIG_VectorSize");

      vector(jint count, const CTYPE &value) throw (std::out_of_range) {
        if (count < 0)
          throw std::out_of_range("vector count must be positive");
        return new std::vector< CTYPE >(static_cast<std::vector< CTYPE >::size_type>(count), value);
      }

      jint doCapacity() throw (std::out_of_range) {
        return SWIG_VectorSize(self->capacity());
      }

      void doReserve(jint n) throw (std::length_error, std::out_of_range) {
        if (n < 0)
          throw std::out_of_range("vector reserve size must be positive");
        self->reserve(n);
      }

      jint doSize() const throw (std::out_of_range) {
        return SWIG_VectorSize(self->size());
      }

      void doAdd(const value_type& x) {
        self->push_back(x);
      }

      void doAdd(jint index, const value_type& x) throw (std::out_of_range) {
        jint size = static_cast<jint>(self->size());
        if (0 <= index && index <= size) {
          self->insert(self->begin() + index, x);
        } else {
          throw std::out_of_range("vector index out of range");
        }
      }

      value_type doRemove(jint index) throw (std::out_of_range) {
        jint size = static_cast<jint>(self->size());
        if (0 <= index && index < size) {
          CTYPE const old_value = (*self)[index];
          self->erase(self->begin() + index);
          return old_value;
        } else {
          throw std::out_of_range("vector index out of range");
        }
      }

      CONST_REFERENCE doGet(jint index) throw (std::out_of_range) {
        jint size = static_cast<jint>(self->size());
        if (index >= 0 && index < size)
          return (*self)[index];
        else
          throw std::out_of_range("vector index out of range");
      }

      value_type doSet(jint index, const value_type& val) throw (std::out_of_range) {
        jint size = static_cast<jint>(self->size());
        if (index >= 0 && index < size) {
          CTYPE const old_value = (*self)[index];
          (*self)[index] = val;
          return old_value;
        }
        else
          throw std::out_of_range("vector index out of range");
      }

      void doRemoveRange(jint fromIndex, jint toIndex) throw (std::out_of_range) {
        jint size = static_cast<jint>(self->size());
        if (0 <= fromIndex && fromIndex <= toIndex && toIndex <= size) {
          self->erase(self->begin() + fromIndex, self->begin() + toIndex);
        } else {
          throw std::out_of_range("vector index out of range");
        }
      }
    }
%enddef

// isEmpty() and clear() are members of the Kotlin collection interfaces so need the override modifier
%kotlinmethodmodifiers std::vector::empty         "public override";
%kotlinmethodmodifiers std::vector::clear         "public override";
%kotlinmethodmodifiers std::vector::doCapacity    "private";
%kotlinmethodmodifiers std::vector::doReserve     "private";
%kotlinmethodmodifiers std::vector::doSize        "private";
%kotlinmethodmodifiers std::vector::doAdd         "private";
%kotlinmethodmodifiers std::vector::doGet         "private";
%kotlinmethodmodifiers std::vector::doSet         "private";
%kotlinmethodmodifiers std::vector::doRemove      "private";
%kotlinmethodmodifiers std::vector::doRemoveRange "private";

namespace std {

    template<class T> class vector {
        SWIG_STD_VECTOR_MINIMUM_INTERNAL(T, const value_type&)
    };

    // bool specialization
    template<> class vector<bool> {
        SWIG_STD_VECTOR_MINIMUM_INTERNAL(bool, bool)
    };
}

%define specialize_std_vector(T)
#warning "specialize_std_vector - specialization for type T no longer needed"
%enddef
