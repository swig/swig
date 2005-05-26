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

%fragment("PySequence_Base","header")
%{
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
%}

%fragment("PySequence_Cont","header",
	  fragment="StdTraits",
	  fragment="PySequence_Base",
	  fragment="PyObject_var")
%{
#include <iterator>
namespace swig
{
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
	PyOS_snprintf(msg, sizeof(msg), "in sequence element %d ", _index);
	if (!PyErr_Occurred()) {
	  SWIG_type_error(swig::type_name<T>(), item);
	}
	SWIG_append_errmsg(msg);
	SWIG_append_errmsg(e.what());
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
  struct PySequence_Iter
  {
    typedef PySequence_Iter<T, Reference > self;

    typedef std::random_access_iterator_tag iterator_category;
    typedef Reference reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;

    PySequence_Iter()
    {
    }

    PySequence_Iter(PyObject* seq, int index)
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
    typedef PySequence_Iter<T, reference> iterator;
    typedef PySequence_Iter<T, const_reference> const_iterator;

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
	    PyOS_snprintf(msg, sizeof(msg), "in sequence element %d", i);
	    SWIG_type_error(swig::type_name<value_type>(), item);
	    SWIG_append_errmsg(msg);
	  }
	  return 0;
	}
      }
      return 1;  
    }

  private:
    PyObject* _seq;
  };

}
%}


/**** The python container methods  ****/


%define %swig_container_methods(Container...)
  // __getitem__ is required to raise an IndexError for for-loops to work
  // other methods which can raise are made to throw an IndexError as well
  %exception __getitem__ {
    try { $action }
    catch (std::out_of_range& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }
    }
    SWIG_CATCH_UNKNOWN
  }

  %exception __setitem__ {
    try { $action }
    catch (std::out_of_range& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }
    }
    SWIG_CATCH_UNKNOWN
  }

  %exception __getslice__ {
    try { $action }
    catch (std::out_of_range& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }
    }
    SWIG_CATCH_UNKNOWN
  }


  %exception __setslice__ {
    try { $action }
    catch (std::out_of_range& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }
    }
    catch (std::invalid_argument& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_TypeError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }      
    }
    SWIG_CATCH_UNKNOWN
  }

  %exception __delslice__ {
    try { $action }
    catch (std::out_of_range& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }
    }
    SWIG_CATCH_UNKNOWN
  }

  %exception __delitem__ {
    try { $action }
    catch (std::out_of_range& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }
    }
    SWIG_CATCH_UNKNOWN
  }

  %exception pop  {
    try { $action }
    catch (std::out_of_range& e) {
      if (!PyErr_Occurred()) {
	SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
      } else {
	SWIG_fail;
      }
    }
    SWIG_CATCH_UNKNOWN
  }

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
  %swig_container_methods(SWIG_arg(Sequence))
  %fragment("PySequence_Base");

  %extend {
    value_type pop() {
      if (self->size() == 0)
	throw std::out_of_range("pop from empty container");
      Sequence::value_type x = self->back();
      self->pop_back();
      return x;
    }

    Sequence* __getslice__(difference_type i, difference_type j) {
      return swig::getslice(self, i, j);
    }

    void __setslice__(difference_type i, difference_type j, const Sequence& v) {
      swig::setslice(self, i, j, v);
    }

    void __delslice__(difference_type i, difference_type j) {
      swig::delslice(self, i, j);
    }

    void __delitem__(difference_type i) {
      self->erase(swig::getpos(self,i));
    }
  }
%enddef

%define %swig_sequence_methods(Sequence...)
  %swig_sequence_methods_common(SWIG_arg(Sequence))
  %extend {
    const value_type& __getitem__(difference_type i) const {
      return *(swig::cgetpos(self, i));
    }

    void __setitem__(difference_type i, const value_type& x) {
      *(swig::getpos(self,i)) = x;
    }

    void append(const value_type& x) {
      self->push_back(x);
    }
 }
%enddef

%define %swig_sequence_methods_val(Sequence...)
  %swig_sequence_methods_common(SWIG_arg(Sequence))
  %extend {
    value_type __getitem__(difference_type i)  {
      return *(swig::cgetpos(self, i));
    }

    void __setitem__(difference_type i, value_type x) {
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
	  fragment="StdTraits",fragment="PyObject_var",
	  fragment="PySequence_Cont")
%{
  namespace swig {
    template <class PySeq, class Seq> 
    static inline void
    assign(const PySeq& pyseq, Seq* seq) {
#ifdef SWIG_STD_NOASSIGN_STL
      typedef typename PySeq::value_type value_type;
      typename PySeq::const_iterator it = pyseq.begin();
      for (;it != pyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
#else
      seq->assign(pyseq.begin(), pyseq.end());
#endif
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
	      if (!PyErr_Occurred())
		PyErr_SetString(PyExc_TypeError, e.what());
	    }
	    return 0;
	  }
	} else {
	  sequence *p;
	  if (SWIG_ConvertPtr(obj,(void**)&p,
			      swig::type_info<sequence>(),0) != -1) {
	    if (seq) *seq = p;
	    return 1;
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
%}
