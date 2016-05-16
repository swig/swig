%include <autobox.i>
%include <stdint.i>

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

namespace std {
  template <typename T> class list {
  public:
    // This typedef is a weird hack to make stuff work
    typedef std::list<T>::iterator iterator;
    typedef size_t size_type;
    typedef T value_type;
    typedef T& reference;

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

    // Possible bug: jint != size_type
    jint size () const;
    void sort();

    // Only for helping implement listIterator
    iterator begin();
    iterator insert(iterator pos, const value_type &v);

    %extend {
      static void set(iterator pos, const value_type& v) {
        *pos = v;
      }

      jint previous_index(const iterator& pos) const {
        return pos == self->begin() ? -1 : std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos));
      }

      jint next_index(const iterator& pos) const {
        return pos == self->end() ? self->size() : std::distance(self->begin(), static_cast<std::list<T>::const_iterator>(pos));
      }

      static iterator next(iterator pos) {
        return ++pos;
      }

      static iterator previous(iterator pos) {
        return --pos;
      }

      static value_type deref(const iterator& pos) {
        return *pos;
      }

      static void advance(iterator& pos, jint index) {
        std::advance(pos, index);
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
#define JAVA_ITERATOR_TYPE $typemap(jstype, $1_basetype::iterator)

%typemap(javacode,noblock=1) std::list {
  public $javaclassname(Collection c) {
    this();
    ListIterator<JAVA_VALUE_TYPE> it = listIterator(0);
    for (Object o: c) {
      it.add((JAVA_VALUE_TYPE)o);
    }
  }

  public ListIterator<JAVA_VALUE_TYPE> listIterator(int index) {
    return new ListIterator<JAVA_VALUE_TYPE>() {
      private JAVA_ITERATOR_TYPE pos;
      private JAVA_ITERATOR_TYPE last;

      private ListIterator<JAVA_VALUE_TYPE> init(int index) {
        pos = $javaclassname.this.begin();
        $javaclassname.advance(pos, index);
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
        $javaclassname.set(last, v);
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
        pos = $javaclassname.previous(pos);
        return $javaclassname.deref(last);
      }

      public JAVA_VALUE_TYPE next() {
        if (!hasNext()) {
          throw new NoSuchElementException();
        }
        last = pos;
        pos = $javaclassname.next(pos);  
        return $javaclassname.deref(last);
      }

      public boolean hasPrevious() {
        return previousIndex() != -1;
      }

      public boolean hasNext() { 
        return $javaclassname.this.has_next(pos);
      }
    }.init(index);
  }
}
