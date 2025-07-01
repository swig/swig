%module cpp11_attribute_specifiers

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) a;

%rename("_noret_%s", match$attribute$noreturn=1) "";
%rename("_%s", match$attribute$nodiscard=1) "";
%rename("__deprecated_%s", %$isdeprecated, notmatch$attribute$nodiscard) "";
%rename("$ignore", %$isgnuhidden) "";

%inline %{

#if defined(__GNUC__)
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // We're using a deprecated attribute here...
#pragma GCC diagnostic ignored "-Wattributes"              // likely is C++20
#pragma GCC diagnostic ignored "-Wunused-variable"         // We are using an unused variable on purpose here
#pragma GCC diagnostic ignored "-Wunused-parameter"        // We are using an unused param on purpose here
#endif

#if defined(__clang__)
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wattributes"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-parameter"
#endif

#if defined(_MSC_VER)
#pragma warning(disable : 4996) // For the deprecated attributes in this testcase
#pragma warning(disable : 5030) // attribute is not recognized ('likely' and 'unlikely')
#endif

#ifndef __BIGGEST_ALIGNMENT__
#define __BIGGEST_ALIGNMENT__ 16
#endif

[[noreturn]] void noReturn() { throw; }
[[nodiscard]] bool noDiscard() { return true; }
[[noreturn]] [[nodiscard]] void noReturnNoDiscard() { throw; }
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

enum E {
  oldval [[deprecated("Replaced by newval")]],
  newval
};

[[gnu::aligned(16)]] int aligned_var_1 = 0;
int aligned_var_2 [[gnu::aligned(__BIGGEST_ALIGNMENT__)]] = 0;

[[gnu::alloc_size (1, 2)]] typedef void* (*calloc_ptr) (size_t, size_t);
struct [[nodiscard, gnu::aligned(16)]] S {
  [[gnu::visibility("default")]] virtual int visible(int a) { return a + 1; }
  [[gnu::visibility("hidden")]] int hiddenWithString(const int &n = int()) { return 4; }
  [[gnu::visibility("hidden")]] static int hidden(int a) { return a + 2; }
  int x;
  virtual ~S() = default;
};

const char *test_string_literal() { return "Test [[ and ]] in string literal"; }

[[gnu::visibility("default")]] int visible(int a) { return a + 1; }
[[gnu::visibility("hidden"), gnu::always_inline]] int hidden(int a) { return a + 2; }

// Check that SWIG handles ]] as two ] tokens when it's not part of an attribute.
int aa = 0;
int *a = &aa;
int b = a[a[0]];

%}
