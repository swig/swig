mod rust_keywords;

fn main() {
    assert_eq!(rust_keywords::crate_(4), 5);
    assert_eq!(
        rust_keywords::select_async(rust_keywords::async_::dyn_),
        rust_keywords::async_::impl_
    );

    let keyword = rust_keywords::type_::new(8);
    assert_eq!(keyword.match_(), 10);
    assert_eq!(keyword.use_(), 8);

    let nested = rust_keywords::outer::mod_::trait_::new(13);
    assert_eq!(nested.self_(), 13);
}
