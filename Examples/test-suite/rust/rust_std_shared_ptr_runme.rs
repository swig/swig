mod rust_std_shared_ptr;

fn main() {
    let thing = rust_std_shared_ptr::rust_make_shared_thing(11).expect("thing");
    if rust_std_shared_ptr::rust_shared_thing_value(&thing) != 11 {
        panic!("expected shared value 11");
    }
    rust_std_shared_ptr::rust_shared_thing_set(&thing, 23);
    if rust_std_shared_ptr::rust_shared_thing_value(&thing) != 23 {
        panic!("expected updated shared value 23");
    }
}
