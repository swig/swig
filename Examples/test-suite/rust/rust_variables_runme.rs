mod rust_variables;

fn main() {
    if rust_variables::get_rust_global_value() != 7 {
        panic!("expected initial global value");
    }
    rust_variables::set_rust_global_value(19);
    if rust_variables::get_rust_global_value() != 19 {
        panic!("expected updated global value");
    }
    if rust_variables::get_rust_global_const() != 11 {
        panic!("expected const global value");
    }

    let box_ = rust_variables::RustVarBox::new();
    if box_.value() != 3 {
        panic!("expected initial member value");
    }
    box_.set_value(23);
    if box_.value() != 23 {
        panic!("expected updated member value");
    }

    if rust_variables::RustVarBox::static_value() != 5 {
        panic!("expected initial static member value");
    }
    rust_variables::RustVarBox::set_static_value(29);
    if rust_variables::RustVarBox::static_value() != 29 {
        panic!("expected updated static member value");
    }
    if rust_variables::RustVarBox::STATIC_CONST != 17 {
        panic!("expected class static const value");
    }
}
