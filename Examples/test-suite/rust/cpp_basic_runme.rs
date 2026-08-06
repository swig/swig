mod cpp_basic;

fn check(got: i32, expected: i32) {
    if got != expected {
        panic!("expected {}, got {}", expected, got);
    }
}

fn main() {
    let mut foo = cpp_basic::Foo::new(7);
    check(foo.func1(3), 42);
    check(foo.func2(3), -21);

    let bar = cpp_basic::Bar::new();
    check(bar.test(5, Some(&mut foo)), 27);
}
