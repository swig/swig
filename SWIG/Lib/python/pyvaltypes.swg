/* in */

%define PY_IN_TYPEMAP(type, pyobj_as)
  %typemap(in,fragment=#pyobj_as) type
    "$1 = ($1_type) pyobj_as($input); 
     if (PyErr_Occurred()) SWIG_fail;"
  %typemap(in) const type& ($basetype temp)
    "temp = ($basetype) pyobj_as($input);
     if (PyErr_Occurred()) SWIG_fail;
     $1 = &temp;";
%enddef

/* out */

%define PY_OUT_TYPEMAP(type, pyobj_from)
  %typemap(out,fragment=#pyobj_from) type 
  "$result = pyobj_from((type)$1);";
  %typemap(out,fragment=#pyobj_from) const type& 
  "$result = pyobj_from((type)*($1));";
%enddef

/* varin */

%define PY_VARIN_TYPEMAP(type, pyobj_as)
  %typemap(varin,fragment=#pyobj_as) type {
    $1_type temp = ($1_type) pyobj_as($input);  
    if (PyErr_Occurred()) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
    }
    $1 = temp;
  }
%enddef

/* varout */

%define PY_VAROUT_TYPEMAP(type, pyobj_from)
  %typemap(varout,fragment=#pyobj_from)
           type, const type&  "$result = pyobj_from((type)$1);";
%enddef


/* Primitive types */
%define PY_CONSTCODE_TYPEMAP(type, pyobj_from)
  %typemap(constcode,fragment=#pyobj_from) type 
     "PyDict_SetItemString(d,\"$symname\", pyobj_from((type)$value));";
%enddef

/* directorin */

%define PY_DIRECTORIN_TYPEMAP(type, pyobj_from)
  %typemap(directorin,fragment=#pyobj_from) type *DIRECTORIN 
  "$input = pyobj_from((type)*$1_name);";
  %typemap(directorin,fragment=#pyobj_from) type, const type& 
  "$input = pyobj_from((type)$1_name);";
%enddef

/* directorout */

%define PY_DIRECTOROUT_TYPEMAP(Type, pyobj_as)
  %typemap(directorargout,fragment=#pyobj_as) Type *DIRECTOROUT
    "*$result = ($basetype) pyobj_as($input);
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
%typemap(directorout,fragment=#pyobj_as) Type
    "$result = ($basetype) pyobj_as($input);
    if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
%typemap(directorout,fragment=#pyobj_as) const Type&
    "$basetype temp = ($basetype) pyobj_as($input);
     $result = &temp;
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
  %typemap(directorout,fragment=#pyobj_as) Type &DIRECTOROUT = Type
%enddef

/* throws */

%define PY_THROWS_TYPEMAP(type, pyobj_from)
  %typemap(throws,fragment=#pyobj_from) type {
  PyErr_SetObject(PyExc_RuntimeError, pyobj_from((type)$1));
    SWIG_fail;
  }
%enddef

/* typecheck */

%define PY_TYPECHECK_TYPEMAP(check, type, pyobj_check)
%typemap(typecheck,precedence=SWIG_TYPECHECK_##check,
	 fragment=#pyobj_check) type, const type&
 "$1 = pyobj_check($input);";
%enddef

/*
  typemap definition for types with As/From/Check methods
 */

%define %typemap_asfromcheck(Type, CheckCode, AsType, FromType, CheckType)  
  PY_IN_TYPEMAP(Type, AsType);
  PY_OUT_TYPEMAP(Type, FromType);
  PY_VARIN_TYPEMAP(Type, AsType);
  PY_VAROUT_TYPEMAP(Type, FromType);
  PY_CONSTCODE_TYPEMAP(Type, FromType);
  PY_DIRECTORIN_TYPEMAP(Type, FromType);
  PY_DIRECTOROUT_TYPEMAP(Type, AsType);
  PY_THROWS_TYPEMAP(Type, FromType);
  PY_TYPECHECK_TYPEMAP(CheckCode, Type, CheckType);
%enddef

/*
  typemap for simple swig types with only As/From conversor methods
  named as SWIG_As##Name/SWIG_From##Name.
*/
%define %typemap_stype(Type, CheckCode, Name)  
%fragment("SWIG_Check"#Name,"header",
	  fragment="SWIG_As"#Name) %{
SWIGSTATICINLINE(int)
SWIG_Check##Name(PyObject* obj)
{
  SWIG_As##Name(obj);
  if (PyErr_Occurred()) {
    PyErr_Clear();
    return 0;
  } else {
    return 1;
  }
}
%}
%typemap_asfromcheck(Type, CheckCode, SWIG_As##Name, 
		     SWIG_From##Name, SWIG_Check##Name)
%enddef
