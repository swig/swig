mod rust_exception_policy;

use rust_exception_policy::RustExceptionKind;

fn silence_expected_panics<F, R>(action: F) -> R
where
    F: FnOnce() -> R,
{
    let previous_hook = std::panic::take_hook();
    std::panic::set_hook(Box::new(|_| {}));
    let result = action();
    std::panic::set_hook(previous_hook);
    result
}

fn check_invalid_argument(error: rust_exception_policy::RustException, message: &str) {
    if error.kind != RustExceptionKind::InvalidArgument {
        panic!("expected invalid_argument, got {:?}", error.kind);
    }
    if error.type_name != "std::invalid_argument" {
        panic!("expected std::invalid_argument, got {}", error.type_name);
    }
    if error.message != message {
        panic!("unexpected exception message {}", error.message);
    }
}

fn check_custom_logic(error: rust_exception_policy::RustException) {
    if error.kind != RustExceptionKind::Logic {
        panic!("expected custom error to map to logic, got {:?}", error.kind);
    }
    if error.type_name != "RustPolicyCustomError" {
        panic!("expected RustPolicyCustomError, got {}", error.type_name);
    }
    if !error.is_type("RustPolicyCustomError") {
        panic!("expected is_type to recognize RustPolicyCustomError");
    }
    if error.code != Some(rust_exception_policy::RUST_POLICY_CUSTOM) {
        panic!("expected structured custom error code, got {:?}", error.code);
    }
    if error.message != "rust policy custom error" {
        panic!("unexpected custom exception message {}", error.message);
    }
}

fn main() {
    if rust_exception_policy::rust_policy_no_throw().unwrap() != 12 {
        panic!("rust_policy_no_throw failed");
    }
    check_invalid_argument(
        rust_exception_policy::rust_policy_throw().unwrap_err(),
        "rust policy invalid argument",
    );
    check_custom_logic(rust_exception_policy::rust_policy_custom_throw().unwrap_err());

    let boxed = rust_exception_policy::RustPolicyBox::new().unwrap();
    if boxed.value().unwrap() != 42 {
        panic!("RustPolicyBox::value failed");
    }
    if rust_exception_policy::RustPolicyBox::panic_new().panic_value() != 42 {
        panic!("panic_ compatibility constructor or method failed");
    }
    check_invalid_argument(
        boxed.fail().unwrap_err(),
        "rust policy method invalid argument",
    );

    let panic_function_result = silence_expected_panics(|| {
        std::panic::catch_unwind(|| rust_exception_policy::panic_rust_policy_throw())
    });
    if panic_function_result.is_ok() {
        panic!("panic_ compatibility wrapper should panic");
    }
    let panic_method_result = silence_expected_panics(|| {
        std::panic::catch_unwind(|| boxed.panic_fail())
    });
    if panic_method_result.is_ok() {
        panic!("panic_ compatibility method should panic");
    }
}
