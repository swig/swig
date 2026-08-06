%module rust_typemap_customization

%pragma(rust) moduleimports=%{
use std::sync::atomic::{AtomicUsize, Ordering};
%}

%pragma(rust) modulecode=%{
pub static RUST_TYPEMAP_DROP_COUNT: AtomicUsize = AtomicUsize::new(0);
%}

%typemap(rustattributes) CustomBox "#[repr(C)]"
%typemap(rustderive) CustomBox "Debug"
%typemap(rustbody) CustomBox %{
  pub fn typemap_body_value(&self) -> c_int {
    33
  }
%}
%typemap(rusttraits) CustomBox %{
impl AsRef<CustomBox> for CustomBox {
  fn as_ref(&self) -> &CustomBox {
    self
  }
}
%}
%typemap(rustdrop) CustomBox %{
RUST_TYPEMAP_DROP_COUNT.fetch_add(1, Ordering::SeqCst);
%}

%inline %{

class CustomBox {
public:
  CustomBox() {
  }
  int value() const {
    return 9;
  }
};

%}
