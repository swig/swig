/* -----------------------------------------------------------------------------
 * std_map.i
 *
 * SWIG typemaps for std::map
 * The Java proxy class extends java.util.AbstractMap. The std::map
 * container looks and feels much like a java.util.HashMap from Java.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>
%include <std_set.i>

// ------------------------------------------------------------------------
// std::map
// ------------------------------------------------------------------------

%{
#include <map>
#include <stdexcept>
%}

%fragment("SWIG_MapSize", "header", fragment="SWIG_JavaIntFromSize_t") {
  SWIGINTERN jint SWIG_MapSize(size_t size) {
    jint sz = SWIG_JavaIntFromSize_t(size);
    if (sz == -1) {
      throw std::out_of_range("map size is too large to fit into a Java int");
    }

    return sz;
  }
}

%javamethodmodifiers std::map::sizeImpl "private";
%javamethodmodifiers std::map::containsImpl "private";
%javamethodmodifiers std::map::getImpl "private";
%javamethodmodifiers std::map::putImpl "private";
%javamethodmodifiers std::map::removeImpl "private";

namespace std {

template<class KeyType, class ValueType, class Comparator = std::less<KeyType> > class map {

%typemap(javabase) std::map<KeyType, ValueType, Comparator>
    "java.util.AbstractMap<$typemap(jboxtype, KeyType), $typemap(jboxtype, ValueType)>"

%proxycode %{

  public int size() {
    return sizeImpl();
  }

  public boolean containsKey(Object object) {
    if (!(object instanceof $typemap(jboxtype, KeyType))) {
      return false;
    }

    return containsImpl(($typemap(jboxtype, KeyType))object);
  }

  public $typemap(jboxtype, ValueType) get(Object object) {
    if (!(object instanceof $typemap(jboxtype, KeyType))) {
      return null;
    }

    try {
      getImpl(($typemap(jboxtype, KeyType)) object);
    } catch (IndexOutOfBoundsException e) {}

    return null;
  }

  public $typemap(jboxtype, ValueType) put($typemap(jboxtype, KeyType) key,
                                           $typemap(jboxtype, ValueType) value) {
    try {
      $typemap(jboxtype, ValueType) oldValue = putImpl(key, value);
      return oldValue;
    } catch (IndexOutOfBoundsException e) {}

    return null;
  }

  public $typemap(jboxtype, ValueType) remove($typemap(jboxtype, KeyType) key) {
    try {
      $typemap(jboxtype, ValueType) oldValue = removeImpl(key);
      return oldValue;
    } catch (IndexOutOfBoundsException e) {}

    return null;
  }

  public java.util.Set<Entry<$typemap(jboxtype, KeyType), $typemap(jboxtype, ValueType)>> entrySet() {
    throw new RuntimeException("Stub");
  }
%}

  public:
    map();
    map(const map<KeyType, ValueType, Comparator >&);

    %rename(isEmpty) empty;
    bool empty() const;
    void clear();
    %extend {
      %fragment("SWIG_MapSize");

      jint sizeImpl() const throw (std::out_of_range) {
        return SWIG_MapSize(self->size());
      }

      bool containsImpl(const KeyType& key) {
        return (self->count(key) > 0);
      }

      const ValueType& getImpl(const KeyType& key) throw (std::out_of_range) {
        std::map<KeyType, ValueType, Comparator >::iterator itr = self->find(key);
        if (itr != self->end()) {
          return itr->second;
        } else {
          throw std::out_of_range("map::get() - key not found");
        }
      }

      ValueType putImpl(const KeyType& key, const ValueType& value) {
        std::map<KeyType, ValueType, Comparator >::iterator itr = self->find(key);
        if (itr != self->end()) {
          ValueType oldValue = itr->second;
          itr->second = value;
          return oldValue;
        } else {
          (*self)[key] = value;
          throw std::out_of_range("map::put() - no existing value for key");
        }
      }

      ValueType removeImpl(const KeyType& key) throw (std::out_of_range) {
        std::map<KeyType, ValueType, Comparator >::iterator itr = self->find(key);
        if (itr != self->end()) {
          ValueType oldValue = itr->second;
          self->erase(itr);
          return oldValue;
        } else {
          throw std::out_of_range("map::remove() - key not found");
        }
      }
    }
};

}
