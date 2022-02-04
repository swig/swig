/* -------------------------------------------------------------------------
 * std_span.i
 * ------------------------------------------------------------------------- */
%include <fortranarray.swg>

/* -------------------------------------------------------------------------
 * Note: even though "span" is currently only a proposed part of C++20, most other C++ scientific codes have similar classes.
 */
namespace std
{
%naturalvar span;

template<class _Tp, int _Ex = -1>
class span
{
 public:
  typedef int index_type;
  typedef _Tp* pointer;

  pointer data();
  index_type size();

  // Value and const reference
  %fortran_array_pointer(_Tp, std::span<_Tp, _Ex >)
  %typemap(in, noblock=1) std::span<_Tp, _Ex > {
    $1 = $1_type(static_cast<$1_basetype::pointer>($input->data), $input->size);
  }
  %typemap(out, noblock=1) std::span<_Tp, _Ex > {
    $result.data = $1.data();
    $result.size = $1.size();
  }

  // Const-reference should act like value; but it requires a temporary
  %apply std::span<_Tp, _Ex > { const std::span<_Tp, _Ex >& };
  %typemap(in, noblock=1) const std::span<_Tp, _Ex >&
  ($1_basetype tmpspan) {
    tmpspan = $1_basetype(static_cast<$1_basetype::pointer>($input->data), $input->size);
    $1 = &tmpspan;
  }
  %typemap(out, noblock=1) const std::span<_Tp, _Ex >& {
    $result.data = (void*)($1->data());
    $result.size = $1->size();
  }

  // Mutable reference input
  %fortran_array_handle(_Tp, std::span<_Tp, _Ex >)
  %typemap(in, noblock=1) std::span<_Tp, _Ex >& (std::span<_Tp, _Ex > tmpspan) {
    tmpspan = $1_basetype(static_cast<$1_basetype::pointer>($input->data), $input->size);
    $1 = &tmpspan;
  }
  %typemap(argout, noblock=1, match="in") std::span<_Tp, _Ex >& {
    $input->data = (void*)tmpspan$argnum.data();
    $input->size = tmpspan$argnum.size();
  }
};
} // end namespace std


