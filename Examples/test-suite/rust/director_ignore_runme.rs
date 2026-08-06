mod director_ignore;

use director_ignore::{DAbstractIgnoresDirector, DIgnoresDirector};
use std::os::raw::{c_double, c_int};

struct RustIgnores {
    called: bool,
}

impl DIgnoresDirector for RustIgnores {
    fn OverloadedMethod(&mut self, arg0: bool) {
        self.called = arg0;
    }

    fn Triple(&mut self, arg0: c_int) -> c_int {
        arg0 * 30
    }

    fn TempMethod(&mut self) {
        self.called = true;
    }

    fn OverloadedProtectedMethod(&mut self) {
        self.called = true;
    }
}

struct RustAbstractIgnores;

impl DAbstractIgnoresDirector for RustAbstractIgnores {
    fn OverloadedMethod(&mut self, arg0: bool) -> c_double {
        if arg0 {
            1.5
        } else {
            2.5
        }
    }

    fn Quadruple(&mut self, arg0: c_int) -> c_int {
        arg0 * 40
    }

    fn OverloadedProtectedMethod(&mut self) -> c_double {
        3.5
    }
}

fn main() {
    let ignores = director_ignore::DIgnoresDirectorOwned::from_proxy(director_ignore::DIgnores::new(), RustIgnores { called: false });
    ignores.OverloadedMethod(true);
    if !ignores.director().called {
        panic!("expected non-ignored overload director dispatch");
    }
    if ignores.Triple(3) != 90 {
        panic!("expected non-ignored virtual director dispatch");
    }

    let abstract_ignores =
        director_ignore::DAbstractIgnoresDirectorOwned::from_proxy(director_ignore::DAbstractIgnores::new(), RustAbstractIgnores);
    if (abstract_ignores.OverloadedMethod(true) - 1.5).abs() > 0.001 {
        panic!("expected abstract ignore overload director dispatch");
    }
    if abstract_ignores.Quadruple(2) != 80 {
        panic!("expected abstract non-ignored virtual dispatch");
    }
}
