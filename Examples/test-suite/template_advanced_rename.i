%module template_advanced_rename

%inline %{
namespace Quirky {
template<typename T> T funky(T a, T b) { return a+b; }
template<typename T> T funky(T a) { return a; }
template<typename T> void funky() {}
}
%}

%rename("%s_void") Quirky::funky<int>();
%template(funky_int) Quirky::funky<int>;

%rename("%(firstuppercase)s_Void") Quirky::funky<double>();
%template(funky_double) Quirky::funky<double>;

%rename("%(uppercase)s") Quirky::funky<bool>;
%template() Quirky::funky<bool>;

%inline %{
namespace Golden {
  template<typename T> T goose(T t);
}
%}

%{
template<typename T> T Golden::goose(T t) { return t; }
%}

%rename("%(firstuppercase)s") Golden::goose<int>(int t);
%template() Golden::goose<int>;

%rename("%(regex:/^(.*)::(.*)/\\1_\\2/)s", fullname=1) Golden::goose<bool>;
%template() Golden::goose<bool>;
