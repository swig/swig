/* -----------------------------------------------------------------------------
 * Define SWIG_VERSION
 * ----------------------------------------------------------------------------- */

/* Define SWIG_VERSION in the interface and the wrapper code.
 *
 * Best practice is to use SWIG-time checks for SWIG_VERSION, but SWIG_VERSION
 * was unintentionally defined like this for many years, and while it was never
 * documented there are likely user interface files which rely on it.
 */
%define %define_swig_version_()%#define SWIG_VERSION_ SWIG_VERSION %enddef
%insert("header") {
%define_swig_version_()
%#define SWIG_VERSION SWIG_VERSION_
}
#undef %define_swig_version_
