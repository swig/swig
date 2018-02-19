/* File : downstream.i */
%module downstream;

%import "except.i"

%inline %{
void throw_error()
{
    throw std::logic_error("Threw an error for you");
}
%}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
