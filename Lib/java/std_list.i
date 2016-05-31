%include <std_common.i>
%include <autobox.i>

%{
#include <list>
#include <algorithm>
%}

%javamethodmodifiers std::list::begin "private";
%javamethodmodifiers std::list::insert "private";
%javamethodmodifiers std::list::set "private";
%javamethodmodifiers std::list::previous_index "private";
%javamethodmodifiers std::list::next_index "private";
%javamethodmodifiers std::list::previous "private";
%javamethodmodifiers std::list::next "private";
%javamethodmodifiers std::list::deref "private";
%javamethodmodifiers std::list::advance "private";
%javamethodmodifiers std::list::has_next "private";

/*
 To conform to Java Collection interface we must return int from size().
 Unfortunately that loses precision from the integer types commonly used in
 C++ implementations. Since we can't overload on return values the best 
 workaround here is to expose the real C++ size() return value to Java as a 
 long under a different name. We can then wrap that with a Java specific 
 size() implementation that at least checks and fails gracefully in the case
 where we have a collection with > 2^31-1 items rather than failing 
 mysteriously. The wrapper implementaiton is in the javacode typemap later.
*/
%rename(realSize) std::list::size;

// Match Java style better:
%rename(Iterator) std::list::iterator;

%nodefaultctor std::list::iterator;

namespace std {
  template <typename T> class list {
  public:
    typedef size_t size_type;
    typedef T value_type;
    typedef T& reference;

    /*
     * We'd actually be better off having the nested class *not* be static in the wrapper
     * output, but this doesn't actually remove the $static from the nested class still.
     * (This would allow us to somewhat simplify the implementation of the ListIterator
     * interface and give "natural" semantics to Java users of the C++ iterator)
     */
    //%typemap(javaclassmodifiers) iterator "public class"
    //%typemap(javainterfaces) iterator "ListIterator<$typemap(autobox,$1_basetype::value_type)>"

    struct iterator {
      %extend {
	void set_unchecked(const value_type& v) {
	  **$self = v;
	}

	iterator next_unchecked() const {
	  std::list<T>::iterator ret=*$self;
	  ++ret;
	  return ret;
	}

	iterator previous_unchecked() const {
	  std::list<T>::iterator ret=*$self;
	  --ret;
	  return ret;
	}

	value_type deref_unchecked() const {
	  return **$self;
	}

	void advance_unchecked(jint index) {
	  std::advance(*$self, index);
	}
      }
    };

    void assign(size_type n, const value_type &val);

    bool empty() const;

    list(size_type n, const value_type &value=value_type());
    list(const list &o);
    list();
    ~list();

    size_type max_size () const;

    void pop_back();
    void pop_front();
    void push_back(const value_type &x);
    void push_front(const value_type &x);

    size_type size() const;
    
    // Although sort() is nice it makes operator<() mandatory which it probably shouldn't be
    //void sort();

    iterator begin();
    iterator end();
    iterator insert(iterator pos, const value_type &v);

    %extend {
      jint previous_index(const iterator& pos) const {
        return pos == self->begin() ? -1 : std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos));
      }

      jint next_index(const iterator& pos) const {
        return pos == self->end() ? self->size() : std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos));
      }

      bool has_next(const iterator& pos) const {
        return pos != $self->end();
      }
    }
  };
}

%typemap(javaimports) std::list %{
  import java.util.AbstractSequentialList;
  import java.util.ListIterator;
  import java.util.NoSuchElementException;
  import java.util.Collection;
%}

%typemap(javabase) std::list "AbstractSequentialList<$typemap(autobox,$1_basetype::value_type)>"

#define JAVA_VALUE_TYPE $typemap(autobox,$1_basetype::value_type)
#define JAVA_ITERATOR_TYPE Iterator

%typemap(javacode,noblock=1) std::list {
  public $javaclassname(Collection c) {
    this();
    ListIterator<JAVA_VALUE_TYPE> it = listIterator(0);
    // We should special case the "copy constructor" here to avoid lots of cross-language calls
    for (Object o: c) {
      it.add((JAVA_VALUE_TYPE)o);
    }
  }

  public int size() {
    final long val = realSize();
    if (val > Integer.MAX_VALUE) {
      throw new IndexOutOfBoundsException("Size of Collection $javaclassname is not representable as int");
    }
    return (int)val;
  }

  public ListIterator<JAVA_VALUE_TYPE> listIterator(int index) {
    return new ListIterator<JAVA_VALUE_TYPE>() {
      private JAVA_ITERATOR_TYPE pos;
      private JAVA_ITERATOR_TYPE last;

      private ListIterator<JAVA_VALUE_TYPE> init(int index) {
        pos = $javaclassname.this.begin();
	pos.advance_unchecked(index);
        return this;
      }

      public void add(JAVA_VALUE_TYPE v) {
        // Technically we can invalidate last here, but this makes more sense
        last=$javaclassname.this.insert(pos, v);
      }

      public void set(JAVA_VALUE_TYPE v) {
        if (null==last) {
          throw new IllegalStateException();
        }
        last.set_unchecked(v);
      }

      public void remove() {
        if (null==last) {
          throw new IllegalStateException();
        }
        $javaclassname.this.remove(last);
        last=null;
      }

      public int previousIndex() {
        return $javaclassname.this.previous_index(pos);
      }

      public int nextIndex() {
        return $javaclassname.this.next_index(pos);
      }

      public JAVA_VALUE_TYPE previous() {
        if (previousIndex() < 0) {
          throw new NoSuchElementException();
        }
        last = pos;
        pos = pos.previous_unchecked();
        return last.deref_unchecked();
      }

      public JAVA_VALUE_TYPE next() {
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
        return $javaclassname.this.has_next(pos);
      }
    }.init(index);
  }
}
