%module enum_scope_template

%inline %{

template<class T> class Tree {
public:
   enum types {Oak, Fir, Cedar};
   void chop(enum types type) {}
};
enum Tree<int>::types chop(enum Tree<int>::types type) { return type; }
 
%}                                                      

%template(TreeInt) Tree<int>;

