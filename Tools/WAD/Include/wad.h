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

#ifndef MAX_PATH
#define MAX_PATH 1024
#endif

/* Typedef's for various addresses and sizes */
typedef char *        wadaddr_t;
typedef unsigned long wadlen_t;

/* Memory management */
extern void *wadmalloc(unsigned int);
extern void  wadfree(void *ptr);

typedef struct WadSegment {
  wadaddr_t      vaddr;                 /* Virtual address start          */
  wadlen_t       size;                  /* Size of the segment (bytes)    */
  int            flags;                 /* Memory access permissions      */
  wadlen_t       offset;                /* Offset into mapped object      */
  char           mapname[MAX_PATH];     /* Filename mapped to this region */
  char           mappath[MAX_PATH];     /* Full path to mapname           */
  int            identifier;            /* identifier (if SysV shmem)     */
  long           wad;                   /* Private wad data (if any)      */
} WadSegment;

extern void wad_segment_print(WadSegment *s);
extern WadSegment *wad_segment_find(wadaddr_t addr);
extern WadSegment *wad_segment_first();
extern WadSegment *wad_segment_next();

/* Structure for managing object files */
typedef struct WadObject {
  void             *mptr;           /* mmap'd pointer */
  int               mlen;           /* mmap'd length  */
  void             *ptr;            /* Pointer to real data                 */
  int               len;            /* Length of real data                  */
  int               refcnt;         /* Reference count                      */
  int               type;           /* Type of the object file              */
  char              path[MAX_PATH]; /* Path name of this object             */
} WadObject;

extern char *wad_find_symbol(WadObject *wo, void *ptr, unsigned base, unsigned long *value);

/* Maximum number of object files that can be simultaneously loaded into memory */
#define WAD_MAX_OBJECT       32

extern WadObject  *wad_object_load(const char *path);
extern WadObject  *wad_arobject_load(const char *path, const char *name);
extern void        wad_object_release(WadObject *);

extern void wad_init();
extern void wad_signalhandler(int, siginfo_t *, void *);
extern void wad_set_return(char *name, long value);
extern int  wad_elf_check(WadObject *wo);
extern void wad_elf_debug(WadObject *wo);

/* Debugging information */
typedef struct WadDebug {
  int   found;               /* Whether or not debugging information was found */
  char  srcfile[1024];       /* Source file */
  char  objfile[1024];       /* Object file */
  int   line_number;         /* Line number */
  int   nargs;               /* Number of function arguments */
} WadDebug;

extern WadDebug *wad_search_stab(void *stab, int size, char *stabstr, char *symbol, unsigned long offset);
extern WadDebug *wad_debug_info(WadObject *wo, char *symbol, unsigned long offset);

/* This data structure is used to report exception data back to handler functions
   The offset fields contain offsets from the start of the frame to a location in
   the data segment */
   
typedef struct WadFrame {
  long     size;                /* Frame size                 */
  long     frameno;             /* Frame number               */
  long     pc;                  /* Program counter            */
  long     sp;                  /* Stack pointer              */
  long     fp;                  /* Frame pointer              */
  long     line_number;         /* Source line number         */
  long     sym_base;            /* Symbol base address        */
  long     sym_off;             /* Symbol name offset         */
  long     src_off;             /* Source filename offset     */
  long     obj_off;             /* Object filename offset     */
  char     data[8];             /* Frame data                 */
} WadFrame;


