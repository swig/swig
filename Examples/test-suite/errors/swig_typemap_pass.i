%module xxx

%typemap(in) int "pass";
%typemap(out) double %{pass%}
