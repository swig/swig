mod rust_std_string_view;

fn main() {
    if rust_std_string_view::rust_string_view_size("hello".to_string()) != 5 {
        panic!("expected string_view size 5");
    }
}
