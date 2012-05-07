// R specific swig components
/*
  Vectors
  Thanks to Richard Beare - richard.beare@ieee.org for StdVectorTraits
*/ 

%fragment("StdVectorTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    // vectors of doubles
    template <>
      struct traits_from_ptr<std::vector<double> > {
      static SEXP from (std::vector<double > *val, int owner = 0) {
	SEXP result;
	PROTECT(result = Rf_allocVector(REALSXP, val->size()));
	for (unsigned pos = 0; pos < val->size(); pos++)
	  {
	    NUMERIC_POINTER(result)[pos] = ((*val)[pos]);
	  }
	UNPROTECT(1);
	return(result);
      }
    };
    // vectors of floats
    template <>
      struct traits_from_ptr<std::vector<float> > {
      static SEXP from (std::vector<float > *val, int owner = 0) {
	SEXP result;
	PROTECT(result = Rf_allocVector(REALSXP, val->size()));
	for (unsigned pos = 0; pos < val->size(); pos++)
	  {
	    NUMERIC_POINTER(result)[pos] = ((*val)[pos]);
	  }
	UNPROTECT(1);
	return(result);
      }
    };
    // vectors of unsigned int
    template <>
      struct traits_from_ptr<std::vector<unsigned int> > {
      static SEXP from (std::vector<unsigned int > *val, int owner = 0) {
	SEXP result;
	PROTECT(result = Rf_allocVector(INTSXP, val->size()));
	for (unsigned pos = 0; pos < val->size(); pos++)
	  {
	    INTEGER_POINTER(result)[pos] = ((*val)[pos]);
	  }
	UNPROTECT(1);
	return(result);
      }
    };
    // vectors of int
    template <>
      struct traits_from_ptr<std::vector<int> > {
      static SEXP from (std::vector<int > *val, int owner = 0) {
	SEXP result;
	PROTECT(result = Rf_allocVector(INTSXP, val->size()));
	for (unsigned pos = 0; pos < val->size(); pos++)
	  {
	    INTEGER_POINTER(result)[pos] = ((*val)[pos]);
	  }
	UNPROTECT(1);
	return(result);
      }
    };
    // vectors of bool
    template <>
      struct traits_from_ptr<std::vector<bool> > {
      static SEXP from (std::vector<bool> *val, int owner = 0) {
	SEXP result;
	PROTECT(result = Rf_allocVector(LGLSXP, val->size()));
	for (unsigned pos = 0; pos < val->size(); pos++)
	  {
	    LOGICAL_POINTER(result)[pos] = ((*val)[pos]);
	  }
	UNPROTECT(1);
	return(result);
	//return SWIG_R_NewPointerObj(val, type_info< std::vector<T > >(), owner);
      }
    };
    // vectors of strings
    template <>
      struct traits_from_ptr<std::vector<std::basic_string<char> > > {
      static SEXP from (std::vector<std::basic_string<char> > *val, int owner = 0) {
	SEXP result;
	 PROTECT(result = Rf_allocVector(STRSXP, val->size()));
	 for (unsigned pos = 0; pos < val->size(); pos++)
	   {
	     CHARACTER_POINTER(result)[pos] = Rf_mkChar(((*val)[pos]).c_str()); 
	   } 
	UNPROTECT(1);
	return(result);
	//return SWIG_R_NewPointerObj(val, type_info< std::vector<T > >(), owner);
      }
    };

    // catch all that does everything with vectors
    template <typename T>
      struct traits_from_ptr< std::vector< T > > {
      static SEXP from (std::vector< T > *val, int owner = 0) {
	return SWIG_R_NewPointerObj(val, type_info< std::vector< T >  >(), owner);
      }
    };

    template <>
  struct traits_asptr < std::vector<double> > {   
    static int asptr(SEXP obj, std::vector<double> **val) {
      std::vector<double> *p;
      // not sure how to check the size of the SEXP obj is correct
      unsigned int sexpsz = Rf_length(obj);
      p = new std::vector<double>(sexpsz);
      double *S = NUMERIC_POINTER(obj);
      for (unsigned pos = 0; pos < p->size(); pos++)
	{
	  (*p)[pos] = static_cast<double>(S[pos]);
	}
      int res = SWIG_OK;
      if (SWIG_IsOK(res)) {
	if (val) *val = p;
      }
      return res;
    }
  }; 

    template <>
  struct traits_asptr < std::vector<float> > {   
    static int asptr(SEXP obj, std::vector<float> **val) {
      std::vector<float> *p;
      // not sure how to check the size of the SEXP obj is correct
      unsigned int sexpsz = Rf_length(obj);
      p = new std::vector<float>(sexpsz);
      double *S = NUMERIC_POINTER(obj);
      for (unsigned pos = 0; pos < p->size(); pos++)
	{
	  (*p)[pos] = static_cast<double>(S[pos]);
	}
      int res = SWIG_OK;
      if (SWIG_IsOK(res)) {
	if (val) *val = p;
      }
      return res;
    }
  }; 
   
    template <>
  struct traits_asptr < std::vector<unsigned int> > {   
    static int asptr(SEXP obj, std::vector<unsigned int> **val) {
      std::vector<unsigned int> *p;
      unsigned int sexpsz = Rf_length(obj);
      p = new std::vector<unsigned int>(sexpsz);
      SEXP coerced;
      PROTECT(coerced = Rf_coerceVector(obj, INTSXP));
      int *S = INTEGER_POINTER(coerced);
      for (unsigned pos = 0; pos < p->size(); pos++)
	{
	  (*p)[pos] = static_cast<unsigned int>(S[pos]);
	}
      int res = SWIG_OK;
      if (SWIG_IsOK(res)) {
	if (val) *val = p;
      }
      UNPROTECT(1);
      return res;
    }
  }; 

    template <>
  struct traits_asptr < std::vector<int> > {   
    static int asptr(SEXP obj, std::vector<int> **val) {
      std::vector<int> *p;
      // not sure how to check the size of the SEXP obj is correct
      int sexpsz = Rf_length(obj);
      p = new std::vector<int>(sexpsz);
      SEXP coerced;
      PROTECT(coerced = Rf_coerceVector(obj, INTSXP));
      int *S = INTEGER_POINTER(coerced);
      for (unsigned pos = 0; pos < p->size(); pos++)
	{
	  (*p)[pos] = static_cast<int>(S[pos]);
	}
      int res = SWIG_OK;
      if (SWIG_IsOK(res)) {
	if (val) *val = p;
      }
      UNPROTECT(1);
      return res;
    }
  }; 

    // catchall for R to vector conversion
  template <typename T>
  struct traits_asptr < std::vector<T> > {   
    static int asptr(SEXP obj, std::vector<T> **val) {
      std::vector<T> *p;
     int res = SWIG_R_ConvertPtr(obj, (void**)&p, type_info< std::vector<T> >(), 0);
      if (SWIG_IsOK(res)) {
	if (val) *val = p;
      }
      return res;
    }
  }; 


  }
%}

#define %swig_vector_methods(Type...) %swig_sequence_methods(Type)
#define %swig_vector_methods_val(Type...) %swig_sequence_methods_val(Type);

%define %traits_type_name(Type...)
%fragment(SWIG_Traits_frag(Type), "header",
	  fragment="StdTraits",fragment="StdVectorTraits") {
  namespace swig {
    template <>  struct traits< Type > {
      typedef pointer_category category;
      static const char* type_name() {
	return #Type;
      }
    };
  }
 }
%enddef

%include <std/std_vector.i>

%typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<double>)
%traits_type_name(std::vector<double>)
%typemap("rtypecheck") std::vector<double> %{ is.numeric($arg) %}
%typemap("rtype") std::vector<double> "numeric"

%typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<float>)
%traits_type_name(std::vector<float>)
%typemap("rtypecheck") std::vector<float> %{ is.numeric($arg) %}
%typemap("rtype") std::vector<float> "numeric"

%typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<bool>);
%traits_type_name(std::vector<bool>);
%typemap("rtypecheck") std::vector<bool> %{ is.logical($arg) %}
%typemap("rtype") std::vector<bool> "logical"

%typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<int>);
%traits_type_name(std::vector<int>);
%typemap("rtypecheck") std::vector<int> 
   %{ is.integer($arg) || is.numeric($arg) %}
%typemap("rtype") std::vector<int> "integer"
%typemap("scoercein") std::vector<int> "$input = as.integer($input);";

%typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<unsigned int>);
%traits_type_name(std::vector<unsigned int>);
%typemap("rtypecheck") std::vector<unsigned int> 
%{ is.integer($arg) || is.numeric($arg) %}
%typemap("rtype") std::vector<unsigned int> "integer"
%typemap("scoercein") std::vector<unsigned int> "$input = as.integer($input);";

// we don't want these to be given R classes as they
// have already been turned into R vectors.
%typemap(scoerceout) std::vector<double>,
   std::vector<double> *,
   std::vector<double> &,
   std::vector<bool>,
   std::vector<bool> *,
   std::vector<bool> &,
   std::vector<unsigned int>,
   std::vector<unsigned int> *,
   std::vector<unsigned int> &
 %{    %}


