/* file: example.h */

typedef int (*binary_func)(int, int);

extern int do_op(int, int, binary_func);
extern int add(int, int);
extern int sub(int, int);
extern int mul(int, int);

extern int (*funcvar)(int, int);

