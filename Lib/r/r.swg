/* */


%insert("header") "swiglabels.swg"

%insert("init") "swiginit.swg"
%insert("runtime") "swigrun.swg"
%insert("runtime") "swigerrors.swg"
%insert("runtime") "rrun.swg"

%init %{
SWIGEXPORT void SWIG_init(void) {
%}

%include <rkw.swg>

#define %Rruntime %insert("s")

#define SWIG_Object SEXP
#define VOID_Object R_NilValue

#define %append_output(obj) SET_VECTOR_ELT($result, $n, obj)

%define %set_constant(name, obj) %begin_block
   SEXP _obj = obj;
   assign(name, _obj);
%end_block %enddef

%runtime %{
SWIGINTERN void SWIG_R_Raise(SEXP obj, const char *msg) {
  Rf_error("%s", Rf_isString(obj) ? CHAR(Rf_asChar(obj)) : msg);
}
%}

#define %raise(OBJ, TYPE, DESC) SWIG_R_Raise(OBJ, "C/C++ exception of type " TYPE); return R_NilValue

%insert("sinit") "srun.swg"

%insert("sinitroutine") %{
SWIG_init();
SWIG_InitializeModule(0);
%}

%include <typemaps/swigmacros.swg>
%typemap(in) (double *x, int len) %{
   $1 = Rf_length(x) ? REAL(x) : 0;
   $2 = Rf_length(x);
%}

/* XXX
   Need to worry about inheritance, e.g. if B extends A 
   and we are looking for an A[], then B elements are okay.
*/
%typemap(scheck) SWIGTYPE[ANY]  
  %{ 
#      assert(length($input) > $1_dim0)
      assert(all(sapply($input, class) == "$R_class"));
  %}

%typemap(out) void ""

%typemap(in) int *,
	     signed int *,
	     unsigned int *,
             short *,
             signed short *,
             unsigned short *,
             long *,
             signed long *,
             unsigned long *,
             long long *,
             signed long long *,
             unsigned long long *
             
{
{ int _rswigi;
  int _rswiglen = Rf_length($input);
  $1 = _rswiglen ? %static_cast(calloc(sizeof($1_basetype), _rswiglen), $1_ltype) : 0;
  for (_rswigi=0; _rswigi< _rswiglen; _rswigi++) {
     $1[_rswigi] = INTEGER($input)[_rswigi];
  }
}
} 

%typemap(in) float *,
             double *
             
{
{  int _rswigi;
  int _rswiglen = Rf_length($input);
  $1 = _rswiglen ? %static_cast(calloc(sizeof($1_basetype), _rswiglen), $1_ltype) : 0;
  for (_rswigi=0; _rswigi<_rswiglen; _rswigi++) {
     $1[_rswigi] = REAL($input)[_rswigi];
  }
}
}

%typemap(freearg,noblock=1) int *, 
	     signed int *,
	     unsigned int *,
             short *,
             signed short *,
             unsigned short *,
             long *,
             signed long *,
             unsigned long *,
             long long *,
             signed long long *,
             unsigned long long *,
             float *,
             double *
%{             
  free($1);
%}

%typemap(freearg, noblock=1) int *OUTPUT,
signed int *OUTPUT,
unsigned int *OUTPUT,
short *OUTPUT,
signed short *OUTPUT,
unsigned short *OUTPUT,
long *OUTPUT,
signed long *OUTPUT,
unsigned long *OUTPUT,
long long *OUTPUT,
signed long long *OUTPUT,
unsigned long long *OUTPUT,
float *OUTPUT,
double *OUTPUT,
char *OUTPUT,
signed char *OUTPUT,
unsigned char *OUTPUT
{}



/* Should we recycle to make the length correct.
   And warn if length() > the dimension. 
*/
%typemap(scheck) SWIGTYPE [ANY] %{
#  assert(length($input) >= $1_dim0)
%}

/* Handling vector case to avoid warnings,
   although we just use the first one. */
%typemap(scheck) unsigned int %{
  assert(length($input) == 1 && $input >= 0, "All values must be non-negative");
%}


%typemap(scheck) int, long %{
  if(length($input) > 1) {
     warning("using only the first element of $input");
  };
%}

%include <typemaps/fragments.swg>
%include <rfragments.swg>
%include <ropers.swg>
%include <typemaps/swigtypemaps.swg>
%include <rtype.swg>

/* A fixed size array is copied from a vector of up to that many elements, any after a shorter vector being 0 */
%define %r_fixed_size_array(TYPE, ELEMENT)
%typemap(in,noblock=1) TYPE [ANY] ($1_basetype temp[$1_dim0], int i, int len) {
  len = Rf_length($input);
  if (len > (int)($1_dim0)) {
    %argument_fail(SWIG_OverflowError, "$type", $symname, $argnum);
  }
  for (i = 0; i < len; i++)
    temp[i] = ($1_basetype)ELEMENT($input)[i];
  for (; i < (int)($1_dim0); i++)
    temp[i] = ($1_basetype)0;
  $1 = len ? temp : 0;
}
%typemap(freearg) TYPE [ANY] ""
%enddef

%r_fixed_size_array(int, INTEGER)
%r_fixed_size_array(signed int, INTEGER)
%r_fixed_size_array(unsigned int, INTEGER)
%r_fixed_size_array(short, INTEGER)
%r_fixed_size_array(signed short, INTEGER)
%r_fixed_size_array(unsigned short, INTEGER)
%r_fixed_size_array(long, INTEGER)
%r_fixed_size_array(signed long, INTEGER)
%r_fixed_size_array(unsigned long, INTEGER)
%r_fixed_size_array(long long, INTEGER)
%r_fixed_size_array(signed long long, INTEGER)
%r_fixed_size_array(unsigned long long, INTEGER)
%r_fixed_size_array(signed char, INTEGER)
%r_fixed_size_array(unsigned char, INTEGER)
%r_fixed_size_array(size_t, INTEGER)
%r_fixed_size_array(std::size_t, INTEGER)
%r_fixed_size_array(ptrdiff_t, INTEGER)
%r_fixed_size_array(std::ptrdiff_t, INTEGER)
%r_fixed_size_array(enum SWIGTYPE, INTEGER)
%r_fixed_size_array(float, REAL)
%r_fixed_size_array(double, REAL)

%typemap(in,noblock=1,fragment="SWIG_strdup") char * {
   $1 = Rf_length($input) ? %reinterpret_cast(SWIG_strdup(CHAR(STRING_ELT($input, 0))), $1_ltype) : 0;
}

%typemap(freearg,noblock=1) char * {
   free($1);
}

%typemap(in,noblock=1,fragment="SWIG_strdup") char *[ANY] (char *temp[$1_dim0], char *copies[$1_dim0]) {
  {
    int i;
    int len = Rf_length($input);
    if (len == 0) {
      %argument_nullref("$type", $symname, $argnum);
    }
    if (!Rf_isString($input)) {
      %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
    }
    if (len > (int)($1_dim0)) {
      %argument_fail(SWIG_OverflowError, "$type", $symname, $argnum);
    }
    for (i = 0; i < len; i++) {
      copies[i] = temp[i] = SWIG_strdup(CHAR(STRING_ELT($input, i)));
    }
    for (; i < (int)($1_dim0); i++) {
      copies[i] = temp[i] = 0;
    }
    $1 = temp;
  }
}

/* Frees the strings from the in typemap, which the wrapped function may have replaced in the array */
%typemap(freearg,noblock=1) char *[ANY] {
  if ($1) {
    int i;
    for (i = 0; i < (int)($1_dim0); i++) {
      free(copies$argnum[i]);
    }
  }
}

/* A variable keeps copies of the strings, as for char *, as freearg frees those from the in typemap */
%define %r_char_ptr_array_variable(METHOD)
%typemap(METHOD,canthrow=1,noblock=1,fragment="<string.h>") char *[ANY] {
  if (!$input) {
    SWIG_exception_fail(SWIG_NullReferenceError, "invalid null reference in variable '$name' of type '$1_type'");
  } else {
    size_t ii;
    for (ii = 0; ii < (size_t)$1_dim0; ii++) {
      %delete_array($1[ii]);
      $1[ii] = $input[ii] ? strcpy(%new_array(strlen($input[ii]) + 1, char), $input[ii]) : 0;
    }
  }
}
%enddef
%r_char_ptr_array_variable(memberin)
%r_char_ptr_array_variable(globalin)

/* char[ANY] uses the Lib/typemaps typemaps, which copy the string into a zero filled array of the declared size */
%typemap(in,noblock=1,fragment="SWIG_strdup") char[] {
    if (Rf_length($input) == 0) {
      %argument_nullref("$type", $symname, $argnum);
    }
    $1 = SWIG_strdup(CHAR(STRING_ELT($input, 0)));
}

%typemap(freearg,noblock=1) char[] {
    free($1);
}

%typemap(in,noblock=1) const enum SWIGTYPE & ($*1_ltype temp) {
  if (Rf_length($input) == 0) {
    %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
  }
  temp = ($*1_ltype)INTEGER($input)[0];
  $1 = &temp;
}

%typemap(out) const enum SWIGTYPE & %{ $result = Rf_ScalarInteger((int)*$1); %}

%typemap(out,noblock=1) char * 
 {  $result = $1 ? Rf_mkString(%reinterpret_cast($1,char *)) : R_NilValue; }

%typemap(in,noblock=1) char {
  if (Rf_length($input) == 0) {
    %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
  }
  $1 = %static_cast(CHAR(STRING_ELT($input, 0))[0],$1_ltype);
}

%typemap(out) char 
 { 
    char tmp[2] = "x";
    tmp[0] = $1;    
    $result = Rf_mkString(tmp); 
 }


%typemap(in,noblock=1) int, long
{
  if (Rf_length($input) == 0) {
    %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
  }
  $1 = %static_cast(INTEGER($input)[0], $1_ltype);
}

%typemap(out,noblock=1) int, long
  "$result = Rf_ScalarInteger($1);";


%typemap(in,noblock=1) bool
{
  if (Rf_length($input) == 0) {
    %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
  }
  $1 = LOGICAL($input)[0] ? true : false;
}


%typemap(out,noblock=1) bool 
  "$result = Rf_ScalarLogical($1);";

%typemap(in,noblock=1) 
             float, 
             double
{
  if (Rf_length($input) == 0) {
    %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
  }
  $1 = %static_cast(REAL($input)[0], $1_ltype);
}

/* Why is this here ? */
/* %typemap(out,noblock=1) unsigned int *
  "$result = ScalarReal(*($1));"; */

%Rruntime %{
setMethod('[', "ExternalReference",
function(x,i,j, ..., drop=TRUE) 
if (!is.null(x$"__getitem__")) 
sapply(i, function(n) x$"__getitem__"(i=as.integer(n-1))))

setMethod('[<-' , "ExternalReference",
function(x,i,j, ..., value) 
if (!is.null(x$"__setitem__")) {
sapply(1:length(i), function(n) 
x$"__setitem__"(i=as.integer(i[n]-1), x=value[n]))
x
})

setAs('ExternalReference', 'character',
function(from) {if (!is.null(from$"__str__")) from$"__str__"()})

suppressMessages(suppressWarnings(setMethod('print', 'ExternalReference',
function(x) {print(as(x, "character"))})))
%}



