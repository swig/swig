%module xxx

#define ZERO 0

#if 1%ZERO
#endif
#if 2/ZERO
#endif

#if 1%(5-5)
#endif
#if 2/(55-55)
#endif
