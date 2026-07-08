mod director_void;

use director_void::{DirectorVoidPointerDirector, DirectorVoidPointerDirectorHandle};
use std::os::raw::{c_int, c_void};

struct RustVoidPointer {
    value: Box<c_int>,
}

impl DirectorVoidPointerDirector for RustVoidPointer {
    fn voidPtrOut(&mut self) -> *mut c_void {
        (&mut *self.value as *mut c_int) as *mut c_void
    }

    fn voidPtrIn(&mut self, arg0: *mut c_void) -> c_int {
        let value = unsafe { *(arg0 as *mut c_int) };
        *self.value = value + 7;
        *self.value
    }
}

fn main() {
    let mut object = director_void::DirectorVoidPointer::new(10);
    let _handle = DirectorVoidPointerDirectorHandle::connect(&object, RustVoidPointer { value: Box::new(30) });
    let caller = director_void::Caller::new();

    if caller.callVirtualOut(Some(&mut object)) != 30 {
        panic!("expected void pointer director out");
    }
    if caller.callVirtualIn(Some(&mut object), 5) != 12 {
        panic!("expected void pointer director in");
    }
    if caller.callVirtualOut(Some(&mut object)) != 12 {
        panic!("expected stored void pointer value");
    }
}
