/* -----------------------------------------------------------------------------
 * std_unordered_set.i
 *
 * SWIG typemaps for std::unordered_set
 * The Java proxy class extends java.util.AbstractSet. The std::unordered_set
 * container looks and feels much like a java.util.HashSet from Java.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::unordered_set
// ------------------------------------------------------------------------

%{
#include <unordered_set>
#include <stdexcept>
%}

%fragment("SWIG_UnorderedSetSize", "header", fragment="SWIG_JavaIntFromSize_t") {
  SWIGINTERN jint SWIG_UnorderedSetSize(size_t size) {
    jint sz = SWIG_JavaIntFromSize_t(size);
    if (sz == -1) {
      throw std::out_of_range("unordered_set size is too large to fit into a Java int");
    }

    return sz;
  }
}

%kotlinmethodmodifiers std::unordered_set::add "public override";
%kotlinmethodmodifiers std::unordered_set::empty "public override";
%kotlinmethodmodifiers std::unordered_set::clear "public override";
%kotlinmethodmodifiers std::unordered_set::sizeImpl "private";
%kotlinmethodmodifiers std::unordered_set::containsImpl "private";
%kotlinmethodmodifiers std::unordered_set::removeImpl "private";
%kotlinmethodmodifiers std::unordered_set::hasNextImpl "private";
%kotlinmethodmodifiers std::unordered_set::begin "private";
%kotlinmethodmodifiers std::unordered_set::end "private";

%rename(Iterator) std::unordered_set::iterator;
%nodefaultctor std::unordered_set::iterator;
%kotlinmethodmodifiers std::unordered_set::iterator::incrementUnchecked "internal";
%kotlinmethodmodifiers std::unordered_set::iterator::derefUnchecked "internal";
%kotlinmethodmodifiers std::unordered_set::iterator::isNot "internal";

namespace std {

template <class Key>
class unordered_set {

%typemap(kbase) std::unordered_set<Key> "java.util.AbstractSet<$typemap(kboxtype, Key)>"

// The kbody typemap is overridden as the base class needs an explicit super() call
// from the secondary constructor.
%typemap(kbody) std::unordered_set<Key> %{
  private var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  internal constructor(cPtr: Long, cMemoryOwn: Boolean) : super() {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}

%proxycode %{
  constructor(collection: java.util.Collection<$typemap(kboxtype, Key)>) : this() {
    for (element in collection) {
      add(element)
    }
  }

  override val size: Int
    get() = sizeImpl()

  override fun iterator(): MutableIterator<$typemap(kboxtype, Key)> {
    return object : MutableIterator<$typemap(kboxtype, Key)> {
      private var curr = this@$kotlinclassname.begin()
      private val end = this@$kotlinclassname.end()

      override fun next(): $typemap(kboxtype, Key) {
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

  override fun contains(element: $typemap(kboxtype, Key)): Boolean {
    return containsImpl(element)
  }

  override fun remove(element: $typemap(kboxtype, Key)): Boolean {
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

        Key derefUnchecked() const {
          return **$self;
        }

        bool isNot(iterator other) const {
          return (*$self != other);
        }
      }
    };

    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef Key value_type;
    typedef Key key_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    unordered_set();
    unordered_set(const unordered_set& other);

    %rename(isEmpty) empty;
    bool empty() const;
    void clear();
    iterator begin();
    iterator end();

    %extend {
      %fragment("SWIG_UnorderedSetSize");

      // Returns whether item was inserted.
      bool add(const Key& key) {
        return self->insert(key).second;
      }

      // Returns whether set contains key.
      bool containsImpl(const Key& key) {
        return (self->count(key) > 0);
      }

      // Returns whether the item was erased.
      bool removeImpl(const Key& key) {
        return (self->erase(key) > 0);
      }

      jint sizeImpl() const throw (std::out_of_range) {
        return SWIG_UnorderedSetSize(self->size());
      }

      bool hasNextImpl(const iterator& itr) const {
        return (itr != $self->end());
      }
    }
};

}
