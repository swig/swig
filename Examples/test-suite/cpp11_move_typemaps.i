%module cpp11_move_typemaps

%include <swigmove.i>
%apply SWIGTYPE MOVE { MoveOnly mo }
%valuewrapper MovableCopyable;
%apply SWIGTYPE MOVE { MovableCopyable mc }

%inline %{
#define WRAP_TAKE_METHOD
%}

%include "cpp11_move_only.i"
