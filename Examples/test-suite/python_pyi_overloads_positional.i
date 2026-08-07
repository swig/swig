%module python_pyi_overloads_positional

// Test that python:annotations:positional-only-overloads adds '/' to the end of the parameter list for overloaded functions.

%feature("python:annotations", "typing");
%feature("python:annotations:positional-only-overloads");

%inline %{
short overloaded() {
    return 42;
}
short overloaded(short a) {
    return a + 1;
}
short overloaded(short a, short b) {
    return a + b;
}

short not_overloaded(short a, short b) {
    return a + b;
}
%}
