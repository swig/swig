%module rust_prepost

%pragma(rust) moduleimports=%{
use std::sync::atomic::{AtomicI32, Ordering};
%}

%pragma(rust) modulecode=%{
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct HookedInt(pub c_int);

pub static RUST_PRE_COUNT: AtomicI32 = AtomicI32::new(0);
pub static RUST_POST_COUNT: AtomicI32 = AtomicI32::new(0);
pub static RUST_TERMINATOR_COUNT: AtomicI32 = AtomicI32::new(0);
%}

%typemap(rusttype) HookedInt "HookedInt"
%typemap(rustin,
         pre="RUST_PRE_COUNT.fetch_add(1, Ordering::SeqCst); let $rustinput_raw = $rustinput.0 + 1;",
         post="RUST_POST_COUNT.fetch_add(1, Ordering::SeqCst);",
         terminator="RUST_TERMINATOR_COUNT.fetch_add(1, Ordering::SeqCst);") HookedInt
  "$rustinput_raw"
%typemap(rustout) HookedInt "HookedInt($imcall)"

%inline %{
typedef int HookedInt;

HookedInt rust_prepost_global(HookedInt value) {
  return value + 10;
}

class RustPrePostBox {
public:
  RustPrePostBox(HookedInt value) : value_(value) {
  }
  HookedInt value() const {
    return value_;
  }
  HookedInt method(HookedInt value) {
    return value_ + value;
  }
  static HookedInt static_method(HookedInt value) {
    return value + 20;
  }
  HookedInt member;
private:
  HookedInt value_;
};
%}
