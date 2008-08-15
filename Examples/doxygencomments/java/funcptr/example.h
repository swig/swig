/* file: example.h */

extern int do_op(int,int, int (*op)(int,int));
/*! Describing function add */
extern int add(int,int);
extern int sub(int,int);
extern int mul(int,int);

extern int (*funcvar)(int,int);

