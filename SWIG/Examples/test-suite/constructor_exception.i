%module constructor_exception

%inline %{
class Error {
};

class Object {
public:
   Object(int x) {
       if (x < 0) {
           throw Error();
       }
   }
};

class Test {
  Object o;
public:
  Test(int x) try : o(x) { }
  catch (Error &e) {
  } 
  catch (int y) {
  }
  catch (...) {
  }
};
%}
