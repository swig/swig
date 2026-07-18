mod rust_naming;

fn main() {
    if rust_naming::global_value() != 7 {
        panic!("expected snake-case global function");
    }

    let widget = rust_naming::NamingWidget::new(3);
    if widget.get_value() != 3 {
        panic!("expected snake-case getter method");
    }
    widget.set_value(9);
    if widget.get_value() != 9 {
        panic!("expected snake-case setter method");
    }
}
