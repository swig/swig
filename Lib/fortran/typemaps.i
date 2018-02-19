/* -------------------------------------------------------------------------
 * typemaps.i
 * ------------------------------------------------------------------------- */

%include <view.i>

/* -------------------------------------------------------------------------
 * STRING VIEWS
 *
 * String views are treated almost exactly like array views, except the Fortran
 * wrapper code uses slightly different types. (To be strictly compatible with
 * Fortran-C interoperability, only arrays of length-1 chars can be passed back
 * and forth between C; we use a fragment in `forfragments.swg` to perform the
 * remapping.
 * ------------------------------------------------------------------------- */

%define %fortran_string_view(CTYPE)
  %fortran_view(CTYPE)

  // Fortran proxy code: accept a character string, but since we don't seem to
  // be able to get character string pointers, return as an array view.
  %typemap(ftype, out="character(kind=C_CHAR), dimension(:), pointer")
       std::pair<const char*, std::size_t>,
       std::pair<char*, std::size_t>
    "character(kind=C_CHAR, len=*), target"

  %typemap(findecl)
      std::pair<const char*, std::size_t>,
      std::pair<char*, std::size_t> %{
    character(kind=C_CHAR), dimension(:), allocatable, target :: $1_chars
  %}

  // Fortran proxy translation code: copy var-length character type to
  // fixed-length character array
  %typemap(fin, fragment="SWIG_string_to_chararray_f", noblock=1)
      std::pair<const char*, std::size_t>,
      std::pair<char*, std::size_t> %{
    call swig_string_to_chararray($input, $1_chars, $1)
  %}

  %typemap(ffreearg, fragment="SWIG_restore_chararray_f", noblock=1)
      std::pair<char*, std::size_t> %{
    call SWIG_restore_chararray($1_chars, $input)
  %}

%enddef


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
