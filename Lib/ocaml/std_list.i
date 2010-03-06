/* -----------------------------------------------------------------------------
 * std_list.i
 *
 * SWIG typemaps for std::list types
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%{
  #include <list>
%}

namespace std {

  template< class T >
  class list {

    public:

      %traits_swigtype(T);

  };
}
