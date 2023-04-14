/*
 * This should not compile in when this bug is present
 * https://github.com/swig/swig/issues/2525
 */

#define my_bad_attr __attribute__
#define my_good_attr(x) __attribute__(x)

int bad my_bad_attr((used));
int good my_good_attr((used));

/*
 * The behaviour of Self-Referential Macros is defined
 * https://gcc.gnu.org/onlinedocs/gcc-4.8.5/cpp/Self-Referential-Macros.html
 */
int y = 0;

#define x (4 + y)
#define y (2 * x)

int z = y;
