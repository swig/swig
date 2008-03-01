/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * pycontainer.swg
 *
 * Octave sequence <-> C++ container wrapper
 *
 * This wrapper, and its iterator, allows a general use (and reuse) of
 * the the mapping between C++ and Octave, thanks to the C++
 * templates.
 *
 * Of course, it needs the C++ compiler to support templates, but
 * since we will use this wrapper with the STL containers, that should
 * be the case.
 * ----------------------------------------------------------------------------- */

%{
#include <iostream>
%}


#if !defined(SWIG_NO_EXPORT_ITERATOR_METHODS)
# if !defined(SWIG_EXPORT_ITERATOR_METHODS)
#  define SWIG_EXPORT_ITERATOR_METHODS SWIG_EXPORT_ITERATOR_METHODS
# endif
#endif

%include <octiterators.swg>

// The Octave C++ Wrap

%insert(header) %{
#include <stdexcept>
%}

%include <std_except.i>

%fragment(SWIG_Traits_frag(octave_value),"header",fragment="StdTraits") {
namespace swig {
  template <>  struct traits<octave_value > {
    typedef value_category category;
    static const char* type_name() { return  "octave_value"; }
  };
  
  template <>  struct traits_from<octave_value> {
    typedef octave_value value_type;
    static octave_value from(const value_type& val) {
      return val;
    }
  };
  
  template <> 
  struct traits_check<octave_value, value_category> {
    static bool check(octave_value) {
      return true;
    }
  };
  
  template <>  struct traits_asval<octave_value > {   
    typedef octave_value value_type;
    static int asval(octave_value obj, value_type *val) {
      if (val) *val = obj;
      return SWIG_OK;
    }
  };
}
}

%fragment("OctSequence_Base","header")
{
%#include <functional>

namespace std {
  template <>
  struct less <octave_value>: public binary_function<octave_value, octave_value, bool>
  {
    bool
    operator()(octave_value v, octave_value w) const
    { 
      /*
      bool res;
      SWIG_PYTHON_THREAD_BEGIN_BLOCK;
      res = PyObject_Compare(v, w) < 0;
      SWIG_PYTHON_THREAD_END_BLOCK;
      return res;
      */
      return false;
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
    size_t ssize = jj - ii;
    if (ssize <= v.size()) {
      typename Sequence::iterator sb = self->begin();
      typename InputSeq::const_iterator vmid = v.begin();
      std::advance(sb,ii);
      std::advance(vmid, jj - ii);
      self->insert(std::copy(v.begin(), vmid, sb), vmid, v.end());
    } else {
      typename Sequence::iterator sb = self->begin();
      typename Sequence::iterator se = self->begin();
      std::advance(sb,ii);
      std::advance(se,jj);
      self->erase(sb,se);
      self->insert(sb, v.begin(), v.end());
    }
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

%fragment("OctSequence_Cont","header",
	  fragment="StdTraits",
	  fragment="OctSequence_Base",
	  fragment="OctSwigIterator_T")
{
namespace swig
{
  template <class T>
  struct OctSequence_Ref
  {
    OctSequence_Ref(octave_value seq, int index)
      : _seq(seq), _index(index)
    {
    }
    
    operator T () const
    {
      //      swig::PyObject_var item = OctSequence_GetItem(_seq, _index);
      octave_value item; // * todo
      try {
	return swig::as<T>(item, true);
      } catch (std::exception& e) {
	char msg[1024];
	sprintf(msg, "in sequence element %d ", _index);
	if (!Octave_Error_Occurred()) {
	  %type_error(swig::type_name<T>());
	}
	SWIG_Octave_AddErrorMsg(msg);
	SWIG_Octave_AddErrorMsg(e.what());
	throw;
      }
    }

    OctSequence_Ref& operator=(const T& v)
    {
      //      OctSequence_SetItem(_seq, _index, swig::from<T>(v));
      // * todo
      return *this;
    }

  private:
    octave_value _seq;
    int _index;
  };

  template <class T>
  struct OctSequence_ArrowProxy
  {
    OctSequence_ArrowProxy(const T& x): m_value(x) {}
    const T* operator->() const { return &m_value; }
    operator const T*() const { return &m_value; }
    T m_value;
  };

  template <class T, class Reference >
  struct OctSequence_InputIterator
  {
    typedef OctSequence_InputIterator<T, Reference > self;

    typedef std::random_access_iterator_tag iterator_category;
    typedef Reference reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;

    OctSequence_InputIterator()
    {
    }

    OctSequence_InputIterator(octave_value seq, int index)
      : _seq(seq), _index(index)
    {
    }

    reference operator*() const
    {
      return reference(_seq, _index);
    }

    OctSequence_ArrowProxy<T>
    operator->() const {
      return OctSequence_ArrowProxy<T>(operator*());
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

    bool operator < (const self& ri) const
    {
      return _index < ri._index;
    }

    reference
    operator[](difference_type n) const
    {
      return reference(_seq, _index + n);
    }

  private:
    octave_value _seq;
    difference_type _index;
  };

  template <class T>
  struct OctSequence_Cont
  {
    typedef OctSequence_Ref<T> reference;
    typedef const OctSequence_Ref<T> const_reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;
    typedef int size_type;
    typedef const pointer const_pointer;
    typedef OctSequence_InputIterator<T, reference> iterator;
    typedef OctSequence_InputIterator<T, const_reference> const_iterator;

    OctSequence_Cont(octave_value seq) : _seq(seq)
    {
      // * assert that we have map type etc.
      /*
      if (!OctSequence_Check(seq)) {
	throw std::invalid_argument("a sequence is expected");
      }
      _seq = seq;
      Py_INCREF(_seq);
      */
    }

    ~OctSequence_Cont()
    {
    }

    size_type size() const
    {
      //      return static_cast<size_type>(OctSequence_Size(_seq));
      return 0; // * todo
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
	//	swig::PyObject_var item = OctSequence_GetItem(_seq, i);
	octave_value item; // * todo
	if (!swig::check<value_type>(item)) {
	  if (set_err) {
	    char msg[1024];
	    sprintf(msg, "in sequence element %d", i);
	    SWIG_Error(SWIG_RuntimeError, msg);
	  }
	  return false;
	}
      }
      return true;
    }

  private:
    octave_value _seq;
  };

}
}

%define %swig_sequence_iterator(Sequence...)
#if defined(SWIG_EXPORT_ITERATOR_METHODS)
  class iterator;
  class reverse_iterator;
  class const_iterator;
  class const_reverse_iterator;

  %typemap(out,noblock=1,fragment="OctSequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    /*
    $result = SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &)),
				 swig::OctSwigIterator::descriptor(),SWIG_POINTER_OWN);
    */
  }
  %typemap(out,noblock=1,fragment="OctSequence_Cont")
    std::pair<iterator, iterator>, std::pair<const_iterator, const_iterator> {
    /*
    $result = PyTuple_New(2);
    PyTuple_SetItem($result,0,SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).first),
						 swig::OctSwigIterator::descriptor(),SWIG_POINTER_OWN));
    PyTuple_SetItem($result,1,SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).second),
						 swig::OctSwigIterator::descriptor(),SWIG_POINTER_OWN));    
    */
  }

  %fragment("PyPairBoolOutputIterator","header",fragment=SWIG_From_frag(bool),fragment="OctSequence_Cont") {}

  %typemap(out,noblock=1,fragment="OctPairBoolOutputIterator")
    std::pair<iterator, bool>, std::pair<const_iterator, bool> {
    /*
    $result = PyTuple_New(2);
    PyTuple_SetItem($result,0,SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).first),
					       swig::OctSwigIterator::descriptor(),SWIG_POINTER_OWN));    
    PyTuple_SetItem($result,1,SWIG_From(bool)(%static_cast($1,const $type &).second));
    */
  }

  %typemap(in,noblock=1,fragment="OctSequence_Cont")
    iterator(swig::OctSwigIterator *iter = 0, int res),
    reverse_iterator(swig::OctSwigIterator *iter = 0, int res),
    const_iterator(swig::OctSwigIterator *iter = 0, int res),
    const_reverse_iterator(swig::OctSwigIterator *iter = 0, int res) {
    /*
    res = SWIG_ConvertPtr($input, %as_voidptrptr(&iter), swig::OctSwigIterator::descriptor(), 0);
    if (!SWIG_IsOK(res) || !iter) {
      %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
    } else {
      swig::OctSwigIterator_T<$type > *iter_t = dynamic_cast<swig::OctSwigIterator_T<$type > *>(iter);
      if (iter_t) {
	$1 = iter_t->get_current();
      } else {
	%argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
      }
    }
    */
  }

  %typecheck(%checkcode(ITERATOR),noblock=1,fragment="OctSequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    /*
    swig::OctSwigIterator *iter = 0;
    int res = SWIG_ConvertPtr($input, %as_voidptrptr(&iter), swig::OctSwigIterator::descriptor(), 0);
    $1 = (SWIG_IsOK(res) && iter && (dynamic_cast<swig::OctSwigIterator_T<$type > *>(iter) != 0));
    */
  }

  %fragment("OctSequence_Cont");
#endif //SWIG_EXPORT_ITERATOR_METHODS
%enddef

// The octave container methods

%define %swig_container_methods(Container...)
%enddef

%define %swig_sequence_methods_common(Sequence...)
  %swig_sequence_iterator(%arg(Sequence))
  %swig_container_methods(%arg(Sequence))
  
  %fragment("OctSequence_Base");
%enddef

%define %swig_sequence_methods(Sequence...)
  %swig_sequence_methods_common(%arg(Sequence))
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
	  fragment="OctSequence_Cont")
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

    static int asptr(octave_value obj, sequence **seq) {
      /*
      if (obj == Py_None || SWIG_Python_GetSwigThis(obj)) {
	sequence *p;
	if (SWIG_ConvertPtr(obj,(void**)&p,
			    swig::type_info<sequence>(),0) == SWIG_OK) {
	  if (seq) *seq = p;
	  return SWIG_OLDOBJ;
	}
      } else if (OctSequence_Check(obj)) {
	try {
	  OctSequence_Cont<value_type> pyseq(obj);
	  if (seq) {
	    sequence *pseq = new sequence();
	    assign(pyseq, pseq);
	    *seq = pseq;
	    return SWIG_NEWOBJ;
	  } else {
	    return pyseq.check() ? SWIG_OK : SWIG_ERROR;
	  }
	} catch (std::exception& e) {
	  if (seq) {
	    if (!PyErr_Occurred()) {
	      PyErr_SetString(PyExc_TypeError, e.what());
	    }
	  }
	  return SWIG_ERROR;
	}
      }
      return SWIG_ERROR;
      */
      return SWIG_ERROR;
    }
  };

  template <class Seq, class T = typename Seq::value_type >
  struct traits_from_stdseq {
    typedef Seq sequence;
    typedef T value_type;
    typedef typename Seq::size_type size_type;
    typedef typename sequence::const_iterator const_iterator;

    static octave_value from(const sequence& seq) {
      /*
#ifdef SWIG_PYTHON_EXTRA_NATIVE_CONTAINERS
      swig_type_info *desc = swig::type_info<sequence>();
      if (desc && desc->clientdata) {
	return SWIG_NewPointerObj(new sequence(seq), desc, SWIG_POINTER_OWN);
      }
#endif
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
	PyErr_SetString(PyExc_OverflowError,"sequence size not valid in python");
	return NULL;
      }
      */
      return octave_value();
    }
  };
}
}

