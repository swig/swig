mod director_string;

use director_string::{ADirector, ADirectorHandle};
use std::ffi::CStr;
use std::os::raw::{c_char, c_int};

struct RustStringDirector {
    processed: usize,
}

impl ADirector for RustStringDirector {
    fn get_first(&mut self) -> String {
        "rust-first".to_string()
    }

    fn get(&mut self, arg0: c_int) -> String {
        format!("rust-{arg0}")
    }

    fn call_get_first(&mut self) -> String {
        "rust-call-first".to_string()
    }

    fn call_get(&mut self, arg0: c_int) -> String {
        format!("rust-call-{arg0}")
    }

    fn string_length(&mut self, arg0: String) -> c_int {
        arg0.len() as c_int
    }

    fn process_text(&mut self, arg0: *mut c_char) {
        if unsafe { CStr::from_ptr(arg0).to_str().unwrap() } == "hello" {
            self.processed += 1;
        }
    }
}

fn main() {
    let a = director_string::A::new("seed".to_string());
    let mut handle = ADirectorHandle::connect(&a, RustStringDirector { processed: 0 });

    if a.get_first() != "rust-first" {
        panic!("expected string director get_first");
    }
    if a.call_get_first() != "rust-call-first" {
        panic!("expected string director call_get_first");
    }
    if a.get(3) != "rust-3" || a.call_get(4) != "rust-call-4" {
        panic!("expected indexed string director calls");
    }
    if a.string_length("abcdef".to_string()) != 6 {
        panic!("expected string argument conversion");
    }
    a.call_process_func();
    if handle.director_mut().processed != 1 {
        panic!("expected char pointer callback input");
    }
}
