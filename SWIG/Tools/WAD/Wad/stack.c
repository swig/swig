/* ----------------------------------------------------------------------------- 
 * stack.c
 *
 *     This file is used to unwind the C call stack.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"
#include <sys/types.h>
#include <sys/mman.h>
#include <dlfcn.h>

/* This needs to be changed so that the value is dynamically determined 
   Might also get weird problems with stacks located in different regions. */

#ifdef WAD_SOLARIS
#define STACK_BASE   0xffbf0000
#endif
#ifdef WAD_LINUX
#define STACK_BASE   0xc0000000
#endif

/* -----------------------------------------------------------------------------
 * stack_unwind()
 *
 * Perform a single level of stack unwinding given the stack pointer, frame pointer
 * and program counter.
 * ----------------------------------------------------------------------------- */

static void
stack_unwind(unsigned long *sp, unsigned long *pc, unsigned long *fp) {

  if (wad_debug_mode & DEBUG_UNWIND) {
    wad_printf("::: stack unwind :  pc = %x, sp = %x, fp = %x\n", *pc, *sp, *fp);
  }
#ifdef WAD_SOLARIS
  *pc = *((unsigned long *) *sp+15);         /* %i7 - Return address  */
  *sp = *((unsigned long *) *sp+14);         /* %i6 - frame pointer   */
#endif

#ifdef WAD_LINUX
  *pc = *((unsigned long *) *fp+1); 
  *sp = *fp;
  *fp = *((unsigned long *) *fp);

  /* If we get a frame pointer of zero, we've gone off the end of the stack.  Set the
     stack pointer to zero to signal the stack unwinder. */

  if (*fp == 0) {
    *sp = 0;
  }
#endif
}

/* -----------------------------------------------------------------------------
 * wad_stack_trace()
 *
 * Create a stack trace of the process. Returns a linked list of stack frames
 * with debugging information and other details.
 * ----------------------------------------------------------------------------- */

WadFrame *
wad_stack_trace(unsigned long pc, unsigned long sp, unsigned long fp) {
  WadSegment      *ws;
  WadObjectFile   *wo;
  WadFrame        *firstframe=0, *lastframe=0, *frame=0;
  WadDebug        wd;
  WadSymbol       wsym;

  unsigned long   p_pc;
  unsigned long   p_sp;
  unsigned long   p_fp;
  unsigned long   p_lastsp;
  int             n = 0;

  /* Read the segments */
  if (wad_segment_read() < 0) {
    wad_printf("WAD: Unable to read segment map\n");
    return 0;
  }
  /* Try to do a stack traceback */

  p_pc = pc;
  p_sp = sp;
  p_fp = fp;

  while (p_sp) {
    /* Add check for stack validity here */
    ws = wad_segment_find((void *) p_sp);

    if (!ws) {
      /* If the stack is bad, we are really hosed here */
      write(1,"Whoa. Stack is corrupted. Bailing out.\n", 39);
      exit(1);
      break;
    }
    ws = wad_segment_find((void *) p_pc);
    {
      int      stacksize = 0;
      char     *symname = 0;
      unsigned long value;
      
      /* Try to load the object file for this address */
      if (ws) {
	wo = wad_object_load(ws->mappath);
      }
      else {
	wo = 0;
      }
      
      /* Try to find the symbol corresponding to this PC */
      if (wo) {
	symname = wad_find_symbol(wo, (void *) p_pc, (unsigned long) ws->base, &wsym);
      } else {
	symname = 0;
      }
      value = wsym.value;

      frame = (WadFrame *) wad_malloc(sizeof(WadFrame));
      frame->frameno = n;
      frame->pc = p_pc;
      frame->sp = p_sp;
      frame->nlocals = -1;
      frame->nargs = -1;
      frame->objfile = 0;
      frame->srcfile = 0;
      frame->psp = 0;
      frame->next = 0;
      frame->prev = lastframe;
      frame->last = 0;
      if (lastframe) {
	lastframe->next = frame;
	lastframe = frame;
      } else {
	lastframe = frame;
	firstframe = frame;
      }
      frame->symbol = wad_strdup(symname);
      frame->sym_base = value + (long) ws->base;
      n++;
      if (symname) {
	/* Try to gather some debugging information about this symbol */
	if (wad_debug_info(wo,&wsym, p_pc - (unsigned long) ws->base - value, &wd)) {
	  frame->srcfile = wad_strdup(wd.srcfile);
	  frame->objfile = wad_strdup(wd.objfile);
	  frame->args = wd.args;
	  frame->lastarg = wd.lastarg;
	  frame->nargs = wd.nargs;

	  /*frame.nargs = wd.nargs;
	  if (wd.nargs > 0) {
	    argsize = sizeof(WadParm)*wd.nargs;
	  }
	  */
	  frame->line_number = wd.line_number;
	}
      }

#ifdef WAD_SOLARIS

#ifdef OLD         /* Might not be necessary. Registers stored on stack already */
      /* Before unwinding the stack, copy the locals and %o registers from previous frame */
      if (!firstframe) {
	int i;
	long *lsp = (long *) p_lastsp;
	for (i = 0; i < 16; i++) {
	  /*	  wad_printf("regs[%d] = 0x%x\n", lsp[i]); */
	  frame.regs[i] = lsp[i];
	}
      }
#endif

#endif
      /* Determine stack frame size */
      p_lastsp = p_sp;
      stack_unwind(&p_sp, &p_pc, &p_fp);

      if (p_sp) {
	stacksize = p_sp - p_lastsp;
      } else {
	stacksize = STACK_BASE - p_lastsp;
      }

      /* Sanity check */
      if ((p_sp + stacksize) > STACK_BASE) {
	stacksize = STACK_BASE - p_sp;
      }

      /* Set the frame pointer and stack size */
      frame->fp = p_sp;
      frame->stack_size = stacksize;
      
      /* Copy stack data */
      frame->psp = (char *) wad_malloc(stacksize);
      if (frame->psp) {
	memcpy(frame->psp, (void *) p_lastsp, stacksize);
      }
    }
  }
  lastframe->last = 1;
  return firstframe;
}

void wad_release_trace() {
}

/* This function steals an argument out of a frame further up the call stack :-) */
long wad_steal_arg(WadFrame *f, char *symbol, int argno, int *error) {
  long *regs;
  WadFrame *lastf = 0;

  *error = 0;
  /* Start searching */
  while (f) {
    if (f->symbol && (strcmp(f->symbol,symbol) == 0)) {
      /* Got a match */
      if (lastf) {
	regs = (long *) f->psp;
	return regs[8+argno];
      }
    }
    lastf = f;
    f = f->next;
  }
  *error = -1;
  return 0;
}


long wad_steal_outarg(WadFrame *f, char *symbol, int argno, int *error) {
  long *regs;
  WadFrame *lastf = 0;

  *error = 0;
  /* Start searching */
  while (f) {
    if (f->symbol && (strcmp(f->symbol,symbol) == 0)) {
      /* Got a match */
      if (lastf) {
#ifdef WAD_SOLARIS
	regs = (long *) lastf->psp;
	return regs[8+argno];
#endif
#ifdef WAD_LINUX
	regs = (long *) f->psp;
	return regs[argno+2];
#endif
      }
    }
    lastf = f;
    f = f->next;
  }
  *error = -1;
  return 0;
}







