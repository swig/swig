/* Swig 1.3.6 fails to understand the "explicit" keyword.
   SF Bug #445233, reported by Krzysztof Kozminski
   <kozminski@users.sf.net>. 
*/

%module "explicit"

%inline %{

class A {
  public:
    explicit A(int) {};
};

%}
