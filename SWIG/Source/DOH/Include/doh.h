/* -----------------------------------------------------------------------------
 * doh.h
 *
 *     This file describes of the externally visible functions in DOH.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

#ifndef _DOH_H
#define _DOH_H

#include <stdio.h>
#include <stdarg.h>

#define DOH_MAJOR_VERSION 0
#define DOH_MINOR_VERSION 1

typedef void DOH;

/*
 * With dynamic typing, all DOH objects are technically of type 'void *'.
 * However, to clarify the reading of source code, the following symbolic
 * names are used.
 */

#define DOHString          DOH
#define DOHList            DOH
#define DOHHash            DOH
#define DOHFile            DOH
#define DOHVoid            DOH
#define DOHString_or_char  DOH
#define DOHObj_or_char     DOH

#define DOH_BEGIN          -1
#define DOH_END            -2
#define DOH_CUR            -3
#define DOH_CURRENT        -3

/* Memory management */

#ifndef DohMalloc
#define DohMalloc malloc
#endif
#ifndef DohRealloc
#define DohRealloc realloc
#endif
#ifndef DohFree
#define DohFree free
#endif

extern int     DohCheck(const DOH *ptr);           /* Check if a DOH object */
extern void    DohIntern(DOH *);                   /* Intern an object      */

/* Basic object methods.  Common to most objects */

extern void          DohDelete(DOH *obj);                /* Delete an object      */
extern DOH          *DohCopy(const DOH *obj);
extern void          DohClear(DOH *obj);
extern DOHString    *DohStr(const DOH *obj);
extern void         *DohData(const DOH *obj);
extern int           DohDump(const DOH *obj, DOHFile *out);
extern int           DohLen(const DOH *obj);
extern int           DohHashval(const DOH *obj);
extern int           DohCmp(const DOH *obj1, const DOH *obj2);

/* Mapping methods */

extern DOH    *DohGetattr(DOH *obj, const DOHString_or_char *name);
extern int     DohSetattr(DOH *obj, const DOHString_or_char *name, const DOHObj_or_char *value);
extern void    DohDelattr(DOH *obj, const DOHString_or_char *name);
extern DOH    *DohFirstkey(DOH *obj);
extern DOH    *DohNextkey(DOH *obj);
extern int     DohGetInt(DOH *obj, const DOHString_or_char *name);
extern double  DohGetDouble(DOH *obj, const DOHString_or_char *name);
extern char   *DohGetChar(DOH *obj, const DOHString_or_char *name);
extern void    DohSetInt(DOH *obj, const DOHString_or_char *name, int);
extern void    DohSetDouble(DOH *obj, const DOHString_or_char *name, double);
extern void   *DohGetVoid(DOH *obj, const DOHString_or_char *name);
extern void    DohSetVoid(DOH *obj, const DOHString_or_char *name, void *value);

/* Sequence methods */

extern DOH    *DohGetitem(DOH *obj, int index);
extern int     DohSetitem(DOH *obj, int index, const DOHObj_or_char *value);
extern int     DohDelitem(DOH *obj, int index);
extern int     DohInsertitem(DOH *obj, int index, const DOHObj_or_char *value);
extern DOH    *DohFirstitem(DOH *obj);
extern DOH    *DohNextitem(DOH *obj);

/* File methods */

extern int     DohWrite(DOHFile *obj, void *buffer, int length);
extern int     DohRead(DOHFile *obj, void *buffer, int length);
extern int     DohSeek(DOHFile *obj, long offset, int whence);
extern long    DohTell(DOHFile *obj);
extern int     DohGetc(DOHFile *obj);
extern int     DohPutc(int ch, DOHFile *obj);
extern int     DohUngetc(int ch, DOHFile *obj);

  /* Positional */

extern int     DohGetline(DOH *obj);
extern void    DohSetline(DOH *obj, int line);
extern DOH    *DohGetfile(DOH *obj);
extern void    DohSetfile(DOH *obj, DOH *file);

  /* String Methods */

extern int     DohReplace(DOHString *src, const DOHString_or_char *token, const DOHString_or_char *rep, int flags);
extern void    DohChop(DOHString *src);

  /* Utility functions */

extern void    DohEncoding(char *name, DOH *(*fn)(DOH *s));
extern int     DohPrintf(DOHFile *obj, const char *format, ...);
extern int     DohvPrintf(DOHFile *obj, const char *format, va_list ap);
extern DOH    *DohReadline(DOHFile *in);

  /* Miscellaneous */

extern int     DohIsMapping(const DOH *obj);
extern int     DohIsSequence(const DOH *obj);
extern int     DohIsString(const DOH *obj);
extern int     DohIsFile(const DOH *obj);

#ifndef DOH_LONG_NAMES
/* Macros to invoke the above functions.  Includes the location of
   the caller to simplify debugging if something goes wrong */

#define Delete             DohDelete
#define Copy               DohCopy
#define Clear              DohClear
#define Str                DohStr
#define Dump               DohDump
#define Getattr            DohGetattr
#define Setattr            DohSetattr
#define Delattr            DohDelattr
#define Hashval            DohHashval
#define Getitem            DohGetitem
#define Setitem            DohSetitem
#define Delitem            DohDelitem
#define Insert             DohInsertitem
#define Append(s,x)        DohInsertitem(s,DOH_END,x)
#define Push(s,x)          DohInsertitem(s,DOH_BEGIN,x)
#define Len                DohLen
#define Firstkey           DohFirstkey
#define Nextkey            DohNextkey
#define Data               DohData
#define Char               (char *) Data
#define Cmp                DohCmp
#define Setline            DohSetline
#define Getline            DohGetline
#define Setfile            DohSetfile
#define Getfile            DohGetfile
#define Write              DohWrite
#define Read               DohRead
#define Seek               DohSeek
#define Tell               DohTell
#define Printf             DohPrintf
#define Getc               DohGetc
#define Putc               DohPutc
#define Ungetc             DohUngetc
#define vPrintf            DohvPrintf
#define GetInt             DohGetInt
#define GetDouble          DohGetDouble
#define GetChar            DohGetChar
#define GetVoid            DohGetVoid
#define SetInt             DohSetInt
#define SetDouble          DohSetDouble
#define SetChar            DohSetattr
#define SetVoid            DohSetVoid
#define Firstitem          DohFirstitem
#define Nextitem           DohNextitem
#define Readline           DohReadline
#define Replace            DohReplace
#define Chop               DohChop
#endif

/* -----------------------------------------------------------------------------
 * Strings.
 * ----------------------------------------------------------------------------- */

extern DOHString   *NewString(const DOH *c);
extern DOHString   *NewStringf(const DOH *fmt, ...);

/* String replacement flags */

#define   DOH_REPLACE_ANY         0x01
#define   DOH_REPLACE_NOQUOTE     0x02
#define   DOH_REPLACE_ID          0x04
#define   DOH_REPLACE_FIRST       0x08

/* -----------------------------------------------------------------------------
 * Files
 * ----------------------------------------------------------------------------- */

extern DOHFile *NewFile(DOH *file, char *mode);
extern DOHFile *NewFileFromFile(FILE *f);
extern int  DohCopyto(DOHFile *input, DOHFile *output);

#define Copyto DohCopyto

/* -----------------------------------------------------------------------------
 * List
 * ----------------------------------------------------------------------------- */

extern DOHList  *NewList();

/* -----------------------------------------------------------------------------
 * Hash
 * ----------------------------------------------------------------------------- */

extern DOHHash   *NewHash();
extern DOHList   *Hash_keys(DOHHash *);

/* -----------------------------------------------------------------------------
 * Void
 * ----------------------------------------------------------------------------- */

extern DOHVoid  *NewVoid(void *ptr, void (*del)(void *));

extern DOHList *DohSplit(DOHFile *input, char *chs, int nsplits);
#define Split DohSplit

extern DOH *DohNone;

#endif /* DOH_H */




