mod rust_director_edgecases;

use rust_director_edgecases::{EdgePayload, EdgeReceiverDirector, EdgeReceiverDirectorOwned};
use std::os::raw::c_int;

struct RustEdgeReceiver {
    calls: c_int,
}

impl EdgeReceiverDirector for RustEdgeReceiver {
    fn overloaded(&mut self, value: c_int) -> c_int {
        self.calls += 1;
        value + 10
    }

    fn overloaded_1(&mut self, payload: Option<&mut EdgePayload>) -> c_int {
        self.calls += 1;
        payload.map(|value| value.value() + 20).unwrap_or(-20)
    }

    fn observe(&mut self, payload: Option<&EdgePayload>) -> c_int {
        self.calls += 1;
        payload.map(|value| value.value() + 30).unwrap_or(-30)
    }

    fn mutate(&mut self, payload: &mut EdgePayload) {
        self.calls += 1;
        payload.set_value(payload.value() + 40);
    }

    fn choose(&mut self, payload: Option<&mut EdgePayload>) -> Option<EdgePayload> {
        self.calls += 1;
        let _ = payload;
        None
    }
}

fn main() {
    let mut receiver = EdgeReceiverDirectorOwned::from_proxy(rust_director_edgecases::EdgeReceiver::new(), RustEdgeReceiver { calls: 0 });
    let mut payload = EdgePayload::new(5);

    if rust_director_edgecases::call_overloaded_int(Some(receiver.as_proxy_mut()), 2) != 12 {
        panic!("expected overloaded int director dispatch");
    }
    if rust_director_edgecases::call_overloaded_payload(Some(receiver.as_proxy_mut()), Some(&mut payload)) != 25 {
        panic!("expected overloaded nullable mutable pointer director dispatch");
    }
    if rust_director_edgecases::call_overloaded_payload(Some(receiver.as_proxy_mut()), None) != -20 {
        panic!("expected nullable mutable pointer None dispatch");
    }
    if rust_director_edgecases::call_observe(Some(receiver.as_proxy_mut()), Some(&payload)) != 35 {
        panic!("expected nullable const pointer director dispatch");
    }
    if rust_director_edgecases::call_observe(Some(receiver.as_proxy_mut()), None) != -30 {
        panic!("expected nullable const pointer None dispatch");
    }
    rust_director_edgecases::call_mutate(Some(receiver.as_proxy_mut()), &mut payload);
    if payload.value() != 45 {
        panic!("expected mutable reference director dispatch");
    }
    if rust_director_edgecases::call_choose(Some(receiver.as_proxy_mut()), Some(&mut payload)).is_some() {
        panic!("expected nullable director return to map to None");
    }
    if rust_director_edgecases::call_choose(Some(receiver.as_proxy_mut()), None).is_some() {
        panic!("expected nullable director return to stay None for null input");
    }
    if receiver.director().calls != 8 {
        panic!("expected every director edge callback to be observed");
    }
}
