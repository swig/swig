mod rust_std_unique_ptr;

fn main() {
    let thing = rust_std_unique_ptr::rust_make_unique_thing(31);
    if rust_std_unique_ptr::rust_unique_thing_value(thing) != 31 {
        panic!("expected unique value 31");
    }

    let taken = rust_std_unique_ptr::rust_make_unique_thing(37);
    if rust_std_unique_ptr::rust_take_unique_thing(taken) != 37 {
        panic!("expected taken unique value 37");
    }
}
