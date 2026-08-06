mod director_default;

use director_default::FooDirector;

struct RustFoo;

impl FooDirector for RustFoo {
    fn Msg(&mut self, arg0: String) -> String {
        format!("rust-{arg0}")
    }

    fn Msg_1(&mut self) -> String {
        "rust-default".to_string()
    }
}

fn main() {
    let foo = director_default::FooDirectorOwned::from_proxy(director_default::Foo::new(), RustFoo);
    if foo.GetMsg() != "rust-default" {
        panic!("expected default argument director dispatch");
    }
    if foo.GetMsg_1("value".to_string()) != "rust-value" {
        panic!("expected explicit argument director dispatch");
    }
}
