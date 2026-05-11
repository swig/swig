/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * Objective-C support for raw C data using NSData.
 * ----------------------------------------------------------------------------- */

%typemap(imtype) (const void *BYTES, size_t LENGTH),
                 (void *BYTES, size_t LENGTH),
                 (const void *BYTES, int LENGTH),
                 (void *BYTES, int LENGTH),
                 (const void *indata, size_t inlen) "NSData *"

%typemap(objctype) (const void *BYTES, size_t LENGTH),
                   (void *BYTES, size_t LENGTH),
                   (const void *BYTES, int LENGTH),
                   (void *BYTES, int LENGTH),
                   (const void *indata, size_t inlen) "NSData *"

%typemap(objcin) (const void *BYTES, size_t LENGTH),
                (void *BYTES, size_t LENGTH),
                (const void *BYTES, int LENGTH),
                (void *BYTES, int LENGTH),
                (const void *indata, size_t inlen) "$objcinput"

%typemap(in) (const void *BYTES, size_t LENGTH) {
  if ($input) {
    $1 = ($1_ltype)[$input bytes];
    $2 = ($2_ltype)[$input length];
  } else {
    $1 = 0;
    $2 = 0;
  }
}

%typemap(in) (void *BYTES, size_t LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(in) (const void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(in) (void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(in) (const void *indata, size_t inlen) = (const void *BYTES, size_t LENGTH);

#define SWIG_CDATA_APPLIED

%include <typemaps/cdata_begin.swg>

%typemap(imtype) SWIGCDATA "NSData *"
%typemap(objctype) SWIGCDATA "NSData *"
%typemap(out) SWIGCDATA {
  $result = [NSData dataWithBytes:$1.data length:(NSUInteger)$1.len];
}
%typemap(objcout) SWIGCDATA {
  return $imcall;
}

%include <typemaps/cdata_end.swg>
