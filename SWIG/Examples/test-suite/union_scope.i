%module union_scope

%warnfilter(801) nRState;		// Ruby, wrong class name
%warnfilter(801) nRState_rstate;	// Ruby, wrong class name

%inline %{
class nRState { 
public: 
  union { 
    int i; 
  } rstate; 
}; 
%}
