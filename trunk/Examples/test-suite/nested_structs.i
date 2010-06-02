%module nested_structs

// bug #491476
%inline %{
struct Outer {
  struct {
    int val;
  } inner1, inner2, *inner3, inner4[1];
  struct Named {
    int val;
  } inside1, inside2, *inside3, inside4[1];
} outer;

void setValues(struct Outer *outer, int val) {
  outer->inner1.val = val;
  outer->inner2.val = val * 2;
  outer->inner3 = &outer->inner2;
  outer->inner4[0].val = val * 4;

  val = val * 10;
  outer->inside1.val = val;
  outer->inside2.val = val * 2;
  outer->inside3 = &outer->inside2;
  outer->inside4[0].val = val * 4;
}
%}

