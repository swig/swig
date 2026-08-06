%module rust_exception_policy

%pragma(rust) exceptionpolicy="result"
%pragma(rust) exceptionkind="RustPolicyCustomError=Logic"
%pragma(rust) exceptioncode="RustPolicyCustomError=RUST_POLICY_CUSTOM"

%include <std_except.i>

%typemap(throws, canthrow=1) RustPolicyCustomError "SWIG_RustSetPendingException(\"RustPolicyCustomError\", $1.what());\n return $null;"

%inline %{
#include <stdexcept>

#if __cplusplus >= 201103L
#define SWIG_RUST_THROW_INVALID_ARGUMENT noexcept(false)
#define SWIG_RUST_THROW_CUSTOM_ERROR noexcept(false)
#else
#define SWIG_RUST_THROW_INVALID_ARGUMENT throw (std::invalid_argument)
#define SWIG_RUST_THROW_CUSTOM_ERROR throw (RustPolicyCustomError)
#endif

class RustPolicyCustomError {
public:
  const char *what() const {
    return "rust policy custom error";
  }
};

int rust_policy_no_throw() SWIG_RUST_THROW_INVALID_ARGUMENT {
  return 12;
}

int rust_policy_throw() SWIG_RUST_THROW_INVALID_ARGUMENT {
  throw std::invalid_argument("rust policy invalid argument");
}

int rust_policy_custom_throw() SWIG_RUST_THROW_CUSTOM_ERROR {
  throw RustPolicyCustomError();
}

class RustPolicyBox {
public:
  RustPolicyBox() {
  }
  int value() SWIG_RUST_THROW_INVALID_ARGUMENT {
    return 42;
  }
  int fail() SWIG_RUST_THROW_INVALID_ARGUMENT {
    throw std::invalid_argument("rust policy method invalid argument");
  }
};
%}
