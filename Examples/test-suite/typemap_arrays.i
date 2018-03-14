%module typemap_arrays

// Test that previously non-working array typemaps special variables are working
%typemap(in) SWIGTYPE[ANY] {
  _should_not_be_used_and_will_not_compile_
}

// Check $basemangle expands to _p_int and $basetype expands to int *
%typemap(in) int *nums[3] (int *temp[3]) {
  $basetype var1$basemangle = new int(10);
  $basetype var2$basemangle = new int(20);
  $basetype var3$basemangle = new int(30);
  temp[0] = var1_p_int;
  temp[1] = var2_p_int;
  temp[2] = var3_p_int;
  $1 = temp;
}

%inline %{
int sumA(int *nums[3]) {
  int sum = 0;
  for (int i=0; i<3; ++i) {
    int *p = nums[i];
    if (p)
      sum += *p;
  }
  return sum;
}
%}

// Test array typemap precedence
%define TEST_TYPEMAP(FUNCSIG, CORRECT, INCORRECT)
%typemap(in) CORRECT { /* Matched $descriptor(CORRECT) */ }
%typemap(in) INCORRECT {
%#error #FUNCSIG matched the wrong typemap: #INCORRECT instead of #CORRECT
}
%inline %{
FUNCSIG { (void)x; }
%}

// Clear typemaps
%typemap(in) CORRECT, INCORRECT;

%enddef

/* Check array matching order. The fixed-size "ANY" typemap should be used
 * instead of
 *
 * INPUT: Foo [3][4]:
 *   Foo [3][4]
 *   Foo [ANY][ANY]
 *   SWIGTYPE [ANY][ANY]
 *   SWIGTYPE [][ANY]
 *
 */

%inline %{
class Foo {};
%}

TEST_TYPEMAP(void multiarray(Foo x[3][4]),
             Foo [ANY][ANY],
             Foo [][])
#if 0
/* It seems to me like Foo[][ANY] and Foo *[ANY] are closer to Foo[3][4] than
 * SWIGTYPE[ANY][ANY], but that's not the current typematch order
 */
TEST_TYPEMAP(void multiarray2(Foo x[3][4]),
             Foo [][ANY],
             SWIGTYPE [ANY][ANY])
TEST_TYPEMAP(void multiarray3(Foo x[3][4]),
             Foo *[ANY],
             SWIGTYPE [ANY][ANY])
TEST_TYPEMAP(void multiarray4(Foo x[3][4]),
             Foo *[ANY],
             SWIGTYPE [ANY][ANY])
#endif
TEST_TYPEMAP(void multiarrayu(Foo x[][4]),
             Foo [][ANY],
             Foo [][])
TEST_TYPEMAP(void multiarrayu2(Foo x[][4]),
             Foo [][4],
             Foo [][ANY])
#if 0
/* Again we have the replacement of [] with [ANY] as opposed to *.
 */
TEST_TYPEMAP(void multiarrayu3(Foo x[][4]),
             Foo *[ANY],
             Foo [ANY][ANY])
#endif
TEST_TYPEMAP(void multiarrayu4(Foo x[][4]),
             SWIGTYPE [][ANY],
             SWIGTYPE [ANY][ANY]) /* first array dim is NOT fixed size! */
/* The first attempt should replace only *known* array dimension */
TEST_TYPEMAP(void multiarrayu5(Foo x[][4]),
             Foo [][ANY],
             Foo [ANY][ANY])

#if 0
/* The given type signature is invalid C++:
 *
 *    array has incomplete element type 'Foo []'
 *
 * but SWIG always searches for SWIGTYPE [ANY][] regardless
 */
TEST_TYPEMAP(void multiarrayubad(Foo x[4][]),
             SWIGTYPE **,
             SWIGTYPE [ANY][])
#endif

TEST_TYPEMAP(void array(Foo x[4]),
             Foo [ANY],
             Foo [])
TEST_TYPEMAP(void array2(Foo x[]),
             Foo [],
             Foo [ANY])
/* Unknown-size arrays shouldn't be tested against fixed-size typemaps.
 */
TEST_TYPEMAP(void array3(Foo x[]),
             SWIGTYPE [],
             Foo [ANY])
#if 0
/* Currently Foo[] does not get converted to Foo* in the type checking order.
 */
TEST_TYPEMAP(void array4(Foo x[]),
             Foo *,
             SWIGTYPE [])
#endif

