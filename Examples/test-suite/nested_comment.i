%module nested_comment

// this example shows a problem with 'dump_nested' (parser.y).

// bug #949654
%inline %{
typedef struct s1 {
union {
int fsc; /* genie structure hiding - Conductor
*/
int fso; /* genie structure hiding - FSOptions
*/
struct {
double *vals;
int size;
} vector_val; /* matrix values are mainly used
in rlgc models */
char *name;
} n ;
} s2; 

%}

// bug #491476
%inline %{
struct {
struct {
int a;
} a, b;
} a;

%}

// bug #909387
%inline %{
struct foo {
  struct happy; // no warning
  struct sad { int x; }; // warning
  happy *good(); // produces good code
  sad *bad(); // produces bad code
};
