/*
 --------------------------------------------------
 argout typemaps
 convert arguments from C to Scheme
 --------------------------------------------------
 */

%{
#define MAXVALUES 6
%}

%typemap(mzscheme, argout)
    int *M_OUTPUT,
    unsigned int *M_OUTPUT,
    short *M_OUTPUT,
    unsigned short *M_OUTPUT
{
    Scheme_Object *s;
    s = scheme_make_integer(*$target);
    m_output_helper(_values, s, &_lenv);
}

%typemap(mzscheme, argout)
    long *M_OUTPUT
{
    Scheme_Object *s;
    s = scheme_make_integer_value(*$target);
    m_output_helper(_values, s, &_lenv);
}


%typemap(mzscheme, argout)
    unsigned long *M_OUTPUT
{
    Scheme_Object *s;
    s = scheme_make_integer_value_from_unsigned(*$target);
    m_output_helper(_values, s, &_lenv);
}


%typemap(mzscheme, argout)
    char *M_OUTPUT,
    unsigned char *M_OUTPUT
{
    Scheme_Object *s;
    s = scheme_make_string(*$target);
    m_output_helper(_values, s, &_lenv);
}

%typemap(mzscheme, argout)
float *M_OUTPUT,
double *M_OUTPUT
{
    Scheme_Object *s;
    s = scheme_make_double(*$target);
    m_output_helper(_values, s, &_lenv);
}

%{
void m_output_helper(Scheme_Object **target, Scheme_Object *s, int *_lenv) {
    target[*_lenv] = s;
    (*_lenv)++;
}
%}

/*
 -------------------------------------------------
 Check the type of the MzScheme arguments and
 convert function arguments from a MzScheme to a C
 representation.
 -------------------------------------------------
 */

%typemap(mzscheme, in) char {
    if(!SCHEME_CHARP($source))
	scheme_wrong_type("$name", "character", $argnum, argc, argv);
    $target = SCHEME_CHAR_VAL($source);
}

%typemap(mzscheme, in) unsigned char {
    if(!SCHEME_CHARP($source))
	scheme_wrong_type("$name", "character", $argnum, argc, argv);
    $target = SCHEME_CHAR_VAL($source);
}

%typemap(mzscheme, in) char * {
    if(!SCHEME_STRINGP($source))
	scheme_wrong_type("$name", "string ", $argnum, argc, argv);
    $target = SCHEME_STR_VAL($source);
}

%typemap(mzscheme, in) char [ANY] {
    if(!SCHEME_STRINGP($source))
	scheme_wrong_type("$name", "string ", $argnum, argc, argv);
    $target = SCHEME_STR_VAL($source);
}

%typemap(mzscheme, in) int {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}

%typemap(mzscheme, in) long {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &$target);
}

%typemap(mzscheme, in) short {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}

%typemap(mzscheme, in) unsigned int {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}

%typemap(mzscheme, in) unsigned long {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_unsigned_int_val($source, &$target);
}

%typemap(mzscheme, in) unsigned short {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}
/*
%typemap(mzscheme, in) long long {
    if(!SCHEME_INTP($source))
    scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &$target);
}
*/
%typemap(mzscheme, in) float {
    if(!SCHEME_DBLP($source))
	scheme_wrong_type("$name", "double", $argnum, argc, argv);
    $target = SCHEME_DBL_VAL($source);
}

%typemap(mzscheme, in) double {
    if(SCHEME_DBLP($source))
	$target = SCHEME_DBL_VAL($source);
    else if(SCHEME_REALP($source))
	$target = scheme_real_to_double($source);
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
/*
%typemap(mzscheme, in) long double {
    if(SCHEME_DBLP($source))
	$target = SCHEME_DBL_VAL($source);
    else if(SCHEME_REALP($source))
	$target = scheme_real_to_double($source);
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
*/

/*
 ------------------------------------
 in typemaps for pass-by-reference
 ------------------------------------
 */

%typemap(mzscheme, in) unsigned char *(unsigned char temp) {
    if(!SCHEME_CHARP($source))
	scheme_wrong_type("$name", "character", $argnum, argc, argv);
    temp = SCHEME_STR_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, in) int *(int temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (int)SCHEME_INT_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, in) long *(long temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &temp);
    $target = &temp;

}

%typemap(mzscheme, in) short *(short temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (short)SCHEME_INT_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, in) unsigned int *(unsigned temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (unsigned)SCHEME_INT_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, in) unsigned long *(unsigned long temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_unsigned_int_val($source, &temp);
    $target = &temp;
}

%typemap(mzscheme, in) unsigned short *(unsigned short temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (unsigned short)SCHEME_INT_VAL($source);
    $target = &temp;

}
/*
%typemap(mzscheme, in) long long *(long long temp) {
    if(!SCHEME_INTP($source))
    scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &temp);
    $target = &temp;
}
*/
%typemap(mzscheme, in) float *(float temp) {
    if(!SCHEME_DBLP($source))
	scheme_wrong_type("$name", "double", $argnum, argc, argv);
    temp = (float)SCHEME_DBL_VAL($source);
    $target = &temp;

}

%typemap(mzscheme, in) double *(double temp) {
    if(SCHEME_DBLP($source)) {
	temp = (double)SCHEME_DBL_VAL($source);
	$target = &temp;
    }
    else if(SCHEME_REALP($source)) {
	temp = (double)scheme_real_to_double($source);
	$target = &temp;
    }
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
/*
%typemap(mzscheme, in) long double *(long double temp) {
    if(SCHEME_DBLP($source)) {
	temp = (long double)SCHEME_DBL_VAL($source);
	$target = &temp;
    }
    else if(SCHEME_REALP($source)) {
	temp = (long double)scheme_real_to_double($source);
	$target = &temp;
    }
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
*/

/*
 ------------------------------------
 convert return type from C to Scheme
 ------------------------------------
 */

%typemap(mzscheme, out) char {
    $target = scheme_make_character($source);
}

%typemap(mzscheme, out) unsigned char {
    $target = scheme_make_character($source);
}

%typemap(mzscheme, out) char * {
    $target = scheme_make_string($source);
}

%typemap(mzscheme, out) char [ANY] {
    $target = scheme_make_string($source);
}

%typemap(mzscheme, out) int {
    $target = scheme_make_integer_value($source);
}

%typemap(mzscheme, out) long {
    $target = scheme_make_integer_value($source);
}

%typemap(mzscheme, out) short {
    $target = scheme_make_integer_value($source);
}
/*
%typemap(mzscheme, out) long long {
    $target = scheme_make_integer_value($source);
}
*/
%typemap(mzscheme, out) unsigned int {
    $target = scheme_make_integer_value_from_unsigned($source);
}

%typemap(mzscheme, out) unsigned long {
    $target = scheme_make_integer_value_from_unsigned($source);
}

%typemap(mzscheme, out) unsigned short {
    $target = scheme_make_integer_value_from_unsigned($source);
}

%typemap(mzscheme, out) float {
    $target = scheme_make_double($source);
}

%typemap(mzscheme, out) double {
    $target = scheme_make_double($source);
}
/*
%typemap(mzscheme, out) long double {
    $target = scheme_make_double($source);
}
*/

/*
 -----------------------------------
 convert pointers from C to MzScheme
 -----------------------------------
 */

%typemap(mzscheme, out) int * {
    $target = scheme_make_integer_value(*$source);
}

%typemap(mzscheme, out) long * {
    $target = scheme_make_integer_value(*$source);
}

%typemap(mzscheme, out) short * {
    $target = scheme_make_integer_value(*$source);
}

/*
%typemap(mzscheme, out) long long * {
    $target = scheme_make_integer_value(*$source);
}
*/
%typemap(mzscheme, out) unsigned int * {
    $target = scheme_make_integer_value_from_unsigned(*$source);
}

%typemap(mzscheme, out) unsigned long * {
    $target = scheme_make_integer_value_from_unsigned(*$source);
}

%typemap(mzscheme, out) unsigned short * {
    $target = scheme_make_integer_value_from_unsigned(*$source);
}

%typemap(mzscheme, out) float * {
    $target = scheme_make_double(*$source);
}

%typemap(mzscheme, out) double * {
    $target = scheme_make_double(*$source);
}
/*
%typemap(mzscheme, out) long double * {
    $target = scheme_make_double(*$source);
}
*/

/*
 ------------------------------------------------------------
 Typemaps for accessing a global C variable from MzScheme
 ------------------------------------------------------------
 */

%typemap(mzscheme, varin) char {
    if(!SCHEME_CHARP($source))
	scheme_wrong_type("$name", "character", $argnum, argc, argv);
    $target = SCHEME_CHAR_VAL($source);
}

%typemap(mzscheme, varin) unsigned char {
    if(!SCHEME_CHARP($source))
	scheme_wrong_type("$name", "character", $argnum, argc, argv);
    $target = SCHEME_CHAR_VAL($source);
}

%typemap(mzscheme, varin) char * {
    if(!SCHEME_STRINGP($source))
	scheme_wrong_type("$name", "string ", $argnum, argc, argv);
    $target = SCHEME_STR_VAL($source);
}

%typemap(mzscheme, varin) char [ANY] {
    if(!SCHEME_STRINGP($source))
	scheme_wrong_type("$name", "string ", $argnum, argc, argv);
    $target = SCHEME_STR_VAL($source);
}

%typemap(mzscheme, varin) int {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}

%typemap(mzscheme, varin) long {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &$target);
}

%typemap(mzscheme, varin) short {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}

%typemap(mzscheme, varin) unsigned int {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}

%typemap(mzscheme, varin) unsigned long {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_unsigned_int_val($source, &$target);
}

%typemap(mzscheme, varin) unsigned short {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    $target = SCHEME_INT_VAL($source);
}
/*
%typemap(mzscheme, varin) long long {
    if(!SCHEME_INTP($source))
    scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &$target);
}
*/
%typemap(mzscheme, varin) float {
    if(!SCHEME_DBLP($source))
	scheme_wrong_type("$name", "double", $argnum, argc, argv);
    $target = SCHEME_DBL_VAL($source);
}

%typemap(mzscheme, varin) double {
    if(SCHEME_DBLP($source))
	$target = SCHEME_DBL_VAL($source);
    else if(SCHEME_REALP($source))
	$target = scheme_real_to_double($source);
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
/*
%typemap(mzscheme, varin) long double {
    if(SCHEME_DBLP($source))
	$target = SCHEME_DBL_VAL($source);
    else if(SCHEME_REALP($source))
	$target = scheme_real_to_double($source);
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
*/

/*
 ------------------------------------
 global pointer variable
 ------------------------------------
 */

%typemap(mzscheme, varin) unsigned char *(unsigned char temp) {
    if(!SCHEME_CHARP($source))
	scheme_wrong_type("$name", "character", $argnum, argc, argv);
    temp = SCHEME_STR_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, varin) int *(int temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (int)SCHEME_INT_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, varin) long *(long temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &temp);
    $target = &temp;

}

%typemap(mzscheme, varin) short *(short temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (short)SCHEME_INT_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, varin) unsigned int *(unsigned temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (unsigned)SCHEME_INT_VAL($source);
    $target = &temp;
}

%typemap(mzscheme, varin) unsigned long *(unsigned long temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_unsigned_int_val($source, &temp);
    $target = &temp;
}

%typemap(mzscheme, varin) unsigned short *(unsigned short temp) {
    if(!SCHEME_INTP($source))
	scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    temp = (unsigned short)SCHEME_INT_VAL($source);
    $target = &temp;

}
/*
%typemap(mzscheme, varin) long long *(long long temp) {
    if(!SCHEME_INTP($source))
    scheme_wrong_type("$name", "integer", $argnum, argc, argv);
    scheme_get_int_val($source, &temp);
    $target = &temp;
}
*/
%typemap(mzscheme, varin) float *(float temp) {
    if(!SCHEME_DBLP($source))
	scheme_wrong_type("$name", "double", $argnum, argc, argv);
    temp = (float)SCHEME_DBL_VAL($source);
    $target = &temp;

}

%typemap(mzscheme, varin) double *(double temp) {
    if(SCHEME_DBLP($source)) {
	temp = (double)SCHEME_DBL_VAL($source);
	$target = &temp;
    }
    else if(SCHEME_REALP($source)) {
	temp = (double)scheme_real_to_double($source);
	$target = &temp;
    }
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
/*
%typemap(mzscheme, varin) long double *(long double temp) {
    if(SCHEME_DBLP($source)) {
	temp = (long double)SCHEME_DBL_VAL($source);
	$target = &temp;
    }
    else if(SCHEME_REALP($source)) {
	temp = (long double)scheme_real_to_double($source);
	$target = &temp;
    }
    else scheme_wrong_type("$name", "real", $argnum, argc, argv);
}
*/


/*
 -----------------------------------
 convert a variable from C to Scheme
 -----------------------------------
 */

%typemap(mzscheme, varout) char {
    $target = scheme_make_character($source);
}

%typemap(mzscheme, varout) unsigned char {
    $target = scheme_make_character($source);
}

%typemap(mzscheme, varout) char * {
    $target = scheme_make_string($source);
}

%typemap(mzscheme, varout) char [ANY] {
    $target = scheme_make_string($source);
}

%typemap(mzscheme, varout) int {
    $target = scheme_make_integer_value($source);
}

%typemap(mzscheme, varout) long {
    $target = scheme_make_integer_value($source);
}

%typemap(mzscheme, varout) short {
    $target = scheme_make_integer_value($source);
}
/*
%typemap(mzscheme, varout) long long {
    $target = scheme_make_integer_value($source);
}
*/
%typemap(mzscheme, varout) unsigned int {
    $target = scheme_make_integer_value_from_unsigned($source);
}

%typemap(mzscheme, varout) unsigned long {
    $target = scheme_make_integer_value_from_unsigned($source);
}

%typemap(mzscheme, varout) unsigned short {
    $target = scheme_make_integer_value_from_unsigned($source);
}

%typemap(mzscheme, varout) float {
    $target = scheme_make_double($source);
}

%typemap(mzscheme, varout) double {
    $target = scheme_make_double($source);
}
/*
%typemap(mzscheme, varout) long double {
    $target = scheme_make_double($source);
}
*/

/*
 -----------------------------------
 convert a pointer variable from C to MzScheme
 -----------------------------------
 */

%typemap(mzscheme, varout) int * {
    $target = scheme_make_integer_value(*$source);
}

%typemap(mzscheme, varout) long * {
    $target = scheme_make_integer_value(*$source);
}

%typemap(mzscheme, varout) short * {
    $target = scheme_make_integer_value(*$source);
}

/*
%typemap(mzscheme, varout) long long * {
    $target = scheme_make_integer_value(*$source);
}
*/
%typemap(mzscheme, varout) unsigned int * {
    $target = scheme_make_integer_value_from_unsigned(*$source);
}

%typemap(mzscheme, varout) unsigned long * {
    $target = scheme_make_integer_value_from_unsigned(*$source);
}

%typemap(mzscheme, varout) unsigned short * {
    $target = scheme_make_integer_value_from_unsigned(*$source);
}

%typemap(mzscheme, varout) float * {
    $target = scheme_make_double(*$source);
}

%typemap(mzscheme, varout) double * {
    $target = scheme_make_double(*$source);
}
/*
%typemap(mzscheme, varout) long double * {
    $target = scheme_make_double(*$source);
}
*/
