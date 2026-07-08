mod global_functions;

fn check(got: i32, expected: i32) {
    if got != expected {
        panic!("expected {}, got {}", expected, got);
    }
}

fn main() {
    global_functions::global_void();
    check(global_functions::global_one(1), 1);
    check(global_functions::global_two(2, 2), 4);
}
