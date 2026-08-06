#![allow(non_snake_case)]

mod director_shared_ptr;

use director_shared_ptr::{Foo, FooBar, FooDerived, FooDerivedDirector, FooDerivedDirectorOwned, FooDirector, FooDirectorOwned};

struct MyBarFoo;

impl FooDirector for MyBarFoo {
    fn ping(&mut self) -> String {
        "director_shared_ptr_MyBarFoo.ping()".to_string()
    }

    fn pong(&mut self) -> String {
        format!("director_shared_ptr_MyBarFoo.pong();{}", self.ping())
    }

    fn upcall(&mut self, fooBarPtr: Option<&mut FooBar>) -> String {
        format!("override;{}", fooBarPtr.expect("fooBarPtr").FooBarDo())
    }

    fn makeFoo(&mut self) -> Foo {
        Foo::new()
    }
}

struct MyBarFooDerived;

impl FooDirector for MyBarFooDerived {
    fn ping(&mut self) -> String {
        "director_shared_ptr_MyBarFooDerived.ping()".to_string()
    }

    fn pong(&mut self) -> String {
        format!("director_shared_ptr_MyBarFooDerived.pong();{}", FooDirector::ping(self))
    }

    fn upcall(&mut self, fooBarPtr: Option<&mut FooBar>) -> String {
        format!("overrideDerived;{}", fooBarPtr.expect("fooBarPtr").FooBarDo())
    }

    fn makeFoo(&mut self) -> Foo {
        Foo::new()
    }
}

impl FooDerivedDirector for MyBarFooDerived {
    fn ping(&mut self) -> String {
        FooDirector::ping(self)
    }

    fn pong(&mut self) -> String {
        FooDirector::pong(self)
    }

    fn upcall(&mut self, fooBarPtr: Option<&mut FooBar>) -> String {
        FooDirector::upcall(self, fooBarPtr)
    }

    fn makeFoo(&mut self) -> Foo {
        FooDirector::makeFoo(self)
    }
}

fn check(got: String, expected: &str) {
    if got != expected {
        panic!("failed, got: {}, expected: {}", got, expected);
    }
}

fn main() {
    let mut foo_bar = FooBar::new();

    let mut my_bar_foo = FooDirectorOwned::from_proxy(Foo::new(), MyBarFoo);
    check(my_bar_foo.ping(), "director_shared_ptr_MyBarFoo.ping()");
    check(
        Foo::callPong(my_bar_foo.as_proxy_mut()),
        "director_shared_ptr_MyBarFoo.pong();director_shared_ptr_MyBarFoo.ping()",
    );
    check(
        Foo::callUpcall(my_bar_foo.as_proxy_mut(), Some(&mut foo_bar)),
        "override;Bar::Foo2::Foo2Bar()",
    );

    let mut my_foo = my_bar_foo.makeFoo();
    check(my_foo.pong(), "Foo::pong();Foo::ping()");
    check(Foo::callPong(&mut my_foo), "Foo::pong();Foo::ping()");
    check(my_foo.upcall(Some(&mut FooBar::new())), "Bar::Foo2::Foo2Bar()");

    let mut my_foo2 = Foo::new().makeFoo();
    check(my_foo2.pong(), "Foo::pong();Foo::ping()");
    check(Foo::callPong(&mut my_foo2), "Foo::pong();Foo::ping()");

    let mut my_bar_foo_derived = FooDerivedDirectorOwned::from_proxy(FooDerived::new(), MyBarFooDerived);
    let mut my_bar_foo_derived_as_foo = my_bar_foo_derived.as_proxy_mut().as_Foo_mut();
    check(my_bar_foo_derived_as_foo.ping(), "director_shared_ptr_MyBarFooDerived.ping()");
    check(
        Foo::callPong(&mut my_bar_foo_derived_as_foo),
        "director_shared_ptr_MyBarFooDerived.pong();director_shared_ptr_MyBarFooDerived.ping()",
    );
    check(
        Foo::callUpcall(&mut my_bar_foo_derived_as_foo, Some(&mut foo_bar)),
        "overrideDerived;Bar::Foo2::Foo2Bar()",
    );
}
