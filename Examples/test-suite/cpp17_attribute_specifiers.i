%module cpp17_attribute_specifiers

%rename("$ignore", match$attribute$gnu$visibility="\"hidden\"") "";

%inline %{
[[using gnu: visibility("hidden"), cold]] int hidden(int a) { return a + 2; }
[[using gnu: visibility("default")]] int visible(int a) { return a + 1; }
%}
