/* -------------------------------------------------------------------------
 * view.i
 * ------------------------------------------------------------------------- */
%include <fortranarray.swg>

/* -------------------------------------------------------------------------
 * \def %fortran_view
 *
 * This maps a return value of pair<T*,size_t> to a small struct (mirrored in
 * fortran) that defines the start and size of a contiguous array.
 */
%define %fortran_view(CTYPE)
  %include <std_pair.i>

  FORT_ARRAYPTR_TYPEMAP(CTYPE, std::pair<CTYPE*, std::size_t >)

  %apply std::pair<CTYPE*, std::size_t> { std::pair<const CTYPE*, std::size_t> }

  // C input translation typemaps: $1 is pair, $input is SwigArrayWrapper
  %typemap(in, noblock=1) std::pair<CTYPE*, std::size_t> {
    $1.first  = static_cast<CTYPE*>($input->data);
    $1.second = $input->size;
  }
  %typemap(in, noblock=1) std::pair<const CTYPE*, std::size_t> {
    $1.first  = static_cast<const CTYPE*>($input->data);
    $1.second = $input->size;
  }

  // C input translation typemaps: $1 is pair, $result is SwigArrayWrapper
  %typemap(out, noblock=1) std::pair<CTYPE*, std::size_t> {
    $result.data = $1.first;
    $result.size = $1.second;
  }
  %typemap(out, noblock=1) std::pair<const CTYPE*, std::size_t> {
    $result.data = const_cast<CTYPE*>($1.first);
    $result.size = $1.second;
  }

  // Instantiate type so that SWIG respects %novaluewrapper
  %template() std::pair<CTYPE*, std::size_t>;
  %template() std::pair<const CTYPE*, std::size_t>;
%enddef


