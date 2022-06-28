%module cpp11_attribute_specifiers

%inline %{

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

%}
