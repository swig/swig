%module debug

extern int seg_crash();
extern int bus_crash();
extern int blowheap_crash();
extern int overflow_crash();
extern int abort_crash(int);
extern int math_crash(int x, int y);
extern void type_crash(int, short, char, unsigned long, float, double);
