%module c_delete

/* check C++ delete keyword is okay in C wrappers */

%inline %{
struct delete {
  int delete;
};
%}

%rename(DeleteGlobalVariable) delete;
%inline %{
int delete = 0;
%}
