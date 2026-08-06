mod rust_director_create_callback;

use rust_director_create_callback::{MessageReceiverDirector, MessageReceiverDirectorHandle, MessageReceiverDirectorOwned};
use std::os::raw::c_int;

struct RustReceiver {
    total: c_int,
}

impl MessageReceiverDirector for RustReceiver {
    fn receive(&mut self, arg0: c_int) -> c_int {
        self.total += arg0;
        self.total * 10
    }
}

fn main() {
    let mut receiver = MessageReceiverDirectorOwned::from_proxy(
        rust_director_create_callback::MessageReceiver::new(),
        RustReceiver { total: 0 },
    );

    let bus = rust_director_create_callback::MessageBus::new();
    bus.create(Some(receiver.as_proxy_mut()));

    if bus.dispatch(4) != 40 {
        panic!("expected dispatch through Rust director callback");
    }
    if bus.dispatch(3) != 70 {
        panic!("expected C++ to keep calling the Rust callback object");
    }
    if bus.current().is_none() {
        panic!("expected stored callback pointer");
    }
    if bus.current_ref().receive(2) != 90 {
        panic!("expected reference return to call the Rust callback object");
    }
    if receiver.director_mut().total != 9 {
        panic!("expected Rust callback state to record messages");
    }

    receiver.disconnect();
    if bus.dispatch(5) != 5 {
        panic!("expected disconnected director to use base callback");
    }

    let receiver = receiver.into_director();
    if receiver.total != 9 {
        panic!("expected owned director proxy to return callback state");
    }

    let mut receiver = rust_director_create_callback::MessageReceiver::new();
    let handle = MessageReceiverDirectorHandle::connect(&receiver, RustReceiver { total: 9 });
    bus.create(Some(&mut receiver));
    if bus.dispatch(1) != 100 {
        panic!("expected reconnected director callback");
    }

    bus.clear();
    if bus.dispatch(5) != -1 {
        panic!("expected cleared callback slot");
    }
    if bus.current().is_some() {
        panic!("expected empty callback pointer");
    }

    let director = handle.into_director();
    if director.total != 10 {
        panic!("expected recovered Rust callback state");
    }

    let handle = MessageReceiverDirectorHandle::connect(&receiver, RustReceiver { total: 20 });
    bus.create(Some(&mut receiver));
    let mut disowned = handle.into_disowned();
    if !disowned.is_connected() {
        panic!("expected safe disown guard to stay connected");
    }
    if bus.dispatch(2) != 220 {
        panic!("expected safely disowned director to stay connected");
    }
    if disowned.director().total != 22 {
        panic!("expected safe disown guard to keep callback state");
    }
    disowned.disconnect();
    if disowned.is_connected() {
        panic!("expected safe disown guard to disconnect");
    }
    if bus.dispatch(2) != 2 {
        panic!("expected disconnected disown guard to restore base callback");
    }

    let handle = MessageReceiverDirectorHandle::connect(&receiver, RustReceiver { total: 30 });
    bus.create(Some(&mut receiver));
    let disowned = unsafe { handle.disown() };
    if bus.dispatch(2) != 320 {
        panic!("expected raw disowned director to stay connected");
    }
    let director = unsafe { MessageReceiverDirectorHandle::reclaim_disowned(&receiver, disowned) };
    if director.total != 32 {
        panic!("expected reclaimed raw disowned callback state");
    }
    if bus.dispatch(2) != 2 {
        panic!("expected raw reclaimed director to disconnect");
    }

    let mut service =
        rust_director_create_callback::MessageService::try_create_with_director(RustReceiver { total: 40 })
            .expect("expected director factory helper to create a service");
    if service.dispatch(2) != 420 {
        panic!("expected generated factory helper to keep director alive");
    }
    if service.current().is_none() {
        panic!("expected generated factory helper to register the callback proxy");
    }
    if service.director_mut().total != 42 {
        panic!("expected generated factory helper to expose callback state");
    }
    let (service_object, service_director) = service.into_parts();
    if service_object.dispatch(1) != 430 {
        panic!("expected split factory guard to keep callback connected while both parts live");
    }
    if service_director.director().total != 43 {
        panic!("expected split factory guard to return callback state");
    }
}
