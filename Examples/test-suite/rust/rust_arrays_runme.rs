mod rust_arrays;

fn main() {
    unsafe {
        let mut values = [5, 8, 13];
        if rust_arrays::rust_array_first(values.as_mut_ptr()) != 5 {
            panic!("expected first array value 5");
        }
    }
}
