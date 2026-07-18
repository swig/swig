mod rust_director_typemaps;

use rust_director_typemaps::{InStreamDirector, InStreamDirectorOwned, LenSlot};
use std::os::raw::{c_int, c_void};

struct RustStream {
    constant: c_int,
}

impl InStreamDirector for RustStream {
    fn Read(&mut self, arg0: *mut c_void, arg1: c_int, arg2: LenSlot) -> c_int {
        let value = if arg0.is_null() { -arg1 - self.constant } else { arg1 + self.constant };
        arg2.set(value);
        value
    }

    fn Write(&mut self, arg0: *mut c_void, arg1: c_int, arg2: LenSlot) -> c_int {
        let value = if arg0.is_null() { -arg1 - self.constant } else { arg1 + self.constant };
        arg2.set(value);
        value
    }
}

fn main() {
    let mut stream = InStreamDirectorOwned::from_proxy(rust_director_typemaps::InStream::new(), RustStream { constant: 100 });
    let mut read_len = -1;
    let mut write_len = -1;
    let mut token = 0i32;

    let read = unsafe {
        rust_director_typemaps::callRead(
            Some(stream.as_proxy_mut()),
            (&mut token as *mut i32) as *mut c_void,
            23,
            LenSlot::from_mut(&mut read_len),
        )
    };
    if read != 123 || read_len != 123 {
        panic!("expected director Read typemap out value");
    }

    let write = unsafe {
        rust_director_typemaps::callWrite(
            Some(stream.as_proxy_mut()),
            std::ptr::null_mut(),
            23,
            LenSlot::from_mut(&mut write_len),
        )
    };
    if write != -123 || write_len != -123 {
        panic!("expected director Write typemap out value");
    }
}
