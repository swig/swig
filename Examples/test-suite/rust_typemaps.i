%module rust_typemaps

%pragma(rust) moduleimports=%{
use std::sync::atomic::{AtomicI32, Ordering};
%}

%pragma(rust) modulecode=%{
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct RustNumber(pub c_int);

pub static RUST_TYPEMAP_LAST_INPUT: AtomicI32 = AtomicI32::new(0);
%}

%typemap(rusttype) RustNumber "RustNumber"
%typemap(rustin,
         pre="RUST_TYPEMAP_LAST_INPUT.store($rustinput.0, Ordering::SeqCst); let $rustinput_raw = $rustinput.0 * 10;") RustNumber
  "$rustinput_raw"
%typemap(rustout) RustNumber "RustNumber($imcall / 10)"

%inline %{
typedef int RustNumber;

RustNumber rust_typemap_roundtrip(RustNumber value) {
  return value + 20;
}

class RustTypemapBox {
public:
  RustTypemapBox(RustNumber value) : value_(value) {
  }
  RustNumber value() const {
    return value_;
  }
  RustNumber scale(RustNumber value) {
    return value_ + value;
  }
  static RustNumber static_scale(RustNumber value) {
    return value + 30;
  }
private:
  RustNumber value_;
};
%}
