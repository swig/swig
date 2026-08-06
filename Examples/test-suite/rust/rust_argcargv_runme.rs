mod rust_argcargv;

use std::ffi::CString;

fn main() {
    unsafe {
        let args = vec![CString::new("one").unwrap(), CString::new("two").unwrap()];
        let mut ptrs = args.iter().map(|arg| arg.as_ptr() as *mut _).collect::<Vec<_>>();
        ptrs.push(std::ptr::null_mut());

        if rust_argcargv::rust_argcargv_count(ptrs.as_mut_ptr()) != 2 {
            panic!("expected argc 2");
        }
    }
}
