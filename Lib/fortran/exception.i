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

/* -------------------------------------------------------------------------
 * Error code retrieval
 *
 * SWIG apps can override the default SWIG_FORTRAN_ERROR_INT to avoid conflicts.
 * ------------------------------------------------------------------------- */
#ifndef SWIG_FORTRAN_ERROR_INT
#define SWIG_FORTRAN_ERROR_INT ierr
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

/* -------------------------------------------------------------------------
 * Error string retrieval
 *
 * SWIG apps can override the default SWIG_FORTRAN_ERROR_STR to avoid conflicts.
 * ------------------------------------------------------------------------- */
#ifndef SWIG_FORTRAN_ERROR_STR
#define SWIG_FORTRAN_ERROR_STR get_serr
#endif

/* Add wrapper code for the error string */
%include <fortranstrings.swg>
const char* SWIG_FORTRAN_ERROR_STR();

/* -------------------------------------------------------------------------
 * Function declarations
 *
 * These must be injected into downstream SWIG modules (via extern_exception.i)
 * so it must be a reusable %fragment rather than a directly injected %runtime.
 * ------------------------------------------------------------------------- */
%fragment("SWIG_exception_decl", "runtime") %{
#ifdef __cplusplus
extern "C" {
#endif
SWIGEXPORT void SWIG_check_unhandled_exception_impl(const char* decl);
SWIGEXPORT void SWIG_store_exception(const char* decl, int errcode, const char *msg);
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
%insert("header") {
// Stored exception message
SWIGINTERN const char* swig_last_exception_cstr = NULL;
// Retrieve error message
SWIGEXPORT const char* SWIG_FORTRAN_ERROR_STR() {
  if (!swig_last_exception_cstr) {
    SWIG_store_exception("UNKNOWN", SWIG_RuntimeError,
                         "no error string was present");
  }
  return swig_last_exception_cstr;
}
}

#ifdef __cplusplus

%fragment("<string>");
%fragment("<cctype>");
%fragment("<stdexcept>");

%insert("header") {
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

#else // __cplusplus

/* C support */
%fragment("<stdio.h>");
%fragment("<stdlib.h>");

%insert("header") {
SWIGEXPORT void SWIG_check_unhandled_exception_impl(const char* decl) {
  if (SWIG_FORTRAN_ERROR_INT != 0) {
    printf("An unhandled error %d occurred before a call to %s\n",
           SWIG_FORTRAN_ERROR_INT, decl);
    exit(SWIG_FORTRAN_ERROR_INT);
  }
}

SWIGEXPORT void SWIG_store_exception(const char *decl,
                                     int errcode,
                                     const char *msg) {
  static char exception_buffer[1024];
  sprintf(exception_buffer, "In %s: %s\n", decl, msg);
  SWIG_FORTRAN_ERROR_INT = errcode;
  swig_last_exception_cstr = exception_buffer;
}
}
#endif /* __cplusplus */

/* Load macros and default typemaps from parent 'exception.i' */
%include "../exception.i"

/* Generate wrapper definitions for each of the SWIG error values */
%fortranconst;
%include <swigerrors.swg>
%nofortranconst;

/* Inject fragments into %include-d code */
%fragment("SWIG_exception_impl");
