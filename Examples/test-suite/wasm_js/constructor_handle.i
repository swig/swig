%module constructor_handle
%{
typedef int Token;
%}
typedef int Token;
%typemap(ctype) Token "EM_VAL"
%typemap(in, tsstub_in="{value: number}") Token {
  emscripten::val v = emscripten::val::take_ownership($input);
  $1 = v["value"].as<int>();
  v.release_ownership();
}
%inline %{
class HandleConsumer {
public:
  HandleConsumer(Token token, int multiplier = 2) : result(token * multiplier) {}
  int result;
};
%}
