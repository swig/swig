mod rust_director_exceptions;

use rust_director_exceptions::{
    rust_director_error, PanicReceiverDirector, PanicReceiverDirectorOwned,
};
use std::os::raw::c_int;

struct RustPanicReceiver;

impl PanicReceiverDirector for RustPanicReceiver {
    fn value(&mut self, _arg0: c_int) -> c_int {
        panic!("rust director value panic");
    }

    fn record(&mut self, _arg0: c_int) {
        panic!("rust director record panic");
    }

    fn status(&mut self) -> c_int {
        rust_director_error("CallbackError", "rust director structured error");
    }
}

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

fn main() {
    let receiver = PanicReceiverDirectorOwned::from_proxy(rust_director_exceptions::PanicReceiver::new(), RustPanicReceiver);
    if silence_expected_panics(|| receiver.call_value_catch()) != 77 {
        panic!("expected Rust director value panic to become C++ director exception");
    }
    if silence_expected_panics(|| receiver.call_record_catch()) != 88 {
        panic!("expected Rust director void panic to become C++ director exception");
    }
    if silence_expected_panics(|| receiver.call_status_catch()) != 99 {
        panic!("expected Rust director structured error to become C++ director exception");
    }
}
