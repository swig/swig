/* -----------------------------------------------------------------------------
 * boost_shared_ptr.i
 *
 * SWIG library file for handling boost::shared_ptr.
 * This file redirects to std_shared_ptr.i which contains the actual typemaps.
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_SHARED_PTR_NAMESPACE
#define SWIG_SHARED_PTR_NAMESPACE boost
#endif
%include <std_shared_ptr.i>
