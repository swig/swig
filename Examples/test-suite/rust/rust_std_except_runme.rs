mod rust_std_except;

fn main() {
    use rust_std_except::RustExceptionKind;

    if rust_std_except::rust_no_throw() != 7 {
        panic!("rust_no_throw failed");
    }
    if rust_std_except::try_rust_no_throw().unwrap() != 7 {
        panic!("try_rust_no_throw failed");
    }

    let error = rust_std_except::try_rust_throw_out_of_range().unwrap_err();
    if error.kind != RustExceptionKind::OutOfRange {
        panic!("expected std::out_of_range, got {:?}", error.kind);
    }
    if error.type_name != "std::out_of_range" {
        panic!("expected std::out_of_range, got {}", error.type_name);
    }
    if error.message != "rust out of range" {
        panic!("unexpected exception message {}", error.message);
    }
}
