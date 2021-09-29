%module constant_expr_c;
/* Tests of constant expressions (C version). */

%inline %{

/* % didn't work in SWIG 1.3.40 and earlier. */
const int X = 123%7;
#define FOO 12 % 9
double d_array[12 % 9];

/* `<` and `>` in constant expressions caused parse errors before SWIG 4.1.0.
 * They're now supported if inside parentheses (and with some restrictions
 * on the LHS of `<`.
 */

// Testcase from https://github.com/swig/swig/issues/635
#define TEST_A 1
#define TEST_B 2
#define TEST_C (TEST_A < TEST_B)
#define TEST_D (TEST_A > TEST_B)
// These have been supported since 1.3.41.
#define TEST_E (TEST_A <= TEST_B)
#define TEST_F (TEST_A >= TEST_B)
// For completeness
#define TEST_G (TEST_A == TEST_B)
#define TEST_H (TEST_A != TEST_B)

// No warning
#if (TEST_A < TEST_B)
#define TEST_I 1
#else
#define TEST_I 0
#endif

%}
