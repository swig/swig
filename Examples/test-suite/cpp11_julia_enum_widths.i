%module cpp11_julia_enum_widths
%include <std_pair.i>
#ifdef SWIGJULIA
%warnfilter(465) unsupported_pointer_pair;
#endif
%ignore Hidden;
%rename(Renamed) Original;
#ifdef SWIGCSHARP
// C# constant expressions need C# suffixes and the renamed enumerator.
%csconstvalue("(-9223372036854775807L - 1)") SignedWide::Low;
%csconstvalue("(1UL << 63)") UnsignedWide::Middle;
%csconstvalue("Renamed") Alias;
#endif
#ifdef SWIGD
// D requires its own integer suffixes and the renamed enumerator.
%dconstvalue("(-9223372036854775807L - 1)") SignedWide::Low;
%dconstvalue("(1UL << 63)") UnsignedWide::Middle;
%dconstvalue("18446744073709551615UL") UnsignedWide::High;
%dconstvalue("18446744073709551615UL") AnonymousHigh;
%dconstvalue("Renamed") Alias;
#endif
#ifdef SWIGGO
// TODO: Go wraps anonymous enum constants as int regardless of their underlying type.
%ignore AnonymousHigh;
%rename(ordinary_value) ordinary;
%rename(nested_value) EnumOwner::nested;
#endif
%inline %{
#include <limits>
enum Ordinary { First = -2, Hidden = 12, Next, Original = 0x20, Alias = Original, Expression = (1 << 8) };
enum : unsigned long long { AnonymousHigh = 18446744073709551615ULL };
enum class SignedShort : short { Low = -32768, High = 32767 };
enum class UnsignedInt : unsigned int { High = 4294967295U };
enum class SignedByte : signed char { Low = -128, High = 127 };
enum class UnsignedByte : unsigned char { Low = 0, High = 255 };
enum class SignedWide : long long { Low = (-9223372036854775807LL - 1), High = 9223372036854775807LL };
enum class UnsignedWide : unsigned long long { Low = 0, Middle = (1ULL << 63), High = 18446744073709551615ULL };
Ordinary ordinary(Ordinary value) { return value; }
SignedByte signed_byte(SignedByte value) { return value; }
UnsignedByte unsigned_byte(const UnsignedByte &value) { return value; }
SignedWide signed_wide(const SignedWide &value) { return value; }
UnsignedWide unsigned_wide(UnsignedWide value) { return value; }
const UnsignedWide &wide_reference() {
  static const UnsignedWide value = UnsignedWide::High;
  return value;
}
std::pair<unsigned long long, unsigned long long> unsigned_pair() {
  return std::make_pair(std::numeric_limits<unsigned long long>::max(), 1ULL << 63);
}
std::pair<unsigned int*, unsigned int*> unsupported_pointer_pair() {
  return std::make_pair(static_cast<unsigned int*>(0), static_cast<unsigned int*>(0));
}
std::pair<long long, long long> signed_pair() {
  return std::make_pair(std::numeric_limits<long long>::min(), std::numeric_limits<long long>::max());
}
std::pair<UnsignedWide, SignedByte> enum_pair() {
  return std::make_pair(UnsignedWide::High, SignedByte::Low);
}
struct EnumOwner {
  enum class Nested : unsigned short { High = 65535 };
  static Nested nested(Nested value) { return value; }
};
%}

#ifdef SWIGJULIA
// Other backends retain the shared const-enum typedef local/cast limitation.
%inline %{
typedef const SignedWide ConstSignedWide;
typedef ConstSignedWide ChainedSignedWide;
SignedWide const_alias_value(ConstSignedWide value) { return value; }
SignedWide chained_alias_value(ChainedSignedWide value) { return value; }
SignedWide const_alias_reference(const ConstSignedWide &value) { return value; }
SignedWide chained_alias_reference(const ChainedSignedWide &value) { return value; }
const ChainedSignedWide &alias_reference_return() {
  static const SignedWide value = SignedWide::High;
  return value;
}
struct ConstEnumOwner {
  ConstEnumOwner(const ChainedSignedWide &value) : value_(value) {}
  SignedWide echo(const ConstSignedWide &value) { return value; }
  static SignedWide static_echo(ChainedSignedWide value) { return value; }
  SignedWide get() const { return value_; }
private:
  SignedWide value_;
};
%}
// Top-level return const is part of the parsed alias, but not the C++ function type.
%{
SignedWide alias_return() { return SignedWide::Low; }
%}
ChainedSignedWide alias_return();
%exception exception_alias_reference %{
  throw std::runtime_error("(enum SignedWide const const &)*arg1");
  $action
%}
%inline %{
SignedWide exception_alias_reference(const ConstSignedWide &value) { return value; }
%}
%typemap(in) ConstSignedWide named %{ $1 = SignedWide::High; %}
%inline %{
SignedWide named_alias(ConstSignedWide named) { return named; }
%}
%typemap(arginit) ChainedSignedWide initialized %{ $1 = SignedWide::Low; %}
%typemap(default) ChainedSignedWide defaulted %{ $1 = SignedWide::High; %}
%typemap(in, numinputs=0) ChainedSignedWide initialized, ChainedSignedWide defaulted "";
%inline %{
bool alias_initializers(ChainedSignedWide initialized, ChainedSignedWide defaulted) {
  return initialized == SignedWide::Low && defaulted == SignedWide::High;
}
%}
#endif
