%module extern_c

%inline %{
extern "C" {
void RealFunction(int value);
typedef void Function1(int value); // Fails
typedef int Integer1;
}
typedef void Function2(int value); // Works
typedef int Integer2;
%}

%{
void RealFunction(int value) {}
%}

