%module enum_scope

%inline %{
class Tree {
public:
enum types {Oak, Fir, Cedar};
void chop(enum types type) {}
};
enum Tree::types chop(enum Tree::types type) {}
 
%}                                                      