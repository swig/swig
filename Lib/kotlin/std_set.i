/* -----------------------------------------------------------------------------
 * std_set.i
 *
 * SWIG typemaps for std::set
 * The Java proxy class extends java.util.AbstractSet. The std::set
 * container looks and feels much like a java.util.HashSet from Java.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::set
// ------------------------------------------------------------------------

%{
#include <set>
#include <stdexcept>
%}

%fragment("SWIG_SetSize", "header", fragment="SWIG_JavaIntFromSize_t") {
  SWIGINTERN jint SWIG_SetSize(size_t size) {
    jint sz = SWIG_JavaIntFromSize_t(size);
    if (sz == -1) {
      throw std::out_of_range("set size is too large to fit into a Java int");
    }

    return sz;
  }
}

%kotlinmethodmodifiers std::set::empty "public override";
%kotlinmethodmodifiers std::set::clear "public override";
%kotlinmethodmodifiers std::set::sizeImpl "private";
%kotlinmethodmodifiers std::set::containsImpl "private";
%kotlinmethodmodifiers std::set::removeImpl "private";
%kotlinmethodmodifiers std::set::hasNextImpl "private";
%kotlinmethodmodifiers std::set::begin "private";
%kotlinmethodmodifiers std::set::end "private";

%rename(Iterator) std::set::iterator;
%nodefaultctor std::set::iterator;
%kotlinmethodmodifiers std::set::iterator::incrementUnchecked "internal";
%kotlinmethodmodifiers std::set::iterator::derefUnchecked "internal";
%kotlinmethodmodifiers std::set::iterator::isNot "internal";

namespace std {

template <class T>
class set {

%typemap(kbase) std::set<T> "java.util.AbstractSet<$typemap(kboxtype, T)>"

// The kbody typemap is overridden as the base class needs an explicit super() call
// from the secondary constructor.
%typemap(kbody) std::set<T> %{
  private var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  internal constructor(cPtr: Long, cMemoryOwn: Boolean) : super() {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}

%proxycode %{
  constructor(collection: java.util.Collection<$typemap(kboxtype, T)>) : this() {
    for (element in collection) {
      add(element)
    }
  }

  override val size: Int
    get() = sizeImpl()

  override fun add(element: $typemap(kboxtype, T)): Boolean {
    return addImpl(element)
  }

  override fun iterator(): MutableIterator<$typemap(kboxtype, T)> {
    return object : MutableIterator<$typemap(kboxtype, T)> {
      private var curr = this@$kotlinclassname.begin()
      private val end = this@$kotlinclassname.end()

      override fun next(): $typemap(kboxtype, T) {
        if (!hasNext()) {
          throw NoSuchElementException()
        }

        // Save the current position, increment it,
        // then return the value at the position before the increment.
        val currValue = curr.derefUnchecked()
        curr.incrementUnchecked()
        return currValue
      }

      override fun hasNext(): Boolean {
        return curr.isNot(end)
      }

      override fun remove() {
        throw UnsupportedOperationException()
      }
    }
  }

  override fun contains(element: $typemap(kboxtype, T)): Boolean {
    return containsImpl(element)
  }

  override fun remove(element: $typemap(kboxtype, T)): Boolean {
    return removeImpl(element)
  }
%}

  public:

    struct iterator {
      %typemap(kclassmodifiers) iterator "class"
      %extend {
        void incrementUnchecked() {
          ++(*$self);
        }

        T derefUnchecked() const {
          return **$self;
        }

        bool isNot(iterator other) const {
          return (*$self != other);
        }
      }
    };

    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T key_type;
    typedef T value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    set();
    set(const set& other);

    %rename(isEmpty) empty;
    bool empty() const;
    void clear();
    iterator begin();
    iterator end();

    %extend {
      %fragment("SWIG_SetSize");

      // Returns whether item was inserted.
      bool addImpl(const T& key) {
        return self->insert(key).second;
      }

      // Returns whether set contains key.
      bool containsImpl(const T& key) {
        return (self->count(key) > 0);
      }

      // Returns whether the item was erased.
      bool removeImpl(const T& key) {
        return (self->erase(key) > 0);
      }

      jint sizeImpl() const throw (std::out_of_range) {
        return SWIG_SetSize(self->size());
      }

      bool hasNextImpl(const iterator& itr) const {
        return (itr != $self->end());
      }
    }
};

}
