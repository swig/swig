%module rust_attributes

%pragma(rust) moduleimports=%{
use std::sync::atomic::{AtomicUsize, Ordering};
%}

%pragma(rust) modulecode=%{
pub trait RustAttributeMarker {
  fn marker_value(&self) -> i32;
}

pub static RUST_ATTRIBUTE_DROPS: AtomicUsize = AtomicUsize::new(0);
%}

%typemap(rustattributes) RustAttributeBox "#[repr(C)]"
%typemap(rustderive) RustAttributeBox "Debug"
%typemap(rustbody) RustAttributeBox %{
  pub fn rust_attribute_body(&self) -> i32 {
    77
  }
%}
%typemap(rusttraits) RustAttributeBox %{
impl RustAttributeMarker for RustAttributeBox {
  fn marker_value(&self) -> i32 {
    self.value()
  }
}
%}
%typemap(rustdrop) RustAttributeBox %{
RUST_ATTRIBUTE_DROPS.fetch_add(1, Ordering::SeqCst);
%}

%inline %{
class RustAttributeBox {
public:
  RustAttributeBox() {
  }
  int value() const {
    return 44;
  }
};
%}
