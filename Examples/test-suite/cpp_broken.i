%module cpp_broken


// bug #1060789
%inline %{
#define MASK(shift, size) (((1 << (size)) - 1) << (shift))
#define SOME_MASK_DEF (80*MASK(8, 10))
%}

// bug #1060079
%inline %{
#define FIELD(name, width) unsigned int name:width
#define SOME_CONST 2
#define NEXT_CONST (2 * SOME_CONST)

typedef struct {
FIELD(a, SOME_CONST);
FIELD(b, NEXT_CONST);
} MyStruct_t;
%}

// bug #994301
%inline %{
#define max(a,b) ((a) > (b) ? (a) : (b))
%}

