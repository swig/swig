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

%javamethodmodifiers std::set::sizeImpl "private";
%javamethodmodifiers std::set::containsImpl "private";
%javamethodmodifiers std::set::removeImpl "private";
%javamethodmodifiers std::set::hasNextImpl "private";
%javamethodmodifiers std::set::begin "private";
%javamethodmodifiers std::set::end "private";

%rename(Iterator) std::set::iterator;
%nodefaultctor std::set::iterator;
%javamethodmodifiers std::set::iterator::incrementUnchecked "private";
%javamethodmodifiers std::set::iterator::derefUnchecked "private";
%javamethodmodifiers std::set::iterator::isNot "private";

namespace std {

template <class KeyType>
class set {

%typemap(javabase) std::set<KeyType> "java.util.AbstractSet<$typemap(jboxtype, KeyType)>"
%proxycode %{
  public $javaclassname(java.util.Collection<? extends $typemap(jboxtype, KeyType)> collection) {
    this();
    addAll(collection);
  }

  public int size() {
    return sizeImpl();
  }

  public boolean addAll(java.util.Collection<? extends $typemap(jboxtype, KeyType)> collection) {
    boolean didAddElement = false;
    for (Object object : collection) {
      didAddElement |= add(($typemap(jboxtype, KeyType))object);
    }

    return didAddElement;
  }

  public java.util.Iterator<$typemap(jboxtype, KeyType)> iterator() {
    return new java.util.Iterator<$typemap(jboxtype, KeyType)>() {
      private Iterator curr;
      private Iterator end;

      private java.util.Iterator<$typemap(jboxtype, KeyType)> init() {
        curr = $javaclassname.this.begin();
        end = $javaclassname.this.end();
        return this;
      }

      public $typemap(jboxtype, KeyType) next() {
        if (!hasNext()) {
          throw new java.util.NoSuchElementException();
        }

        // Save the current position, increment it,
        // then return the value at the position before the increment.
        final $typemap(jboxtype, KeyType) currValue = curr.derefUnchecked();
        curr.incrementUnchecked();
        return currValue;
      }

      public boolean hasNext() {
        return curr.isNot(end);
      }
    }.init();
  }

  public boolean containsAll(java.util.Collection<?> collection) {
    for (Object object : collection) {
      if (!contains(object)) {
        return false;
      }
    }

    return true;
  }

  public boolean contains(Object object) {
    if (!(object instanceof $typemap(jboxtype, KeyType))) {
      return false;
    }

    return containsImpl(($typemap(jboxtype, KeyType))object);
  }

  public boolean removeAll(java.util.Collection<?> collection) {
    boolean didRemoveElement = false;
    for (Object object : collection) {
      didRemoveElement |= remove(object);
    }

    return didRemoveElement;
  }

  public boolean remove(Object object) {
    if (!(object instanceof $typemap(jboxtype, KeyType))) {
      return false;
    }

    return removeImpl(($typemap(jboxtype, KeyType))object);
  }
%}

  public:

    struct iterator {
      %extend {
        void incrementUnchecked() {
          ++(*$self);
        }

        KeyType derefUnchecked() const {
          return **$self;
        }

        bool isNot(const iterator other) const {
          return (*$self != other);
        }
      }
    };

    set();
    set(const set<KeyType>&);

    %rename(isEmpty) empty;
    bool empty() const;
    void clear();
    iterator begin();
    iterator end();

    %extend {
      %fragment("SWIG_SetSize");

      // Returns whether item was inserted.
      bool add(const KeyType& key) {
        return self->insert(key).second;
      }

      // Returns whether set contains key.
      bool containsImpl(const KeyType& key) {
        return (self->count(key) > 0);
      }

      // Returns whether the item was erased.
      bool removeImpl(const KeyType& key) {
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

}  // namespace std