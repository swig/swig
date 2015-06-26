/* -----------------------------------------------------------------------------
 * matlabcontainer.swg
 *
 * MATLAB cell <-> C++ container wrapper
 *
 * This wrapper, and its iterator, allows a general use (and reuse) of
 * the mapping between C++ and MATLAB, thanks to the C++ templates.
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

%include <matlabiterators.swg>

// The Matlab C++ Wrap

%fragment("<stdexcept>");

%include <std_except.i>

%fragment(SWIG_Traits_frag(mxArray),"header",fragment="StdTraits") {
namespace swig {
  template <>  struct traits<mxArray* > {
    typedef value_category category;
    static const char* type_name() { return  "mxArray"; }
  };
  
  template <>  struct traits_from<mxArray*> {
    typedef mxArray* value_type;
    static mxArray* from(const value_type& val) {
      return val;
    }
  };
  
  template <> 
  struct traits_check<mxArray*, value_category> {
    static bool check(mxArray*) {
      return true;
    }
  };
  
  template <>  struct traits_asval<mxArray* > {   
    typedef mxArray* value_type;
    static int asval(mxArray* obj, value_type *val) {
      if (val) *val = obj;
      return SWIG_OK;
    }
  };
}
}

%fragment("MatlabSequence_Base","header",fragment="<stddef.h>")
{
%#include <functional>

namespace std {
#if 0
KT do we need this?
  template <>
  struct less <mxArray*>: public binary_function<mxArray*, mxArray*, bool>
  {
    bool
    operator()(mxArray* v, mxArray* w) const
    { 
      mxArray* res = do_binary_op(mxArray*::op_le,v,w);
      return res.is_true();
    }
  };
#endif
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

%fragment("MatlabSequence_Cont","header",
	  fragment="StdTraits",
	  fragment="MatlabSequence_Base",
	  fragment="MatlabSwigIterator_T")
{
namespace swig
{
  template <class T>
    struct MatlabSequence_Ref // * matlab can't support these, because of how assignment works
  {
    MatlabSequence_Ref(mxArray* const seq, int index)
      : _seq(seq), _index(index)
    {
    }
    
    operator T () const
    {
      //      swig::SwigVar_PyObject item = MatlabSequence_GetItem(_seq, _index);
      mxArray* item; // * todo
      try {
	return swig::as<T>(item, true);
      } catch (std::exception& e) {
	char msg[1024];
	sprintf(msg, "in sequence element %d ", _index);
	if (!Matlab_Error_Occurred()) {
	  %type_error(swig::type_name<T>());
	}
	SWIG_Matlab_AddErrorMsg(msg);
	SWIG_Matlab_AddErrorMsg(e.what());
	throw;
      }
    }

    MatlabSequence_Ref& operator=(const T& v)
    {
      //      MatlabSequence_SetItem(_seq, _index, swig::from<T>(v));
      // * todo
      return *this;
    }

  private:
    mxArray* _seq;
    int _index;
  };

  template <class T>
  struct MatlabSequence_ArrowProxy
  {
    MatlabSequence_ArrowProxy(const T& x): m_value(x) {}
    const T* operator->() const { return &m_value; }
    operator const T*() const { return &m_value; }
    T m_value;
  };

  template <class T, class Reference >
  struct MatlabSequence_InputIterator
  {
    typedef MatlabSequence_InputIterator<T, Reference > self;

    typedef std::random_access_iterator_tag iterator_category;
    typedef Reference reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;

    MatlabSequence_InputIterator()
    {
    }

    MatlabSequence_InputIterator(mxArray* const seq, int index)
      : _seq(seq), _index(index)
    {
    }

    reference operator*() const
    {
      return reference(_seq, _index);
    }

    MatlabSequence_ArrowProxy<T>
    operator->() const {
      return MatlabSequence_ArrowProxy<T>(operator*());
    }

    bool operator==(const self& ri) const
    {
      return (_index == ri._index);
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
    mxArray* _seq;
    difference_type _index;
  };

  template <class T>
  struct MatlabSequence_Cont
  {
    typedef MatlabSequence_Ref<T> reference;
    typedef const MatlabSequence_Ref<T> const_reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;
    typedef int size_type;
    typedef const pointer const_pointer;
    typedef MatlabSequence_InputIterator<T, reference> iterator;
    typedef MatlabSequence_InputIterator<T, const_reference> const_iterator;

    MatlabSequence_Cont(mxArray* const seq) : _seq(seq)
    {
      // * assert that we have map type etc.
      /*
      if (!MatlabSequence_Check(seq)) {
	throw std::invalid_argument("a sequence is expected");
      }
      _seq = seq;
      Py_INCREF(_seq);
      */
    }

    ~MatlabSequence_Cont()
    {
    }

    size_type size() const
    {
      //      return static_cast<size_type>(MatlabSequence_Size(_seq));
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
	//	swig::SwigVar_PyObject item = MatlabSequence_GetItem(_seq, i);
	mxArray* item; // * todo
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
    mxArray* _seq;
  };

}
}

%define %swig_sequence_iterator(Sequence...)
#if defined(SWIG_EXPORT_ITERATOR_METHODS)
  class iterator;
  class reverse_iterator;
  class const_iterator;
  class const_reverse_iterator;

  %typemap(out,noblock=1,fragment="MatlabSequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    $result = SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &)),
				 swig::MatlabSwigIterator::descriptor(),SWIG_POINTER_OWN);
  }
  %typemap(out,fragment="MatlabSequence_Cont")
    std::pair<iterator, iterator>, std::pair<const_iterator, const_iterator> {
    mxArray_list tmpc;
    tmpc.append(SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).first),
				   swig::MatlabSwigIterator::descriptor(),SWIG_POINTER_OWN));
    tmpc.append(SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).second),
				   swig::MatlabSwigIterator::descriptor(),SWIG_POINTER_OWN));
    $result = Cell(tmpc);
  }

  %fragment("SwigPyPairBoolOutputIterator","header",fragment=SWIG_From_frag(bool),fragment="MatlabSequence_Cont") {}

  %typemap(out,fragment="MatlabPairBoolOutputIterator")
    std::pair<iterator, bool>, std::pair<const_iterator, bool> {
    mxArray_list tmpc;
    tmpc.append(SWIG_NewPointerObj(swig::make_output_iterator(%static_cast($1,const $type &).first),
				   swig::MatlabSwigIterator::descriptor(),SWIG_POINTER_OWN));
    tmpc.append(SWIG_From(bool)(%static_cast($1,const $type &).second));
    $result = Cell(tmpc);
  }

  %typemap(in,noblock=1,fragment="MatlabSequence_Cont")
    iterator(swig::MatlabSwigIterator *iter = 0, int res),
    reverse_iterator(swig::MatlabSwigIterator *iter = 0, int res),
    const_iterator(swig::MatlabSwigIterator *iter = 0, int res),
    const_reverse_iterator(swig::MatlabSwigIterator *iter = 0, int res) {
    res = SWIG_ConvertPtr($input, %as_voidptrptr(&iter), swig::MatlabSwigIterator::descriptor(), 0);
    if (!SWIG_IsOK(res) || !iter) {
      %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
    } else {
      swig::MatlabSwigIterator_T<$type > *iter_t = dynamic_cast<swig::MatlabSwigIterator_T<$type > *>(iter);
      if (iter_t) {
	$1 = iter_t->get_current();
      } else {
	%argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
      }
    }
  }

  %typecheck(%checkcode(ITERATOR),noblock=1,fragment="MatlabSequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    swig::MatlabSwigIterator *iter = 0;
    int res = SWIG_ConvertPtr($input, %as_voidptrptr(&iter), swig::MatlabSwigIterator::descriptor(), 0);
    $1 = (SWIG_IsOK(res) && iter && (dynamic_cast<swig::MatlabSwigIterator_T<$type > *>(iter) != 0));
  }

  %fragment("MatlabSequence_Cont");
#endif //SWIG_EXPORT_ITERATOR_METHODS
%enddef

// The matlab container methods

%define %swig_container_methods(Container...)
%enddef

%define %swig_sequence_methods_common(Sequence...)
  %swig_sequence_iterator(%arg(Sequence))
  %swig_container_methods(%arg(Sequence))
  
  %fragment("MatlabSequence_Base");

  %extend {
    value_type pop() throw (std::out_of_range) {
      if (self->size() == 0)
	throw std::out_of_range("pop from empty container");
      Sequence::value_type x = self->back();
      self->pop_back();
      return x;
    }

    // KT TODO need to get this in matlab conventions
    value_type paren(difference_type i) throw (std::out_of_range) {
      return *(swig::cgetpos(self, i));
    }

    // KT TODO need to get this in matlab conventions
    void paren_asgn(difference_type i, value_type x) throw (std::out_of_range) {
      *(swig::getpos(self,i)) = x;
    }

    void append(value_type x) {
      self->push_back(x);
    }
  }

%enddef

%define %swig_sequence_methods(Sequence...)
  %swig_sequence_methods_common(%arg(Sequence))
%enddef

%define %swig_sequence_methods_val(Sequence...)
  %swig_sequence_methods_common(%arg(Sequence))
%enddef

//
// Common fragments
//

%fragment("StdSequenceTraits","header",
	  fragment="StdTraits",
	  fragment="MatlabSequence_Cont")
{
namespace swig {
  template <class Matlabseq, class Seq>
  inline void
  assign(const Matlabseq& matlabseq, Seq* seq) {
%#ifdef SWIG_STD_NOASSIGN_STL
    typedef typename Matlabseq::value_type value_type;
    typename Matlabseq::const_iterator it = matlabseq.begin();
    for (;it != matlabseq.end(); ++it) {
      seq->insert(seq->end(),(value_type)(*it));
    }
%#else
    seq->assign(matlabseq.begin(), matlabseq.end());
%#endif
  }

  template <class Seq, class T = typename Seq::value_type >
  struct traits_asptr_stdseq {
    typedef Seq sequence;
    typedef T value_type;

    static int asptr(mxArray* obj, sequence **seq) {
      if (obj && mxGetClassID(obj)==mxCELL_CLASS && mxGetM(obj)==1) {
        // TODO
        SWIG_Error(SWIG_SystemError, "Not implemented");
        return SWIG_ERROR;
      } else {
	sequence *p;
	if (SWIG_ConvertPtr(obj,(void**)&p,
			    swig::type_info<sequence>(),0) == SWIG_OK) {
	  if (seq) *seq = p;
	  return SWIG_OLDOBJ;
	}
      }
      return SWIG_ERROR;
    }
  };

  template <class Seq, class T = typename Seq::value_type >
  struct traits_from_stdseq {
    typedef Seq sequence;
    typedef T value_type;
    typedef typename Seq::size_type size_type;
    typedef typename sequence::const_iterator const_iterator;

    static mxArray* from(const sequence& seq) {
#ifdef SWIG_MATLAB_EXTRA_NATIVE_CONTAINERS
      swig_type_info *desc = swig::type_info<sequence>();
      if (desc && desc->clientdata) {
	return SWIG_NewPointerObj(new sequence(seq), desc, SWIG_POINTER_OWN);
      }
#endif

      size_type size = seq.size();
      if (size <= (size_type)INT_MAX) {
	mxArray* c = mxCreateCellMatrix(size,1);
	int i = 0;
	for (const_iterator it = seq.begin();
	     it != seq.end(); ++it, ++i) {
	  mxSetCell(c, i, swig::from<value_type>(*it));
	}
	return c;
      } else {
	SWIG_Error(SWIG_RuntimeError, "swig overflow error: sequence size not valid in matlab");
	return 0;
      }
      return 0;
    }
  };
}
}

