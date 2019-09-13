/* -------------------------------------------------------------------------
 * exception.i
 *
 * This file is automatically included when the user loads <std_except.i>.
 * Since it's also loaded by constraints.i, it must be compatible with C as
 * well.
 * ------------------------------------------------------------------------- */

/* Error if this file is being imported without being loaded through
 * extern_exception.i */
#if defined(SWIGIMPORTED) && !defined(SWIG_FORTRAN_EXTERN_EXCEPTION)
#error "exception.i cannot be %imported directly: instead, %include <extern_exception.i> just below your %module declaration"
#endif

/* Allow the user to change the name of the error flag on the fortran side */
#ifndef SWIG_FORTRAN_ERROR_INT
#define SWIG_FORTRAN_ERROR_INT ierr
#endif
#ifndef SWIG_FORTRAN_ERROR_STR
#define SWIG_FORTRAN_ERROR_STR get_serr
#endif

/* Declare C-bound global, available from Fortran */
%fortranbindc SWIG_FORTRAN_ERROR_INT;
%inline {
#ifdef __cplusplus
extern "C" {
#endif
int SWIG_FORTRAN_ERROR_INT = 0;
#ifdef __cplusplus
}
#endif
}

/* Add wrapper code for the error string */
%include <fortranstrings.swg>
const char* SWIG_FORTRAN_ERROR_STR();

/* -------------------------------------------------------------------------
 * Function declarations
 *
 * These should appear both in the module %including exception.i as well as any
 * downstream module that uses exceptions.
 * ------------------------------------------------------------------------- */
%fragment("SWIG_exception_decl", "runtime") %{
#ifdef __cplusplus
extern "C" {
#endif
void SWIG_check_unhandled_exception_impl(const char* decl);
void SWIG_store_exception(const char* decl, int errcode, const char *msg);
#ifdef __cplusplus
}
#endif
%}

/* -------------------------------------------------------------------------
 * Runtime code
 *
 * Note that the SWIG_exception_impl macro is also used by
 * SWIG_contract_assert, as well as a few other macros in our library.
 * ------------------------------------------------------------------------- */
%fragment("SWIG_exception_impl", "runtime",
          fragment="SWIG_exception_decl") %{
#undef SWIG_exception_impl
#define SWIG_exception_impl(DECL, CODE, MSG, RETURNNULL) \
    SWIG_store_exception(DECL, CODE, MSG); RETURNNULL;
%}

/* Note that this replaces wrapper code: the phrase "SWIG_exception" never
 * shows up in the .cxx file. */
#define SWIG_exception(CODE, MSG) \
    SWIG_exception_impl("$decl", CODE, MSG, return $null)

/* This also replaces wrapper code.  */
#define SWIG_check_unhandled_exception() \
    SWIG_check_unhandled_exception_impl("$decl");

/* -------------------------------------------------------------------------
 * Variable definitions: used only if %included, not %imported
 * ------------------------------------------------------------------------- */
#ifdef __cplusplus
%fragment("SWIG_exception", "header", fragment="SWIG_exception_impl",
          fragment="<string>", fragment="<cctype>", fragment="<stdexcept>") {
// Stored exception message
SWIGINTERN const char* swig_last_exception_cstr = NULL;
// Inlined error retrieval function
SWIGEXPORT const char* SWIG_FORTRAN_ERROR_STR() {
  if (!swig_last_exception_cstr) {
    SWIG_store_exception("UNKNOWN", SWIG_RuntimeError,
                         "no error string was present");
  }
  return swig_last_exception_cstr;
}

extern "C" {
// Call this function before any new action
SWIGEXPORT void SWIG_check_unhandled_exception_impl(const char* decl) {
  if (SWIG_FORTRAN_ERROR_INT != 0) {
    // Construct message; calling the error string function ensures that
    // the string is allocated if the user did something goofy like
    // manually setting the integer. Since this function is not expected to
    // be wrapped by a catch statement, it will probably terminate the
    // program.
    std::string msg("An unhandled exception occurred before a call to ");
    msg += decl;
    msg += "; ";
    std::string prev_msg = SWIG_FORTRAN_ERROR_STR();
    prev_msg[0] = std::tolower(prev_msg[0]);
    msg += prev_msg;
    throw std::runtime_error(msg);
  }
}

// Save an exception to the fortran error code and string
SWIGEXPORT void SWIG_store_exception(const char *decl,
                                     int errcode,
                                     const char *msg) {
  ::SWIG_FORTRAN_ERROR_INT = errcode;

  static std::string last_exception_msg;
  // Save the message to a std::string first
  last_exception_msg = "In ";
  last_exception_msg += decl;
  last_exception_msg += ": ";
  last_exception_msg += msg;
  swig_last_exception_cstr = last_exception_msg.c_str();
}
}
}

#else

/* C support */
%fragment("SWIG_exception", "header", fragment="SWIG_exception_impl",
          fragment="<stdio.h>", fragment="<stdlib.h>") {

SWIGEXPORT void SWIG_store_exception(const char *decl,
                                     int errcode,
                                     const char *msg) {
    printf("Error %d in %s: %s\n", errcode, decl, msg);
}

SWIGEXPORT void SWIG_check_unhandled_exception_impl(const char* decl) {
  if (SWIG_FORTRAN_ERROR_INT != 0) {
    printf("An unhandled error %d occurred before a call to %s\n",
           SWIG_FORTRAN_ERROR_INT, decl);
    exit(SWIG_FORTRAN_ERROR_INT);
  }
}
}
#endif /* __cplusplus */

/* If not being imported, add the implementation of the exception macros */
%fragment("SWIG_exception");

/* Load macros and default typemaps from parent 'exception.i' */
%include "../exception.i"
