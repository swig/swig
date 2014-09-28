%module operator_precedence

%include "stdint.i"
typedef unsigned int size_t;

%inline %{

#define NN_PROTO_PIPELINE 5

#define NN_PUSH (NN_PROTO_PIPELINE * 16 + 0)
#define NN_PULL (NN_PROTO_PIPELINE * 16 + 1)

#define NN_PUSH_RESULT 80
#define NN_PULL_RESULT 81
%}
