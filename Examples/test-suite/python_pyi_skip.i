%module python_pyi_skip
%feature("python:annotations", "typing");
%feature("python:stub:skip") hidden;
%feature("python:stub:skip") visible;
%feature("python:stub:skip", "0") visible;
%feature("python:stub:skip") replaced;
%feature("python:stub:skip") Widget::Widget;
%feature("python:stub:skip") Widget::call;
%feature("python:stub:skip") Widget::twice;
%feature("python:stub:skip") Widget::internal;

%inline %{
int hidden(int n) { return n + 1; }
int replaced(int n) { return n * 2; }
int visible(int n) { return n; }
class Widget {
public:
  Widget(int n) : value(n) {}
  int call(int n) { return value + n; }
  int call(int n, int extra) { return value + n + extra; }
  static int twice(int n) { return 2 * n; }
  int internal(int n) { return value - n; }
  int ordinary(int n) { return n; }
  int value;
};
%}

%pythonstubcode %{
def replaced(value: int) -> int: ...
%}

%extend Widget {
  %pythonstubcode %{
    def __init__(self, value: int) -> None: ...
    def call(self, __value: int, __extra: int = ...) -> int: ...
    @staticmethod
    def twice(value: int) -> int: ...
  %}
}
