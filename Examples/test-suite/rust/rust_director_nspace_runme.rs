mod rust_director_nspace;

use rust_director_nspace::outer::{
    NamespacedReceiverDirector, NamespacedReceiverDirectorHandle,
};
use std::os::raw::c_int;

struct RustNamespaced {
    total: c_int,
}

impl NamespacedReceiverDirector for RustNamespaced {
    fn receive(&mut self, arg0: c_int) -> c_int {
        self.total += arg0;
        self.total * 2
    }
}

fn main() {
    let receiver = rust_director_nspace::outer::NamespacedReceiver::new();
    let handle = NamespacedReceiverDirectorHandle::connect(&receiver, RustNamespaced { total: 0 });

    if receiver.call_receive(5) != 10 {
        panic!("expected namespaced Rust director callback");
    }
    if receiver.call_receive(7) != 24 {
        panic!("expected namespaced Rust director state to remain alive");
    }
    if handle.director().total != 12 {
        panic!("expected namespaced director state");
    }
}
