/* -----------------------------------------------------------------------------
 * std_shared_ptr.i
 * ----------------------------------------------------------------------------- */

%{
#include <memory>
%}
#define SWIG_SHARED_PTR_NAMESPACE std
%include <boost_shared_ptr.i>
