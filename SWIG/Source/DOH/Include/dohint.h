#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>
#include <stdarg.h>

#include "doh.h"

extern void XBase_setfile(DOH *, DOH *);
extern DOH *XBase_getfile(DOH *);
extern void XBase_setline(DOH *, int);
extern int  XBase_getline(DOH *);
