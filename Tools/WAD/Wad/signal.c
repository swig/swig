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

static void (*sig_callback)(int signo, WadFrame *data, char *ret) = 0;

void wad_set_callback(void (*s)(int,WadFrame *,char *ret)) {
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

/* Set the return value from another module */
void wad_set_return_value(long value) {
  nlr_value = value;
}

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
  greg_t  *pc;
  greg_t  *npc;
  greg_t  *sp;
  unsigned long   addr;
  ucontext_t      *context;
  unsigned long   p_sp;        /* process stack pointer   */
  unsigned long   p_pc;        /* Process program counter */
  int      nlevels = 0;
  int      found = 0;
  void     _returnsignal();
  WadFrame  *frame, *origframe;
  char      *framedata;
  char      *retname = 0;

  context = (ucontext_t *) vcontext;

  /* Get some information about the current context */
  pc = &((context->uc_mcontext).gregs[REG_PC]);
  npc = &((context->uc_mcontext).gregs[REG_nPC]);
  sp = &((context->uc_mcontext).gregs[REG_SP]);

  /* Get some information out of the signal handler stack */
  addr = (unsigned long) si->si_addr;
  p_pc = (unsigned long) (*pc);
  p_sp = (unsigned long) (*sp);

  frame = wad_stack_trace(p_pc, p_sp, 0);
  origframe =frame;
  if (!frame) {
    /* We're really hosed here */
    return;
  }
  
  /* Walk the exception frames and try to find a return point */

  framedata = (char *) frame;

  while (frame->size) {
    nonlocal *nl = return_points;
    nl = return_points;
    while (nl) {
      if (strcmp(framedata + frame->sym_off,nl->symname) == 0) {
	found = 1;
	nlr_value = nl->value;
	retname = nl->symname;
	break;
      }
      nl = nl->next;
    }
    framedata = framedata + frame->size;
    frame = (WadFrame *) framedata;
    if (found) {
      frame->last = 1;   /* Cut off top of the stack trace */
      break;
    }
    nlevels++;
  }


  if (found) {
    nlr_levels = nlevels - 1;
  } else {
    nlr_levels = 0;
  }

  if (sig_callback) {
    (*sig_callback)(sig,origframe,retname);
  } else {
    /* No signal handler defined.  Go invoke the default */
    wad_default_callback(sig, origframe,retname);
  }

  /* If we found a function to which we should return, we jump to
     an alternative piece of code that unwinds the stack and 
     initiates a non-local return. */

  if (nlr_levels > 0) {
    *(pc) = (greg_t) _returnsignal;
    *(npc) = *(pc) + 4;
    return;
  }
}
