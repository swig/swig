mod rust_boost_shared_ptr;

fn main() {
    let thing = rust_boost_shared_ptr::rust_make_boost_shared_thing(41).expect("thing");
    if rust_boost_shared_ptr::rust_boost_shared_thing_value(&thing) != 41 {
        panic!("expected boost shared value 41");
    }
}
