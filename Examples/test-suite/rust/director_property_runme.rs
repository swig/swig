mod director_property;

use director_property::FooDirector;

struct RustFoo {
    value: String,
}

impl FooDirector for RustFoo {
    fn ping(&mut self) -> String {
        "rust-ping".to_string()
    }

    fn pong(&mut self) -> String {
        format!("rust-pong-{}", self.value)
    }

    fn getA(&mut self) -> String {
        self.value.clone()
    }

    fn setA(&mut self, arg0: String) {
        self.value = arg0;
    }

    fn setAByRef(&mut self, arg0: String) {
        self.value = format!("ref-{arg0}");
    }
}

fn main() {
    let foo = director_property::FooDirectorOwned::from_proxy(director_property::Foo::new(), RustFoo { value: "start".to_string() });
    if foo.ping() != "rust-ping" {
        panic!("expected property director ping");
    }
    if foo.getA() != "start" {
        panic!("expected property getter director dispatch");
    }
    foo.setA("value".to_string());
    if foo.getA() != "value" {
        panic!("expected property setter director dispatch");
    }
    foo.setAByRef("value".to_string());
    if foo.pong() != "rust-pong-ref-value" {
        panic!("expected by-ref setter director dispatch");
    }
}
