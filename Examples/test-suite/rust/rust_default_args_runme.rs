mod rust_default_args;

fn main() {
    assert_eq!(rust_default_args::rust_default_add(1, 2, 3), 6);
    assert_eq!(rust_default_args::rust_default_add_1(1, 2), 6);
    assert_eq!(rust_default_args::rust_default_add_2(1), 6);

    let defaults = rust_default_args::RustDefaults::new();
    assert_eq!(defaults.sum_2(), 13);
    assert_eq!(defaults.sum_1(5), 17);
    assert_eq!(defaults.sum(5, 6), 21);
    assert_eq!(defaults.next_1(), rust_default_args::RustDefaultMode::ModeHigh);
    assert_eq!(
        defaults.next(rust_default_args::RustDefaultMode::ModeHigh),
        rust_default_args::RustDefaultMode::ModeLow
    );

    let custom = rust_default_args::RustDefaults::new_0(20);
    assert_eq!(custom.sum_2(), 23);
    assert_eq!(rust_default_args::RustDefaults::stat_2(), 12);
    assert_eq!(rust_default_args::RustDefaults::stat_1(5), 20);
    assert_eq!(rust_default_args::RustDefaults::stat(5, 6), 30);
}
