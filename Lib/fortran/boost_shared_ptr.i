/* -------------------------------------------------------------------------
 * boost_shared_ptr.i
 * ------------------------------------------------------------------------- */

%include <shared_ptr.i>

#ifndef SWIG_SHARED_PTR_NOT_NULL
#define SWIG_SHARED_PTR_NOT_NULL(f) f
#endif

// Runtime check for a class wrapper not being const.
%fragment("SWIG_check_sp_nonnull", "runtime") %{
#define SWIG_check_sp_nonnull(INPUT, TYPENAME, FNAME, FUNCNAME, RETURNNULL) \
  if (!(INPUT)) { \
    SWIG_exception_impl(FUNCNAME, SWIG_TypeError, \
                        "Cannot pass null " TYPENAME " (class " FNAME ") " \
                        "as a reference", RETURNNULL); \
  }
%}

%define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...)
/* -------------------------------------------------------------------------
 *
 */
#define SWIGSP__ SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE >
#define SWIGSP_PTRS__ SWIGSP__ &, SWIGSP__ *
#define SWIGSP_CPTRS__ const SWIGSP__ &, const SWIGSP__ *

/* -------------------------------------------------------------------------
 * Shared pointers *always* return either NULL or a newly allocated shared
 * pointer.
 * -------------------------------------------------------------------------
 * %naturalvar causes these types to be wrapped as const references rather than
 * pointers when they're member variables.
 */
%naturalvar TYPE;
%naturalvar SWIGSP__;

/* -------------------------------------------------------------------------
 * Deferred copy of basic settings from non-SP type (i.e. Fortran will see it the same; we override the in/out/ctype below)
 */

%typemap(ftype, in={$typemap(ftype:in, TYPE*)}, noblock=1) SWIGSP_CPTRS__
  {$typemap(ftype, const TYPE*)}

/* -------------------------------------------------------------------------
 * C types: we wrap the *shared pointer* as the value type. The 'in' type is
 * always passed to us as a pointer to a SwigClassWrapper, and the 'out' is
 * returned by value.
 */

%typemap(ctype, in="const SwigClassWrapper *", null="SwigClassWrapper_uninitialized()", noblock=1, fragment="SwigClassWrapper")
    SWIGSP__, SWIGSP_PTRS__, SWIGSP_CPTRS__
"SwigClassWrapper"

/* -------------------------------------------------------------------------
 * Original class by value: access the 'cptr' member of the input, return a
 * SP-owned copy of the obtained value.
 * ------------------------------------------------------------------------- */
%typemap(in, noblock=1, fragment="SWIG_check_sp_nonnull") CONST TYPE ($&1_type argp = 0) {
  SWIG_check_sp_nonnull($input, "$1_ltype", "$fclassname", "$decl", return $null)
  argp = $input->cptr ? %static_cast($input->cptr, SWIGSP__*)->get() : NULL;
  $1 = *argp;
}
%typemap(out, noblock=1) CONST TYPE {
 $result.cptr = new SWIGSP__(%new_copy($1, $1_basetype));
 $result.mem = SWIG_MOVE;
}

/* -------------------------------------------------------------------------
 * Original class by pointer. Note that the deleter is determined by the owner
 * mem, but the shared pointer instance itself is in a "moving" mem
 * regardless.
 * ------------------------------------------------------------------------- */
%typemap(in, noblock=1) CONST TYPE * (SWIGSP__* smartarg) {
  smartarg = %static_cast($input->cptr, SWIGSP__*);
  $1 = smartarg ? %const_cast(smartarg->get(), TYPE*) : NULL;
}

// The string "SWIG_NO_NULL_DELETER_$owner" is replaced by the macro
// SWIG_NO_NULL_DELETER_1 if a raw pointer is being emitted via %newobject
//   (for a shared pointer this macro is empty);
// or SWIG_NO_NULL_DELETER_0 if the raw pointer is simply a reference
//   (in which case the macro evaluates to `, SWIG_null_deleter()`, which
//   prevents the memory from being deallocated when the shared pointer is
//   destroyed).
%typemap(out, noblock=1, fragment="SWIG_null_deleter") CONST TYPE * {
  $result.cptr = $1 ? new SWIGSP__($1 SWIG_NO_NULL_DELETER_$owner) : NULL;
  $result.mem = SWIG_MOVE;
}

/* -------------------------------------------------------------------------
 * Original class by reference. Same as by pointer, but with null checks.
 * ------------------------------------------------------------------------- */
%typemap(in, noblock=1, fragment="SWIG_check_sp_nonnull") CONST TYPE& (SWIGSP__* smartarg) {
  SWIG_check_sp_nonnull($input, "$1_ltype", "$fclassname", "$decl", return $null)
  smartarg = %static_cast($input->cptr, SWIGSP__*);
  $1 = %const_cast(smartarg->get(), TYPE*);
}

// Output value is never null. Because we're allocating a shared pointer, we set the memory ownership to MOVE so that the *SP*
// will be properly deallocated. But we also must use a null deleter so that when the SP is deleted the corresponding memory
// will not be.
%typemap(out) CONST TYPE& {
  $result.cptr = new SWIGSP__($1 SWIG_NO_NULL_DELETER_0);
  $result.mem = SWIG_MOVE;
}

/* -------------------------------------------------------------------------
 * SP by value
 * ------------------------------------------------------------------------- */
%typemap(in, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE > {
  if ($input->cptr) $1 = *%static_cast($input->cptr, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr<CONST TYPE >*);
}

%typemap(out, noblock=1) SWIGSP__ {
  $result.cptr = %new_copy($1, SWIGSP__);
  $result.mem = SWIG_MOVE;
}

/* -------------------------------------------------------------------------
 * SP by reference
 * ------------------------------------------------------------------------- */
%typemap(in, noblock=1) SWIGSP__& ($*1_ltype tempnull) {
  $1 = $input->cptr ? %static_cast($input->cptr, $1_ltype) : &tempnull;
}

%typemap(out, noblock=1) SWIGSP__& {
  $result.cptr = SWIG_SHARED_PTR_NOT_NULL(*$1) ? new $*1_ltype(*$1) : 0;
  $result.mem = SWIG_MOVE;
}

/* -------------------------------------------------------------------------
 * SP by pointer
 *
 * Make sure that the SP* is allocated.
 * ------------------------------------------------------------------------- */
%typemap(in, noblock=1) SWIGSP__ * ($*1_ltype tempnull) {
  $1 = $input->cptr ? %static_cast($input->cptr, $1_ltype) : &tempnull;
}

%typemap(out, noblock=1, fragment="SWIG_null_deleter") SWIGSP__ * {
  $result.cptr = ($1 && SWIG_SHARED_PTR_NOT_NULL(*$1)) ? new $*1_ltype(*($1_ltype)$1) : 0;
  $result.mem = SWIG_MOVE;
  if ($owner) delete $1;
}

/* -------------------------------------------------------------------------
 * Miscellaneous
 * -------------------------------------------------------------------------
 * Various missing typemaps - If ever used (unlikely) ensure compilation error
 * inside the wrapper
 */
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}

/* -------------------------------------------------------------------------
 * Replace call to "delete (Foo*) arg1;" with call to delete the *shared
 * pointer* (so decrement the reference count instead of forcing the object to
 * be destroyed and causing a double-delete)
 */

%feature("unref") TYPE
%{ (void)$self; delete smart$self; %}

/* -------------------------------------------------------------------------
 * Instantiate shared pointer
 */
%template() SWIGSP__;

/* -------------------------------------------------------------------------
 * Clean up macros
 */
#undef SWIGSP__
#undef SWIGSP_PTRS__
#undef SWIGSP_CPTRS__

%enddef



