/* This interface file checks whether the SWIG parses anonymous
   arguments with default values.  Bug reported by Annalisa Terracina
   <annalisa.terracina@datamat.it> on 2001-07-03. 
*/

%module anonymous_arg

%inline %{
  void foo(int = 7771);
  void foo(int x) {}
%}
