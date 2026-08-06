mod messages;

use messages::{Receiver, ReceiverDirectorOwned};
use std::os::raw::c_int;

struct MyReceiver {
    total: c_int,
}

impl messages::ReceiverDirector for MyReceiver {
    fn message(&mut self, value: c_int) {
        self.total += value;
    }
}

fn main() {
    let mut receiver = ReceiverDirectorOwned::from_proxy(Receiver::new(), MyReceiver { total: 0 });
    messages::deliver(Some(receiver.as_proxy_mut()), 42);
    if receiver.director().total != 42 {
        panic!("expected 42, got {}", receiver.director().total);
    }
}
