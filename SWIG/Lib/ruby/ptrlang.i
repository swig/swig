//
// Pointer library for Ruby
//
// $Header$
//
// Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
// Copyright (C) 2000  Information-technology Promotion Agency, Japan
//
// Masaki Fukushima
//
// Originally derived from python/ptrlang.i
//

//
// SWIG pointer conversion and utility library
// 
// Dave Beazley
// April 19, 1997
//
// Python specific implementation.   This file is included
// by the file ../pointer.i

%{
#include <ctype.h>

/* Pointer library specific types */

static _swig_type_info _swig_pointer_int_p[] = {{"_p_int",0},{"_p_int",0},{0}};
static _swig_type_info _swig_pointer_short_p[] = {{"_p_short",0},{"_p_short",0},{0}};
static _swig_type_info _swig_pointer_long_p[] = {{"_p_long",0},{"_p_long",0},{0}};
static _swig_type_info _swig_pointer_float_p[] = {{"_p_float",0},{"_p_float",0},{0}};
static _swig_type_info _swig_pointer_double_p[] = {{"_p_double",0},{"_p_double",0},{0}};
static _swig_type_info _swig_pointer_char_p[] = {{"_p_char",0},{"_p_char",0},{0}};
static _swig_type_info _swig_pointer_char_pp[] = {{"_pp_char",0},{"_pp_char",0},{0}};

static _swig_type_info *_swig_pointer_types[] = {
   _swig_pointer_int_p,
   _swig_pointer_short_p,
   _swig_pointer_long_p,
   _swig_pointer_float_p,
   _swig_pointer_double_p,
   _swig_pointer_char_p,
   _swig_pointer_char_pp,
   0
};

#define SWIG_POINTER_int_p     _swig_pointer_types[0]
#define SWIG_POINTER_short_p   _swig_pointer_types[1]
#define SWIG_POINTER_long_p    _swig_pointer_types[2]
#define SWIG_POINTER_float_p   _swig_pointer_types[3]
#define SWIG_POINTER_double_p  _swig_pointer_types[4]
#define SWIG_POINTER_char_p    _swig_pointer_types[5]
#define SWIG_POINTER_char_pp   _swig_pointer_types[6]

/*------------------------------------------------------------------
  ptrcast(value,type)

  Constructs a new pointer value.   Value may either be a string
  or an integer. Type is a string corresponding to either the
  C datatype or mangled datatype.

  ptrcast(0,"Vector *")
               or
  ptrcast(0,"Vector_p")   
  ------------------------------------------------------------------ */

static VALUE ptrcast(VALUE _PTRVALUE, char *type) {

  char *r,*s;
  void *ptr;
  VALUE obj;
  char *typestr,*c;
  _swig_type_info   temptype;

  /* Produce a "mangled" version of the type string.  */

  typestr = (char *) malloc(strlen(type)+2);
  
  /* Go through and munge the typestring */
  
  r = typestr;
  *(r++) = '_';
  c = type;
  while (*c) {
    if (!isspace(*c)) {
      if ((*c == '*') || (*c == '&')) {
	*(r++) = 'p';
      }
      else *(r++) = *c;
    } else {
        *(r++) = '_';
    }
    c++;
  }
  *(r++) = 0;
  /* Check to see what kind of object _PTRVALUE is */
  switch (TYPE(_PTRVALUE)) {
  case T_FIXNUM:
  case T_BIGNUM:
    ptr = (void *) NUM2LONG(_PTRVALUE);
    /* Received a numerical value. Make a pointer out of it */
    temptype.name = typestr;
    obj = SWIG_NewPointerObj(ptr,&temptype);
    obj = rb_str_new2(r);
    break;
  default:
    /* Now extract the pointer value */
    ptr = SWIG_ConvertPtr(_PTRVALUE,0);
    temptype.name=typestr;
    obj = SWIG_NewPointerObj(ptr,&temptype);
  }
  if (!obj) 
    rb_raise(rb_eTypeError,"Type error in ptrcast. Argument is not a valid pointer value.");
  return obj;
}

/*------------------------------------------------------------------
  ptrvalue(ptr,type = 0)

  Attempts to dereference a pointer value.  If type is given, it 
  will try to use that type.  Otherwise, this function will attempt
  to "guess" the proper datatype by checking against all of the 
  builtin C datatypes. 
  ------------------------------------------------------------------ */

static VALUE ptrvalue(VALUE _PTRVALUE, int index, char *type) {
  void     *ptr;
  char     *s;
  VALUE obj;

  ptr = SWIG_ConvertPtr(_PTRVALUE,0);

  /* If no datatype was passed, try a few common datatypes first */
  if (!type) {
    /* No datatype was passed.   Type to figure out if it's a common one */
    if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_int_p)) {
      type = "int";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_double_p)) {
      type = "double";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_short_p)) {
      type = "short";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_long_p)) {
      type = "long";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_float_p)) {
      type = "float";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_char_p)) {
      type = "char";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_char_pp)) {
      type = "char *";
    } else {
      type = "unknown";
    }
  }
  if (!ptr) {
    rb_raise(rb_eTypeError,"Unable to dereference NULL pointer.");
  }
  /* Now we have a datatype.  Try to figure out what to do about it */
  if (strcmp(type,"int") == 0) {
    obj = LONG2NUM((long) *(((int *) ptr) + index));
  } else if (strcmp(type,"double") == 0) {
    obj = rb_float_new((double) *(((double *) ptr)+index));
  } else if (strcmp(type,"short") == 0) {
    obj = LONG2NUM((long) *(((short *) ptr)+index));
  } else if (strcmp(type,"long") == 0) {
    obj = LONG2NUM((long) *(((long *) ptr)+index));
  } else if (strcmp(type,"float") == 0) {
    obj = rb_float_new((double) *(((float *) ptr)+index));
  } else if (strcmp(type,"char") == 0) {
    obj = rb_str_new2(((char *) ptr)+index);
  } else if (strcmp(type,"char *") == 0) {
    char *c = *(((char **) ptr)+index);
    if (c) obj = rb_str_new2(c);
    else obj = rb_str_new2("NULL");
  } else {
    rb_raise(rb_eTypeError,"Unable to dereference unsupported datatype.");
  }
  return obj;
}

/*------------------------------------------------------------------
  ptrcreate(type,value = 0,numelements = 1)

  Attempts to create a new object of given type.  Type must be
  a basic C datatype.  Will not create complex objects.
  ------------------------------------------------------------------ */

static VALUE ptrcreate(char *type, VALUE _RBVALUE, int numelements) {
  void     *ptr;
  VALUE obj;
  int       sz;
  _swig_type_info *cast;
  char      temp[40];

  /* Check the type string against a variety of possibilities */

  if (strcmp(type,"int") == 0) {
    sz = sizeof(int)*numelements;
    cast = SWIG_POINTER_int_p;
  } else if (strcmp(type,"short") == 0) {
    sz = sizeof(short)*numelements;
    cast = SWIG_POINTER_short_p;
  } else if (strcmp(type,"long") == 0) {
    sz = sizeof(long)*numelements;
    cast = SWIG_POINTER_long_p;
  } else if (strcmp(type,"double") == 0) {
    sz = sizeof(double)*numelements;
    cast = SWIG_POINTER_double_p;
  } else if (strcmp(type,"float") == 0) {
    sz = sizeof(float)*numelements;
    cast = SWIG_POINTER_float_p;
  } else if (strcmp(type,"char") == 0) {
    sz = sizeof(char)*numelements;
    cast = SWIG_POINTER_char_p;
  } else if (strcmp(type,"char *") == 0) {
    sz = sizeof(char *)*(numelements+1);
    cast = SWIG_POINTER_char_pp;
  } else {
    rb_raise(rb_eTypeError,"Unable to create unknown datatype."); 
  }
   
  /* Create the new object */
  
  ptr = (void *) malloc(sz);
  if (!ptr) {
    rb_raise(rb_eFatal,"Out of memory in swig_create."); 
  }

  /* Now try to set its default value */

  if (_RBVALUE) {
    if (strcmp(type,"int") == 0) {
      int *ip,i,ivalue;
      ivalue = (int) NUM2LONG(_RBVALUE);
      ip = (int *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"short") == 0) {
      short *ip,ivalue;
      int i;
      ivalue = (short) NUM2LONG(_RBVALUE);
      ip = (short *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"long") == 0) {
      long *ip,ivalue;
      int i;
      ivalue = (long) NUM2LONG(_RBVALUE);
      ip = (long *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"double") == 0) {
      double *ip,ivalue;
      int i;
      ivalue = (double) NUM2DBL(_RBVALUE);
      ip = (double *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"float") == 0) {
      float *ip,ivalue;
      int i;
      ivalue = (float) NUM2DBL(_RBVALUE);
      ip = (float *) ptr;
      for (i = 0; i < numelements; i++)
	ip[i] = ivalue;
    } else if (strcmp(type,"char") == 0) {
      char *ip,*ivalue;
      ivalue = (char *) STR2CSTR(_RBVALUE);
      ip = (char *) ptr;
      strncpy(ip,ivalue,numelements-1);
    } else if (strcmp(type,"char *") == 0) {
      char **ip, *ivalue;
      int  i;
      ivalue = (char *) STR2CSTR(_RBVALUE);
      ip = (char **) ptr;
      for (i = 0; i < numelements; i++) {
	if (ivalue) {
	  ip[i] = (char *) malloc(strlen(ivalue)+1);
	  strcpy(ip[i],ivalue);
	} else {
	  ip[i] = 0;
	}
      }
      ip[numelements] = 0;
    }
  } 
  /* Create the pointer value */
  
  obj = SWIG_NewPointerObj(ptr,cast);
  return obj;
}


/*------------------------------------------------------------------
  ptrset(ptr,value,index = 0,type = 0)

  Attempts to set the value of a pointer variable.  If type is
  given, we will use that type.  Otherwise, we'll guess the datatype.
  ------------------------------------------------------------------ */

static VALUE ptrset(VALUE _PTRVALUE, VALUE _RBVALUE, int index, char *type) {
  void     *ptr;
  VALUE obj;

  ptr = SWIG_ConvertPtr(_PTRVALUE,0);

  /* If no datatype was passed, try a few common datatypes first */
  if (!type) {
    /* No datatype was passed.   Type to figure out if it's a common one */
    if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_int_p)) {
      type = "int";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_double_p)) {
      type = "double";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_short_p)) {
      type = "short";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_long_p)) {
      type = "long";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_float_p)) {
      type = "float";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_char_p)) {
      type = "char";
    } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_char_pp)) {
      type = "char *";
    } else {
      type = "unknown";
    }
  }
  if (!ptr) {
    rb_raise(rb_eTypeError,"Unable to set NULL pointer.");
  }
  
  /* Now we have a datatype.  Try to figure out what to do about it */
  if (strcmp(type,"int") == 0) {
    *(((int *) ptr)+index) = (int) NUM2LONG(_RBVALUE);
  } else if (strcmp(type,"double") == 0) {
    *(((double *) ptr)+index) = (double) NUM2DBL(_RBVALUE);
  } else if (strcmp(type,"short") == 0) {
    *(((short *) ptr)+index) = (short) NUM2LONG(_RBVALUE);
  } else if (strcmp(type,"long") == 0) {
    *(((long *) ptr)+index) = (long) NUM2LONG(_RBVALUE);
  } else if (strcmp(type,"float") == 0) {
    *(((float *) ptr)+index) = (float) NUM2DBL(_RBVALUE);
  } else if (strcmp(type,"char") == 0) {
    char *c = STR2CSTR(_RBVALUE);
    strcpy(((char *) ptr)+index, c);
  } else if (strcmp(type,"char *") == 0) {
    char *c = STR2CSTR(_RBVALUE);
    char **ca = (char **) ptr;
    if (ca[index]) free(ca[index]);
    if (strcmp(c,"NULL") == 0) {
      ca[index] = 0;
    } else {
      ca[index] = (char *) malloc(strlen(c)+1);
      strcpy(ca[index],c);
    }
  } else {
    rb_raise(rb_eTypeError,"Unable to set unsupported datatype.");
  }
  return Qnil;
}

/*------------------------------------------------------------------
  ptradd(ptr,offset)

  Adds a value to an existing pointer value.  Will do a type-dependent
  add for basic datatypes.  For other datatypes, will do a byte-add.
  ------------------------------------------------------------------ */

static VALUE ptradd(VALUE _PTRVALUE, int offset) {

  char *r;
  void *ptr,*junk;
  VALUE obj;
  _swig_type_info *type;

  ptr = SWIG_ConvertPtr(_PTRVALUE,0);

  /* Check to see what kind of object _PTRVALUE is */
  
  /* Try to handle a few common datatypes first */
  if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_int_p)) {
    ptr = (void *) (((int *) ptr) + offset);
    type = SWIG_POINTER_int_p;
  } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_double_p)) {
    ptr = (void *) (((double *) ptr) + offset);
    type = SWIG_POINTER_double_p;
  } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_short_p)) {
    ptr = (void *) (((short *) ptr) + offset);
    type = SWIG_POINTER_short_p;
  } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_long_p)) {
    ptr = (void *) (((long *) ptr) + offset);
    type = SWIG_POINTER_long_p;
  } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_float_p)) {
    ptr = (void *) (((float *) ptr) + offset);
    type = SWIG_POINTER_float_p;
  } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_char_p)) {
    ptr = (void *) (((char *) ptr) + offset);
    type = SWIG_POINTER_char_p;
  } else if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_char_pp)) {
    ptr = (void *) (((char *) ptr) + offset);
    type = SWIG_POINTER_char_pp;
  } else {
    rb_raise(rb_eTypeError,"Type error in ptradd. Argument is not a valid pointer value.");
  }
  obj = SWIG_NewPointerObj(ptr, type);
  return obj;
}

/*------------------------------------------------------------------
  ptrmap(type1,type2)

  Allows a mapping between type1 and type2. (Like a typedef)
  ------------------------------------------------------------------ */
static void ptrmap(char *type1, char *type2) {
  char *typestr1,*typestr2,*c,*r;

  /* Produce a "mangled" version of the type string.  */
  typestr1 = (char *) malloc(strlen(type1)+2);
  
  /* Go through and munge the typestring */
  r = typestr1;
  *(r++) = '_';
  c = type1;
  while (*c) {
    if (!isspace(*c)) {
      if ((*c == '*') || (*c == '&')) {
	*(r++) = 'p';
      }
      else *(r++) = *c;
    } else {
      *(r++) = '_';
    }
    c++;
  }
  *(r++) = 0;
  
  typestr2 = (char *) malloc(strlen(type2)+2);

  /* Go through and munge the typestring */
  
  r = typestr2;
  *(r++) = '_';
  c = type2;
  while (*c) {
    if (!isspace(*c)) {
      if ((*c == '*') || (*c == '&')) {
	*(r++) = 'p';
      }
      else *(r++) = *c;
    } else {
      *(r++) = '_';
    }
    c++;
  }
  *(r++) = 0;
  
  /* Currently unsupported */
  /*
  SWIG_RegisterMapping(typestr1,typestr2,0);
  SWIG_RegisterMapping(typestr2,typestr1,0);
  */
}

/*------------------------------------------------------------------
  ptrfree(ptr)

  Destroys a pointer value
  ------------------------------------------------------------------ */

VALUE ptrfree(VALUE _PTRVALUE) {
  void *ptr;

  ptr = SWIG_ConvertPtr(_PTRVALUE,0);
  
  /* Check to see if this pointer is a char ** */
  if (SWIG_CheckConvert(_PTRVALUE,SWIG_POINTER_char_pp)) {
    char **c = (char **) ptr;
    if (c) {
      int i = 0;
      while (c[i]) {
	free(c[i]);
	i++;
      }
    }
  }
  if (ptr)
    free((char *) ptr);

  return Qnil;
}

%}
%typemap(ruby,in) VALUE ptr, VALUE value {
  $target = $source;
}

%typemap(ruby,out) VALUE ptrcast,
                     VALUE ptrvalue,
                     VALUE ptrcreate,
                     VALUE ptrset,
                     VALUE ptradd,
                     VALUE ptrfree  
{
  $target = $source;
}

%typemap(ruby,ret) int ptrset {
  if ($source == -1) return Qnil;
}

VALUE ptrcast(VALUE ptr, char *type); 
// Casts a pointer ptr to a new datatype given by the string type.
// type may be either the SWIG generated representation of a datatype
// or the C representation.  For example :
// 
//    ptrcast(ptr,"double_p");   # Ruby representation
//    ptrcast(ptr,"double *");    # C representation
//
// A new pointer value is returned.   ptr may also be an integer
// value in which case the value will be used to set the pointer
// value.  For example :
//
//    a = ptrcast(0,"Vector_p");
//
// Will create a NULL pointer of type "Vector_p"
//
// The casting operation is sensitive to formatting.  As a result,
// "double *" is different than "double*".  As a result of thumb,
// there should always be exactly one space between the C datatype
// and any pointer specifiers (*).

VALUE ptrvalue(VALUE ptr, int index = 0, char *type = 0);
// Returns the value that a pointer is pointing to (ie. dereferencing).
// The type is automatically inferred by the pointer type--thus, an
// integer pointer will return an integer, a double will return a double,
// and so on.   The index and type fields are optional parameters.  When
// an index is specified, this function returns the value of ptr[index].
// This allows array access.   When a type is specified, it overrides
// the given pointer type.   Examples :
//
//    ptrvalue(a)             #  Returns the value *a
//    ptrvalue(a,10)          #  Returns the value a[10]
//    ptrvalue(a,10,"double") #  Returns a[10] assuming a is a double *

VALUE ptrset(VALUE ptr, VALUE value, int index = 0, char *type = 0);
// Sets the value pointed to by a pointer.  The type is automatically
// inferred from the pointer type so this function will work for
// integers, floats, doubles, etc...  The index and type fields are
// optional.  When an index is given, it provides array access.  When
// type is specified, it overrides the given pointer type.  Examples :
// 
//   ptrset(a,3)            # Sets the value *a = 3
//   ptrset(a,3,10)         # Sets a[10] = 3
//   ptrset(a,3,10,"int")   # Sets a[10] = 3 assuming a is a int *

VALUE ptrcreate(char *type, VALUE value = 0, int nitems = 1);
// Creates a new object and returns a pointer to it.  This function 
// can be used to create various kinds of objects for use in C functions.
// type specifies the basic C datatype to create and value is an
// optional parameter that can be used to set the initial value of the
// object.  nitems is an optional parameter that can be used to create
// an array.  This function results in a memory allocation using
// malloc().  Examples :
//
//   a = ptrcreate("double")     # Create a new double, return pointer
//   a = ptrcreate("int",7)      # Create an integer, set value to 7
//   a = ptrcreate("int",0,1000) # Create an integer array with initial
//                               # values all set to zero
//
// This function only recognizes a few common C datatypes as listed below :
//
//        int, short, long, float, double, char, char *, void
//
// All other datatypes will result in an error.  However, other
// datatypes can be created by using the ptrcast function.  For
// example:
//
//  a = ptrcast(ptrcreate("int",0,100),"unsigned int *")

VALUE ptrfree(VALUE ptr);
// Destroys the memory pointed to by ptr.  This function calls free()
// and should only be used with objects created by ptrcreate().  Since
// this function calls free, it may work with other objects, but this
// is generally discouraged unless you absolutely know what you're
// doing.

VALUE ptradd(VALUE ptr, int offset);
// Adds a value to the current pointer value.  For the C datatypes of
// int, short, long, float, double, and char, the offset value is the
// number of objects and works in exactly the same manner as in C.  For
// example, the following code steps through the elements of an array
//
//  a = ptrcreate("double",0,100);    # Create an array double a[100]
//  b = a;
//  for i in range(0,100):
//      ptrset(b,0.0025*i);           # set *b = 0.0025*i
//      b = ptradd(b,1);              # b++ (go to next double)
//
// In this case, adding one to b goes to the next double.
// 
// For all other datatypes (including all complex datatypes), the
// offset corresponds to bytes.  This function does not perform any
// bounds checking and negative offsets are perfectly legal.  

void      ptrmap(char *type1, char *type2);
// This is a rarely used function that performs essentially the same
// operation as a C typedef.  To manage datatypes at run-time, SWIG
// modules manage an internal symbol table of type mappings.  This
// table keeps track of which types are equivalent to each other.  The
// ptrmap() function provides a mechanism for scripts to add symbols
// to this table.  For example :
//
//    ptrmap("double_p","Real_p");
//
// would make the types "doublePtr" and "RealPtr" equivalent to each
// other.  Pointers of either type could now be used interchangably.
//
// Normally this function is not needed, but it can be used to
// circumvent SWIG's normal type-checking behavior or to work around
// weird type-handling problems.

    
%init %{
  {
    int i;
    for (i = 0; _swig_pointer_types[i]; i++) {
      _swig_pointer_types[i] = SWIG_TypeRegister(_swig_pointer_types[i]);
      SWIG_define_class(_swig_pointer_types[i]);
    }
  }

  %}
    


