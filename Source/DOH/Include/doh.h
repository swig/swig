/*******************************************************************************
 * DOH (Dynamic Object Hack)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/

/***********************************************************************
 * $Header$
 *
 * doh.h
 ***********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>
#include <stdarg.h>

typedef void DOH;                

#define DOH_BEGIN    -1
#define DOH_END      -2
#define DOH_CUR      -3

/* -----------------------------------------------------------------------------
 * Object classes
 * ----------------------------------------------------------------------------- */

/* Mapping Objects */
typedef struct {
  DOH    *(*doh_getattr)(DOH *obj, DOH *name);                             /* Get attribute */
  int     (*doh_setattr)(DOH *obj, DOH *name, DOH *value);                 /* Set attribute */
  int     (*doh_delattr)(DOH *obj, DOH *name);                             /* Del attribute */
  DOH    *(*doh_firstkey)(DOH *obj);                                       /* First key     */
  DOH    *(*doh_nextkey)(DOH *obj);                                        /* Next key      */
} DohMappingMethods;

/* Sequence methods */
typedef struct {
  DOH      *(*doh_getitem)(DOH *obj, int index);
  int       (*doh_setitem)(DOH *obj, int index, DOH *value);
  int       (*doh_delitem)(DOH *obj, int index);
  int       (*doh_insitem)(DOH *obj, int index, DOH *value);
  DOH      *(*doh_first)(DOH *obj);
  DOH      *(*doh_next)(DOH *obj);
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

/* -----------------------------------------------------------------------------
 * DohObjInfo
 * 
 * Included in all DOH types.  
 * ----------------------------------------------------------------------------- */

typedef struct DohObjInfo {
  char       *objname;                     /* Object name        */
  int         objsize;                     /* Object size        */

  /* Basic object methods */
  void      (*doh_del)(DOH *obj);          /* Delete object      */
  DOH      *(*doh_copy)(DOH *obj);         /* Copy and object    */
  void      (*doh_clear)(DOH *obj);        /* Clear an object    */

  /* Output methods */
  DOH       *(*doh_str)(DOH *obj);             /* Make a full string */
  void      *(*doh_data)(DOH *obj);            /* Return raw data    */
  int        (*doh_dump)(DOH *obj, DOH *out);  /* Serialize on out */

  /* Length and hash values */
  int       (*doh_len)(DOH *obj);          
  int       (*doh_hash)(DOH *obj); 

  /* Compare */ 
  int       (*doh_cmp)(DOH *obj1, DOH *obj2);

  DohMappingMethods  *doh_mapping;         /* Mapping methods    */
  DohSequenceMethods *doh_sequence;        /* Sequence methods   */
  DohFileMethods     *doh_file;            /* File methods       */
  void               *reserved2;           /* Number methods     */
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
extern void   *DohMalloc(int size);     
extern void    DohFree(DOH *ptr);
extern int     DohCheck(DOH *ptr);
extern int     DohFreeCheck(DOH *ptr);

/* Low-level doh methods.  Do not call directly (well, unless you want to). */

extern void    DohDestroy(DOH *obj);
extern DOH    *DohCopy(DOH *obj);
extern void    DohClear(DOH *obj);
extern int     DohCmp(DOH *obj1, DOH *obj2);
extern DOH    *DohStr(DOH *obj);
extern int     DohDump(DOH *obj, DOH *out);
extern DOH    *DohGetattr(DOH *obj, DOH *name);
extern int     DohGetattrf(DOH *obj, DOH *name, char *fmt, ...);
extern int     DohSetattr(DOH *obj, DOH *name, DOH *value);
extern int     DohSetattrf(DOH *obj, DOH *name, char *fmt, ...);
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
extern void   *DohData(DOH *obj);
extern int     DohGetline(DOH *obj);
extern void    DohSetline(DOH *obj, int line);
extern DOH    *DohGetfile(DOH *obj);
extern void    DohSetfile(DOH *obj, DOH *file);
extern void    DohInit(DOH *obj);

extern int     DohGetInt(DOH *obj, DOH *name);
extern double  DohGetDouble(DOH *obj, DOH *name);

/* File methods */

extern int     DohWrite(DOH *obj, void *buffer, int length);
extern int     DohRead(DOH *obj, void *buffer, int length);
extern int     DohSeek(DOH *obj, long offser, int whence);
extern long    DohTell(DOH *obj);
extern int     DohGetc(DOH *obj);
extern int     DohPutc(int ch, DOH *obj);
extern int     DohUngetc(int ch, DOH *obj);

extern int     DohPrintf(DOH *obj, char *format, ...);
extern int     DohvPrintf(DOH *obj, char *format, va_list ap);
/* extern int     DohScanf(DOH *obj, char *format, ...);
   extern int     DohvScanf(DOH *obj, char *format, va_list ap); */

/* Macros to invoke the above functions.  Includes the location of
   the caller to simplify debugging if something goes wrong */

#define Delete             DohDestroy
#define Copy               DohCopy
#define Clear              DohClear
#define Str                DohStr
#define Dump               DohDump
#define Signature          DohSignature
#define Getattr            DohGetattr
#define Getattrf           DohGetattrf
#define Setattr            DohSetattr
#define Setattrf           DohSetattrf
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

/* #define Scanf              DohScanf
   #define vScanf             DohvScanf*/

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

extern DOH *NewFile(char *file, char *mode);
extern DOH *NewFileFromFile(FILE *f);
extern DOH *NewFileFromFd(int fd);

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


