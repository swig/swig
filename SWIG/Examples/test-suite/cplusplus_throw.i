/* This interface file checks whether the SWIG parses the throw
   directive in combination with the const directive.  Bug reported by
   Scott B. Drummonds, 08 June 2001.  
*/

%module test

class Bar {
  void baz() const;
  void foo() throw (exception);
  void bazfoo() const throw ();
};
