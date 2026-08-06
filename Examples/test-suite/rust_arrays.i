%module rust_arrays

%include <arrays_csharp.i>

%apply int INPUT[] { int values[] };

%inline %{
int rust_array_first(int values[]) {
  return values[0];
}
%}
