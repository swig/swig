/* ----------------------------------------------------------------------------- 
 * wad.h
 *
 *     WAD header file (obviously)
 *    
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2001. University of Chicago. All rights reserved.
 *
 * $Id$
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
#include <sys/ucontext.h>

#ifdef WAD_SOLARIS
#include <procfs.h>

#endif

#ifdef __cplusplus
extern "C" {
#endif

  /* Core datatypes */

  typedef int             int32;
  typedef unsigned        uint32;
  typedef short           int16;
  typedef unsigned short  uint16;
  typedef signed char     int8;
  typedef unsigned char   uint8;


#ifndef MAX_PATH
#define MAX_PATH 1024
#endif

#define WAD_SRC_WINDOW 2

/* --- Low level memory management functions --- */

extern int   wad_memory_init();
extern void *wad_malloc(int nbytes);
extern char *wad_strdup(const char *c);
extern void  wad_memory_debug();
extern void  wad_memcpy(void *t, const void *s, unsigned len);

  /* --- Low level string handling --- */

extern char *wad_string_lookup(char *s);
extern void  wad_string_debug();
extern char *wad_strcpy(char *t, const char *s);
extern char *wad_strcat(char *t, const char *s);
extern int   wad_strlen(const char *s);

/* --- I/O, Debugging --- */

extern void wad_printf(const char *fmt, ...);
extern char *wad_format_hex(unsigned long u, int leading);
extern char *wad_format_unsigned(unsigned long u, int width);
extern char *wad_format_signed(long s, int width);

/* --- Memory segments --- */
typedef struct WadSegment {
  char              *base;                  /* Base address for symbol lookup */
  char              *vaddr;                 /* Virtual address start          */
  unsigned long      size;                  /* Size of the segment (bytes)    */
  unsigned long      offset;                /* Offset into mapped object      */
  char              *mapname;               /* Filename mapped to this region */
  char              *mappath;               /* Full path to mapname           */
  struct WadSegment *next;                  /* Next segment                   */
} WadSegment;

extern int         wad_segment_read();
extern WadSegment *wad_segment_find(void *vaddr);
extern int         wad_segment_valid(void *vaddr);

/* --- Object files --- */
typedef struct WadObjectFile {
  void             *ptr;            /* Pointer to data           */
  int               len;            /* Length of data            */
  int               type;           /* Type of the object file   */
  char             *path;           /* Path name of this object  */
  struct WadObjectFile *next;
} WadObjectFile;

extern void            wad_object_reset();
extern WadObjectFile  *wad_object_load(const char *path);
extern int             wad_file_check(void *);

#define SYM_LOCAL     1
#define SYM_GLOBAL    2

/* Signal handling */
extern void wad_init();
extern void wad_signalhandler(int, siginfo_t *, void *);
extern void wad_signal_init();
extern void wad_signal_clear();
extern void wad_set_return(const char *name, long value);
extern void wad_set_return_value(long value);
extern void wad_set_return_func(void (*f)(void));

typedef struct WadLocal {
  char              *name;       /* Name of the local */
  void              *ptr;        /* Pointer to the actual data (if known)  */
  int                size;       /* Size of the data (if known)  */
  int                type;       /* Data type         */

  /* Debugging information */

  int                loc;        /* Location: register or stack */
  int                stack;      /* location on the stack       */
  int                reg;        /* Register number             */
  int                line;       /* Line number where defined   */
  struct WadLocal   *next;
} WadLocal;

#define PARM_REGISTER 1
#define PARM_STACK    2

/* Type codes for local variables */

#define WAD_TYPE_UNKNOWN      0
#define WAD_TYPE_INT32        1
#define WAD_TYPE_INT16        2
#define WAD_TYPE_INT8         3
#define WAD_TYPE_INT64        4
#define WAD_TYPE_UINT32       5
#define WAD_TYPE_UINT16       6
#define WAD_TYPE_UINT8        7
#define WAD_TYPE_UINT64       8
#define WAD_TYPE_FLOAT        9
#define WAD_TYPE_DOUBLE      10
#define WAD_TYPE_POINTER     11
#define WAD_TYPE_CHAR        12

extern long   wad_local_as_long(WadLocal *loc);
extern double wad_local_as_double(WadLocal *loc);

/* Data structure containing information about each stack frame */

typedef struct WadFrame {
  long               frameno;       /* Frame number */
  struct WadFrame   *next;          /* Next frame up the stack */
  struct WadFrame   *prev;          /* Previous frame down the stack */

  /* Stack context information */
  long               pc;            /* Real PC */
  long               sp;            /* Real SP */
  long               fp;            /* Real FP */
  char              *stack;         /* Pointer to where a copy of the stack frame is stored */
  int                stack_size;    /* Stack frame size (fp-sp) */

  /* Loading information.  Contains information from /proc as well as a pointer to
     the executable or shared library in which the PC is located */

  WadSegment        *segment;       /* Memory segment corresponding to PC */
  WadObjectFile     *object;        /* Object file corresponding to PC */

  /* Symbol table information for PC */

  char              *sym_name;        /* Symbol name          */
  int                sym_nlen;        /* Symbol name length   */
  char              *sym_file;        /* Source file (if any) */
  unsigned long      sym_base;        /* Symbol base address  */
  unsigned long      sym_size;        /* Symbol size          */
  int                sym_type;        /* Symbol type          */
  int                sym_bind;        /* Symbol binding       */

  /* Location information */
  char              *loc_objfile;     /* Object filename */
  char              *loc_srcfile;     /* Source filename */
  int                loc_line;        /* Source line */

  /* Debugging information */
  int                debug_check;     /* Checked debugging information */
  int                debug_nargs;     /* Number of arguments */
  WadLocal          *debug_args;      /* Arguments           */
  WadLocal          *debug_lastarg;   /* Last argument       */
  int                debug_nlocals;   /* Number of locals    */
  WadLocal          *debug_locals;    /* Local variables     */
  WadLocal          *debug_lastlocal; /* Last local          */

  /* Output strings */
  char              *debug_str;       /* Debugging string */
  char              *debug_srcstr;    /* Source string    */

  int                last;            /* Last frame flag */
} WadFrame;

extern WadFrame *wad_stack_trace(unsigned long, unsigned long, unsigned long);
extern void      wad_stack_debug(WadFrame *f);

extern char   *wad_strip_dir(char *);
extern void    wad_default_callback(int signo, WadFrame *frame, char *ret);
extern void    wad_dump_trace(int fd, int signo, WadFrame *frame, char *ret);

extern void    wad_set_callback(void (*h)(int, WadFrame *, char *));
extern char   *wad_load_source(char *, int line);
extern void    wad_release_source();
extern void    wad_release_trace();
extern long    wad_steal_arg(WadFrame *f, char *symbol, int argno, int *error);
extern long    wad_steal_outarg(WadFrame *f, char *symbol, int argno, int *error);

extern char *wad_arg_string(WadFrame *f);

typedef struct {
  char        name[128];
  long        value;
} WadReturnFunc;

extern void wad_set_returns(WadReturnFunc *rf);
extern WadReturnFunc *wad_check_return(const char *name);

extern int wad_search_stab(void *stab, int size, char *stabstr, WadFrame *f);

extern void wad_find_object(WadFrame *f);
extern void wad_find_symbol(WadFrame *f);
extern void wad_find_debug(WadFrame *f);
extern void wad_build_vars(WadFrame *f);
extern char *wad_format_var(WadLocal *l);

extern void  wad_debug_make_strings(WadFrame *f);

/* --- Debugging Interface --- */

#define DEBUG_SEGMENT        0x1
#define DEBUG_SYMBOL         0x2
#define DEBUG_STABS          0x4
#define DEBUG_OBJECT         0x8
#define DEBUG_FILE           0x10
#define DEBUG_HOLD           0x20
#define DEBUG_RETURN         0x40
#define DEBUG_SYMBOL_SEARCH  0x80
#define DEBUG_INIT           0x100
#define DEBUG_NOSTACK        0x200
#define DEBUG_ONESHOT        0x400
#define DEBUG_STACK          0x800
#define DEBUG_UNWIND         0x1000
#define DEBUG_SIGNAL         0x2000
#define DEBUG_STRING         0x4000
#define DEBUG_MEMORY         0x8000

extern int wad_debug_mode;
extern int wad_heap_overflow;

#ifdef WAD_LINUX
#define   WAD_LITTLE_ENDIAN
#endif
#ifdef WAD_SOLARIS
#define   WAD_BIG_ENDIAN
#endif

#ifdef __cplusplus
}
#endif




