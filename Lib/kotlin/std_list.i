/* -----------------------------------------------------------------------------
 * std_list.i
 *
 * SWIG typemaps for std::list.
 * The Java proxy class extends java.util.AbstractSequentialList. The std::list
 * container looks and feels much like a java.util.LinkedList from Java.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
#include <list>
#include <stdexcept>
%}

%fragment("SWIG_ListSize", "header", fragment="SWIG_JavaIntFromSize_t") {
SWIGINTERN jint SWIG_ListSize(size_t size) {
  jint sz = SWIG_JavaIntFromSize_t(size);
  if (sz == -1)
    throw std::out_of_range("list size is too large to fit into a Java int");
  return sz;
}
}

%kotlinmethodmodifiers std::list::empty "override";
%kotlinmethodmodifiers std::list::clear "override";
%kotlinmethodmodifiers std::list::push_back "private";
%kotlinmethodmodifiers std::list::begin "private";
%kotlinmethodmodifiers std::list::insert "private";
%kotlinmethodmodifiers std::list::doSize "private";
%kotlinmethodmodifiers std::list::doPreviousIndex "private";
%kotlinmethodmodifiers std::list::doNextIndex "private";
%kotlinmethodmodifiers std::list::doHasNext "private";

// Match Java style better:
%rename(Iterator) std::list::iterator;

%nodefaultctor std::list::iterator;

namespace std {
  template <typename T> class list {

%typemap(kbase) std::list<T> "java.util.AbstractSequentialList<$typemap(kboxtype, T)>"


%proxycode %{
  constructor(c: java.util.Collection<$typemap(kboxtype, T)>) : this() {
    val it = listIterator(0)
    // Special case the "copy constructor" here to avoid lots of cross-language calls
    for (o in c) {
      it.add(o)
    }
  }

  override val size: Int
    get() = doSize()

  override fun add(element: $typemap(kboxtype, T)): Boolean {
    push_back(element)
    return true
  }

  override fun listIterator(index: Int): MutableListIterator<$typemap(kboxtype, T)> {
    return object : MutableListIterator<$typemap(kboxtype, T)> {
      private var pos: Iterator
      private var last: Iterator? = null

      init {
        if (index < 0 || index > this@$kotlinclassname.size)
          throw IndexOutOfBoundsException("Index: " + index)
        pos = this@$kotlinclassname.begin()
        pos = pos.advance_unchecked(index)
      }

      override fun add(element: $typemap(kboxtype, T)) {
        // Technically we can invalidate last here, but this makes more sense
        last = this@$kotlinclassname.insert(pos, element)
      }

      override fun set(element: $typemap(kboxtype, T)) {
        val l = last ?: throw IllegalStateException()
        l.set_unchecked(element)
      }

      override fun remove() {
        val l = last ?: throw IllegalStateException()
        this@$kotlinclassname.remove(l)
        last = null
      }

      override fun previousIndex(): Int {
        return this@$kotlinclassname.doPreviousIndex(pos)
      }

      override fun nextIndex(): Int {
        return this@$kotlinclassname.doNextIndex(pos)
      }

      override fun previous(): $typemap(kboxtype, T) {
        if (previousIndex() < 0) {
          throw NoSuchElementException()
        }
        val l = pos
        last = l
        pos = pos.previous_unchecked()
        return l.deref_unchecked()
      }

      override fun next(): $typemap(kboxtype, T) {
        if (!hasNext()) {
          throw NoSuchElementException()
        }
        val l = pos
        last = l
        pos = pos.next_unchecked()
        return l.deref_unchecked()
      }

      override fun hasPrevious(): Boolean {
        // This call to previousIndex() will be much slower than the hasNext() implementation, but it's simpler like this with C++ forward iterators
        return previousIndex() != -1
      }

      override fun hasNext(): Boolean {
        return this@$kotlinclassname.doHasNext(pos)
      }
    }
  }
%}

  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    /*
     * We'd actually be better off having the nested class *not* be static in the wrapper
     * output, but this doesn't actually remove the $static from the nested class still.
     * (This would allow us to somewhat simplify the implementation of the ListIterator
     * interface and give "natural" semantics to Java users of the C++ iterator)
     */
    //%typemap(kclassmodifiers) iterator "public class"
    //%typemap(kinterfaces) iterator "java.util.ListIterator<$typemap(kboxtype, T)>"

    struct iterator {
      %extend {
	void set_unchecked(const T &v) {
	  **$self = v;
	}

	iterator next_unchecked() const {
	  std::list<T>::iterator ret = *$self;
	  ++ret;
	  return ret;
	}

	iterator previous_unchecked() const {
	  std::list<T>::iterator ret = *$self;
	  --ret;
	  return ret;
	}

	T deref_unchecked() const {
	  return **$self;
	}

	iterator advance_unchecked(int index) const {
	  std::list<T>::iterator ret = *$self;
	  std::advance(ret, index);
	  return ret;
	}
      }
    };

    list();
    list(const list& other);

    %rename(isEmpty) empty;
    bool empty() const;
    void clear();
    %rename(remove) erase;
    iterator erase(iterator pos);
    void push_back(const T &value);
    iterator begin();
    iterator end();
    iterator insert(iterator pos, const T &value);

    %extend {
      %fragment("SWIG_ListSize");

      list(jint count, const T &value) throw (std::out_of_range) {
        if (count < 0)
          throw std::out_of_range("list count must be positive");
        return new std::list<T>(static_cast<std::list<T>::size_type>(count), value);
      }

      jint doSize() const throw (std::out_of_range) {
        return SWIG_ListSize(self->size());
      }

      jint doPreviousIndex(const iterator &pos) const throw (std::out_of_range) {
        return pos == self->begin() ? -1 : SWIG_ListSize(std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos)));
      }

      jint doNextIndex(const iterator &pos) const throw (std::out_of_range) {
        return pos == self->end() ? SWIG_ListSize(self->size()) : SWIG_ListSize(std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos)));
      }

      bool doHasNext(const iterator &pos) const {
        return pos != $self->end();
      }
    }
  };
}
