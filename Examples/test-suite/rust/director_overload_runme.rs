mod director_overload;

use director_overload::{
    OverloadedClass, OverloadedClassDirector, OverloadedClassDirectorMethodTypes0,
    OverloadedClassDirectorMethodTypes3, OverloadedClassDirectorOwned, OverloadedGetSet,
    OverloadedGetSetDirector, OverloadedGetSetDirectorOwned,
};

struct RustOverloadedClass {
    method1: i32,
    method2: i32,
    method2_bool: i32,
    last_bool: bool,
}

impl OverloadedClassDirector for RustOverloadedClass {
    fn method1(&mut self) {
        self.method1 += 1;
    }

    fn method2(&mut self) {
        self.method2 += 1;
    }

    fn method2_1(&mut self, value: bool) {
        self.method2_bool += 1;
        self.last_bool = value;
    }
}

struct RustOverloadedGetSet;

impl OverloadedGetSetDirector for RustOverloadedGetSet {
    fn rw(&mut self) -> i32 {
        77
    }
}

fn main() {
    if !OverloadedClassDirectorMethodTypes0.is_empty() {
        panic!("expected no argument metadata for method1");
    }
    if OverloadedClassDirectorMethodTypes3 != ["bool"] {
        panic!("expected bool metadata for overloaded method2(bool)");
    }

    let object = OverloadedClassDirectorOwned::from_proxy(
        OverloadedClass::new(),
        RustOverloadedClass {
            method1: 0,
            method2: 0,
            method2_bool: 0,
            last_bool: false,
        },
    );

    object.method1();
    object.method2();
    object.method2_1(true);

    if object.director().method1 != 1 {
        panic!("expected method1 director callback");
    }
    if object.director().method2 != 1 {
        panic!("expected method2 director callback");
    }
    if object.director().method2_bool != 1 || !object.director().last_bool {
        panic!("expected overloaded method2(bool) director callback");
    }

    let getter = OverloadedGetSetDirectorOwned::from_proxy(OverloadedGetSet::new(), RustOverloadedGetSet);
    if getter.rw() != 77 {
        panic!("expected overloaded getter director callback");
    }
}
