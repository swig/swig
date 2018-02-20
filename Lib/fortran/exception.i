/* -------------------------------------------------------------------------
 * exception.i
 *
 * This file is automatically included when the user loads <std_except.i>.
 * Since it's also loaded by constraints.i, it must be compatible with C as
 * well.
 * ------------------------------------------------------------------------- */

// Allow the user to change the name of the error flag on the fortran side
#ifndef SWIG_FORTRAN_ERROR_INT
#define SWIG_FORTRAN_ERROR_INT ierr
#endif
#ifndef SWIG_FORTRAN_ERROR_STR
#define SWIG_FORTRAN_ERROR_STR get_serr
#endif

/* -------------------------------------------------------------------------
 * Fortran variable declaration
 * ------------------------------------------------------------------------- */
%insert("fparams") {
 integer(C_INT), bind(C), public :: SWIG_FORTRAN_ERROR_INT
}

/* -------------------------------------------------------------------------
 * Function declarations
 *
 * These are declared as fragments so that they will be included in imported
 * modules as well.
 * ------------------------------------------------------------------------- */
#ifdef __cplusplus
%fragment("SWIG_exception_decl", "runtime") %{
extern "C" {
void SWIG_check_unhandled_exception_impl(const char* decl);
void SWIG_store_exception(const char* decl, int errcode, const char *msg);
}
#define SWIG_check_unhandled_exception() \
    SWIG_check_unhandled_exception_impl("$decl");
%}
#else
%fragment("SWIG_exception_decl", "runtime") %{
void SWIG_check_unhandled_exception_impl(const char* decl);
void SWIG_store_exception(const char* decl, int errcode, const char *msg);
#define SWIG_check_unhandled_exception() \
    SWIG_check_unhandled_exception_impl("$decl");
%}
#endif

%fragment("SWIG_exception_decl");

/* -------------------------------------------------------------------------
 * Runtime code
 *
 * This is always inserted into the wrapped file, even if imported. It
 * overrides the  default exception handler (defined in forruntime.swg).
 *
 * Note that SWIG_exception_impl is also used by SWIG_contract_assert, so the
 * *_impl* is the one that changes.
 * ------------------------------------------------------------------------- */
%fragment("SWIG_exception_impl", "runtime") %{
#undef SWIG_exception_impl
#define SWIG_exception_impl(DECL, CODE, MSG, RETURNNULL) \
    SWIG_store_exception(DECL, CODE, MSG); RETURNNULL;
%}
%fragment("SWIG_exception_impl");

/* Note that this replaces wrapper code: the phrase "SWIG_exception" never
 * shows up in the .cxx file
 */
#define SWIG_exception(CODE, MSG) \
    SWIG_exception_impl("$decl", CODE, MSG, return $null)

/* -------------------------------------------------------------------------
 * Variable definitions: used only if %included, not %imported
 * ------------------------------------------------------------------------- */
#ifdef __cplusplus

%fragment("<string>");
%fragment("<cctype>");
%fragment("<stdexcept>");

%insert("header") {
// Stored exception message
SWIGINTERN std::string* swig_last_exception_msg = NULL;
// Declare %inlined error retrieval function
const std::string& SWIG_FORTRAN_ERROR_STR();

extern "C" {
// Stored exception integer
SWIGEXPORT int SWIG_FORTRAN_ERROR_INT = 0;

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
    prev_msg.front() = std::tolower(prev_msg.front());
    msg += prev_msg;
    throw std::runtime_error(msg);
  }
}

// Save an exception to the fortran error code and string
SWIGEXPORT void SWIG_store_exception(const char *decl,
                                     int errcode,
                                     const char *msg) {
  ::SWIG_FORTRAN_ERROR_INT = errcode;

  if (!swig_last_exception_msg) {
    swig_last_exception_msg = new std::string;
  }
  // Save the message to a std::string first
  *swig_last_exception_msg = "In ";
  *swig_last_exception_msg += decl;
  *swig_last_exception_msg += ": ";
  *swig_last_exception_msg += msg;
}
}
}
#else
/* C support */
%fragment("<stdio.h>");
%fragment("<stdlib.h>");
%insert("header") {
SWIGEXPORT int SWIG_FORTRAN_ERROR_INT = 0;

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
#endif

/* -------------------------------------------------------------------------
 * Functional interface to SWIG error string
 * ------------------------------------------------------------------------- */
#ifdef __cplusplus
%include <forstring.swg>

%apply const std::string& NATIVE { const std::string& SWIG_FORTRAN_ERROR_STR};

// Return a wrapped version of the error string
%inline {
const std::string& SWIG_FORTRAN_ERROR_STR() {
    if (!swig_last_exception_msg || swig_last_exception_msg->empty()) {
        SWIG_store_exception("UNKNOWN", SWIG_RuntimeError,
                             "no error string was present");

    }
    return *swig_last_exception_msg;
}
}
#endif


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
