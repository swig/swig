//
// SWIG typemaps for std::string
// Luigi Ballabio
// Apr 8, 2002
//
// Python implementation

// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%include exception.i
%include std_container.i

%{
#include <string>
%}

namespace std {
  template <class _CharT> 
  class basic_string
  {
  public:
    typedef size_t size_type;    
    typedef ptrdiff_t difference_type;
    typedef _CharT value_type;
    typedef value_type reference;
    typedef value_type const_reference;
    
    static const size_type npos;

    basic_string(const _CharT* __s, size_type __n);

    // Capacity:

    size_type length() const;

    size_type max_size() const;

    size_type capacity() const;

    void reserve(size_type __res_arg = 0);


    // Modifiers:

    basic_string& 
    append(const basic_string& __str);

    basic_string& 
    append(const basic_string& __str, size_type __pos, size_type __n);

    basic_string& 
    append(const _CharT* __s, size_type __n);
    
    basic_string& 
    append(size_type __n, _CharT __c);

    basic_string& 
    assign(const basic_string& __str);

    basic_string& 
    assign(const basic_string& __str, size_type __pos, size_type __n);
    
    basic_string& 
    assign(const _CharT* __s, size_type __n);

    basic_string& 
    insert(size_type __pos1, const basic_string& __str);    

    basic_string& 
    insert(size_type __pos1, const basic_string& __str,
	   size_type __pos2, size_type __n);

    basic_string& 
    insert(size_type __pos, const _CharT* __s, size_type __n);

    basic_string& 
    insert(size_type __pos, size_type __n, _CharT __c);

    basic_string& 
    erase(size_type __pos = 0, size_type __n = npos);

    basic_string& 
    replace(size_type __pos, size_type __n, const basic_string& __str);

    basic_string& 
    replace(size_type __pos1, size_type __n1, const basic_string& __str,
	    size_type __pos2, size_type __n2);

    basic_string& 
    replace(size_type __pos, size_type __n1, const _CharT* __s,
	    size_type __n2);

    basic_string& 
    replace(size_type __pos, size_type __n1, size_type __n2, _CharT __c);

    %ignore pop_back();
    %ignore front() const;
    %ignore back() const;
    %ignore basic_string(size_type n);
    %std_sequence_methods_val(basic_string);    


    %ignore pop();
    %pysequence_methods_val(std::basic_string<_CharT>);

    #ifdef SWIG_EXPORT_ITERATOR_METHODS
    iterator 
    insert(iterator __p, _CharT __c = _CharT());

    iterator 
    erase(iterator __position);

    iterator 
    erase(iterator __first, iterator __last);

    void 
    insert(iterator __p, size_type __n, _CharT __c);

    basic_string& 
    replace(iterator __i1, iterator __i2, const basic_string& __str);

    basic_string& 
    replace(iterator __i1, iterator __i2,
	    const _CharT* __s, size_type __n);

    basic_string& 
    replace(iterator __i1, iterator __i2, const _CharT* __s);

    basic_string& 
    replace(iterator __i1, iterator __i2, size_type __n, _CharT __c);

    basic_string& 
    replace(iterator __i1, iterator __i2, _CharT* __k1, _CharT* __k2);

    basic_string& 
    replace(iterator __i1, iterator __i2, const _CharT* __k1, const _CharT* __k2);

    basic_string& 
    replace(iterator __i1, iterator __i2, iterator __k1, iterator __k2);

    basic_string& 
    replace(iterator __i1, iterator __i2, const_iterator __k1, const_iterator __k2);
    #endif
  };

  /*
    swig workaround. if used as expected, __iadd__ deletes 'self'.
  */
  %newobject basic_string<char>::__iadd__;    
  %extend basic_string<char> {
    std::string* __iadd__(const std::string& v) {
      *self += v;
      return new std::string(*self);
    }
    std::string __str__() {
      return *self;
    }
  }

  %std_equal_methods(basic_string<char>);
  %std_order_methods(basic_string<char>);

  typedef basic_string<char> string;

}

/* defining the std::string asptr/from methods */

%fragment(SWIG_AsPtr_frag(std::basic_string<char>),"header",
	  fragment="SWIG_AsCharPtrAndSize") {
SWIGSTATICINLINE(int)
  SWIG_AsPtr_meth(std::basic_string<char>)(PyObject* obj, std::string **val)
  {
    static swig_type_info* string_info = SWIG_TypeQuery("std::string *");
    std::string *vptr;    
    if (SWIG_ConvertPtr(obj, (void**)&vptr, string_info, 0) != -1) {
      if (val) *val = vptr;
      return SWIG_OLDOBJ;
    } else {
      PyErr_Clear();
      char* buf = 0 ; size_t size = 0;
      if (SWIG_AsCharPtrAndSize(obj, &buf, &size)) {
	if (buf) {
	  if (val) *val = new std::string(buf, size);
	  return SWIG_NEWOBJ;
	}
      } else {
	PyErr_Clear();
      }  
      if (val) {
	PyErr_SetString(PyExc_TypeError,"a string is expected");
      }
      return 0;
    }
  }
}

%fragment(SWIG_From_frag(std::basic_string<char>),"header",
	  fragment="SWIG_FromCharArray") {
SWIGSTATICINLINE(PyObject*)
  SWIG_From_meth(std::basic_string<char>)(const std::string& s)
  {
    return SWIG_FromCharArray(s.data(), s.size());
  }
}

%typemap_asptrfromn(SWIG_CCode(STRING), std::basic_string<char>);


