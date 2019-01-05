/* -------------------------------------------------------------------------
 * forstrings.swg
 *
 * C-string typemaps for native fortran conversion.
 * ------------------------------------------------------------------------- */

%include <forarray.swg>

/* -------------------------------------------------------------------------
 * FRAGMENTS
 * ------------------------------------------------------------------------- */
/* Return fortran allocatable array from assumed-length character string. Put a
 * null character *after* the string for compatibility with const char*.
 */
%fragment("SWIG_string_to_chararray_f", "fwrapper", fragment="SwigArrayWrapper_f", noblock=1) {
subroutine SWIG_string_to_chararray(string, chars, wrap)
  use, intrinsic :: ISO_C_BINDING
  character(kind=C_CHAR, len=*), intent(IN) :: string
  character(kind=C_CHAR), dimension(:), target, allocatable, intent(OUT) :: chars
  type(SwigArrayWrapper), intent(OUT) :: wrap
  integer :: i

  allocate(character(kind=C_CHAR) :: chars(len(string) + 1))
  do i=1,len(string)
    chars(i) = string(i:i)
  end do
  i = len(string) + 1
  chars(i) = C_NULL_CHAR ! C string compatibility
  wrap%data = c_loc(chars)
  wrap%size = len(string)
end subroutine
}

// Copy string to character array
%fragment("SWIG_restore_chararray_f", "fwrapper", fragment="SwigArrayWrapper_f", noblock=1) {
subroutine SWIG_restore_chararray(chars, string)
  use, intrinsic :: ISO_C_BINDING
  character(kind=C_CHAR), dimension(:), intent(IN) :: chars
  character(kind=C_CHAR, len=*), intent(OUT) :: string
  integer :: i
  do i=1, len(string)
    string(i:i) = chars(i)
  enddo
end subroutine
}

// Return fortran allocatable string from character array
%fragment("SWIG_chararray_to_string_f", "fwrapper", fragment="SwigArrayWrapper_f", noblock=1) {
subroutine SWIG_chararray_to_string(wrap, string)
  use, intrinsic :: ISO_C_BINDING
  type(SwigArrayWrapper), intent(IN) :: wrap
  character(kind=C_CHAR, len=:), allocatable, intent(OUT) :: string
  character(kind=C_CHAR), dimension(:), pointer :: chars
  integer(kind=C_SIZE_T) :: i
  call c_f_pointer(wrap%data, chars, [wrap%size])
  allocate(character(kind=C_CHAR, len=wrap%size) :: string)
  do i=1, wrap%size
    string(i:i) = chars(i)
  enddo
end subroutine
}

/* -------------------------------------------------------------------------
 * C STRING TYPEMAPS
 *
 * By default, "const char*" and "char*" are automatically converted to and
 * from Fortran native strings.
 * ------------------------------------------------------------------------- */

FORT_ARRAYWRAP_TYPEMAP(const char*)

// Since we add a final null character in SWIG_chararray_to_string_f, we can
// just access the data directly.
%typemap(in, noblock=1) const char * {
  $1 = %reinterpret_cast($input->data, $1_ltype);
}

// Save the outgoing string
%typemap(out, fragment="<stdlib.h>", fragment="<string.h>", noblock=1) const char * {
  $result.size = strlen(%reinterpret_cast($1, const char*));
  $result.data = %const_cast($1, $*1_ltype *);
}

// Fortran proxy code: return allocatable string
%typemap(ftype, in="character(kind=C_CHAR, len=*), target") const char *
  "character(kind=C_CHAR, len=:), allocatable"

%typemap(findecl, match="fin") const char *
  "character(kind=C_CHAR), dimension(:), allocatable, target :: $1_chars"

%typemap(fin, fragment="SWIG_string_to_chararray_f", noblock=1) const char * {
  call SWIG_string_to_chararray($input, $1_chars, $1)
}

// Fortran proxy translation code: convert from char array to Fortran string
%typemap(fout, fragment="SWIG_chararray_to_string_f", noblock=1,
         fragment="SWIG_free_f") const char * {
  call SWIG_chararray_to_string($1, $result)
  if ($owner) call SWIG_free($1%data)
}

%apply const char* { char* };

/* -------------------------------------------------------------------------
 * BYTE ARRAY TYPEMAPS
 *
 * Transform (char *STRING, size_t LENGTH) to a byte array.
 *
 * Note that it's necessary to use a macro for FORT_ARRAYWRAP_TYPEMAP to work correctly.
 * ------------------------------------------------------------------------- */

/* ISO interface type: pointer to templated array wrapper */
FORT_ARRAYWRAP_TYPEMAP(%arg((char *STRING, size_t LENGTH)))

%typemap(in, noblock=1) (char *STRING, size_t LENGTH) {
  $1 = %reinterpret_cast($input->data, $1_ltype);
  $2 = $input->size;
}

%typemap(ftype, in="character(kind=C_CHAR, len=*), target") (char *STRING, size_t LENGTH)
  "character(kind=C_CHAR, len=:), allocatable"

%typemap(findecl, match="fin") (char *STRING, size_t LENGTH)
  "character(kind=C_CHAR), dimension(:), allocatable, target :: $1_chars"

%typemap(fin, fragment="SWIG_string_to_chararray_f", noblock=1) (char *STRING, size_t LENGTH) {
  call SWIG_string_to_chararray($input, $1_chars, $1)
}

// Fortran proxy translation code: convert from char array to Fortran string
%typemap(fout, fragment="SWIG_chararray_to_string_f", noblock=1,
         fragment="SWIG_free_f") (char *STRING, size_t LENGTH) {
  call SWIG_chararray_to_string($1, $result)
  if ($owner) call SWIG_free($1%data)
}

%apply (char *STRING, size_t LENGTH) { (char *STRING, int LENGTH) }

