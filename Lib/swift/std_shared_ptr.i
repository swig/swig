/* -----------------------------------------------------------------------------
 * std_shared_ptr.i
 *
 * Swift typemaps for std::shared_ptr<T>.
 * The shared_ptr* is stored as the opaque handle in the Swift proxy class.
 * Memory: the Swift proxy owns a heap-allocated shared_ptr<T>*.
 * ----------------------------------------------------------------------------- */

#define SWIG_SHARED_PTR_NAMESPACE std
%include <boost_shared_ptr.i>

