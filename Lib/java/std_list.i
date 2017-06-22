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

%javamethodmodifiers std::list::begin "private";
%javamethodmodifiers std::list::insert "private";
%javamethodmodifiers std::list::set "private";
%javamethodmodifiers std::list::previous "private";
%javamethodmodifiers std::list::next "private";
%javamethodmodifiers std::list::deref "private";
%javamethodmodifiers std::list::advance "private";
%javamethodmodifiers std::list::doSize "private";
%javamethodmodifiers std::list::doPreviousIndex "private";
%javamethodmodifiers std::list::doNextIndex "private";
%javamethodmodifiers std::list::doHasNext "private";

// Match Java style better:
%rename(Iterator) std::list::iterator;

%nodefaultctor std::list::iterator;

%typemap(javaimports) std::list %{
  import java.util.AbstractSequentialList;
  import java.util.ListIterator;
  import java.util.NoSuchElementException;
  import java.util.Collection;
%}

%typemap(javabase) std::list "AbstractSequentialList<$typemap(jboxtype, $1_basetype::value_type)>"

namespace std {
  template <typename T> class list {

%proxycode %{
  public $javaclassname(Collection c) {
    this();
    ListIterator<$typemap(jboxtype, T)> it = listIterator(0);
    // Special case the "copy constructor" here to avoid lots of cross-language calls
    for (Object o : c) {
      it.add(($typemap(jboxtype, T))o);
    }
  }

  public int size() {
    return doSize();
  }

  public ListIterator<$typemap(jboxtype, T)> listIterator(int index) {
    return new ListIterator<$typemap(jboxtype, T)>() {
      private Iterator pos;
      private Iterator last;

      private ListIterator<$typemap(jboxtype, T)> init(int index) {
        pos = $javaclassname.this.begin();
	pos = pos.advance_unchecked(index);
        return this;
      }

      public void add($typemap(jboxtype, T) v) {
        // Technically we can invalidate last here, but this makes more sense
        last = $javaclassname.this.insert(pos, v);
      }

      public void set($typemap(jboxtype, T) v) {
        if (null == last) {
          throw new IllegalStateException();
        }
        last.set_unchecked(v);
      }

      public void remove() {
        if (null == last) {
          throw new IllegalStateException();
        }
        $javaclassname.this.remove(last);
        last = null;
      }

      public int previousIndex() {
        return $javaclassname.this.doPreviousIndex(pos);
      }

      public int nextIndex() {
        return $javaclassname.this.doNextIndex(pos);
      }

      public $typemap(jboxtype, T) previous() {
        if (previousIndex() < 0) {
          throw new NoSuchElementException();
        }
        last = pos;
        pos = pos.previous_unchecked();
        return last.deref_unchecked();
      }

      public $typemap(jboxtype, T) next() {
        if (!hasNext()) {
          throw new NoSuchElementException();
        }
        last = pos;
        pos = pos.next_unchecked();
        return last.deref_unchecked();
      }

      public boolean hasPrevious() {
        // This call to previousIndex() will be much slower than the hasNext() implementation, but it's simpler like this with C++ forward iterators
        return previousIndex() != -1;
      }

      public boolean hasNext() {
        return $javaclassname.this.doHasNext(pos);
      }
    }.init(index);
  }
%}

  public:
    typedef size_t size_type;
    typedef T value_type;
    typedef T &reference;

    /*
     * We'd actually be better off having the nested class *not* be static in the wrapper
     * output, but this doesn't actually remove the $static from the nested class still.
     * (This would allow us to somewhat simplify the implementation of the ListIterator
     * interface and give "natural" semantics to Java users of the C++ iterator)
     */
    //%typemap(javaclassmodifiers) iterator "public class"
    //%typemap(javainterfaces) iterator "ListIterator<$typemap(jboxtype, $1_basetype::value_type)>"

    struct iterator {
      %extend {
	void set_unchecked(const value_type &v) {
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

	value_type deref_unchecked() const {
	  return **$self;
	}

	iterator advance_unchecked(const size_type index) const {
	  std::list<T>::iterator ret = *$self;
	  std::advance(ret, index);
	  return ret;
	}
      }
    };

    list();
    list(size_type n, const value_type &value = value_type());
    list(const list &o);
    ~list();
    void assign(size_type n, const value_type &val);
    bool empty() const;
    size_type max_size() const;
    void pop_back();
    void pop_front();
    void push_back(const value_type &x);
    void push_front(const value_type &x);
    iterator begin();
    iterator end();
    iterator insert(iterator pos, const value_type &v);

    %extend {
      %fragment("SWIG_ListSize");
      jint doSize() const throw (std::out_of_range) {
        return SWIG_ListSize(self->size());
      }

      jint doPreviousIndex(const iterator &pos) const {
        return pos == self->begin() ? -1 : SWIG_ListSize(std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos)));
      }

      jint doNextIndex(const iterator &pos) const {
        return pos == self->end() ? self->size() : SWIG_ListSize(std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos)));
      }

      bool doHasNext(const iterator &pos) const {
        return pos != $self->end();
      }
    }
  };
}
