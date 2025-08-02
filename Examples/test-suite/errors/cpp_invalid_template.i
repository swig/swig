%module xxx

%template(abc) SSS::AAA<int>;

namespace UUU {
  struct JJJ;
}

%template(xxx) UUU::JJJ<int>;

%template(TTT_int) VVV::TTT<int>; // needs to be after template is parsed
namespace VVV {
  template<typename T> struct TTT {};
}
