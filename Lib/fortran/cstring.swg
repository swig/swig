/* -------------------------------------------------------------------------
 * cstring.swg
 * ------------------------------------------------------------------------- */
%include <forarray.swg>

/* -------------------------------------------------------------------------
 * FRAGMENTS
 * ------------------------------------------------------------------------- */
/* Return fortran allocatable array from assumed-length character string. Put a
 * null character *after* the string for compatibility with const char*.
 */
%fragment("SWIG_string_to_chararray_f", "fwrapper", fragment="SwigArrayWrapper_f", noblock="1") %{
subroutine SWIG_string_to_chararray(string, chars, wrap)
  use, intrinsic :: ISO_C_BINDING
  character(kind=C_CHAR, len=*), intent(IN) :: string
  character(kind=C_CHAR), dimension(:), target, allocatable, intent(OUT) :: chars
  type(SwigArrayWrapper), intent(OUT) :: wrap
  integer(kind=C_SIZE_T) :: i

  allocate(character(kind=C_CHAR) :: chars(len(string) + 1))
  do i=1,len(string)
    chars(i) = string(i:i)
  enddo
  chars(size(chars)) = C_NULL_CHAR ! C string compatibility
  wrap%data = c_loc(chars)
  wrap%size = len(string)
end subroutine
%}

// Copy string to character array
%fragment("SWIG_restore_chararray_f", "fwrapper", fragment="SwigArrayWrapper_f", noblock="1") %{
subroutine SWIG_restore_chararray(chars, string)
  use, intrinsic :: ISO_C_BINDING
  character(kind=C_CHAR), dimension(:), intent(IN) :: chars
  character(kind=C_CHAR, len=*), intent(OUT) :: string
  integer(kind=C_SIZE_T) :: i
  do i=1, len(string)
    string(i:i) = chars(i)
  enddo
end subroutine
%}

// Return fortran allocatable string from character array
%fragment("SWIG_chararray_to_string_f", "fwrapper", fragment="SwigArrayWrapper_f", noblock="1") %{
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
%}

/* -------------------------------------------------------------------------
 * TYPEMAPS
 * ------------------------------------------------------------------------- */

// C wrapper type: pointer to templated array wrapper
%typemap(ctype, noblock=1, out="SwigArrayWrapper", null="SwigArrayWrapper_uninitialized()", fragment="SwigArrayWrapper") const char* NATIVE {
  SwigArrayWrapper*
}

// Copy the output string (if owned) or reference it
%typemap(out, fragment="<stdlib.h>", fragment="<string.h>") const char* NATIVE %{
  $result.size = strlen($1);
  if ($owner) {
    $result.data = malloc($result.size);
    memcpy($result.data, $1, $result.size);
  } else {
    $result.data = $1;
  }
%}

// Since we add a final null character in SWIG_chararray_to_string_f, we can
// just access the data directly.
%typemap(in, noblock=1) const char* NATIVE {
  $1 = %reinterpret_cast($input->data, $1_ltype);
}

%typemap(imtype, import="SwigArrayWrapper") const char* NATIVE
  "type(SwigArrayWrapper)"

// Fortran proxy code: return allocatable string
%typemap(ftype, out="character(kind=C_CHAR, len=:), allocatable") const char* NATIVE
  "character(kind=C_CHAR, len=*), target"

%typemap(findecl) const char* NATIVE %{
  character(kind=C_CHAR), dimension(:), allocatable, target :: $1_chars
%}

%typemap(fin, fragment="SWIG_string_to_chararray_f", noblock=1) const char* NATIVE %{
  call SWIG_string_to_chararray($input, $1_chars, $1)
%}

// Fortran proxy translation code: convert from char array to Fortran string
%typemap(fout, fragment="SWIG_chararray_to_string_f",
         fragment="SWIG_free_f") const char* NATIVE %{
  call SWIG_chararray_to_string($1, $result)
  if ($owner) call SWIG_free($1%data)
%}
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
