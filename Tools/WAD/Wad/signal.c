/* ----------------------------------------------------------------------------- 
 * signal.c
 *
 *     WAD signal handler. 
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */


#include "wad.h"
#include <sys/ucontext.h>
#include <sys/types.h>
#include <sys/mman.h>

static char *strip_dir(char *name) {
  char *c;
  c = name + strlen(name);
  while (c != name) {
    if (*c == '/') {
      c++;
      return c;
    }
    c--;
  }
  return name;
}

/* -----------------------------------------------------------------------------
 * Default callback
 * ----------------------------------------------------------------------------- */

void wad_default_callback(int signo, void *framedata) {
  char *fd;
  WadFrame *f;
  switch(signo) {
  case SIGSEGV:
    printf("Segmentation fault.\n");
    break;
  case SIGBUS:
    printf("Bus error.\n");
    break;
  case SIGABRT:
    printf("Abort.\n");
    break;
  default:
    printf("Signal %d\n", signo);
    break;
  }
  fd = (char *) framedata;
  f = (WadFrame *) fd;
  while (f->size) {
    printf("#%-3d 0x%08x in %s()", f->frameno, f->pc, *(fd + f->sym_off) ? fd+f->sym_off : "?");
    if (strlen(fd+f->src_off)) {
      printf(" in '%s'", strip_dir(fd+f->src_off));
      if (f->line_number >= 0) {
	printf(", line %d", f->line_number);
      }
    } else {
      if (strlen(fd+f->obj_off)) {
	printf(" from '%s'", fd+f->obj_off);
      }
    }
    printf("\n");
    fd = fd + f->size;
    f = (WadFrame *) fd;
  }
}



/* Perform one level of stack unwinding */
unsigned long *stack_unwind(unsigned long *sp) {
  unsigned long  *new_sp;
  unsigned long  ret_addr;
  int i;
  new_sp = (unsigned long *) *(sp+14);
  ret_addr = *(sp+15);
  return (unsigned long *) new_sp;
}

/* Data structures for containing information about non-local returns */

typedef struct nonlocal {
  char symname[256];
  long value;
  struct nonlocal *next;
} nonlocal;

static nonlocal *return_points = 0;

void wad_set_return(char *name, long value) {
  nonlocal *nl;
  nl = (nonlocal *) malloc(sizeof(nonlocal));
  strcpy(nl->symname,name);
  nl->value = value;
  nl->next = return_points;
  return_points = nl;
}

static void (*sig_callback)(int signo, void *data) = 0;

void wad_set_callback(void (*s)(int,void *)) {
  sig_callback = s;
}

/* This bit of nastiness is used to make a non-local return from the
   signal handler to a configurable location on the call stack. In a nutshell,
   this works by repeatedly calling "restore" to roll back the 
   register windows and stack pointer.  Then we fake a return value and
   return to the caller as if the function had actually completed
   normally. */

static int            nlr_levels = 0;
static int  *volatile nlr_p = &nlr_levels;
static long           nlr_value = 0;

static void nonlocalret() {
  long a;
  
  a = nlr_value;
  /* We never call this procedure as a function.  This code
     causes an immediate return if someone does this */

  asm("jmp %i7 + 8");
  asm("restore");

  /* This is the real entry point */
  /*  asm(".globl _returnsignal");*/
  asm(".type   _returnsignal,2");
  asm("_returnsignal:");

  while (*nlr_p > 0) {
    (*nlr_p)--;
    asm("restore");
  }

  asm("sethi %hi(nlr_value), %o0");
  asm("or %o0, %lo(nlr_value), %o0");
  asm("ld [%o0], %i0");

  asm("jmp %i7 + 8");
  asm("restore");
  asm(".size	_returnsignal,(.-_returnsignal)");
}

void wad_signalhandler(int sig, siginfo_t *si, void *vcontext) {
  int current;
  greg_t  *pc;
  greg_t  *npc;
  greg_t  *ret;
  greg_t  *sp;
  int i;
  unsigned long   *user_fp;  
  unsigned long   *addr;
  ucontext_t      *context;
  unsigned long   *p_sp;        /* process stack pointer   */
  unsigned long   *p_pc;        /* Process program counter */
  WadSegment      *ws;
  WadObject       *wo;
  int      nlevels;
  int      found = 0;
  void     _returnsignal();
  int      n = 0;
  char     framefile[256];
  int      ffile;
  WadFrame        frame;
  void    *framedata;
  int   fsize = 0;              /* Total frame size */
  sprintf(framefile,"/tmp/wad.%d", getpid());

  /* Open the output file for the traceback */

  ffile = open(framefile, O_CREAT | O_TRUNC | O_WRONLY, 0644);
  
  if (ffile < 0) {
    printf("can't open %s\n", framefile);
  }

  context = (ucontext_t *) vcontext;

  /* Get some information about the current context */
  pc = &((context->uc_mcontext).gregs[REG_PC]);
  npc = &((context->uc_mcontext).gregs[REG_nPC]);
  sp = &((context->uc_mcontext).gregs[REG_SP]);
  ret = &((context->uc_mcontext).gregs[REG_O7]);

  /* Get some information out of the signal handler stack */
  user_fp = (unsigned long *) _get_fp();   /* Current frame pointer */
  addr = (unsigned long *) si->si_addr;

  /* Try to do a stack traceback */
  nlevels = 0;
  p_pc = (unsigned long *) (*pc);
  p_sp = (unsigned long *) (*sp);

  while (p_pc) {
    ws = wad_segment_find((wadaddr_t) p_pc);
    if (!ws) {
      printf("No segment found for %x\n", p_pc);
    } else {
      WadObject *wo;
      char *name;

      int   symsize = 0;            /* Symbol size */
      int   srcsize = 0;
      int   objsize = 0;
      char  *srcname = 0;
      char  *objname = 0;
      char  *symname = 0;
      int    pad = 0;

      unsigned long value;
      wo = wad_object_load(ws->mappath);
      if (strcmp(ws->mapname,"a.out") == 0) ws->vaddr= 0;
      name = wad_find_symbol(wo,(void *) p_pc, (unsigned long) ws->vaddr, &value);
      
      /* Build up some information about the exception frame */
      frame.frameno = n;
      frame.pc = (long) p_pc;
      frame.sp = (long) p_sp;
      n++;
      if (name) {
	nonlocal *nl;
	symsize = strlen(name)+1;
	symname = name;
	nl = return_points;
	while (nl) {
	  if (strcmp(name,nl->symname) == 0) {
	    found = 1;
	    nlr_value = nl->value;
	  }
	  nl = nl->next;
	}
	{
	  WadDebug *wd;
	  wd = wad_debug_info(wo,name, (unsigned long) p_pc - (unsigned long) ws->vaddr - value);
	  if (wd) {
	    srcname = wd->srcfile;
	    srcsize = strlen(srcname)+1;
	    objname = wd->objfile;
	    objsize = strlen(objname)+1;
	    frame.line_number = wd->line_number;
	  }
	}
      }
      /* Build up the exception frame object */
      frame.size = sizeof(WadFrame) + symsize + srcsize + objsize;
      pad = 8 - (frame.size % 8);
      frame.size += pad;

      frame.data[0] = 0;
      frame.data[1] = 0;
      
      /* Build up the offsets */
      if (!name) {
	frame.sym_off = sizeof(WadFrame) - 8;
	frame.src_off = sizeof(WadFrame) - 8;
	frame.obj_off = sizeof(WadFrame) - 8;
      } else {
	frame.sym_off = sizeof(WadFrame);
	frame.src_off = sizeof(WadFrame)+symsize;
	frame.obj_off = sizeof(WadFrame)+symsize+srcsize;
      }
      write(ffile,&frame,sizeof(WadFrame));
      if (symname) {
	write(ffile,symname,symsize);
	write(ffile,srcname,srcsize);
	write(ffile,objname,objsize);
      }
      write(ffile,frame.data, pad);
      wad_object_release(wo);
    }
    if (!found) nlevels++;
    p_pc = (unsigned long *) *(p_sp+15);
    p_sp = stack_unwind(p_sp);
    if (found) break;
  }
  /* Write terminator */
  frame.size = 0;
  write(ffile,&frame,sizeof(WadFrame));
  close(ffile);

  if (found) {
    nlr_levels = nlevels - 1;
  } else {
    nlr_levels = 0;
  }

  /* Go mmap the debug file */
  ffile = open(framefile, O_RDONLY, 0644);  
  fsize = lseek(ffile,0,SEEK_END);
  lseek(ffile,0,SEEK_SET);
  
  framedata = mmap(NULL, fsize, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE, ffile, 0);

  if (sig_callback) {
    (*sig_callback)(sig,framedata);
  } else {
    /* No signal handler defined.  Go invoke the default */
    wad_default_callback(sig, framedata);
  }

  /* If we found a function to which we should return, we jump to
     an alternative piece of code that unwinds the stack and 
     initiates a non-local return. */

  munmap(framedata,fsize);
  close(ffile);
  unlink(framefile);
  if (nlr_levels > 0) {
    *(pc) = (greg_t) _returnsignal;
    *(npc) = *(pc) + 4;
    return;
  }
}

static void
asm_stuff()
{
    asm("	.globl _get_sp");
    asm("_get_sp:");
    asm("	retl");
    asm("	mov	%sp, %o0");
    asm("	.globl _get_fp");
    asm("_get_fp:");
    asm("	retl");
    asm("	mov	%fp, %o0");
}

