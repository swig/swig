/* ----------------------------------------------------------------------------- 
 * wad.h
 *
 *     WAD header file (obviously)
 *    
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/mman.h>
#include <ctype.h>

#ifdef WAD_SOLARIS
#include <procfs.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef MAX_PATH
#define MAX_PATH 1024
#endif

/* Memory segments */
typedef struct WadSegment {
  char          *base;                  /* Base address for symbol lookup */
  char          *vaddr;                 /* Virtual address start          */
  unsigned long  size;                  /* Size of the segment (bytes)    */
  unsigned long  offset;                /* Offset into mapped object      */
  char           mapname[MAX_PATH];     /* Filename mapped to this region */
  char           mappath[MAX_PATH];     /* Full path to mapname           */
} WadSegment;

extern WadSegment *wad_segment_read();
extern WadSegment *wad_segment_find(WadSegment *s, void *vaddr);
extern void        wad_segment_release(WadSegment *s);

/* Structure for managing object files */
typedef struct WadObjectFile {
  void             *mptr;           /* mmap'd pointer to file */
  int               mlen;           /* mmap'd length  */
  void             *ptr;            /* Pointer to real data                 */
  int               len;            /* Length of real data                  */
  int               refcnt;         /* Reference count                      */
  int               type;           /* Type of the object file              */
  char              path[MAX_PATH]; /* Path name of this object             */
} WadObjectFile;

extern char *wad_find_symbol(WadObjectFile *wo, void *ptr, unsigned base, unsigned long *value);

/* Maximum number of object files that can be simultaneously loaded into memory */
#define WAD_MAX_OBJECT       32

extern WadObjectFile  *wad_object_load(const char *path);
extern WadObjectFile  *wad_arobject_load(const char *path, const char *name);
extern void        wad_object_release(WadObjectFile *);

extern void wad_init();
extern void wad_signalhandler(int, siginfo_t *, void *);
extern void wad_set_return(const char *name, long value);
extern void wad_set_return_value(long value);

extern int  wad_elf_check(WadObjectFile *wo);
extern void wad_elf_debug(WadObjectFile *wo);

typedef struct WadParm {
  char  name[64];
  int   loc;
  int   type;
  int   value;
} WadParm;

/* Debugging information */
typedef struct WadDebug {
  int   found;               /* Whether or not debugging information was found */
  char  srcfile[1024];       /* Source file */
  char  objfile[1024];       /* Object file */
  int   line_number;         /* Line number */
  int   nargs;               /* Number of function arguments */
  WadParm parms[100];        /* Parameters */
} WadDebug;

#define PARM_REGISTER 1
#define PARM_STACK    2

extern WadDebug *wad_search_stab(void *stab, int size, char *stabstr, char *symbol, unsigned long offset);
extern WadDebug *wad_debug_info(WadObjectFile *wo, char *symbol, unsigned long offset);

/* This data structure is used to report exception data back to handler functions
   The offset fields contain offsets from the start of the frame to a location in
   the data segment */
   
typedef struct WadFrame {
  long     size;                /* Frame size                 */
  long     lastsize;            /* Size of previous frame     */
  long     last;                /* Last frame ?               */
  long     frameno;             /* Frame number               */
  long     pc;                  /* Program counter            */
  long     sp;                  /* Stack pointer              */
  long     fp;                  /* Frame pointer              */
  long     nargs;               /* Number of arguments        */
  long     arg_off;             /* Argument offset            */
  long     line_number;         /* Source line number         */
  long     sym_base;            /* Symbol base address        */
  long     sym_off;             /* Symbol name offset         */
  long     src_off;             /* Source filename offset     */
  long     obj_off;             /* Object filename offset     */
  long     stack_off;           /* Stack offset               */
  long     stack_size;          /* Size of the stack segment  */
  long     regs[16];            /* Integer registers (%on, %ln) */
  double   fregs[16];           /* Floating point registers   */
  char     data[8];             /* Frame data                 */
} WadFrame;

#define SRCFILE(x)  ((char *) x) + x->src_off
#define SYMBOL(x)   ((char *) x) + x->sym_off
#define OBJFILE(x)  ((char *) x) + x->obj_off
#define STACK(x)    (long *) (((char *) x) + x->stack_off)
#define ARGUMENTS(x) (WadParm *) (((char *) x) + x->arg_off)

extern WadFrame *wad_stack_trace(unsigned long, unsigned long, unsigned long);
extern char *wad_strip_dir(char *);
extern void  wad_default_callback(int signo, WadFrame *frame, char *ret);
extern void wad_set_callback(void (*h)(int, WadFrame *, char *));
extern char *wad_load_source(char *, int line);
extern void wad_release_source();
extern void wad_release_trace();
extern long wad_steal_arg(WadFrame *f, char *symbol, int argno, int *error);
extern long wad_steal_outarg(WadFrame *f, char *symbol, int argno, int *error);

extern char *wad_arg_string(WadFrame *f);

typedef struct {
  const char *name;
  long        value;
} WadReturnFunc;

extern void wad_set_returns(WadReturnFunc *rf);

/* --- Debugging Interface --- */

#define DEBUG_SEGMENT    0x1
#define DEBUG_SYMBOL     0x2
#define DEBUG_STABS      0x4

extern int wad_debug_mode;




#ifdef __cplusplus
}
#endif

