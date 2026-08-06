mod rust_boost_intrusive_ptr;

fn main() {
    let thing = rust_boost_intrusive_ptr::rust_make_boost_intrusive_thing(43);
    if rust_boost_intrusive_ptr::rust_boost_intrusive_thing_value(thing) != 43 {
        panic!("expected boost intrusive value 43");
    }
}
