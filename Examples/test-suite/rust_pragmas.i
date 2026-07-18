%module rust_pragmas

%pragma(rust) moduleimports=%{
use std::os::raw::c_int as RustPragmaInt;
%}

%pragma(rust) modulecode=%{
pub const RUST_PRAGMA_MODULE_VALUE: RustPragmaInt = 41;
%}

%pragma(rust) externattributes=%{
#[allow(improper_ctypes)]
%}

%pragma(rust) externcode=%{
  pub fn rust_pragma_unused(input: RustPragmaInt) -> RustPragmaInt;
%}

%pragma(rust) classattributes=%{
#[repr(C)]
%}

%pragma(rust) classderive="Debug"

%pragma(rust) classcode=%{
  pub fn pragma_marker(&self) -> RustPragmaInt {
    RUST_PRAGMA_MODULE_VALUE
  }
%}

%inline %{

class RustPragmaBox {
public:
  RustPragmaBox() {
  }
  int value() const {
    return 7;
  }
};

%}
