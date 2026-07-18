mod example;

fn main() {
    let result = example::add(19, 23);
    if result != 42 {
        panic!("expected 42, got {}", result);
    }
}
