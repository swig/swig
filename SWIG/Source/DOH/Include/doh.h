/*******************************************************************************
 * DOH (Dave's Object Hack)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which DOH
 * can be used and distributed.
 *******************************************************************************/

/***********************************************************************
 * $Header$
 *
 * doh.h
 *
 * DOH is really not much more than an interface.  This file describes
 * the interface.
 ***********************************************************************/

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
  int       (*doh_read)(DOH *obj, void *buffer, int nbytes);
  int       (*doh_write)(DOH *obj, void *buffer, int nbytes);
  int       (*doh_putc)(DOH *obj, int ch);
  int       (*doh_getc)(DOH *obj);
  int       (*doh_ungetc)(DOH *obj, int ch);
  int       (*doh_seek)(DOH *obj, long offset, int whence);
  long      (*doh_tell)(DOH *obj);
  int       (*doh_close)(DOH *obj);
} DohFileMethods;

/* String methods */
typedef struct {
  int     (*doh_replace)(DOH *obj, DOH *old, DOH *rep, int flags);
} DohStringMethods;

/* Callable */
typedef struct {
  DOH     (*doh_call)(DOH *obj, DOH *args);                 /* Callable */
} DohCallableMethods;
  

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
  int       (*doh_len)(DOH *obj);          
  int       (*doh_hash)(DOH *obj); 

  /* Compare */ 
  int       (*doh_cmp)(DOH *obj1, DOH *obj2);

  DohMappingMethods  *doh_mapping;             /* Mapping methods    */
  DohSequenceMethods *doh_sequence;            /* Sequence methods   */
  DohFileMethods     *doh_file;                /* File methods       */
  DohStringMethods   *doh_string;              /* String methods     */
  DohCallableMethods *doh_callable;            /* Callable methods   */ 
  void               *reserved4;
  void               *reserved5;
  void               *reserved6;
  void               *user1;
  void               *user2;
  void               *user3;
  void               *user4;
} DohObjInfo;

/* Memory management */
extern void   *DohMalloc(size_t size);     
extern void   *DohObjMalloc(size_t size);
extern void    DohFree(DOH *ptr);
extern void    DohObjFree(DOH *ptr);
extern int     DohObjFreeCheck(DOH *ptr);
extern int     DohCheck(DOH *ptr);
extern int     DohFreeCheck(DOH *ptr);
extern int     DohMemoryUse();
extern int     DohMemoryHigh();
extern int     DohPoolSize(int);

/* Low-level doh methods.  Do not call directly (well, unless you want to). */
extern void    DohError(int level, char *fmt,...);
extern void    DohDebug(int d);
extern void    DohDestroy(DOH *obj);
extern DOH    *DohCopy(DOH *obj);
extern void    DohClear(DOH *obj);
extern int     DohCmp(DOH *obj1, DOH *obj2);
extern DOH    *DohStr(DOH *obj);
extern int     DohDump(DOH *obj, DOH *out);
extern DOH    *DohGetattr(DOH *obj, DOH *name);
extern int     DohSetattr(DOH *obj, DOH *name, DOH *value);
extern void    DohDelattr(DOH *obj, DOH *name);
extern int     DohHashval(DOH *obj);
extern DOH    *DohGetitem(DOH *obj, int index);
extern void    DohSetitem(DOH *obj, int index, DOH *value);
extern void    DohDelitem(DOH *obj, int index);
extern void    DohInsertitem(DOH *obj, int index, DOH *value);
extern int     DohLen(DOH *obj);
extern DOH    *DohFirst(DOH *obj);
extern DOH    *DohNext(DOH *obj);
extern DOH    *DohFirstkey(DOH *obj);
extern DOH    *DohNextkey(DOH *obj);
extern DOH    *DohFirstitem(DOH *obj);
extern DOH    *DohNextitem(DOH *obj);
extern void   *DohData(DOH *obj);
extern int     DohGetline(DOH *obj);
extern void    DohSetline(DOH *obj, int line);
extern DOH    *DohGetfile(DOH *obj);
extern void    DohSetfile(DOH *obj, DOH *file);
extern void    DohInit(DOH *obj);

extern int     DohGetInt(DOH *obj, DOH *name);
extern double  DohGetDouble(DOH *obj, DOH *name);
extern char   *DohGetChar(DOH *obj, DOH *name);
extern void    DohSetInt(DOH *obj, DOH *name, int);
extern void    DohSetDouble(DOH *obj, DOH *name, double);

/* File methods */

extern int     DohWrite(DOH *obj, void *buffer, int length);
extern int     DohRead(DOH *obj, void *buffer, int length);
extern int     DohSeek(DOH *obj, long offser, int whence);
extern long    DohTell(DOH *obj);
extern int     DohGetc(DOH *obj);
extern int     DohPutc(int ch, DOH *obj);
extern int     DohUngetc(int ch, DOH *obj);

extern void    DohEncoding(char *name, DOH *(*fn)(DOH *s));
extern int     DohPrintf(DOH *obj, char *format, ...);
extern int     DohvPrintf(DOH *obj, char *format, va_list ap);
/* extern int     DohScanf(DOH *obj, char *format, ...);
   extern int     DohvScanf(DOH *obj, char *format, va_list ap); */

extern DOH    *DohReadline(DOH *in);

#ifndef DOH_LONG_NAMES
/* Macros to invoke the above functions.  Includes the location of
   the caller to simplify debugging if something goes wrong */

#define Delete             DohDestroy
#define Copy               DohCopy
#define Clear              DohClear
#define Str                DohStr
#define Dump               DohDump
#define Signature          DohSignature
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
#define First              DohFirst
#define Next               DohNext
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
#define SetInt             DohSetInt
#define SetDouble          DohSetDouble
#define Firstitem          DohFirstitem
#define Nextitem           DohNextitem
#define Readline           DohReadline

#endif

/* -----------------------------------------------------------------------------
 * DohBase
 *
 * DohBase object type.  Attributes common to all objects.
 * ----------------------------------------------------------------------------- */

#define  DOHCOMMON      \
   DohObjInfo    *objinfo; \
   int            refcount; \
   int            line; \
   DOH           *file 

typedef struct {
  DOHCOMMON;
} DohBase;

/* Macros for decrefing and increfing (safe for null objects). */
#define Decref(a)        if (a) ((DohBase *) a)->refcount--;
#define Incref(a)        if (a) ((DohBase *) a)->refcount++;
#define Objname(a)       ((DohBase *) a)->objinfo->objname

/* -----------------------------------------------------------------------------
 * Strings.   
 * ----------------------------------------------------------------------------- */

extern DOH   *NewString(char *c);
extern int    String_check(DOH *s);
extern void   String_replace(DOH *s, DOH *token, DOH *rep, int flags);

/* String replacement flags */

#define   DOH_REPLACE_ANY         0x00
#define   DOH_REPLACE_NOQUOTE     0x01
#define   DOH_REPLACE_ID          0x02
#define   DOH_REPLACE_FIRST       0x04

/* -----------------------------------------------------------------------------
 * Files
 * ----------------------------------------------------------------------------- */

extern DOH *NewFile(DOH *file, char *mode);
extern DOH *NewFileFromFile(FILE *f);
extern DOH *NewFileFromFd(int fd);
extern int  DohCopyto(DOH *input, DOH *output);

#define Copyto DohCopyto

/* -----------------------------------------------------------------------------
 * List
 * ----------------------------------------------------------------------------- */

extern DOH  *NewList();
extern int  List_check(DOH *);
extern void List_sort(DOH *);

/* -----------------------------------------------------------------------------
 * Hash
 * ----------------------------------------------------------------------------- */

extern DOH   *NewHash();
extern int    Hash_check(DOH *h);
extern DOH   *Hash_keys(DOH *);

/* -----------------------------------------------------------------------------
 * Void
 * ----------------------------------------------------------------------------- */

extern DOH  *NewVoid(void *ptr, void (*del)(void *));

extern DOH *DohSplit(DOH *input, char *chs, int nsplits);
#define Split DohSplit

/* -----------------------------------------------------------------------------
 * Error handling levels.
 * ----------------------------------------------------------------------------- */

#define DOH_UNSUPPORTED 1
#define DOH_UNKNOWN     2
#define DOH_MEMORY      3
#define DOH_CONVERSION  5
#define DOH_CALLS       10

#ifdef __cplusplus
}
#endif

#endif /* DOH_H */
