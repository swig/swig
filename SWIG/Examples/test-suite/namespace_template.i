/* Tests the use of %template with namespaces */

%module namespace_template

%{
namespace test {
   template<typename T> T max(T a, T b) { return (a > b) ? a : b; }
   template<typename T> class vector { }; 
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
   template<typename T> class vector { }; 	
}

using namespace test;
%template(maxint) max<int>;
%template(vectorint) vector<int>;

namespace test2 {
   using namespace test;
   %template(maxint2) max<int>;
   %template(vectorint2) vector<int>;
}

namespace test3 {
   using test::max;
   using test::vector;
   %template(maxint3) max<int>;
   %template(vectorint3) vector<int>;
}

