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

#ifdef __cplusplus
extern "C" {
#endif

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

#define DOH_BEGIN    -1
#define DOH_END      -2
#define DOH_CUR      -3
#define DOH_CURRENT  -3

/* -----------------------------------------------------------------------------
 * These structures define the interface to various categories of objects.
 * ----------------------------------------------------------------------------- */

/* Mapping Objects (i.e., hash tables) */
typedef struct {
  DOH    *(*doh_getattr)(DOH *obj, DOH *name);               /* Get attribute */
  int     (*doh_setattr)(DOH *obj, DOH *name, DOH *value);   /* Set attribute */
  int     (*doh_delattr)(DOH *obj, DOH *name);               /* Del attribute */
  DOH    *(*doh_firstkey)(DOH *obj);                         /* First key     */
  DOH    *(*doh_nextkey)(DOH *obj);                          /* Next key      */
} DohMappingMethods;

/* Sequence methods (i.e., lists) */
typedef struct {
  DOH      *(*doh_getitem)(DOH *obj, int index);             /* Get item      */
  int       (*doh_setitem)(DOH *obj, int index, DOH *value); /* Set item      */
  int       (*doh_delitem)(DOH *obj, int index);             /* Delete item   */
  int       (*doh_insitem)(DOH *obj, int index, DOH *value); /* Insert item   */
  DOH      *(*doh_firstitem)(DOH *obj);                      /* Iterators     */
  DOH      *(*doh_nextitem)(DOH *obj);
} DohSequenceMethods;

/* File methods */
typedef struct {
  int       (*doh_read)(DOH *obj, void *buffer, int nbytes);  /* Read bytes */
  int       (*doh_write)(DOH *obj, void *buffer, int nbytes); /* Write bytes */
  int       (*doh_putc)(DOH *obj, int ch);                    /* Put character */
  int       (*doh_getc)(DOH *obj);                            /* Get character */
  int       (*doh_ungetc)(DOH *obj, int ch);                  /* Unget character */
  int       (*doh_seek)(DOH *obj, long offset, int whence);   /* Seek */
  long      (*doh_tell)(DOH *obj);                            /* Tell */
  int       (*doh_close)(DOH *obj);                           /* Close */
} DohFileMethods;

/* String methods */
typedef struct {
  int     (*doh_replace)(DOH *obj, DOH *old, DOH *rep, int flags);
  void    (*doh_chop)(DOH *obj);
} DohStringMethods;

/* -----------------------------------------------------------------------------
 * DohObjInfo
 *
 * A pointer to this structure is included in all DOH types and is used to
 * describe the properties of various objects.
 * ----------------------------------------------------------------------------- */

typedef struct DohObjInfo {
  char       *objname;                         /* Object name        */
  int         objsize;                         /* Object size        */

  /* Basic object methods */
  void      (*doh_del)(DOH *obj);              /* Delete object      */
  DOH      *(*doh_copy)(DOH *obj);             /* Copy and object    */
  void      (*doh_clear)(DOH *obj);            /* Clear an object    */

  /* Output methods */
  DOH       *(*doh_str)(DOH *obj);             /* Make a full string */
  void      *(*doh_data)(DOH *obj);            /* Return raw data    */
  int        (*doh_dump)(DOH *obj, DOH *out);  /* Serialize on out   */
  DOH       *(*doh_load)(DOH *in);             /* Unserialize from in */

  /* Length and hash values */
  int        (*doh_len)(DOH *obj);
  int        (*doh_hash)(DOH *obj);

  /* Compare */
  int        (*doh_cmp)(DOH *obj1, DOH *obj2);

  DohMappingMethods  *doh_mapping;             /* Mapping methods    */
  DohSequenceMethods *doh_sequence;            /* Sequence methods   */
  DohFileMethods     *doh_file;                /* File methods       */
  DohStringMethods   *doh_string;              /* String methods     */
  void               *reserved2;
  void               *reserved3;
  void               *reserved4;
  void               *reserved5;
  void               *reserved6;
  void               *user1;
  void               *user2;
  void               *user3;
  void               *user4;
} DohObjInfo;

/* Memory management */

  extern void   *DohMalloc(size_t size);             /* Allocate memory       */
  extern void   *DohRealloc(void *, size_t size);    /* Reallocate memory     */
  extern void    DohFree(DOH *ptr);                  /* Free memory           */
  extern void   *DohObjMalloc(size_t size);          /* Allocate a DOH object */
  extern void    DohObjFree(DOH *ptr);               /* Free a DOH object     */
  extern int     DohObjFreeCheck(DOH *ptr);          /* Check if already free */
  extern void    DohInit(DOH *obj);                  /* Initialize an object  */
  extern int     DohCheck(const DOH *ptr);           /* Check if a DOH object */
  extern int     DohPoolSize(int);                   /* Set memory alloc size */
  extern void    DohIntern(DOH *);                   /* Intern an object      */
  extern void    DohMemoryInfo();

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

  extern void    DohTrace(int level, char *fmt,...);
  extern void    DohDebug(int d);

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
 * DohBase
 *
 * DohBase object type.  Attributes common to all objects.
 * ----------------------------------------------------------------------------- */

#define  DOHCOMMON      \
   DohObjInfo    *objinfo; \
   DOH           *nextptr; \
   int            refcount; \
   DOH           *file; \
   int            line; \
   unsigned char  flags

typedef struct {
  DOHCOMMON;
} DohBase;

/* Macros for decrefing and increfing (safe for null objects). */
#define Decref(a)        if (a) ((DohBase *) a)->refcount--
#define Incref(a)        if (a) ((DohBase *) a)->refcount++
#define Refcount(a)      ((DohBase *) a)->refcount
#define Objname(a)       ((DohBase *) a)->objinfo->objname

/* Flags for various internal operations */

#define DOH_FLAG_PRINT       0x02
#define DOH_FLAG_INTERN      0x10

/* -----------------------------------------------------------------------------
 * Strings.
 * ----------------------------------------------------------------------------- */

extern DOHString   *NewString(const DOH *c);
extern DOHString   *NewStringf(const DOH *fmt, ...);

extern int    String_check(const DOH *s);

/* String replacement flags */

#define   DOH_REPLACE_ANY         0x00
#define   DOH_REPLACE_NOQUOTE     0x01
#define   DOH_REPLACE_ID          0x02
#define   DOH_REPLACE_FIRST       0x04

/* -----------------------------------------------------------------------------
 * Files
 * ----------------------------------------------------------------------------- */

extern DOHFile *NewFile(DOH *file, char *mode);
extern DOHFile *NewFileFromFile(FILE *f);
extern DOHFile *NewFileFromFd(int fd);
extern int  DohCopyto(DOHFile *input, DOHFile *output);

#define Copyto DohCopyto

/* -----------------------------------------------------------------------------
 * List
 * ----------------------------------------------------------------------------- */

extern DOHList  *NewList();
extern int  List_check(const DOH *);
extern void List_sort(DOHList *);

/* -----------------------------------------------------------------------------
 * Hash
 * ----------------------------------------------------------------------------- */

extern DOHHash   *NewHash();
extern int        Hash_check(const DOH *h);
extern DOHList   *Hash_keys(DOHHash *);

/* -----------------------------------------------------------------------------
 * Void
 * ----------------------------------------------------------------------------- */

extern DOHVoid  *NewVoid(void *ptr, void (*del)(void *));

extern DOHList *DohSplit(DOHFile *input, char *chs, int nsplits);
#define Split DohSplit

extern DOH *DohNone;

/* -----------------------------------------------------------------------------
 * Error handling levels.
 * ----------------------------------------------------------------------------- */

#define DOH_UNSUPPORTED 0x01
#define DOH_UNKNOWN     0x02
#define DOH_MEMORY      0x04
#define DOH_CONVERSION  0x08
#define DOH_CALLS       0x10

#ifdef __cplusplus
}
#endif

#endif /* DOH_H */




