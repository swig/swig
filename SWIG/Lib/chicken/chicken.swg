/* -----------------------------------------------------------------------------
 * chicken.swg
 *
 * CHICKEN configuration module.
 * ----------------------------------------------------------------------------- */

/* chicken.h has to appear first. */

%insert(runtime) %{
#include "chicken.h"
%}

%insert(runtime) "common.swg";          // Common type-checking code
%insert(runtime) "chickenrun.swg";      // CHICKEN run-time code

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */

/*
  CHICKEN: C
  ----------

  fixnum: int, short, unsigned int, unsigned short, unsigned char,
  signed char

  char: char

  bool: bool

  flonum: float, double, long, long long, unsigned long, unsigned long
  long
 */

/* --- Primitive types --- */

%include "fragments.i"

%define SIMPLE_TYPEMAP(type_, from_scheme, to_scheme, checker, convtype, storage_)

%typemap(in) type_ 
%{  if (!checker ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'type_'");
  }
  $1 = ($1_ltype) from_scheme ($input); %}

/* Const primitive references.  Passed by value */

%typemap(in) const type_ & (type_ temp)
%{  if (!checker ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'type_'");
  }
  temp = ($*1_ltype) from_scheme ($input); 
  $1 = &temp; %}

/* --- Variable input --- */
%typemap(varin) type_
%{  if (!checker ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Cannot use '$1_ltype' for variable '$name' of type 'type_'");
  }
  $1 = ($1_ltype) from_scheme ($input); %}

#if "storage_" == "0"

%typemap(out, fragment="list_output_helper",chicken_words="storage_") type_ 
%{/*if ONE*/
  $result = to_scheme (convtype ($1));
/*else*/
  $result = list_output_helper (&known_space, $result, to_scheme (convtype ($1)));
/*endif*/ %}

/* References to primitive types.  Return by value */

%typemap(out, fragment="list_output_helper",chicken_words="storage_") const type_ &
%{/*if ONE*/
  $result = to_scheme (convtype (*$1));
/*else*/
  $result = list_output_helper (&known_space, $result, to_scheme (convtype (*$1)));
/*endif*/ %}

/* --- Variable output --- */
%typemap(varout, fragment="list_output_helper",chicken_words="storage_") type_ 
%{/*if ONE*/
  $result = to_scheme (convtype ($varname));
/*else*/
  $result = list_output_helper (&known_space, $result, to_scheme (convtype ($varname)));
/*endif*/ %}

#else

%typemap(out, fragment="list_output_helper",chicken_words="storage_") type_ 
%{/*if ONE*/
  $result = to_scheme (&known_space, convtype ($1));
/*else*/
  $result = list_output_helper (&known_space, $result, to_scheme (&known_space, convtype ($1)));
/*endif*/ %}

/* References to primitive types.  Return by value */

%typemap(out, fragment="list_output_helper",chicken_words="storage_") const type_ &
%{/*if ONE*/
  $result = to_scheme (convtype (*$1));
/*else*/
  $result = list_output_helper (&known_space, $result, to_scheme (convtype (*$1)));
/*endif*/ %}

/* --- Variable output --- */
%typemap(varout, fragment="list_output_helper",chicken_words="storage_") type_ 
%{/*if ONE*/
  $result = to_scheme (&known_space, convtype ($varname));
/*else*/
  $result = list_output_helper (&known_space, $result, to_scheme (&known_space, convtype ($varname)));
/*endif*/ %}

#endif

/* --- Constants --- */

#if ("type_" == "char") || ("type_" == "unsigned char") || ("type_" == "signed char")
%typemap(constcode) type_
"static const type_ $result = '$value';"
#else
%typemap(constcode) type_
"static const type_ $result = $value;"
#endif

%enddef

SIMPLE_TYPEMAP(int, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(enum SWIGTYPE, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(short, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(long, C_flonum_magnitude, C_flonum, C_swig_is_flonum, (double), WORDS_PER_FLONUM);
SIMPLE_TYPEMAP(long long, C_flonum_magnitude, C_flonum, C_swig_is_flonum, (double), WORDS_PER_FLONUM);
SIMPLE_TYPEMAP(unsigned int, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(unsigned short, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(unsigned long, C_flonum_magnitude, C_flonum, C_swig_is_flonum, (double), WORDS_PER_FLONUM);
SIMPLE_TYPEMAP(unsigned long long, C_flonum_magnitude, C_flonum, C_swig_is_flonum, (double), WORDS_PER_FLONUM);
SIMPLE_TYPEMAP(unsigned char, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(signed char, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(char, C_character_code, C_make_character, C_swig_is_char, (char), 0);
SIMPLE_TYPEMAP(bool, C_truep, C_mkbool, C_swig_is_bool, (bool), 0);
SIMPLE_TYPEMAP(float, C_flonum_magnitude, C_flonum, C_swig_is_flonum, (double), WORDS_PER_FLONUM);
SIMPLE_TYPEMAP(double, C_flonum_magnitude, C_flonum, C_swig_is_flonum, (double), WORDS_PER_FLONUM);

/* --- Input arguments --- */

/* Strings */

%typemap(in) char * 
{ if ($input == C_SCHEME_FALSE) {
  $1 = NULL;
 }
 else { 
   if (!C_swig_is_string ($input)) {
     swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'char *'");
   }
   $1 = ($ltype) swig_make_string ($input);
 }
}

%typemap(freearg) char * "if ($1 != NULL) { free ($1); }"

/* Pointers, references, and arrays */
%typemap(in) SWIGTYPE *, 
             SWIGTYPE [] 
       "swig_convert_ptr($input,(void **) &$1, $1_descriptor,SWIG_POINTER_EXCEPTION);"

/* Additional check for null references */
%typemap(in) SWIGTYPE & 
"swig_convert_ptr($input,(void **) &$1, $1_descriptor,SWIG_POINTER_EXCEPTION);
 if ($1 == NULL) swig_barf (SWIG_BARF1_ARGUMENT_NULL, \"null reference\");"

/* Void pointer.  Accepts any kind of pointer */
%typemap(in) void * "swig_convert_ptr($input,(void **) &$1, 0, SWIG_POINTER_EXCEPTION);"

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_ltype argp) "swig_convert_ptr($input,(void **) &argp, $&1_descriptor,SWIG_POINTER_EXCEPTION);
$1 = *argp; ";

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) "swig_convert_packed($input, (void *) &$1, sizeof($1_type), $1_descriptor,SWIG_POINTER_EXCEPTION);";


/* --- Output values --- */

/* Strings */

%typemap(out,fragment="list_output_helper",chicken_words="0") 
  char *
{ char *s = (char*) $1;
  if ($1 == NULL) {
    $result = C_SCHEME_FALSE;
  } 
  else {
    int string_len = strlen ($1);
    C_word *string_space = C_alloc (C_SIZEOF_STRING (string_len));
/*if ONE*/
    $result = C_string (&string_space, string_len, s);
/*else*/
    $result = list_output_helper (&known_space, $result, C_string (&string_space, string_len, s));
/*endif*/ 
  }
}

%typemap(varout,fragment="list_output_helper",chicken_words="0") 
  char *
{ char *s = (char*) $varname;
  if ($varname == NULL) {
    $result = C_SCHEME_FALSE;
  } 
  else {
    int string_len = strlen ($varname);
    C_word *string_space = C_alloc (C_SIZEOF_STRING (string_len));
/*if ONE*/
    $result = C_string (&string_space, string_len, s);
/*else*/
    $result = list_output_helper (&known_space, $result, C_string (&string_space, string_len, s));
/*endif*/ 
  }
}

/* Pointers, references, and arrays */

%typemap(out,chicken_words="SWIG_ALLOCSZ_POINTER($typename)") SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
"$result = swig_new_pointer_obj((void *) $1, &known_space, $1_descriptor);";

/* Dynamic casts */

%typemap(out,chicken_words="SWIG_ALLOCSZ_POINTER($typename)") SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
   swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
   $result = swig_new_pointer_obj((void *) $1, &known_space, ty);
}

/* Member pointer */

%typemap(out,chicken_words="SWIG_ALLOCSZ_PACKED_OBJ(sizeof($1_type),$typename)") SWIGTYPE (CLASS::*) "$result = swig_new_packed_obj((void *) &$1, &known_space, sizeof($1_type), $1_descriptor);";

/* Void */
%typemap(out,chicken_words="void") void
%{
/*if ONE*/
$result = C_SCHEME_UNDEFINED;
/*else*/
  /* void return value, no need to be in $result */
/*endif*/ 
%}

/* Special typemap for character array return values */

%typemap(out,fragment="list_output_helper",chicken_words="0") 
  char [ANY], const char [ANY] 
%{ if ($1 == NULL) {
  $result = C_SCHEME_FALSE;
 }
 else {
   const int string_len = strlen ($1);
   C_word *string_space = C_alloc (C_SIZEOF_STRING (string_len));
/*if ONE*/
   $result = C_string (&string_space, string_len, $1);
/*else*/
   $result = list_output_helper (&known_space, $result, C_string (&string_space, string_len, $1));
/*endif*/
 } %}

/* Primitive types--return by value */

%typemap(out,chicken_words="SWIG_ALLOCSZ_POINTER($typename)") SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &) $1);
  $result = swig_new_pointer_obj((void *) resultptr, &known_space, $&1_descriptor);
}
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = swig_new_pointer_obj((void *) resultptr, &known_space, $&1_descriptor);
}
#endif

/* --- Variable input --- */

/* A string */
#ifdef __cplusplus
%typemap(varin) char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_swig_is_string ($input)) {
      swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    if ($1) delete [] $1;
    $1 = ($type) new char[len+1];
    strncpy((char*)$1, temp, len);
    ((char*)$1) [len] = 0;
  }
}
%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_swig_is_string ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    $1 = ($type) new char[len+1];
    strncpy((char*)$1,temp,len);
    ((char*)$1) [len] = 0;
  }
}
#else
%typemap(varin) char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_swig_is_string ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    if ($1) free((char*) $1);
    $1 = ($type) malloc(len+1);
    strncpy((char*)$1,temp,len);
    ((char*)$1) [len] = 0;
  }
}
%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_swig_is_string ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    $1 = ($type) malloc(len+1);
    strncpy((char*)$1,temp,len);
    ((char*)$1) [len] = 0;
  }
}
#endif

%typemap(varin) SWIGTYPE [] {
  swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Variable $name is read-only");
}

/* Special case for string array variables */
%typemap(varin) char [ANY] {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_swig_is_string ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    strncpy($1,temp,$1_dim0);
  }
}

%typemap(varin) SWIGTYPE * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else {
    void *temp;
    swig_convert_ptr($input,(void **) &temp, $1_descriptor, SWIG_POINTER_EXCEPTION);
    $1 = ($1_ltype) temp;
  }
}

%typemap(varin) SWIGTYPE & {
  void *temp;
  swig_convert_ptr($input,(void **) &temp, $1_descriptor, SWIG_POINTER_EXCEPTION);
  if (temp == NULL) {
    swig_barf (SWIG_BARF1_ARGUMENT_NULL, "$name is a null reference");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

%typemap(varin) void * {
  void * temp;
  swig_convert_ptr($input,(void **) &temp, 0, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN);
  $1 = ($1_ltype) temp;
}

%typemap(varin) SWIGTYPE (CLASS::*) {
  char      temp[sizeof($1_type)];
  swig_convert_packed($input,(void *) temp, sizeof($1_type), $1_descriptor, SWIG_POINTER_EXCEPTION);
  memmove((void *) &$1,temp,sizeof($1_type));
}

%typemap(varin) SWIGTYPE {
  $&1_ltype temp;
  swig_convert_ptr($input, (void **) &temp, $&1_descriptor, SWIG_POINTER_EXCEPTION);
  $1 = *(($&1_type) temp);
}

/* --- Variable output --- */

/* Pointers, references, and arrays */
%typemap(varout,chicken_words="SWIG_ALLOCSZ_POINTER($typename)") SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
"$result = swig_new_pointer_obj((void *) $varname, &known_space, $1_descriptor);";

/* Member pointer */
%typemap(varout,chicken_words="SWIG_ALLOCSZ_PACKED_OBJ(sizeof($1_type),$typename)") SWIGTYPE (CLASS::*) 
"$result = swig_new_packed_obj((void *) &$varname, sizeof($1_type), &known_space, $1_descriptor);";

/* Void */
%typemap(varout) void "$result = C_SCHEME_UNDEFINED;";

/* Special typemap for character array return values */
%typemap(varout) char [ANY], const char [ANY] 
%{  if ($varname == C_SCHEME_FALSE) {
    $result = NULL;
  }
  else if (C_swig_is_string ($varname)) {
    $result = swig_make_string ($varname);
  }
  else {
     swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'string'");    
  } %}

%typemap(varout,chicken_words="SWIG_ALLOCSZ_POINTER($typename)") SWIGTYPE "$result = swig_new_pointer_obj((void *) &$varname, &known_space, $&1_descriptor);";

/* --- Constants --- */

%typemap(constcode) char *
"static const char *$result = \"$value\";"

%typemap(constcode) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
"static const void *$result = (void*) $value;"

%typemap(constcode) SWIGTYPE (CLASS::*) 
"static const void *$result = (void*) &$value;"

/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (char *STRING, int LENGTH) {
  if ($input == C_SCHEME_FALSE) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Cannot use a null/#f string for a char*, int arguments");
  }
  else if (C_swig_is_string ($input)) {
    $1 = ($1_ltype) C_c_string ($input);
    $2 = ($2_ltype) C_header_size ($input);
  }
  else {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'string'");
  }
}

/* ------------------------------------------------------------
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%typemap(in)     size_t
%{  if (!C_swig_is_flonum ($input)) {
    swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'flonum'");
  }
  $1 = (size_t) C_flonum_magnitude ($input); %}
%typemap(out)       size_t = long;
%typemap(varin)     size_t = long;
%typemap(varout)    size_t = long;
%typemap(constcode) size_t = long;

/* ------------------------------------------------------------
 * CHICKEN types
 * ------------------------------------------------------------ */

%typemap(in)   C_word "$1 = $input;";
%typemap(out)  C_word "$result = $1;";

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_INTEGER)
         bool, const bool & 
{
  $1 = C_swig_is_bool ($input);
}

%typecheck(SWIG_TYPECHECK_INTEGER)
	 int, short, 
 	 unsigned int, unsigned short,
	 signed char, unsigned char,
	 const int &, const short &, 
 	 const unsigned int &, const unsigned short &,
	 enum SWIGTYPE
{
  $1 = C_swig_is_fixnum ($input);
}

%typecheck(SWIG_TYPECHECK_INTEGER)
	 long,
 	 unsigned long,
	 long long, unsigned long long,
	 const long &,
 	 const unsigned long &,
	 const long long &, const unsigned long long &
{
  $1 = (C_swig_is_bool ($input) || 
    C_swig_is_fixnum ($input) || 
    C_swig_is_flonum ($input)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE)
	float, double,
	const float &, const double &
{
  $1 = C_swig_is_flonum ($input);
}

%typecheck(SWIG_TYPECHECK_CHAR) char {
  $1 = C_swig_is_string ($input);
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  $1 = C_swig_is_string ($input);
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *ptr;
  if (swig_convert_ptr($input, (void **) &ptr, $1_descriptor, 0) == -1) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *ptr;
  if (swig_convert_ptr($input, (void **) &ptr, $&1_descriptor, 0) == -1) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (swig_convert_ptr($input, (void **) &ptr, 0, 0) == -1) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */

/* TODO */

/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */

#ifdef __cplusplus
%rename(__add__)      *::operator+;
%rename(__pos__)      *::operator+();
%rename(__pos__)      *::operator+() const;
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
%rename(__neg__)      *::operator-() const;
%rename(__mul__)      *::operator*;
%rename(__div__)      *::operator/;
%rename(__mod__)      *::operator%;
%rename(__lshift__)   *::operator<<;
%rename(__rshift__)   *::operator>>;
%rename(__and__)      *::operator&;
%rename(__or__)       *::operator|;
%rename(__xor__)      *::operator^;
%rename(__invert__)   *::operator~;
%rename(__iadd__)     *::operator+=;
%rename(__isub__)     *::operator-=;
%rename(__imul__)     *::operator*=;
%rename(__idiv__)     *::operator/=;
%rename(__imod__)     *::operator%=;
%rename(__ilshift__)  *::operator<<=;
%rename(__irshift__)  *::operator>>=;
%rename(__iand__)     *::operator&=;
%rename(__ior__)      *::operator|=;
%rename(__ixor__)     *::operator^=;
%rename(__lt__)       *::operator<;
%rename(__le__)       *::operator<=;
%rename(__gt__)       *::operator>;
%rename(__ge__)       *::operator>=;
%rename(__eq__)       *::operator==;
%rename(__ne__)       *::operator!=;

/* Special cases */
%rename(__call__)     *::operator();

/* Ignored operators */
%ignorewarn("362:operator= ignored") operator=;
%ignorewarn("383:operator++ ignored") operator++;
%ignorewarn("384:operator-- ignored") operator--;
%ignorewarn("381:operator&& ignored") operator&&;
%ignorewarn("382:operator|| ignored") operator||;
%ignorewarn("386:operator->* ignored") operator->*;
%ignorewarn("389:operator[] ignored (consider using %extend)") operator[];

#endif

/* Warnings for certain CHICKEN keywords. From Section 7.1.1 of
   Revised^5 Report on the Algorithmic Language Scheme */
#define CHICKW(x) %namewarn("314:" #x " is a R^5RS syntatic keyword")  #x

CHICKW(else);
CHICKW(=>);
CHICKW(define);
CHICKW(unquote);
CHICKW(unquote-splicing);
CHICKW(quote);
CHICKW(lambda);
CHICKW(if);
CHICKW(set!);
CHICKW(begin);
CHICKW(cond);
CHICKW(and);
CHICKW(or);
CHICKW(case);
CHICKW(let);
CHICKW(let*);
CHICKW(letrec);
CHICKW(do);
CHICKW(delay);
CHICKW(quasiquote);

/* TinyCLOS <--> Low-level CHICKEN */

%typemap("clos_in") SIMPLE_CLOS_OBJECT * "(slot-ref $input (quote this))"
%typemap("clos_out") SIMPLE_CLOS_OBJECT * "(make $class (quote this) $1)"

/* VERBATIM CODE INSERTIONS */

%insert(header) %{
#ifdef __cplusplus
extern "C" {
#endif
/* Chicken initialization function */
SWIGEXPORT(void) $module_swig_init(int, C_word, C_word) C_noret;
/* Tag functions */
SWIGEXPORT(int) $module_swig_num_types (void);
SWIGEXPORT(const char*) $module_swig_type_name (int);
SWIGEXPORT(void*) $module_swig_type_ptr  (int);
SWIGEXPORT(const char*) $module_swig_type_str  (int);
SWIGEXPORT(void)  $module_swig_type_tag  (int, C_word);
#ifdef __cplusplus
}
#endif
%}

%insert(init) %{
/* CHICKEN initialization function */
SWIGEXPORT(void)
$module_swig_init(int argc, C_word closure, C_word continuation) {
  static int       typeinit = 0;
  int       i;

  if (!typeinit) {
    for (i = 0; swig_types_initial[i]; i++) {
      swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
    }
    typeinit = 1;
    swig_init_helper (continuation);
  }
  else {
    C_kontinue (continuation, C_SCHEME_FALSE);
  }
}

/* Tag functions */

SWIGEXPORT(int)
$module_swig_num_types (void)
{
  int i; 
  for (i=0; swig_types_initial[i]; i++); 
  return i;
}
SWIGEXPORT(const char*)
$module_swig_type_name (int index)
{
  return swig_types[index]->name;
}
SWIGEXPORT(void*)
$module_swig_type_ptr  (int index)
{
  return (void*) (swig_types[index]);
}
SWIGEXPORT(const char*)
$module_swig_type_str  (int index)
{
  return swig_types[index]->str;
}
SWIGEXPORT(void)
$module_swig_type_tag  (int index, C_word tag)
{
  swig_chicken_clientdata *data = 
    (swig_chicken_clientdata*) malloc (sizeof (swig_chicken_clientdata));
  C_mutate (&(data->tag), tag);
  data->literal_frame = C_register_lf (&(data->tag), 1);
  SWIG_TypeClientData (swig_types[index], (void*) data);
}
%}

%insert(chicken) %{
(declare 
 (foreign-declare "C_extern int   $module_swig_num_types (void);")
 (foreign-declare "C_extern char* $module_swig_type_name (int);")
 (foreign-declare "C_extern void* $module_swig_type_ptr (int);")
 (foreign-declare "C_extern char* $module_swig_type_str (int);")
 (foreign-declare "C_extern void  $module_swig_type_tag (int, C_word);"))
(define-record swig-$module-tag class name ptr str)
(define-record-printer (swig-$module-tag tag out)
 (fprintf out "#<c++ ~S>(~A)" (swig-$module-tag-str tag) 
  (swig-$module-tag-ptr tag)))
(define swig-$module-tag-num 
 ((foreign-lambda int "$module_swig_num_types")))
(define swig-$module-tags (make-vector swig-$module-tag-num #f))
(letrec
 ((gen
   (lambda (l i)
    (if (= i 0) (cons 0 l) (gen (cons i l) (- i 1))))))
 (let ((indices (if (<= swig-$module-tag-num 0) (quote ())
		 (gen (quote ()) (- swig-$module-tag-num 1)))))
  (for-each 
   (lambda (index)
    (let 
     ((tag
       (make-swig-$module-tag 
	1000 
	((foreign-lambda
	  c-string "$module_swig_type_name" int) index)
	((foreign-lambda
	  c-pointer "$module_swig_type_ptr" int) index)
	((foreign-lambda
	  c-string "$module_swig_type_str" int) index))))
     (vector-set! swig-$module-tags index tag)
     ((foreign-lambda void "$module_swig_type_tag"
       int scheme-object) index tag)))
   indices)))
%}
