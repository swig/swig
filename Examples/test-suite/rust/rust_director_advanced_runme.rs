mod rust_director_advanced;

use rust_director_advanced::{AdvancedDirector, AdvancedDirectorHandle};
use std::os::raw::c_int;

struct MyAdvanced {
    total: c_int,
}

impl AdvancedDirector for MyAdvanced {
    fn transform(&mut self, arg0: c_int) -> c_int {
        self.total += arg0;
        arg0 * 2
    }

    fn overloaded(&mut self, arg0: c_int) -> c_int {
        arg0 + 100
    }

    fn overloaded_1(&mut self, arg0: c_int, arg1: c_int) -> c_int {
        arg0 * 10 + arg1
    }

    fn pure(&mut self, arg0: c_int) -> c_int {
        arg0 + 7
    }

    fn record(&mut self, arg0: c_int) {
        self.total += arg0;
    }

    fn no_throw(&mut self, arg0: c_int) -> c_int {
        arg0 + 200
    }
}

fn main() {
    let advanced = rust_director_advanced::Advanced::new();
    {
        let mut handle = AdvancedDirectorHandle::connect(&advanced, MyAdvanced { total: 0 });

        if rust_director_advanced::AdvancedDirectorMethodTypes0 != ["c_int"] {
            panic!("unexpected director method metadata");
        }
        if advanced.call_transform(4) != 12 {
            panic!("expected rustdirectorin/rustdirectorout conversion for transform");
        }
        if handle.director().total != 5 {
            panic!("expected transformed input in Rust director");
        }
        if advanced.call_overloaded_one(2) != 105 {
            panic!("expected one-argument overload dispatch");
        }
        if advanced.call_overloaded_two(1, 2) != 25 {
            panic!("expected two-argument overload dispatch");
        }
        if advanced.call_pure(3) != 13 {
            panic!("expected pure virtual director dispatch");
        }
        if advanced.call_no_throw(6) != 209 {
            panic!("expected noexcept director dispatch");
        }

        advanced.call_record(10);
        if handle.director_mut().total != 16 {
            panic!("expected void director callback to update state");
        }

        handle.disconnect();
        if handle.is_connected() {
            panic!("expected explicit director disconnect");
        }
        if advanced.call_transform(4) != 4 {
            panic!("expected explicit disconnect to restore base dispatch");
        }
    }

    if advanced.call_transform(4) != 4 {
        panic!("expected handle drop to disconnect the director");
    }

    let handle = AdvancedDirectorHandle::connect(&advanced, MyAdvanced { total: 0 });
    advanced.call_transform(2);
    let director = handle.into_director();
    if director.total != 3 {
        panic!("expected into_director to return callback state");
    }
    if advanced.call_transform(4) != 4 {
        panic!("expected into_director to disconnect");
    }
}
