//
// Python sequence <-> C++ container wrapper
//
// This wrapper, and its iterator, allows a general use (and reuse) of
// the the mapping between C++ and Python, thanks to the C++
// templates.
//
// Of course, it needs the C++ compiler to support templates, but
// since we will use this wrapper with the STL containers, that should
// be the case.
//
%{
#include <iostream>
%}


/**** The PySequence C++ Wrap ***/

%insert(header) %{
#if PY_VERSION_HEX < 0x02000000
#define PySequence_Size PySequence_Length
#endif
#include <stdexcept>
%}

%include <std_except.i>

  

%fragment(SWIG_Traits_frag(swig::PyObject_ptr),"header",fragment="StdTraits") {
namespace swig {
  template <>  struct traits<PyObject_ptr > {
    typedef value_category category;
    static const char* type_name() { return  "PyObject_ptr"; }
  };
  
  template <>  struct traits_from<PyObject_ptr> {
    typedef PyObject_ptr value_type;
    static PyObject *from(const value_type& val) {
      PyObject *obj = static_cast<PyObject *>(val);
      Py_XINCREF(obj);
      return obj;
    }
  };
  
  template <> 
  struct traits_check<PyObject_ptr, value_category> {
    static bool check(PyObject_ptr) {
      return true;
    }
  };
  
  template <>  struct traits_asval<PyObject_ptr > {   
    typedef PyObject_ptr value_type;
    static int asval(PyObject *obj, value_type *val) {
      if (val) *val = obj;
      return SWIG_OK;
    }
  };
}
}


%fragment(SWIG_Traits_frag(swig::PyObject_var),"header",fragment="StdTraits") {
namespace swig {
  template <>  struct traits<PyObject_var > {
    typedef value_category category;
    static const char* type_name() { return  "PyObject_var"; }
  };
  
  template <>  struct traits_from<PyObject_var> {
    typedef PyObject_var value_type;
    static PyObject *from(const value_type& val) {
      PyObject *obj = static_cast<PyObject *>(val);
      Py_XINCREF(obj);
      return obj;
    }
  };
  
  template <> 
  struct traits_check<PyObject_var, value_category> {
    static bool check(PyObject_var) {
      return true;
    }
  };
  
  template <>  struct traits_asval<PyObject_var > {   
    typedef PyObject_var value_type;
    static int asval(PyObject *obj, value_type *val) {
      if (val) *val = obj;
      return SWIG_OK;
    }
  };
} 
}



%fragment("PySequence_Base","header")
{

namespace std {
  template <>
  struct less <PyObject *>: public binary_function<PyObject *, PyObject *, bool>
  {
    bool
    operator()(PyObject * v, PyObject *w) const
    { 
      bool res;
      SWIG_PYTHON_THREAD_BEGIN_BLOCK;
      res = PyObject_Compare(v, w) < 0;
      SWIG_PYTHON_THREAD_END_BLOCK;
      return res;
    }
  };

  template <>
  struct less <swig::PyObject_ptr>: public binary_function<swig::PyObject_ptr, swig::PyObject_ptr, bool>
  {
    bool
    operator()(const swig::PyObject_ptr& v, const swig::PyObject_ptr& w) const
    {
      return std::less<PyObject *>()(v, w);
    }
  };

  template <>
  struct less <swig::PyObject_var>: public binary_function<swig::PyObject_var, swig::PyObject_var, bool>
  {
    bool
    operator()(const swig::PyObject_var& v, const swig::PyObject_var& w) const
    {
      return std::less<PyObject *>()(v, w);
    }
  };

}

namespace swig {
  template <> struct traits<PyObject *> {
    typedef value_category category;
    static const char* type_name() { return "PyObject *"; }
  };  

  template <>  struct traits_asval<PyObject * > {   
    typedef PyObject * value_type;
    static int asval(PyObject *obj, value_type *val) {
      if (val) *val = obj;
      return SWIG_OK;
    }
  };

  template <> 
  struct traits_check<PyObject *, value_category> {
    static bool check(PyObject *) {
      return true;
    }
  };

  template <>  struct traits_from<PyObject *> {
    typedef PyObject * value_type;
    static PyObject *from(const value_type& val) {
      Py_XINCREF(val);
      return val;
    }
  };
  
}


namespace swig {

  inline size_t
  check_index(ptrdiff_t i, size_t size, bool insert = false) {
    if ( i < 0 ) {
      if ((size_t) (-i) <= size)
	return (size_t) (i + size);
    } else if ( (size_t) i < size ) {
      return (size_t) i;
    } else if (insert && ((size_t) i == size)) {
      return size;
    }
    
    throw std::out_of_range("index out of range");
  }

  inline size_t
  slice_index(ptrdiff_t i, size_t size) {
    if ( i < 0 ) {
      if ((size_t) (-i) <= size) {
	return (size_t) (i + size);
      } else {
	throw std::out_of_range("index out of range");
      }
    } else {
      return ( (size_t) i < size ) ? ((size_t) i) : size;
    }
  }

  template <class Sequence, class Difference>
  inline typename Sequence::iterator
  getpos(Sequence* self, Difference i)  {
    typename Sequence::iterator pos = self->begin();
    std::advance(pos, check_index(i,self->size()));
    return pos;
  }

  template <class Sequence, class Difference>
  inline typename Sequence::const_iterator
  cgetpos(const Sequence* self, Difference i)  {
    typename Sequence::const_iterator pos = self->begin();
    std::advance(pos, check_index(i,self->size()));
    return pos;
  }

  template <class Sequence, class Difference>
  inline Sequence*
  getslice(const Sequence* self, Difference i, Difference j) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = swig::check_index(i, size);
    typename Sequence::size_type jj = swig::slice_index(j, size);

    if (jj > ii) {
      typename Sequence::const_iterator vb = self->begin();
      typename Sequence::const_iterator ve = self->begin();
      std::advance(vb,ii);
      std::advance(ve,jj);
      return new Sequence(vb, ve);
    } else {
      return new Sequence();
    }
  }

  template <class Sequence, class Difference, class InputSeq>
  inline void
  setslice(Sequence* self, Difference i, Difference j, const InputSeq& v) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = swig::check_index(i, size, true);
    typename Sequence::size_type jj = swig::slice_index(j, size);
    if (jj < ii) jj = ii;
    typename Sequence::iterator sb = self->begin();
    typename InputSeq::const_iterator vmid = v.begin();
    std::advance(sb,ii);
    std::advance(vmid, jj - ii);
    self->insert(std::copy(v.begin(), vmid, sb), vmid, v.end());
  }

  template <class Sequence, class Difference>
  inline void
  delslice(Sequence* self, Difference i, Difference j) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = swig::check_index(i, size, true);
    typename Sequence::size_type jj = swig::slice_index(j, size);
    if (jj > ii) {
      typename Sequence::iterator sb = self->begin();
      typename Sequence::iterator se = self->begin();
      std::advance(sb,ii);
      std::advance(se,jj);
      self->erase(sb,se);
    }
  }
}
}


#define SWIG_EXPORT_ITERATOR_METHODS SWIG_EXPORT_ITERATOR_METHODS
  
#if defined(SWIG_EXPORT_ITERATOR_METHODS)
/*
   Throw a StopIteration exception
*/
namespace swig 
{
  %ignore stop_iteration;
  %typemap(throws) stop_iteration {
    SWIG_SetErrorObj(PyExc_StopIteration, SWIG_Py_Void());
    SWIG_fail;
  }
}



namespace swig {
  %newobject PySequence_OutputIterator::operator +;
  %newobject PySequence_OutputIterator::operator - (ptrdiff_t n) const;
  %newobject PySequence_OutputIterator::copy;
}

%inline {
  namespace swig {
    struct stop_iteration
    {
    };

    struct PySequence_OutputIterator
    {
    private:
      PyObject_ptr _seq;

    protected:
      PySequence_OutputIterator(PyObject *seq) : _seq(seq)
      {
      }
      
    public:
      virtual ~PySequence_OutputIterator() {}

      virtual PyObject *value() const throw (stop_iteration) = 0;
      virtual PySequence_OutputIterator *incr(size_t n = 1) throw (stop_iteration) = 0;
      virtual PySequence_OutputIterator *decr(size_t n = 1) throw (stop_iteration) = 0;
      virtual PySequence_OutputIterator *copy() const = 0;
      virtual ptrdiff_t distance(const PySequence_OutputIterator &x) const = 0;
      virtual bool equal (const PySequence_OutputIterator &x) const = 0;

      PyObject *next() throw (stop_iteration)
      {
	PyObject *obj = value();
	incr();
	return obj;
      }

      PyObject *previous() throw (stop_iteration)
      {
	decr();
	return value();
      }

      PySequence_OutputIterator *advance(ptrdiff_t n) throw (stop_iteration)
      {
	return  (n > 0) ?  incr(n) : decr(-n);
      }
      
    public:
      
      bool operator == (const PySequence_OutputIterator& x)  const
      {
	return equal(x);
      }
      
      bool operator != (const PySequence_OutputIterator& x) const
      {
	return ! operator==(x);
      }
      
      PySequence_OutputIterator& operator += (ptrdiff_t n) throw (stop_iteration)
      {
	return *advance(n);
      }

      PySequence_OutputIterator& operator -= (ptrdiff_t n) throw (stop_iteration)
      {
	return *advance(-n);
      }
      
      PySequence_OutputIterator* operator + (ptrdiff_t n) const throw (stop_iteration)
      {
	return copy()->advance(n);
      }

      PySequence_OutputIterator* operator - (ptrdiff_t n) const throw (stop_iteration)
      {
	return copy()->advance(-n);
      }
      
      ptrdiff_t operator - (const PySequence_OutputIterator& x) const
      {
	return x.distance(*this);
      }
      
      static swig_type_info* desc() {
	static swig_type_info* desc = SWIG_TypeQuery("swig::PySequence_OutputIterator *");
	return desc;
      }
    };
  }
}
#endif //SWIG_EXPORT_ITERATOR_METHODS

%fragment("PySequence_Cont","header",
	  fragment="StdTraits",
	  fragment="PySequence_Base")
{
#include <iterator>
  
namespace swig
{
#if defined(SWIG_EXPORT_ITERATOR_METHODS)
  template<typename OutIterator>
  class PySequence_OutputIterator_T :  public PySequence_OutputIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;
    
    typedef PySequence_OutputIterator_T<out_iterator> self_type;
    
    PySequence_OutputIterator_T(out_iterator curr, out_iterator first, out_iterator last, PyObject *seq)
      : PySequence_OutputIterator(seq), current(curr), begin(first), end(last)
    {
    }
    
    PyObject *value() const throw (stop_iteration) {
      if (current == end) {
	throw stop_iteration();
      } else {
	return swig::from((const value_type&)*(current));
      }
    }
    
    
    PySequence_OutputIterator_T *copy() const
    {
      return new self_type(*this);
    }

    PySequence_OutputIterator_T *incr(size_t n = 1) throw (stop_iteration)
    {
      while (n--) {
	if (current == end) {
	  throw stop_iteration();
	} else {
	  ++current;
	}
      }
      return this;
    }

    PySequence_OutputIterator_T *decr(size_t n = 1) throw (stop_iteration)
    {
      while (n--) {
	if (current == begin) {
	  throw stop_iteration();
	} else {
	  --current;
	}
      }
      return this;
    }
    
    
    bool equal (const PySequence_OutputIterator &iter) const throw (std::invalid_argument)
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    ptrdiff_t distance(const PySequence_OutputIterator &iter) const throw (std::invalid_argument)
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return std::distance(current, iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    const out_iterator& get_current() const
    {
      return current;
    }
    
  private:
    out_iterator current;
    out_iterator begin;
    out_iterator end;
  };

  template<typename OutIter>
  inline PySequence_OutputIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin = OutIter(), 
		       const OutIter& end = OutIter(), PyObject *seq = 0)
  {
    return new PySequence_OutputIterator_T<OutIter>(current, begin, end, seq);
  }
#endif //SWIG_EXPORT_ITERATOR_METHODS
  
  template <class T>
  struct PySequence_Ref
  {
    PySequence_Ref(PyObject* seq, int index)
      : _seq(seq), _index(index)
    {
    }
    
    operator T () const
    {
      swig::PyObject_var item = PySequence_GetItem(_seq, _index);
      try {
	return swig::as<T>(item, true);
      } catch (std::exception& e) {
	char msg[1024];
	snprintf(msg, sizeof(msg), "in sequence element %d ", _index);
	if (!PyErr_Occurred()) {
	  %type_error(swig::type_name<T>());
	}
	SWIG_Python_AddErrorMsg(msg);
	SWIG_Python_AddErrorMsg(e.what());
	throw;
      }
    }

    PySequence_Ref& operator=(const T& v)
    {
      PySequence_SetItem(_seq, _index, swig::from<T>(v));
      return *this;
    }

  private:
    PyObject* _seq;
    int _index;
  };

  template <class T>
  struct PySequence_ArrowProxy
  {
    PySequence_ArrowProxy(const T& x): m_value(x) {}
    const T* operator->() const { return &m_value; }
    operator const T*() const { return &m_value; }
    T m_value;
  };

  template <class T, class Reference >
  struct PySequence_InputIterator
  {
    typedef PySequence_InputIterator<T, Reference > self;

    typedef std::random_access_iterator_tag iterator_category;
    typedef Reference reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;

    PySequence_InputIterator()
    {
    }

    PySequence_InputIterator(PyObject* seq, int index)
      : _seq(seq), _index(index)
    {
    }

    reference operator*() const
    {
      return reference(_seq, _index);
    }

    PySequence_ArrowProxy<T>
    operator->() const {
      return PySequence_ArrowProxy<T>(operator*());
    }

    bool operator==(const self& ri) const
    {
      return (_index == ri._index) && (_seq == ri._seq);
    }

    bool operator!=(const self& ri) const
    {
      return !(operator==(ri));
    }

    self& operator ++ ()
    {
      ++_index;
      return *this;
    }

    self& operator -- ()
    {
      --_index;
      return *this;
    }

    self& operator += (difference_type n)
    {
      _index += n;
      return *this;
    }

    self operator +(difference_type n) const
    {
      return self(_seq, _index + n);
    }

    self& operator -= (difference_type n)
    {
      _index -= n;
      return *this;
    }

    self operator -(difference_type n) const
    {
      return self(_seq, _index - n);
    }

    difference_type operator - (const self& ri) const
    {
      return _index - ri._index;
    }

    reference
    operator[](difference_type n) const
    {
      return reference(_seq, _index + n);
    }

  private:
    PyObject* _seq;
    int _index;
  };

  template <class T>
  struct PySequence_Cont
  {
    typedef PySequence_Ref<T> reference;
    typedef const PySequence_Ref<T> const_reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;
    typedef int size_type;
    typedef const pointer const_pointer;
    typedef PySequence_InputIterator<T, reference> iterator;
    typedef PySequence_InputIterator<T, const_reference> const_iterator;

    PySequence_Cont(PyObject* seq) : _seq(0)
    {
      if (!PySequence_Check(seq)) {
	throw std::invalid_argument("a sequence is expected");
      }
      _seq = seq;
      Py_INCREF(_seq);
    }

    ~PySequence_Cont()
    {
      if (_seq) Py_DECREF(_seq);
    }

    size_type size() const
    {
      return PySequence_Size(_seq);
    }

    bool empty() const
    {
      return size() == 0;
    }

    iterator begin()
    {
      return iterator(_seq, 0);
    }

    const_iterator begin() const
    {
      return const_iterator(_seq, 0);
    }

    iterator end()
    {
      return iterator(_seq, size());
    }

    const_iterator end() const
    {
      return const_iterator(_seq, size());
    }

    reference operator[](difference_type n)
    {
      return reference(_seq, n);
    }

    const_reference operator[](difference_type n)  const
    {
      return const_reference(_seq, n);
    }

    bool check(bool set_err = true) const
    {
      int s = size();
      for (int i = 0; i < s; ++i) {
	swig::PyObject_var item = PySequence_GetItem(_seq, i);
	if (!swig::check<value_type>(item)) {
	  if (set_err) {
	    char msg[1024];
	    snprintf(msg, sizeof(msg), "in sequence element %d of type %s", i, swig::type_name<value_type>());
	    SWIG_Error(SWIG_RuntimeError, msg);
	  }
	  return false;
	}
      }
      return true;
    }

  private:
    PyObject* _seq;
  };

}
}

%define %swig_sequence_iterator(Sequence...)
#if defined(SWIG_EXPORT_ITERATOR_METHODS)
  class iterator;
  class reverse_iterator;
  class const_iterator;
  class const_reverse_iterator;

  %typemap(out,noblock=1,fragment="PySequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    $result = SWIG_NewPointerObj(swig::make_output_iterator((const $type &)$1),
				 swig::PySequence_OutputIterator::desc(),SWIG_POINTER_OWN);
  }
  %typemap(out,noblock=1,fragment="PySequence_Cont")
    std::pair<iterator, iterator>, std::pair<const_iterator, const_iterator> {
    $result = PyTuple_New(2);
    PyTuple_SetItem($result,0,SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).first),
					       swig::PySequence_OutputIterator::desc(),SWIG_POINTER_OWN));
    PyTuple_SetItem($result,1,SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).second),
					       swig::PySequence_OutputIterator::desc(),SWIG_POINTER_OWN));    
  }

  %fragment("PyPairBoolOutputIterator","header",fragment=SWIG_From_frag(bool),fragment="PySequence_Cont") {}

  %typemap(out,noblock=1,fragment="PyPairBoolOutputIterator")
    std::pair<iterator, bool>, std::pair<const_iterator, bool> {
    $result = PyTuple_New(2);
    PyTuple_SetItem($result,0,SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).first),
					       swig::PySequence_OutputIterator::desc(),SWIG_POINTER_OWN));    
    PyTuple_SetItem($result,1,SWIG_From(bool)(%static_cast($1,const $type &).second));
  }

  %typemap(in,noblock=1,fragment="PySequence_Cont")
    iterator(swig::PySequence_OutputIterator *iter),
    reverse_iterator(swig::PySequence_OutputIterator *iter),
    const_iterator(swig::PySequence_OutputIterator *iter),
    const_reverse_iterator(swig::PySequence_OutputIterator *iter) {
    if (SWIG_ConvertPtr($input, %as_voidptrptr(&iter), swig::PySequence_OutputIterator::desc(), 0) != SWIG_OK) {
      %argument_fail(SWIG_TypeError, "$type", $argnum);
    }
    if (iter) {
      swig::PySequence_OutputIterator_T<$type > *iter_t 
	= dynamic_cast<swig::PySequence_OutputIterator_T<$type > *>(iter);
      $1 = iter_t->get_current();
    } else {
      %argument_fail(SWIG_TypeError, "$type", $argnum);
    }
  }

  %typecheck(%checkcode(ITERATOR),noblock=1,fragment="PySequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    swig::PySequence_OutputIterator *iter = 0;
    $1 = ((SWIG_ConvertPtr($input, %as_voidptrptr(&iter), 
			   swig::PySequence_OutputIterator::desc(), 0) == SWIG_OK)
	  && iter
	  && (dynamic_cast<swig::PySequence_OutputIterator_T<$type > *>(iter) != 0));
  }

  %fragment("PySequence_Cont");

  %newobject iterator(PyObject **PYTHON_SELF);
  %extend  {
    swig::PySequence_OutputIterator* iterator(PyObject **PYTHON_SELF) {
      return swig::make_output_iterator(self->begin(), self->begin(), self->end(), *PYTHON_SELF);
    }

    %pythoncode {
      def __iter__(self):
        return self.iterator()
    }
  }
#endif //SWIG_EXPORT_ITERATOR_METHODS
%enddef


/**** The python container methods  ****/


%define %swig_container_methods(Container...)

  %newobject __getslice__;

  %extend {
    bool __nonzero__() const {
      return !(self->empty());
    }

    size_type __len__() const {
      return self->size();
    }
  }
%enddef

%define %swig_sequence_methods_common(Sequence...)
  %swig_sequence_iterator(%arg(Sequence))
  %swig_container_methods(%arg(Sequence))
  
  %fragment("PySequence_Base");

  %extend {
    value_type pop() throw (std::out_of_range) {
      if (self->size() == 0)
	throw std::out_of_range("pop from empty container");
      Sequence::value_type x = self->back();
      self->pop_back();
      return x;
    }

    Sequence* __getslice__(difference_type i, difference_type j) throw (std::out_of_range) {
      return swig::getslice(self, i, j);
    }

    void __setslice__(difference_type i, difference_type j, const Sequence& v) 
      throw (std::out_of_range, std::invalid_argument) {
      swig::setslice(self, i, j, v);
    }

    void __delslice__(difference_type i, difference_type j) throw (std::out_of_range) {
      swig::delslice(self, i, j);
    }

    void __delitem__(difference_type i) throw (std::out_of_range) {
      self->erase(swig::getpos(self,i));
    }
  }
%enddef

%define %swig_sequence_methods(Sequence...)
  %swig_sequence_methods_common(%arg(Sequence))
  %extend {
    const value_type& __getitem__(difference_type i) const throw (std::out_of_range) {
      return *(swig::cgetpos(self, i));
    }

    void __setitem__(difference_type i, const value_type& x) throw (std::out_of_range) {
      *(swig::getpos(self,i)) = x;
    }

    void append(const value_type& x) {
      self->push_back(x);
    }
 }
%enddef

%define %swig_sequence_methods_val(Sequence...)
  %swig_sequence_methods_common(%arg(Sequence))
  %extend {
    value_type __getitem__(difference_type i) throw (std::out_of_range) {
      return *(swig::cgetpos(self, i));
    }

    void __setitem__(difference_type i, value_type x) throw (std::out_of_range) {
      *(swig::getpos(self,i)) = x;
    }

    void append(value_type x) {
      self->push_back(x);
    }
 }
%enddef




//
// Common fragments
//

%fragment("StdSequenceTraits","header",
	  fragment="StdTraits",
	  fragment="PySequence_Cont")
{
  namespace swig {
    template <class PySeq, class Seq>
    inline void
    assign(const PySeq& pyseq, Seq* seq) {
%#ifdef SWIG_STD_NOASSIGN_STL
      typedef typename PySeq::value_type value_type;
      typename PySeq::const_iterator it = pyseq.begin();
      for (;it != pyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
%#else
      seq->assign(pyseq.begin(), pyseq.end());
%#endif
    }

    template <class Seq, class T = typename Seq::value_type >
    struct traits_asptr_stdseq {
      typedef Seq sequence;
      typedef T value_type;

      static int asptr(PyObject *obj, sequence **seq) {
	if (PySequence_Check(obj)) {
	  try {
	    PySequence_Cont<value_type> pyseq(obj);
	    if (seq) {
	      sequence *pseq = new sequence();
	      assign(pyseq, pseq);
	      *seq = pseq;
	      return SWIG_NEWOBJ;
	    } else {
	      return pyseq.check();
	    }
	  } catch (std::exception& e) {
	    if (seq) {
	      if (!PyErr_Occurred()) {
		PyErr_SetString(PyExc_TypeError, e.what());
	      }
	    }
	    return 0;
	  }
	} else {
	  sequence *p;
	  if (SWIG_ConvertPtr(obj,(void**)&p,
			      swig::type_info<sequence>(),0) == SWIG_OK) {
	    if (seq) *seq = p;
	    return SWIG_OLDOBJ;
	  }
	}
	if (seq) {
	  PyErr_Format(PyExc_TypeError, "a %s is expected",
		       swig::type_name<sequence>());
	}
	return 0;
      }
    };

    template <class Seq, class T = typename Seq::value_type >
    struct traits_from_stdseq {
      typedef Seq sequence;
      typedef T value_type;
      typedef typename Seq::size_type size_type;
      typedef typename sequence::const_iterator const_iterator;

      static PyObject *from(const sequence& seq) {
	size_type size = seq.size();
	if (size <= (size_type)INT_MAX) {
	  PyObject *obj = PyTuple_New((int)size);
	  int i = 0;
	  for (const_iterator it = seq.begin();
	       it != seq.end(); ++it, ++i) {
	    PyTuple_SetItem(obj,i,swig::from<value_type>(*it));
	  }
	  return obj;
	} else {
	  PyErr_SetString(PyExc_OverflowError,
			  "sequence size not valid in python");
	  return NULL;
	}
      }
    };
  }
}
