mod rust_std_auto_ptr;

fn main() {
    unsafe {
        let thing = rust_std_auto_ptr::rust_make_auto_thing(73);
        if rust_std_auto_ptr::rust_take_auto_thing(thing) != 73 {
            panic!("expected auto_ptr value 73");
        }
    }
}
