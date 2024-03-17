%module final_c

%warnfilter(SWIGWARN_PARSE_KEYWORD) final; // 'final' is a java keyword, renaming to '_final'

%inline %{
struct Y {
  int yval;
};
struct Y final;
void init() {
  final.yval = 123;
}
%}
