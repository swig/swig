mod rust_attributes;

use rust_attributes::RustAttributeMarker;
use std::sync::atomic::Ordering;

fn main() {
    {
        let boxed = rust_attributes::RustAttributeBox::new();
        if boxed.value() != 44 {
            panic!("expected wrapped value");
        }
        if boxed.rust_attribute_body() != 77 {
            panic!("expected rustbody method");
        }
        if boxed.marker_value() != 44 {
            panic!("expected rusttraits implementation");
        }
        let text = format!("{:?}", boxed);
        if !text.contains("RustAttributeBox") {
            panic!("expected rustderive Debug");
        }
    }
    if rust_attributes::RUST_ATTRIBUTE_DROPS.load(Ordering::SeqCst) != 1 {
        panic!("expected rustdrop hook");
    }
}
