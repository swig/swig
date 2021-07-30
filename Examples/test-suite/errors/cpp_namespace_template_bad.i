%module xxx

namespace test {
  template<typename T> T max(T a, T b) { return (a > b) ? a : b; }
  template<typename T> class vector { 
  public:
    vector() { }
    ~vector() { }
  }; 
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

using namespace test;
namespace test5 {
  %template(maxdouble) max<double>;
  %template(vectordouble) vector<double>;
}

