/* File : funcptr.h */

extern int do_op(int, int, int (*op)(int, int));
extern int add(int, int);
extern int sub(int, int);
extern int mul(int, int);

extern int (*funcvar)(int, int);
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
