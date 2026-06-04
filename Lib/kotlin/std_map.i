/* -----------------------------------------------------------------------------
 * std_map.i
 *
 * SWIG typemaps for std::map
 * The Java proxy class extends java.util.AbstractMap. The std::map
 * container looks and feels much like a java.util.HashMap from Java.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

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

%kotlinmethodmodifiers std::map::empty "public override";
%kotlinmethodmodifiers std::map::clear "public override";
%kotlinmethodmodifiers std::map::sizeImpl "private";
%kotlinmethodmodifiers std::map::containsImpl "private";
%kotlinmethodmodifiers std::map::putUnchecked "private";
%kotlinmethodmodifiers std::map::removeUnchecked "private";
%kotlinmethodmodifiers std::map::find "private";
%kotlinmethodmodifiers std::map::begin "private";
%kotlinmethodmodifiers std::map::end "private";

%rename(Iterator) std::map::iterator;
%nodefaultctor std::map::iterator;
%kotlinmethodmodifiers std::map::iterator::getNextUnchecked "internal";
%kotlinmethodmodifiers std::map::iterator::isNot "internal";
%kotlinmethodmodifiers std::map::iterator::getKey "internal";
%kotlinmethodmodifiers std::map::iterator::getValue "internal";
%kotlinmethodmodifiers std::map::iterator::setValue "internal";

namespace std {

template<class K, class T, class C = std::less< K> > class map {

%typemap(kbase) std::map< K, T, C >
    "java.util.AbstractMap<$typemap(kboxtype, K), $typemap(kboxtype, T)>"

// The kbody typemap is overridden as the base class needs an explicit super() call
// from the secondary constructor.
%typemap(kbody) std::map< K, T, C > %{
  private var swigCPtr: Long
  protected var swigCMemOwn: Boolean

  internal constructor(cPtr: Long, cMemoryOwn: Boolean) : super() {
    swigCMemOwn = cMemoryOwn
    swigCPtr = cPtr
  }
%}


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

    map();
    map(const map& other);

    struct iterator {
      %typemap(kclassmodifiers) iterator "class"
      %extend {
        std::map< K, T, C >::iterator getNextUnchecked() {
          std::map< K, T, C >::iterator copy = (*$self);
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

      void removeUnchecked(const std::map< K, T, C >::iterator itr) {
        self->erase(itr);
      }
    }
};

}
