mod rust_ownership;

use rust_ownership::{LifetimeThing, RustOwnership};
use std::os::raw::c_void;

fn main() {
    let borrowed = rust_ownership::maybe_lifetime(1).expect("expected borrowed pointer result");
    if !borrowed.is_borrowed() || borrowed.ownership() != RustOwnership::Borrowed {
        panic!("expected non-newobject pointer result to be borrowed");
    }
    if borrowed.value() != 100 {
        panic!("expected borrowed pointer method dispatch");
    }
    if rust_ownership::maybe_lifetime(0).is_some() {
        panic!("expected null pointer result to map to None");
    }

    let alive_at_start = LifetimeThing::alive();

    let mut owned = rust_ownership::make_owned_lifetime(7).expect("expected owned factory result");
    if !owned.is_owned() || owned.ownership() != RustOwnership::Owned {
        panic!("expected factory result to be owned");
    }
    if owned.value() != 7 {
        panic!("expected owned proxy method dispatch");
    }
    if rust_ownership::lifetime_value(Some(&mut owned)) != 7 {
        panic!("expected nullable mutable proxy pointer argument");
    }
    if rust_ownership::lifetime_value(None) != -1 {
        panic!("expected None to map to a null mutable proxy pointer");
    }
    if rust_ownership::const_lifetime_value(Some(&owned)) != 7 {
        panic!("expected nullable const proxy pointer argument");
    }
    if rust_ownership::const_lifetime_value(None) != -1 {
        panic!("expected None to map to a null const proxy pointer");
    }

    rust_ownership::set_lifetime_value(&mut owned, 8);
    if owned.value() != 8 {
        panic!("expected mutable reference argument");
    }
    rust_ownership::set_lifetime_value(&mut owned, 7);

    let borrowed_ref = rust_ownership::lifetime_ref(&mut owned);
    if !borrowed_ref.is_borrowed() {
        panic!("expected reference return to be borrowed");
    }
    if borrowed_ref.value() != 7 {
        panic!("expected borrowed reference method dispatch");
    }

    let alias = owned.borrow_proxy();
    if !alias.is_borrowed() || alias.value() != 7 {
        panic!("expected explicit lifetime-bound borrowed proxy alias");
    }
    if alias.as_proxy().ownership() != RustOwnership::Borrowed {
        panic!("expected borrowed proxy view");
    }
    if rust_ownership::const_lifetime_value(Some(&alias)) != 7 {
        panic!("expected borrowed proxy view to pass as a const proxy pointer");
    }
    let const_ref = rust_ownership::const_lifetime_ref(&alias);
    if !const_ref.is_borrowed() || const_ref.value() != 7 {
        panic!("expected borrowed proxy view to pass as a const proxy reference");
    }
    drop(alias);

    {
        let mut mutable_alias = owned.borrow_proxy_mut();
        rust_ownership::set_lifetime_value(mutable_alias.as_proxy_mut(), 9);
        if mutable_alias.value() != 9 {
            panic!("expected mutable borrowed proxy view to update the object");
        }
        if rust_ownership::lifetime_value(Some(mutable_alias.as_proxy_mut())) != 9 {
            panic!("expected mutable borrowed proxy view to pass as mutable pointer");
        }
    }
    if owned.value() != 9 {
        panic!("expected mutable borrowed proxy view to share object identity");
    }
    rust_ownership::set_lifetime_value(&mut owned, 7);

    let _const_ptr: *const c_void = owned.as_ptr();

    let raw = owned.into_raw();
    let owned_again = unsafe { LifetimeThing::from_raw(raw) }.expect("expected non-null raw pointer");
    if !owned_again.is_owned() || owned_again.value() != 7 {
        panic!("expected raw ownership transfer back into an owned proxy");
    }
    drop(owned_again);

    if LifetimeThing::alive() != alive_at_start {
        panic!("expected owned proxy drop to free exactly one object");
    }

    if unsafe { LifetimeThing::from_raw(std::ptr::null_mut()) }.is_some() {
        panic!("expected null raw pointer construction to fail");
    }

    let delete_me = rust_ownership::make_owned_lifetime(11).expect("expected owned value for explicit delete");
    if LifetimeThing::alive() != alive_at_start + 1 {
        panic!("expected explicit-delete object to be alive");
    }
    delete_me.delete();
    if LifetimeThing::alive() != alive_at_start {
        panic!("expected safe explicit delete to free owned object");
    }
}
