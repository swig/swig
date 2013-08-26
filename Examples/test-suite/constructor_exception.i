%module constructor_exception

#ifdef SWIGSCILAB
%inline %{
#undef Error
%}
#endif

%inline %{
class Error {
};

class SomeClass {
public:
   SomeClass(int x) {
       if (x < 0) {
           throw Error();
       }
   }
};

class Test {
  SomeClass o;
public:
  Test(int x) try : o(x) { }
  catch (Error &) {
  } 
  catch (int) {
  }
  catch (...) {
  }
};
%}
