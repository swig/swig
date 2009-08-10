/* This testcase checks whether Swig correctly uses the new 'decltype()'
   introduced in C++0x.
*/
%module cpp0x_decltype

%inline %{
class A {
public:
        int i;
        decltype(i) j;
        
        auto foo( decltype(i) a ) -> decltype(i) {
                if (a==5)
                        return 10;
                else
                        return 0;
        }
};
%}
