/* Tests the use of %template with namespaces */

%module namespace_template

%{
namespace test {
   template<typename T> T max(T a, T b) { return (a > b) ? a : b; }
}

namespace test2 {
   using namespace test;
}

namespace test3 {
   using test::max;
}

using namespace test2;
namespace T4 = test;
%}

namespace test {
   template<typename T> T max(T a, T b) { return (a > b) ? a : b; }
}

using namespace test;
%template(maxint) max<int>;

namespace test2 {
   using namespace test;
   %template(maxint2) max<int>;
}

namespace test3 {
   using test::max;
   %template(maxint3) max<int>;
}
