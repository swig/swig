%module enum_widths
%include <std_vector.i>
%inline %{
#include <limits>
typedef unsigned long long wide_unsigned;
enum class SignedWide : long long { low = (-9223372036854775807LL - 1), high = 9223372036854775807LL };
enum class UnsignedWide : wide_unsigned { high = 18446744073709551615ULL };
enum class Signed32 : int { low = (-2147483647 - 1), high = 2147483647 };
enum class Unsigned32 : unsigned int { high = 4294967295U };
enum class Narrow : unsigned char { high = 255 };
enum class DefaultScoped { one = 1 };
enum ImplicitWide { implicit_high = 1ULL << 40 };
enum Plain { plain_one = 1 };
typedef SignedWide SignedAlias;
SignedAlias alias_echo(SignedAlias value) { return value; }
Signed32 signed32_echo(Signed32 value) { return value; }
Unsigned32 unsigned32_echo(Unsigned32 value) { return value; }
int choose_width(SignedWide) { return 64; }
int choose_width(Signed32) { return 32; }
SignedWide signed_echo(SignedWide value) { return value; }
UnsignedWide unsigned_echo(UnsignedWide value) { return value; }
Narrow narrow_echo(Narrow value) { return value; }
DefaultScoped scoped_echo(DefaultScoped value) { return value; }
ImplicitWide implicit_echo(ImplicitWide value) { return value; }
Plain plain_echo(Plain value) { return value; }
const SignedWide &signed_reference(const SignedWide &value) { return value; }
%}
%constant UnsignedWide MAX_ENUM = UnsignedWide::high;
%template(SignedVector) std::vector<SignedWide>;
%template(NarrowVector) std::vector<Narrow>;
%template(ImplicitVector) std::vector<ImplicitWide>;
%inline %{
std::vector<SignedWide> signed_values(std::vector<SignedWide> values) { return values; }
std::vector<Narrow> narrow_values(std::vector<Narrow> values) { return values; }
std::vector<ImplicitWide> implicit_values(std::vector<ImplicitWide> values) { return values; }
%}

%inline %{
typedef unsigned long long ConstantInteger;
%}
%feature("wasmjs:enum_int_type", "ConstantInteger") ConstantOverride;
%inline %{
enum class ConstantOverride : unsigned int { high = 4294967295U };
ConstantOverride override_echo(ConstantOverride value) { return value; }
%}
%template(OverrideVector) std::vector<ConstantOverride>;
%inline %{
std::vector<ConstantOverride> override_values(std::vector<ConstantOverride> values) { return values; }
%}
