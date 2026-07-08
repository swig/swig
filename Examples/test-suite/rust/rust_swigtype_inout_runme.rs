mod rust_swigtype_inout;

fn main() {
    let mut raw = std::ptr::null_mut();
    unsafe {
        rust_swigtype_inout::rust_make_inout_thing(&mut raw);
        let mut thing = rust_swigtype_inout::InoutThing::from_raw(raw).expect("expected inout thing");
        if rust_swigtype_inout::rust_inout_thing_value(Some(&mut thing)) != 61 {
            panic!("expected inout value 61");
        }
    }
}
