mod rust_nspace;

fn main() {
    let thing = rust_nspace::outer::Thing::new(7);
    assert_eq!(thing.value(), 7);
    assert_eq!(rust_nspace::outer::Kind::KindLarge, rust_nspace::outer::Kind::KindLarge);

    let nested = rust_nspace::outer::inner::Nested::new(9);
    assert_eq!(nested.value(), 9);

    let mut made = rust_nspace::make_outer_thing(11).expect("factory returned a Thing");
    assert_eq!(rust_nspace::read_outer_thing(Some(&mut made)), 11);
}
