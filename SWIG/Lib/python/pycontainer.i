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


/**** The PySequence C++ Wrap ***/

%insert(header) %{
#if PY_VERSION_HEX < 0x02000000
#define PySequence_Size PySequence_Length
#endif
#include <stdexcept>
%}

%fragment("PySequence_Base","header")
%{
namespace swigpy {
  inline size_t
  check_index(ptrdiff_t i, size_t size) {
    if ( i < 0 ) {
      if ((size_t) (-i) <= size) 
	return (size_t) (i + size);
    } else if ( (size_t) i < size ) {
      return (size_t) i;
    }
    throw std::out_of_range("index out of range");
  }

  inline size_t
  slice_index(ptrdiff_t i, size_t size) {
    if ( i < 0 ) {
      return ((size_t) (-i) <= size) ? (size_t) (i + size) : 0;
    } else {
      return ( (size_t) i < size ) ? ((size_t) i) 
	: (size ? (size_t)(size - 1) : 0);
    }
  }

  template <class Sequence, class Difference>
  inline typename Sequence::iterator 
  getpos(Sequence* self, Difference i)  {
    typename Sequence::iterator pos = self->begin(); 
    std::advance(pos, swigpy::check_index(i, self->size()));
    return pos;
  }

  template <class Sequence, class Difference>
  inline typename Sequence::const_iterator 
  getpos(const Sequence* self, Difference i)  {
    typename Sequence::const_iterator pos = self->begin(); 
    std::advance(pos, swigpy::check_index(i, self->size()));
    return pos;
  }

  template <class Sequence, class Difference>
  inline Sequence*
  getslice(const Sequence* self, Difference i, Difference j) { 
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = swigpy::slice_index(i, size);
    typename Sequence::size_type jj = swigpy::slice_index(j, size);
    if (jj > ii) {
      return new Sequence(getpos(self, ii), getpos(self, jj));
    } else {
      return new Sequence();
    }
  }

  template <class Sequence, class Difference, class InputSeq>
  inline void
  setslice(Sequence* self, Difference i, Difference j, const InputSeq& v) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = swigpy::slice_index(i, size);
    typename Sequence::size_type jj = swigpy::slice_index(j, size);
    if (jj < ii) jj = ii;
    typename InputSeq::const_iterator vmid = getpos(&v, jj - ii);
    self->insert(std::copy(v.begin(), vmid, getpos(self,ii)), vmid, v.end());
  }
 
  template <class Sequence, class Difference>
  inline void
  delslice(Sequence* self, Difference i, Difference j) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = swigpy::slice_index(i, size);
    typename Sequence::size_type jj = swigpy::slice_index(j, size);
    if (jj > ii) {
      self->erase(getpos(self,ii), getpos(self,jj));
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
namespace swigpy
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
      swigpy::PyObject_var item = PySequence_GetItem(_seq, _index);
      try {
	return swigpy::as<T>(item, true);
      } catch (std::exception& e) {
	PyErr_Format(PyExc_TypeError, 
		     "error in sequence element %d: %s", _index, e.what());
	throw;
      }
    }
    
    PySequence_Ref& operator=(const T& v) 
    {
      PySequence_SetItem(_seq, _index, swigpy::from<T>(v));
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
	swigpy::PyObject_var item = PySequence_GetItem(_seq, i);
	if (!swigpy::check<value_type>(item)) {
	  if (set_err) {
	    PyErr_Format(PyExc_TypeError, 
			 "element %d is not of type '%s' as expected",
			 i, swigpy::type_name<value_type>());
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


%define %pycontainer_methods(Container)
  // __getitem__ is required to raise an IndexError for for-loops to work
  // other methods which can raise are made to throw an IndexError as well
  %exception __getitem__ {
    try { $action }
    catch (std::out_of_range& e) {
      SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
  }

  %exception __setitem__ {
    try { $action }
    catch (std::out_of_range& e) {
      SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
  }

  %exception __setslice__ {
    try { $action }
    catch (std::invalid_argument& e) {
      SWIG_exception(SWIG_TypeError,const_cast<char*>(e.what()));
    }
  }

  %exception __delitem__ {
    try { $action }
    catch (std::out_of_range& e) {
      SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
  }

  %exception pop  {
    try { $action }
    catch (std::out_of_range& e) {
      SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
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

%define %pysequence_methods_common(Sequence)
  %pycontainer_methods(SWIG_arg(Sequence))
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
      return swigpy::getslice(self, i, j);
    }

    void __setslice__(difference_type i, difference_type j, const Sequence& v) {
      swigpy::setslice(self, i, j, v);
    }

    void __delslice__(difference_type i, difference_type j) {
      swigpy::delslice(self, i, j);
    }

    void __delitem__(difference_type i) {
      self->erase(swigpy::getpos(self,i));
    }
  }
%enddef

%define %pysequence_methods(Sequence)
  %pysequence_methods_common(SWIG_arg(Sequence))
  %extend {
    const value_type& __getitem__(difference_type i) const {
      return *(swigpy::getpos(self, i));
    }

    void __setitem__(difference_type i, const value_type& x) {
      *(swigpy::getpos(self,i)) = x;
    }

    void append(const value_type& x) {
      self->push_back(x);
    }
 }
%enddef

%define %pysequence_methods_val(Sequence)
  %pysequence_methods_common(SWIG_arg(Sequence))
  %extend {
    value_type __getitem__(difference_type i)  {
      return *(swigpy::getpos(self, i));
    }

    void __setitem__(difference_type i, value_type x) {
      *(swigpy::getpos(self,i)) = x;
    }

    void append(value_type x) {
      self->push_back(x);
    }
 }
%enddef


%define %pydict_methods(Dict)
  %pycontainer_methods(SWIG_arg(Dict))

  %extend {
    mapped_type __getitem__(const key_type& key) const {
      Dict::const_iterator i = self->find(key);
      if (i != self->end())
	return i->second;
      else
	throw std::out_of_range("key not found");
    }
    
    void __setitem__(const key_type& key, const mapped_type& x) {
      self->insert(Dict::value_type(key,x));
    }
    
    void __delitem__(const key_type& key) {
      Dict::iterator i = self->find(key);
      if (i != self->end())
	self->erase(i);
      else
	throw std::out_of_range("key not found");
    }
    
    bool has_key(const key_type& key) const {
      Dict::const_iterator i = self->find(key);
      return i != self->end();
    }
    
    PyObject* keys() {
      Dict::size_type size = self->size();
      int pysize = size <= INT_MAX ? (int) size : 0;
      if (!pysize) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	Py_INCREF(Py_None);
	return Py_None;
      }
      PyObject* keyList = PyList_New(pysize);
      Dict::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyList_SetItem(keyList, j, swigpy::from(i->first));
      }
      return keyList;
    }
    
    PyObject* values() {
      Dict::size_type size = self->size();
      int pysize = size <= INT_MAX ? (int) size : 0;
      if (!pysize) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	Py_INCREF(Py_None);
	return Py_None;
      }
      PyObject* valList = PyTuple_New(pysize);
      Dict::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyTuple_SetItem(valList, j, swigpy::from(i->second));
      }
      return valList;
    }
    
    PyObject* items() {
      Dict::size_type size = self->size();
      int pysize = size <= INT_MAX ? (int) size : 0;
      if (!pysize) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	Py_INCREF(Py_None);
	return Py_None;
      }    
      PyObject* itemList = PyTuple_New(pysize);
      Dict::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyTuple_SetItem(itemList, j, swigpy::from(*i));
      }
      return itemList;
    }
    
    // Python 2.2 methods
    bool __contains__(const key_type& key) {
      return self->find(key) != self->end();
    }

    PyObject* __iter__() {
      Dict::size_type size = self->size();
      int pysize = size <= INT_MAX ? (int) size : 0;
      if (!pysize) {
	PyErr_SetString(PyExc_OverflowError,
			"map size not valid in python");
	Py_INCREF(Py_None);
	return Py_None;
      }
      PyObject* keyList = PyList_New(pysize);
      Dict::const_iterator i = self->begin();
      for (int j = 0; j < pysize; ++i, ++j) {
	PyList_SetItem(keyList, j, swigpy::from(i->first));
      }
%#if PY_VERSION_HEX >= 0x02020000
      PyObject* iter = PyObject_GetIter(keyList);
      Py_DECREF(keyList);
      return iter;
%#else
      return keyList;
%#endif
    }
  }
%enddef
