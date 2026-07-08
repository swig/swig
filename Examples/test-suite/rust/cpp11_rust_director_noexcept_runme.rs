mod cpp11_rust_director_noexcept;

use cpp11_rust_director_noexcept::{NoexceptReceiverDirector, NoexceptReceiverDirectorHandle};
use std::os::raw::c_int;

struct Receiver;

impl NoexceptReceiverDirector for Receiver {
    fn no_throw(&mut self, arg0: c_int) -> c_int {
        arg0 + 40
    }
}

fn main() {
    let receiver = cpp11_rust_director_noexcept::NoexceptReceiver::new();
    assert_eq!(receiver.call_no_throw(1), 2);

    let _handle = NoexceptReceiverDirectorHandle::connect(&receiver, Receiver);
    assert_eq!(receiver.call_no_throw(2), 42);
}
