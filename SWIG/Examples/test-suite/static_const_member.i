/* Swig 1.3.6 does not understand initialization of static class
   constants like this.  SF Bug #445221, reported by Krzysztof
   Kozminski <kozminski@users.sf.net>. 
*/

%module static_const_member

%inline %{
  
class X {
public:
  static const int PN = 0;
  static const int CN = 1;
  static const int EN = 2;
};

%}
