%module enum_scope

#ifdef SWIGPHP
// php internal naming conflict
%rename (chops) chop;
#endif

%inline %{
class Tree {
public:
enum types {Oak, Fir, Cedar};
void chop(enum types type) {}
void test(int x = Oak + Fir + Cedar) {}
};
enum Tree::types chop(enum Tree::types type) { return type; }
 
%}                                                      
