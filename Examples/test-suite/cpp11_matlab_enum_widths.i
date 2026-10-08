%module(directors="1") cpp11_matlab_enum_widths
%feature("director") EnumCallback;
%include <std_vector.i>
%include <std_pair.i>
%inline %{
enum : unsigned long long { ANONYMOUS_HIGH = 18446744073709551615ULL };
enum class SignedWide : long long { low = (-9223372036854775807LL - 1), high = 9223372036854775807LL };
typedef unsigned long long WideBase;
enum class UnsignedWide : WideBase { high = 18446744073709551615ULL };
enum class Flag : bool { off = false, on = true };
enum class PairNarrow : unsigned char { high = 255 };
enum class PairWide : unsigned long long { high = 18446744073709551615ULL };
enum class Narrow : unsigned char { high = 255 };
enum class Signed32 : int { low = (-2147483647 - 1), high = 2147483647 };
enum class Unsigned32 : unsigned int { high = 4294967295U };
typedef SignedWide SignedAlias;
typedef const SignedWide ConstSignedAlias;
ConstSignedAlias const_signed_echo(ConstSignedAlias value) { return value; }
struct EnumCallback {
  virtual ~EnumCallback() {}
  virtual SignedWide signed_value(SignedWide value) = 0;
  virtual UnsignedWide unsigned_value(UnsignedWide value) = 0;
};
SignedWide invoke_signed(EnumCallback &callback, SignedWide value) { return callback.signed_value(value); }
UnsignedWide invoke_unsigned(EnumCallback &callback, UnsignedWide value) { return callback.unsigned_value(value); }
Flag flag_echo(Flag value) { return value; }
SignedAlias signed_echo(SignedAlias value) { return value; }
UnsignedWide unsigned_echo(UnsignedWide value) { return value; }
Narrow narrow_echo(Narrow value) { return value; }
Signed32 signed32_echo(Signed32 value) { return value; }
Unsigned32 unsigned32_echo(Unsigned32 value) { return value; }
const SignedWide &signed_ref(const SignedWide &value) { return value; }
struct EnumHolder {
  enum class Code : unsigned short { high = 65535 };
  Narrow narrow;
  SignedWide wide;
  EnumHolder() : narrow(Narrow::high), wide(SignedWide::low) {}
};
%}
%constant UnsignedWide MAX_ENUM = UnsignedWide::high;
%template(EnumPair) std::pair<PairNarrow, PairWide>;
%template(NarrowVector) std::vector<Narrow>;
%template(WideVector) std::vector<UnsignedWide>;
%inline %{
std::pair<PairNarrow, PairWide> pair_values(std::pair<PairNarrow, PairWide> value) { return value; }
std::vector<Narrow> narrow_values(std::vector<Narrow> values) { return values; }
std::vector<UnsignedWide> wide_values(std::vector<UnsignedWide> values) { return values; }
bool enum_storage_guard(mxArray *input);
%}
%insert("wrapper") %{
bool enum_storage_guard(mxArray *input) {
  struct alignas(int) Guard {
    Narrow value;
    unsigned char canary[sizeof(int)];
  } guard;
  guard.value = Narrow::high;
  for (unsigned i = 0; i < sizeof(guard.canary); ++i) guard.canary[i] = 0xa5;
  int status = swig::traits_asval<Narrow>::asval(input, &guard.value);
  for (unsigned i = 0; i < sizeof(guard.canary); ++i)
    if (guard.canary[i] != 0xa5) return false;
  return SWIG_IsOK(status) && guard.value == Narrow::high;
}
%}
