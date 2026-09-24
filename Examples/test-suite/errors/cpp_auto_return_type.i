%module xxx

// Auto return type with no trailing return type, including cv-qualified placeholders.

struct A {
  auto plain() const {
    return 42;
  }
  const auto& cref() const {
    static const int i = 42;
    return i;
  }
  auto const& cref2() const {
    static const int i = 42;
    return i;
  }
  const auto& forward_decl() const;
};

const auto& global_cref();
auto const& global_cref2();

// A deleted function has no definition to deduce a return type from and is ignored without a
// warning.  A defaulted one is ignored with the usual warning; the return type is not deduced
// from the '= default', which would give the function a bogus type.
struct B {
  auto deleted_fn() = delete;
  auto defaulted_fn() = default;
};

// A trailing return type requires the placeholder on its own, so these are not valid C++.
const auto& bad_trailing(int x) -> int;
Numeric auto const& bad_trailing2(int x) -> int;

// A conversion function with a deduced type and a conversion-declarator.
struct C {
  operator auto&();
  operator const auto&() const;
  operator auto*();
  operator auto&&();
  operator auto const*&();
};
