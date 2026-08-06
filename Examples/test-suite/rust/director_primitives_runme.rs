mod director_primitives;

use director_primitives::{BaseDirector, BaseDirectorHandle, HShadowMode};
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_float, c_int, c_uint};

struct RustBase {
    calls: usize,
}

impl BaseDirector for RustBase {
    fn NoParmsMethod(&mut self) {
        self.calls += 1;
    }

    fn BoolMethod(&mut self, arg0: bool) -> bool {
        !arg0
    }

    fn IntMethod(&mut self, arg0: c_int) -> c_int {
        arg0 + 10
    }

    fn UIntMethod(&mut self, arg0: c_uint) -> c_uint {
        arg0 + 20
    }

    fn FloatMethod(&mut self, arg0: c_float) -> c_float {
        arg0 + 1.5
    }

    fn CharPtrMethod(&mut self, arg0: *mut c_char) -> *mut c_char {
        arg0
    }

    fn ConstCharPtrMethod(&mut self, arg0: *mut c_char) -> *mut c_char {
        arg0
    }

    fn EnumMethod(&mut self, _arg0: HShadowMode) -> HShadowMode {
        HShadowMode::HShadowSoft
    }

    fn ManyParmsMethod(&mut self, arg0: bool, arg1: c_int, arg2: c_uint, arg3: c_float, arg4: *mut c_char, arg5: *mut c_char, arg6: HShadowMode) {
        if !arg0 || arg1 != -3 || arg2 != 4 || (arg3 - 5.5).abs() > 0.001 {
            panic!("unexpected primitive values");
        }
        if unsafe { CStr::from_ptr(arg4).to_str().unwrap() } != "left" || unsafe { CStr::from_ptr(arg5).to_str().unwrap() } != "right" {
            panic!("unexpected string values");
        }
        if arg6 != HShadowMode::HShadowHard {
            panic!("unexpected enum value");
        }
        self.calls += 1;
    }

    fn NotOverriddenMethod(&mut self) {
        self.calls += 1;
    }
}

fn main() {
    let caller = director_primitives::Caller::new();
    let mut base = director_primitives::Base::new(100.0);
    let mut handle = BaseDirectorHandle::connect(&base, RustBase { calls: 0 });

    caller.set(Some(&mut base));
    caller.NoParmsMethodCall();
    if caller.BoolMethodCall(true) {
        panic!("expected bool director result");
    }
    if caller.IntMethodCall(5) != 15 {
        panic!("expected int director result");
    }
    if caller.UIntMethodCall(5) != 25 {
        panic!("expected uint director result");
    }
    if (caller.FloatMethodCall(2.0) - 3.5).abs() > 0.001 {
        panic!("expected float director result");
    }

    let left = CString::new("left").unwrap();
    let right = CString::new("right").unwrap();
    unsafe {
        let returned = caller.CharPtrMethodCall(left.as_ptr() as *mut c_char);
        if CStr::from_ptr(returned).to_str().unwrap() != "left" {
            panic!("expected char pointer director result");
        }
        caller.ManyParmsMethodCall(true, -3, 4, 5.5, left.as_ptr() as *mut c_char, right.as_ptr() as *mut c_char, HShadowMode::HShadowHard);
    }
    if caller.EnumMethodCall(HShadowMode::HShadowHard) != HShadowMode::HShadowSoft {
        panic!("expected enum director result");
    }
    caller.NotOverriddenMethodCall();
    caller.reset();

    if handle.director_mut().calls != 3 {
        panic!("expected three void-like director calls");
    }
}
