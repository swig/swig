%module xxx

#ifdef FOO
long long i;
#elsif defined(BAR)
long i;
#else
int i;
#endif
