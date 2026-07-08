mod rust_pragmas;

fn main() {
    let boxed = rust_pragmas::RustPragmaBox::new();
    if boxed.value() != 7 {
        panic!("expected wrapped method to work");
    }
    if boxed.pragma_marker() != rust_pragmas::RUST_PRAGMA_MODULE_VALUE {
        panic!("expected pragma-injected class code to see module code");
    }
    let debug_text = format!("{:?}", boxed);
    if !debug_text.contains("RustPragmaBox") {
        panic!("expected pragma-injected derive");
    }
}
