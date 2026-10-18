#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "c_exceptions/c_exceptions_wrap.h"

static void check_error(const char *test, int code, const char *msg) {
  c_exceptions_SWIG_CException *ex = c_exceptions_SWIG_CException_get_pending();
  if (!ex) {
    fprintf(stderr, "Test %s failed: no pending exception\n", test);
    exit(1);
  }
  if (c_exceptions_SWIG_CException_code_get(ex) != code) {
    fprintf(stderr, "Test %s failed: code %d\n", test, c_exceptions_SWIG_CException_code_get(ex));
    exit(1);
  }
  if (msg && strcmp(c_exceptions_SWIG_CException_msg_get(ex), msg) != 0) {
    fprintf(stderr, "Test %s failed: message \"%s\"\n", test, c_exceptions_SWIG_CException_msg_get(ex));
    exit(1);
  }
  c_exceptions_SWIG_CException_reset_pending();
}

static void check_no_error(const char *test) {
  if (c_exceptions_SWIG_CException_get_pending()) {
    fprintf(stderr, "Test %s failed: unexpected pending exception\n", test);
    exit(1);
  }
}

static void check(int ok, const char *test) {
  if (!ok) {
    fprintf(stderr, "Test %s failed\n", test);
    exit(1);
  }
}

int main() {
  /* %exception tests */
  c_exceptions_ThrowByValue();
  check_error("ThrowByValue", SWIG_DivisionByZero, "ThrowByValue");
  c_exceptions_ThrowByReference();
  check_error("ThrowByReference", SWIG_DivisionByZero, "ThrowByReference");

  /* %feature("except") without canthrow */
  c_exceptions_NoFailException();
  check_no_error("NoFailException");
  {
    c_exceptions_Ex *ex = c_exceptions_Ex_new("should not fail");
    c_exceptions_NullReference(ex);
    check_no_error("NullReference valid");
    c_exceptions_Ex_delete(ex);
  }

  /* exception specifications */
  c_exceptions_ExceptionSpecificationValue();
  check_error("ExceptionSpecificationValue", SWIG_UnknownError, NULL);
  c_exceptions_ExceptionSpecificationReference();
  check_error("ExceptionSpecificationReference", SWIG_UnknownError, NULL);
  c_exceptions_ExceptionSpecificationString();
  check_error("ExceptionSpecificationString", SWIG_RuntimeError, "ExceptionSpecificationString");
  c_exceptions_ExceptionSpecificationInteger();
  check_error("ExceptionSpecificationInteger", SWIG_UnknownError, NULL);
  check(c_exceptions_ExceptionSpecificationResult() == 0, "ExceptionSpecificationResult result");
  check_error("ExceptionSpecificationResult", SWIG_RuntimeError, "ExceptionSpecificationResult");

  /* null reference exceptions */
  c_exceptions_NullReference(NULL);
  check_error("NullReference", SWIG_NullReferenceError, NULL);

  /* enums */
  c_exceptions_ExceptionSpecificationEnumValue();
  check_error("ExceptionSpecificationEnumValue", SWIG_UnknownError, NULL);
  c_exceptions_ExceptionSpecificationEnumReference();
  check_error("ExceptionSpecificationEnumReference", SWIG_UnknownError, NULL);

  /* memory leak check */
  c_exceptions_MemoryLeakCheck();
  check_error("MemoryLeakCheck", SWIG_DivisionByZero, NULL);
  check(c_exceptions_Counter_count_get() == 0, "MemoryLeakCheck count");

  /* error raised by a constructor */
  check(c_exceptions_constructor_new() == NULL, "constructor result");
  check_error("constructor", SWIG_UnknownError, NULL);

  /* error raised in the out typemap */
  check(c_exceptions_ushorttest() == 0, "ushorttest result");
  check_error("ushorttest", SWIG_IndexError, "don't like 100");

  /* errors raised in the variable getters and setters */
  /* 1) global variables */
  c_exceptions_numberin_set(5);
  c_exceptions_numberin_set(-1);
  check_error("global numberin set", SWIG_IndexError, "too small");
  check(c_exceptions_numberin_get() == 5, "global numberin not 5");
  c_exceptions_numberout_set(20);
  check(c_exceptions_numberout_get() == 0, "global numberout result");
  check_error("global numberout get", SWIG_IndexError, "too big");
  /* 2) static member variables */
  c_exceptions_InOutStruct_staticnumberin_set(5);
  c_exceptions_InOutStruct_staticnumberin_set(-1);
  check_error("static staticnumberin set", SWIG_IndexError, "too small");
  check(c_exceptions_InOutStruct_staticnumberin_get() == 5, "static staticnumberin not 5");
  c_exceptions_InOutStruct_staticnumberout_set(20);
  check(c_exceptions_InOutStruct_staticnumberout_get() == 0, "static staticnumberout result");
  check_error("static staticnumberout get", SWIG_IndexError, "too big");
  /* 3) member variables */
  {
    c_exceptions_InOutStruct *io = c_exceptions_InOutStruct_new();
    c_exceptions_InOutStruct_numberin_set(io, 5);
    c_exceptions_InOutStruct_numberin_set(io, -1);
    check_error("member numberin set", SWIG_IndexError, "too small");
    check(c_exceptions_InOutStruct_numberin_get(io) == 5, "member numberin not 5");
    c_exceptions_InOutStruct_numberout_set(io, 20);
    check(c_exceptions_InOutStruct_numberout_get(io) == 0, "member numberout result");
    check_error("member numberout get", SWIG_IndexError, "too big");
    c_exceptions_InOutStruct_delete(io);
  }
  check_no_error("variables");

  /* errors raised in %exceptionvar code */
  c_exceptions_exceptionvar_number_set(-1);
  check_error("global %exceptionvar set", SWIG_IndexError, "exceptionvar_number negative");
  check(c_exceptions_exceptionvar_number_get() == 0, "global %exceptionvar get result");
  check_error("global %exceptionvar get", SWIG_IndexError, "exceptionvar_number negative");
  c_exceptions_exceptionvar_number_set(5);
  check(c_exceptions_exceptionvar_number_get() == 5, "global exceptionvar_number not 5");
  c_exceptions_ExceptionVarStruct_staticnumber_set(-1);
  check_error("static %exceptionvar set", SWIG_IndexError, "staticnumber negative");
  check(c_exceptions_ExceptionVarStruct_staticnumber_get() == 0, "static %exceptionvar get result");
  check_error("static %exceptionvar get", SWIG_IndexError, "staticnumber negative");
  c_exceptions_ExceptionVarStruct_staticnumber_set(5);
  check(c_exceptions_ExceptionVarStruct_staticnumber_get() == 5, "static staticnumber not 5");
  check_no_error("%exceptionvar");

  /* SWIG_exception macro - it must leave the wrapper without executing any further code */
  c_exceptions_exceptionmacrotest(-1);
  check_error("exceptionmacrotest", SWIG_IndexError, "testing SWIG_exception macro");
  check(!c_exceptions_exception_macro_run_flag_get(), "exceptionmacrotest was executed");
  c_exceptions_exceptionmacrotest(1);
  check_no_error("exceptionmacrotest valid");
  check(c_exceptions_exception_macro_run_flag_get(), "exceptionmacrotest was not executed");

  return 0;
}
