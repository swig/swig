// This is a helper file for auto_ptr and should not be included directly.

// Predefining these symbols allows to apply typemaps to classes different
// from std::auto_ptr<> itself, e.g. std::unique_ptr<> or boost::unique_ptr<>.
// Of course, the class must have similar/same API as std::auto_ptr<> for this
// to work.
#if !defined(SWIG_AUTO_PTR_NAMESPACE)
# define SWIG_AUTO_PTR_NAMESPACE std
#endif

#if !defined(SWIG_AUTO_PTR_CLASSNAME)
# define SWIG_AUTO_PTR_CLASSNAME auto_ptr
#endif

#define SWIG_AUTO_PTR_FULL_NAME SWIG_AUTO_PTR_NAMESPACE::SWIG_AUTO_PTR_CLASSNAME

namespace SWIG_AUTO_PTR_NAMESPACE {
   template <class T> class SWIG_AUTO_PTR_CLASSNAME {};
}
