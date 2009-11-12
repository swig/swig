%module union_scope

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) nRState;		// Ruby, wrong class name
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) nRState_rstate;	// Ruby, wrong class name
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) nRState::rstate;

%inline %{
class nRState { 
public: 
  union { 
    int i; 
  } rstate; 
}; 
%}
