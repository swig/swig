/* -----------------------------------------------------------------------------
 * swift.swg
 *
 * Main typemap file for the Swift language module.
 * ----------------------------------------------------------------------------- */

/* This module does not suppress any warnings (no `#pragma SWIG nowarn`), matching
 * the other SWIG language modules.  Anything a real interface triggers should be
 * resolved at its source, e.g.:
 *   - 401 (unknown base class, e.g. std::exception): %include <std_except.i> in
 *     the interface so the base is a known (ignored) type.
 *   - 467 (incomplete typecheck typemap): the SWIGTYPE typecheck typemaps in
 *     swiftswigtype.swg carry a real precedence, so this only fires on a genuine
 *     bug (a typecheck typemap with no precedence silently drops an overload) and
 *     must surface.
 *   - 524 (experimental target language): an accurate one-shot banner; silence it
 *     per-invocation with -w524 if a build runs SWIG under -Werror.
 */

/* Override the Swift access modifier of a wrapped method or constructor (default
 * is "public"), analogous to %csmethodmodifiers / %javamethodmodifiers. Example:
 *   %swiftmethodmodifiers Foo::helper "internal";
 * The "override"/"class" (static) qualifiers are always preserved by the module. */
#define %swiftmethodmodifiers %feature("swiftmethodmodifiers")

/* C runtime helpers inserted into the generated _wrap.cxx file */
%insert(runtime) %{
#include <stdlib.h>
#include <string.h>

/* Thread-local exception state: set from C++, read and cleared from Swift. */
#ifdef __cplusplus
  #include <string>
  static thread_local std::string _swig_swift_pending_exception;
  static thread_local bool        _swig_swift_has_exception = false;

  extern "C" {
#else
  #include <stdbool.h>
  extern
#endif

SWIGEXPORT void SWIG_Swift_SetPendingException(const char *msg) {
#ifdef __cplusplus
    _swig_swift_has_exception = true;
    _swig_swift_pending_exception = msg ? msg : "";
#endif
}

SWIGEXPORT const char *swig_swift_get_pending_exception(void) {
#ifdef __cplusplus
    if (!_swig_swift_has_exception) return NULL;
    return _swig_swift_pending_exception.c_str();
#else
    return NULL;
#endif
}

SWIGEXPORT void swig_swift_clear_pending_exception(void) {
#ifdef __cplusplus
    _swig_swift_has_exception = false;
    _swig_swift_pending_exception.clear();
#endif
}

/* Thread-local buffer for director methods that return std::string.
 * The C++ director copies the const char* into a std::string immediately after
 * the callback returns, so the storage only needs to survive that one operation. */
#ifdef __cplusplus
  static thread_local std::string _swig_swift_director_str_result;
#endif

SWIGEXPORT const char *swig_swift_director_store_string(const char *s) {
#ifdef __cplusplus
    _swig_swift_director_str_result = s ? s : "";
    return _swig_swift_director_str_result.c_str();
#else
    return s;
#endif
}

#ifdef __cplusplus
  } /* extern "C" */
#endif

/* Convenience macros used in generated wrapper bodies */
#ifdef __cplusplus
  #define SWIG_SWIFT_TRY      try {
  #define SWIG_SWIFT_CATCH(r) \
      } catch (const std::exception& e) {            \
          SWIG_Swift_SetPendingException(e.what());  \
          return r;                                  \
      } catch (...) {                                \
          SWIG_Swift_SetPendingException("Unknown C++ exception"); \
          return r;                                  \
      }
  #define SWIG_SWIFT_CATCH_VOID \
      } catch (const std::exception& e) {            \
          SWIG_Swift_SetPendingException(e.what());  \
          return;                                    \
      } catch (...) {                                \
          SWIG_Swift_SetPendingException("Unknown C++ exception"); \
          return;                                    \
      }
#else
  /* C has no exceptions: the try/catch wrappers are no-ops. */
  #define SWIG_SWIFT_TRY
  #define SWIG_SWIFT_CATCH(r)
  #define SWIG_SWIFT_CATCH_VOID
#endif

/* Typed exception support.
 *
 * SWIG_Swift_SetTypedException<T>(ex, typeName) stores a heap-allocated copy
 * of the C++ exception together with its class name in thread-local storage.
 * The Swift side reads it with the three swig_swift_*_typed_exception_* C
 * functions below and dispatches to the right Swift proxy via
 * swigBuildTypedException() (supplied by the module's %pragma(swift) modulecode,
 * or the nil-returning default emitted by the backend).  swigCheckException()
 * (defined further down) first tries the typed path before falling back to the
 * string-only pending-exception path.
 */
#ifdef __cplusplus
  struct _SwigSwiftTypedEx {
    const char *type_name;
    void       *ptr;
    void      (*deleter)(void *);
  };
  static thread_local _SwigSwiftTypedEx _swig_swift_typed_ex;

  template<typename T>
  void SWIG_Swift_SetTypedException(const T& ex, const char *type_name) {
    if (_swig_swift_typed_ex.ptr && _swig_swift_typed_ex.deleter)
      _swig_swift_typed_ex.deleter(_swig_swift_typed_ex.ptr);
    _swig_swift_typed_ex.type_name = type_name;
    _swig_swift_typed_ex.ptr       = static_cast<void *>(new T(ex));
    _swig_swift_typed_ex.deleter   = +[](void *p){ delete static_cast<T *>(p); };
  }

  extern "C" {
  /* Returns the stored exception type name, or NULL if none is pending. */
  SWIGEXPORT const char *swig_swift_get_typed_exception_type(void) {
    return _swig_swift_typed_ex.type_name;
  }
  /* Transfers ownership of the exception pointer to the caller and clears the
   * TLS name/pointer fields.  The deleter is kept so that
   * swig_swift_release_typed_exception() can free unrecognised types. */
  SWIGEXPORT void *swig_swift_steal_typed_exception_ptr(void) {
    void *p = _swig_swift_typed_ex.ptr;
    _swig_swift_typed_ex.ptr       = nullptr;
    _swig_swift_typed_ex.type_name = nullptr;
    return p;
  }
  /* Frees an exception pointer whose Swift type was not recognised.
   * Must be called with the pointer returned by swig_swift_steal_typed_exception_ptr(). */
  SWIGEXPORT void swig_swift_release_typed_exception(void *p) {
    if (p && _swig_swift_typed_ex.deleter)
      _swig_swift_typed_ex.deleter(p);
    _swig_swift_typed_ex.deleter = nullptr;
  }
  } /* extern "C" */
#endif
%}

/* Default exception handling: wrap every wrapped call so a C++ exception is
 * stored as the pending exception instead of escaping the C wrapper (which would
 * call std::terminate).  Every Swift proxy method is generated as `throws` and
 * calls swigCheckException() after the call, which then rethrows it into Swift.
 * Users can still override this with their own %exception. */
%exception {
  SWIG_SWIFT_TRY
  $action
  SWIG_SWIFT_CATCH($null)
}

/* Swift module-level code: error type and helper injected into the .swift file */
%pragma(swift) moduleimports = %{
import Foundation
%}

%pragma(swift) modulecode = %{
// swigBuildTypedException() maps a pending C++ exception to a Swift Error.  A
// module can supply its own (from an Exceptions.i %pragma(swift) modulecode) to
// dispatch to typed Swift error classes; otherwise the backend emits a
// nil-returning default so swigCheckException() falls through to the
// string/NSError path.
@inline(__always)
private func swigCheckException() throws {
    if swig_swift_get_typed_exception_type() != nil,
       let ex = swigBuildTypedException() {
        throw ex
    }
    if let msg = swig_swift_get_pending_exception() {
        defer { swig_swift_clear_pending_exception() }
        // No typed exception matched (std::*, a director error, or an unknown C++
        // exception): surface it as a standard NSError carrying the message, the
        // way the Java/C# bindings map these to RuntimeException / System
        // exceptions rather than a binding-specific error type.
        throw NSError(domain: "$module", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: String(cString: msg)])
    }
}
%}

/* Pull in sub-files */
%include <swiftprimitives.swg>
%include <swiftvoid.swg>
%include <swiftswigtype.swg>
%include <swiftenums.swg>
%include <swiftstrings.swg>
