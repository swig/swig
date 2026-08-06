mod rust_typemap_customization;

use std::sync::atomic::Ordering;

fn main() {
    {
        let boxed = rust_typemap_customization::CustomBox::new();
        if boxed.value() != 9 {
            panic!("expected wrapped value 9");
        }
        if boxed.typemap_body_value() != 33 {
            panic!("expected rustbody method");
        }
        if boxed.as_ref().value() != 9 {
            panic!("expected rusttraits impl");
        }
        let debug_text = format!("{:?}", boxed);
        if !debug_text.contains("CustomBox") {
            panic!("expected rustderive Debug");
        }
    }

    if rust_typemap_customization::RUST_TYPEMAP_DROP_COUNT.load(Ordering::SeqCst) != 1 {
        panic!("expected rustdrop to run once");
    }
}
