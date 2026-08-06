mod example;

fn check_close(got: f64, expected: f64) {
    if (got - expected).abs() > 0.00001 {
        panic!("expected {}, got {}", expected, got);
    }
}

fn main() {
    let circle = example::Circle::new(10.0);
    let square = example::Square::new(10.0);

    check_close(circle.area(), 314.1592653589793);
    check_close(circle.perimeter(), 62.83185307179586);
    check_close(square.area(), 100.0);
    check_close(square.perimeter(), 40.0);

    circle.delete();
    square.delete();
}
