mod rust_typemaps;

use std::sync::atomic::Ordering;

fn main() {
    let value = rust_typemaps::rust_typemap_roundtrip(rust_typemaps::RustNumber(4));
    if value != rust_typemaps::RustNumber(6) {
        panic!("expected global rustin/rustout typemap conversion");
    }
    if rust_typemaps::RUST_TYPEMAP_LAST_INPUT.load(Ordering::SeqCst) != 4 {
        panic!("expected rustin pre code to observe original input");
    }

    let boxed = rust_typemaps::RustTypemapBox::new(rust_typemaps::RustNumber(7));
    if boxed.value() != rust_typemaps::RustNumber(7) {
        panic!("expected constructor typemap conversion");
    }
    if boxed.scale(rust_typemaps::RustNumber(8)) != rust_typemaps::RustNumber(15) {
        panic!("expected method typemap conversion");
    }
    if rust_typemaps::RustTypemapBox::static_scale(rust_typemaps::RustNumber(9)) != rust_typemaps::RustNumber(12) {
        panic!("expected static method typemap conversion");
    }
}
