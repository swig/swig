%module xxx

%template(abc) SSS::AAA<int>;

namespace UUU {
  struct JJJ;
}

%template(xxx) UUU::JJJ<int>;
