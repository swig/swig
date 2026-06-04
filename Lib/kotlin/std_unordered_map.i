/* -----------------------------------------------------------------------------
 * std_unordered_map.i
 *
 * SWIG typemaps for std::unordered_map
 * The Java proxy class extends java.util.AbstractMap. The std::unordered_map
 * container looks and feels much like a java.util.HashMap from Java.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::unordered_map
// ------------------------------------------------------------------------

%{
#include <unordered_map>
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

%kotlinmethodmodifiers std::unordered_map::empty "public override";
%kotlinmethodmodifiers std::unordered_map::clear "public override";
%kotlinmethodmodifiers std::unordered_map::sizeImpl "private";
%kotlinmethodmodifiers std::unordered_map::containsImpl "private";
%kotlinmethodmodifiers std::unordered_map::putUnchecked "private";
%kotlinmethodmodifiers std::unordered_map::removeUnchecked "private";
%kotlinmethodmodifiers std::unordered_map::find "private";
%kotlinmethodmodifiers std::unordered_map::begin "private";
%kotlinmethodmodifiers std::unordered_map::end "private";

%rename(Iterator) std::unordered_map::iterator;
%nodefaultctor std::unordered_map::iterator;
%kotlinmethodmodifiers std::unordered_map::iterator::getNextUnchecked "internal";
%kotlinmethodmodifiers std::unordered_map::iterator::isNot "internal";
%kotlinmethodmodifiers std::unordered_map::iterator::getKey "internal";
%kotlinmethodmodifiers std::unordered_map::iterator::getValue "internal";
%kotlinmethodmodifiers std::unordered_map::iterator::setValue "internal";

namespace std {

template<class K, class T> class unordered_map {

%typemap(kbase) std::unordered_map<K, T>
    "java.util.AbstractMap<$typemap(kboxtype, K), $typemap(kboxtype, T)>"


%proxycode %{
  override val size: Int
    get() = sizeImpl()

  override fun containsKey(key: $typemap(kboxtype, K)): Boolean {
    return containsImpl(key)
  }

  override fun get(key: $typemap(kboxtype, K)): $typemap(kboxtype, T)? {
    val itr = find(key)
    if (itr.isNot(end())) {
      return itr.getValue()
    }
    return null
  }

  override fun put(key: $typemap(kboxtype, K), value: $typemap(kboxtype, T)): $typemap(kboxtype, T)? {
    val itr = find(key)
    if (itr.isNot(end())) {
      val oldValue = itr.getValue()
      itr.setValue(value)
      return oldValue
    }
    putUnchecked(key, value)
    return null
  }

  override fun remove(key: $typemap(kboxtype, K)): $typemap(kboxtype, T)? {
    val itr = find(key)
    if (itr.isNot(end())) {
      val oldValue = itr.getValue()
      removeUnchecked(itr)
      return oldValue
    }
    return null
  }

  override val entries: MutableSet<MutableMap.MutableEntry<$typemap(kboxtype, K), $typemap(kboxtype, T)>>
    get() {
      val setToReturn = HashSet<MutableMap.MutableEntry<$typemap(kboxtype, K), $typemap(kboxtype, T)>>()
      var itr = begin()
      val endItr = end()
      while (itr.isNot(endItr)) {
        setToReturn.add(object : MutableMap.MutableEntry<$typemap(kboxtype, K), $typemap(kboxtype, T)> {
          private val iterator = itr

          override val key: $typemap(kboxtype, K)
            get() = iterator.getKey()

          override val value: $typemap(kboxtype, T)
            get() = iterator.getValue()

          override fun setValue(newValue: $typemap(kboxtype, T)): $typemap(kboxtype, T) {
            val oldValue = iterator.getValue()
            iterator.setValue(newValue)
            return oldValue
          }
        })
        itr = itr.getNextUnchecked()
      }
      return setToReturn
    }
%}

  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef K key_type;
    typedef T mapped_type;
    typedef std::pair< const K, T > value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    unordered_map();
    unordered_map(const unordered_map& other);

    struct iterator {
      %typemap(kclassmodifiers) iterator "class"
      %extend {
        std::unordered_map< K, T >::iterator getNextUnchecked() {
          std::unordered_map< K, T >::iterator copy = (*$self);
          return ++copy;
        }

        bool isNot(iterator other) const {
          return (*$self != other);
        }

        K getKey() const {
          return (*$self)->first;
        }

        T getValue() const {
          return (*$self)->second;
        }

        void setValue(const T& newValue) {
          (*$self)->second = newValue;
        }
      }
    };

    %rename(isEmpty) empty;
    bool empty() const;
    void clear();
    iterator find(const K& key);
    iterator begin();
    iterator end();
    %extend {
      %fragment("SWIG_MapSize");

      jint sizeImpl() const throw (std::out_of_range) {
        return SWIG_MapSize(self->size());
      }

      bool containsImpl(const K& key) {
        return (self->count(key) > 0);
      }

      void putUnchecked(const K& key, const T& value) {
%#ifdef __cpp_lib_map_try_emplace
        (*self).insert_or_assign(key, value);
%#else
        (*self)[key] = value;
%#endif
      }

      void removeUnchecked(const std::unordered_map< K, T >::iterator itr) {
        self->erase(itr);
      }
    }
};

}
