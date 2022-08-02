%module cpp11_attribute_specifiers

%inline %{

#if defined(__GNUC__)
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // We're using a deprecated attribute here...
#pragma GCC diagnostic ignored "-Wattributes"              // likely is C++20
#pragma GCC diagnostic ignored "-Wunused-variable"         // We are using an unused variable on purpose here
#pragma GCC diagnostic ignored "-Wunused-parameter"        // We are using an unused param on purpose here
#endif

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wattributes"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-parameter"
#endif

#if defined(_MSC_VER)
#pragma warning(disable : 4996) // For the deprecated attributes in this testcase
#endif


[[noreturn]] void noReturn() { throw; }
[[nodiscard]] bool noDiscard() { return true; }
[[nodiscard, deprecated("This has been replaced")]] bool noDiscardDeprecated() { return true; }
void maybeUnused1([[maybe_unused]] bool b) { }
bool maybeUnused2(bool a, [[maybe_unused]] bool b) { return a; }

[[deprecated, nodiscard]] bool likely([[maybe_unused]] bool a, bool b) {
  [[maybe_unused]] bool c = b;
  if (b) [[likely]] {
    return true;
  } else [[unlikely]] {
    if(a) {
      return true;
    }
  }
  return false;
}

struct [[nodiscard]] S { };

const char *test_string_literal() { return "Test [[ and ]] in string literal"; }

#if 0
// Check that SWIG doesn't choke on ]] when it's not part of an attribute.
// FIXME: SWIG's parser doesn't handle this case currently.
int *a;
int b = a[a[0]];
#endif

%}
