mod director_basic;

use director_basic::{Bar, FooDirector, FooDirectorHandle, MyClassDirector, MyClassDirectorHandle};
use std::os::raw::{c_int, c_void};

struct RustFoo;

impl FooDirector for RustFoo {
    fn ping(&mut self) -> String {
        "RustFoo::ping()".to_string()
    }

    fn pong(&mut self) -> String {
        "RustFoo::pong()".to_string()
    }
}

struct RustMyClass;

impl MyClassDirector for RustMyClass {
    fn method(&mut self, _arg0: *mut c_void) {}

    fn vmethod(&mut self, arg0: Bar) -> Bar {
        Bar::new_0(arg0.x() + 30)
    }

    fn pmethod(&mut self, arg0: Option<&mut Bar>) -> Option<Bar> {
        arg0.map(|bar| Bar::new_0(bar.x()))
    }

    fn nonVirtual(&mut self) -> c_int {
        202
    }

    fn nonOverride(&mut self) -> c_int {
        303
    }

    fn Connect(&mut self) {}
}

fn main() {
    let foo = director_basic::Foo::new();
    let _foo_handle = FooDirectorHandle::connect(&foo, RustFoo);
    if foo.ping() != "RustFoo::ping()" {
        panic!("expected Rust Foo ping override");
    }
    if foo.pong() != "RustFoo::pong()" {
        panic!("expected Rust Foo pong override");
    }

    let mut my = director_basic::MyClass::new();
    let _my_handle = MyClassDirectorHandle::connect(&my, RustMyClass);
    let mut bar = Bar::new_0(7);
    let returned = director_basic::MyClass::call_pmethod(Some(&mut my), Some(&mut bar)).expect("expected Bar pointer");
    if returned.x() != 7 {
        panic!("expected pointer return from Rust director");
    }
    let copied = my.cmethod(&bar);
    if copied.x() != 37 {
        panic!("expected value return from Rust director");
    }
    if director_basic::MyClass::call_nonVirtual(Some(&mut my)) != 202 {
        panic!("expected Rust override for virtual method");
    }
    if director_basic::MyClass::call_nonOverride(Some(&mut my)) != 303 {
        panic!("expected Rust override for virtual method");
    }
}
