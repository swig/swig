%include std_common.i
%include pycontainer.i
%include exception.i

%{
#include <algorithm>
%}

// Common container methods

%define %std_container_methods(container)
  container();
  container(const container&);

  bool empty() const;
  size_type size() const;
  void clear();


  %extend {
    bool operator == (const container& v) {
      return *self == v;
    }
    
    bool operator != (const container& v) {
      return *self != v;
    }  
  }

  void swap(container& v);

  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator begin();
  const_iterator begin() const;
  iterator end();
  const_iterator end() const;
  reverse_iterator rbegin();
  const_reverse_iterator rbegin() const;
  reverse_iterator rend();
  const_reverse_iterator rend() const;
  #endif

%enddef

// Common sequence

%define %std_sequence_methods_common(sequence)
  
    %std_container_methods(SWIG_arg(sequence));
  
  sequence(size_type size);
  void pop_back();
  
  void resize(size_type new_size);
  
  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(iterator pos);
  iterator erase(iterator pos);
  iterator erase(iterator first, iterator last);
  #endif
  
%enddef


%define %std_sequence_methods(sequence)
  
  %std_sequence_methods_common(SWIG_arg(sequence));
  
  sequence(size_type size, const value_type& value);
  void push_back(const value_type& x);
  
  value_type& front();
  value_type& back();

  const value_type& front() const;
  const value_type& back() const;
 
  void assign(size_type n, const value_type& x);

  void resize(size_type new_size, const value_type& x);
  
  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(iterator pos, const value_type& x);
  void insert(iterator pos, size_type n, const value_type& x);
  #endif
  
%enddef

%define %std_sequence_methods_val(sequence)
  
  %std_sequence_methods_common(SWIG_arg(sequence));
  
  sequence(size_type size, value_type value);
  void push_back(value_type x);  

  value_type front() const;
  value_type back() const;
 
  void assign(size_type n, value_type x);

  void resize(size_type new_size, value_type x);
  
  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(iterator pos, value_type x);
  void insert(iterator pos, size_type n, value_type x);
  #endif
  
%enddef

//
// Common fragments
//

%fragment("StdSequenceTraits","header",
	  fragment="traits",fragment="PyObject_var",
	  fragment="PySequence_Cont")
%{
  namespace swigpy {
    template <class PySeq, class Seq> 
    void assign(const PySeq& pyseq, Seq* seq) {
      seq->assign(pyseq.begin(), pyseq.end());
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
	      return 2;
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
			      swigpy::type_info<sequence>(),0) != -1) {
	    if (seq) *seq = p;
	    return 1;
	  }
	}
	if (seq) {
	  PyErr_Format(PyExc_TypeError, "a %s is expected", 
		       swigpy::type_name<sequence>());
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
	    PyTuple_SetItem(obj,i,swigpy::from<value_type>(*it));
	  }
	  return obj;
	} else {
	  PyErr_SetString(PyExc_OverflowError,
			  "sequence size not valid in python");
	  Py_INCREF(Py_None);
	  return Py_None;
	}
      }
    };
  }
%}

%define %std_comp_methods(...)
%extend __VA_ARGS__ {
  bool operator > (const __VA_ARGS__& v) {
    return *self > v;
  }
  
  bool operator < (const __VA_ARGS__& v) {
    return *self < v;
  }

  bool operator >= (const __VA_ARGS__& v) {
    return *self >= v;
  }

  bool operator <= (const __VA_ARGS__& v) {
    return *self <= v;
  }  
}
%enddef
