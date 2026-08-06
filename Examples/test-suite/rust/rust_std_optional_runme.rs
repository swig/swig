mod rust_std_optional;

fn main() {
    let some = rust_std_optional::rust_make_optional_thing(19);
    match some {
        Some(value) => {
            if value.get_value() != 19 {
                panic!("expected optional value 19");
            }
            if rust_std_optional::rust_optional_thing_value(Some(value)) != 19 {
                panic!("expected optional input value 19");
            }
        }
        None => panic!("expected optional value"),
    }

    if rust_std_optional::rust_make_empty_optional_thing().is_some() {
        panic!("expected empty optional");
    }
    if rust_std_optional::rust_optional_thing_value(None) != -1 {
        panic!("expected empty optional input marker");
    }
}
