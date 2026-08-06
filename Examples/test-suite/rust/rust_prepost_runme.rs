mod rust_prepost;

use std::sync::atomic::Ordering;

fn counts() -> (i32, i32, i32) {
    (
        rust_prepost::RUST_PRE_COUNT.load(Ordering::SeqCst),
        rust_prepost::RUST_POST_COUNT.load(Ordering::SeqCst),
        rust_prepost::RUST_TERMINATOR_COUNT.load(Ordering::SeqCst),
    )
}

fn main() {
    if rust_prepost::rust_prepost_global(rust_prepost::HookedInt(4)) != rust_prepost::HookedInt(15) {
        panic!("expected global pre/post typemap conversion");
    }

    let boxed = rust_prepost::RustPrePostBox::new(rust_prepost::HookedInt(6));
    if boxed.value() != rust_prepost::HookedInt(7) {
        panic!("expected constructor pre typemap conversion");
    }
    if boxed.method(rust_prepost::HookedInt(8)) != rust_prepost::HookedInt(16) {
        panic!("expected method pre typemap conversion");
    }
    if rust_prepost::RustPrePostBox::static_method(rust_prepost::HookedInt(9)) != rust_prepost::HookedInt(30) {
        panic!("expected static method pre typemap conversion");
    }
    boxed.set_member(rust_prepost::HookedInt(10));
    if boxed.member() != rust_prepost::HookedInt(11) {
        panic!("expected setter pre typemap conversion");
    }

    if counts() != (5, 5, 5) {
        panic!("expected pre/post/terminator hooks to run for each input");
    }
}
