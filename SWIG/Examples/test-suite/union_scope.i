%module union_scope

%inline %{
class nRState { 
public: 
  union { 
    int i; 
  } rstate; 
}; 
%}
