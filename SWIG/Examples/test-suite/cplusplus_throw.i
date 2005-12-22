/* This interface file checks whether the SWIG parses the throw
   directive in combination with the const directive.  Bug reported by
   Scott B. Drummonds, 08 June 2001.  
*/

%module cplusplus_throw

%nodefaultctor;

%inline %{

class Foo { };

class Bar {
public:
  void baz() const { };
  void foo() throw (Foo) { };
  void bazfoo() const throw (int) { };
};

%}

