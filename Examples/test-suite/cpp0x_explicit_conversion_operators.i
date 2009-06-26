/* This interface checks whether Swig correctly compiles the new
   explicit conversion operators feature introduced in C++0x.
*/
%module foo

%inline %{

class U {
public:
        int u;
};

class V {
public:
        int v;
};

class TestClass {
public:
        //implicit converting constructor
        TestClass( U const &val ) { t=val.u; }
        // explicit constructor
        explicit TestClass( V const &val ) { t=val.v; }
        
        int t;
};
%}

