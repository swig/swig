mod rust_director_protected;

use rust_director_protected::{ProtectedBaseDirector, ProtectedBaseDirectorHandle};
use std::os::raw::c_int;

struct RustProtected {
    total: c_int,
}

impl ProtectedBaseDirector for RustProtected {
    fn secret(&mut self, arg0: c_int) -> c_int {
        self.total += arg0;
        arg0 * 3
    }

    fn plain(&mut self) -> c_int {
        self.total += 1;
        42
    }
}

fn main() {
    let base = rust_director_protected::ProtectedBase::new();
    let mut handle = ProtectedBaseDirectorHandle::connect(&base, RustProtected { total: 0 });

    if base.call_secret(4) != 12 {
        panic!("expected protected virtual call through Rust director");
    }
    if base.call_plain() != 42 {
        panic!("expected protected zero-argument virtual call through Rust director");
    }
    if handle.director_mut().total != 5 {
        panic!("expected protected director state updates");
    }

    handle.disconnect();
    if base.call_secret(4) != 5 {
        panic!("expected protected director disconnect to restore base method");
    }
    if base.call_plain() != 5 {
        panic!("expected protected base method after disconnect");
    }
}
