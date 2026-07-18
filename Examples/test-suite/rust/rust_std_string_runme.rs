mod rust_std_string;

fn main() {
    let value = rust_std_string::echo_string("hello".to_string());
    if value != "hello!" {
        panic!("expected hello!, got {}", value);
    }

    let size = rust_std_string::string_size("hello".to_string());
    if size != 5 {
        panic!("expected size 5, got {}", size);
    }
}
