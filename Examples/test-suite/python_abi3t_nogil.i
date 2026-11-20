%module python_abi3t_nogil

%inline %{
int abi3t_nogil_value() { return 7; }
%}
