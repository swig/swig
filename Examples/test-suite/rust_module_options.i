%module(rustname="rust_module_options_generated", crate="rust_module_options_crate") rust_module_options

%inline %{
int rust_module_options_value() {
  return 91;
}
%}
