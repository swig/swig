%module final_c

%inline %{
struct Y {
  int yval;
};
struct Y final;
void init() {
  final.yval = 123;
}
%}
