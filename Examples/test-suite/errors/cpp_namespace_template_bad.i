%module xxx

namespace test {
  template<typename T> T max(T a, T b) { return (a > b) ? a : b; }
  template<typename T> class vector { 
  public:
    vector() { }
    ~vector() { }
  }; 
}

namespace test1 {
  %template(maxchar) ::test::max<char>;
  %template(vectorchar) ::test::vector<char>;
}

namespace test2 {
  using namespace test;
  %template(maxshort) max<short>;
  %template(vectorshort) vector<short>;
}

namespace test3 {
  using test::max;
  using test::vector;
  %template(maxlong) max<long>;
  %template(vectorlong) vector<long>;
}

namespace test4 {
  using namespace test;
  typedef int Integer;
}

namespace test4 {
  %template(maxInteger) max<Integer>;
  %template(vectorInteger) vector<Integer>;
}

namespace test5 {
// Empty namespace
}
template<typename T> struct GlobalVector {
  void gook(T i) {}
  void geeko(double d) {}
  void geeky(int d) {}
};
%template(GlobalVectorIntPtr) test5::GlobalVector<int *>; // should fail as GlobalVector is in global namespace

using namespace test;
namespace test6 {
  %template(maxdouble) max<double>;
  %template(vectordouble) vector<double>;
}
