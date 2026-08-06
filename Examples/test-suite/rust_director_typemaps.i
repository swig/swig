%module(directors="1") rust_director_typemaps

%pragma(rust) modulecode=%{
#[derive(Clone, Copy)]
pub struct LenSlot {
  ptr: *mut c_int,
}

impl LenSlot {
  pub fn from_mut(value: &mut c_int) -> Self {
    Self { ptr: value as *mut c_int }
  }

  pub unsafe fn borrow(ptr: *mut c_void) -> Self {
    Self { ptr: ptr as *mut c_int }
  }

  pub fn as_mut_ptr(self) -> *mut c_void {
    self.ptr as *mut c_void
  }

  pub fn set(self, value: c_int) {
    unsafe {
      *self.ptr = value;
    }
  }
}
%}

%feature("director") InStream;

%typemap(rusttype) int *readLen, int *writeLen "LenSlot"
%typemap(rustin) int *readLen, int *writeLen "$rustinput.as_mut_ptr()"
%typemap(rustdirectorin) int *readLen, int *writeLen "unsafe { LenSlot::borrow($iminput) }"
%typemap(directorin) int *readLen, int *writeLen "$input = $1;"
%typemap(directorout) int *readLen, int *writeLen "$result = ($1_ltype)$input;"

%inline %{
class InStream
{
public:
  virtual int Read(void *buf, int len, int *readLen) = 0;
  virtual int Write(void *buf, int len, int *writeLen) = 0;
  virtual ~InStream() {}
};

int callRead(InStream *stream, void *buf, int len, int *readLen) {
  return stream->Read(buf, len, readLen);
}

int callWrite(InStream *stream, void *buf, int len, int *writeLen) {
  return stream->Write(buf, len, writeLen);
}
%}
