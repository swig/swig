%module swift_typed_exception

// Swift-specific test: user code calling the runtime by its plain names.  A
// %exception block stores a typed exception with SWIG_Swift_SetTypedException and
// a plain one with SWIG_Swift_SetPendingException; module code reads the typed
// one back through swig_swift_get_typed_exception_type(),
// swig_swift_steal_typed_exception_ptr() and swig_swift_release_typed_exception()
// and builds the Swift error, the way an interface file of a real binding does.

%include <std_except.i>

%exception {
  try {
    $action
  } catch (const CodedError &e) {
    SWIG_Swift_SetTypedException(e, "CodedError"); return $null;
  } catch (const OtherError &e) {
    SWIG_Swift_SetTypedException(e, "OtherError"); return $null;
  } catch (const std::exception &e) {
    SWIG_Swift_SetPendingException(e.what()); return $null;
  }
}

%inline %{
#include <stdexcept>
struct CodedError : public std::exception {
  int code;
  CodedError(int c) : code(c) {}
  int getCode() const { return code; }
};
struct OtherError : public std::exception {
  OtherError() {}
};
void throw_coded(int code) { throw CodedError(code); }
void throw_other() { throw OtherError(); }
void throw_plain() { throw std::runtime_error("plain failure"); }
int no_throw() { return 7; }
%}

%pragma(swift) modulecode = %{
extension CodedError: Error {}

private func swigBuildTypedException() -> (any Error)? {
    guard let typeName = swig_swift_get_typed_exception_type(),
          let ptr = swig_swift_steal_typed_exception_ptr() else {
        return nil
    }
    switch String(cString: typeName) {
    case "CodedError":
        return CodedError(ptr, true)
    default:
        // No Swift type for this one: free the copy and report the name.
        let name = String(cString: typeName)
        swig_swift_release_typed_exception(ptr)
        return NSError(domain: "swift_typed_exception", code: 2,
                       userInfo: [NSLocalizedDescriptionKey: "unhandled typed exception \(name)"])
    }
}
%}
