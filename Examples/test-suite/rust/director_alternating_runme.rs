mod director_alternating;

fn main() {
    if director_alternating::idFromGetBar() != 2 {
        panic!("expected C++ alternating inherited dispatch");
    }
    if director_alternating::getBar().is_none() {
        panic!("expected getBar to return a wrapped pointer");
    }
}
