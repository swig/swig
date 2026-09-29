%module stl_typemaps
%include <std_vector.i>
%template(IntVector) std::vector<int>;
%typemap(in, tsstub_in="{items: number[]}") std::vector<int> custom {
  emscripten::val input = swig_wasmjs::borrowed_value($input);
  $1 = swig_wasmjs::conversion<std::vector<int> >::read(input["items"]);
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) std::vector<int> custom {
  try {
    emscripten::val input = swig_wasmjs::borrowed_value($input);
    swig_wasmjs::conversion<std::vector<int> >::read(input["items"]);
    $1 = 1;
  } catch (...) { $1 = 0; }
}
%typemap(out, tsstub_out="{items: number[]}") std::vector<int> custom_values {
  emscripten::val output = emscripten::val::object();
  output.set("items", swig_wasmjs::conversion<std::vector<int> >::write($1));
  $result = output.release_ownership();
}
%inline %{
std::vector<int> custom_values(std::vector<int> custom) { custom.push_back(7); return custom; }
std::vector<int> ordinary_values(std::vector<int> value) { return value; }
%}
