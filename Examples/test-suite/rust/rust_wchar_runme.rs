mod rust_wchar;

fn main() {
    if rust_wchar::rust_wchar_identity('Z' as u32) != 'Z' as u32 {
        panic!("expected wchar identity");
    }
}
