/* ----------------------------------------------------------------------------- 
 * stack.c
 *
 *     This file unwinds the C call stack and creates a list of stack frames.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"

/* -----------------------------------------------------------------------------
 * new_frame()
 *
 * Create a new stack frame object and initialize all of the fields.
 * ----------------------------------------------------------------------------- */

static WadFrame *
new_frame() {
  WadFrame *f;
  f = (WadFrame *) wad_malloc(sizeof(WadFrame));
  f->frameno = 0;
  f->segment = 0;
  f->object = 0;
  f->pc = 0;
  f->sp = 0;
  f->sp = 0;
  f->stack = 0;
  f->stack_size = 0;

  f->sym_name = 0;
  f->sym_file = 0;
  f->sym_base = 0;
  f->sym_size = 0;
  f->sym_type = 0;
  f->sym_bind = 0;

  f->loc_objfile = 0;
  f->loc_srcfile = 0;
  f->loc_line = 0;

  f->debug_nargs = -1;
  f->debug_args = 0;
  f->debug_lastarg = 0;

  f->last = 0;
  f->next = 0;
  f->prev = 0;
  return f;
}

/* -----------------------------------------------------------------------------
 * stack_unwind()
 *
 * This function performs a single level of stack unwinding given the stack pointer
 * frame pointer and program counter.   Validations are made to make sure the stack
 * and frame pointers are in valid memory.  Updates the values of the sp, pc, and fp
 * in-place.  Returns a stack frame object on success, 0 if memory is invalid
 * or the end of the stack has been reached.
 * ----------------------------------------------------------------------------- */

static WadFrame *
stack_unwind(unsigned long *pc, unsigned long *sp, unsigned long *fp) {
  WadSegment *sp_seg, *fp_seg;
  WadFrame   *f;
  if (wad_debug_mode & DEBUG_UNWIND) {
    wad_printf("::: stack unwind :  pc = %x, sp = %x, fp = %x\n", *pc, *sp, *fp);
  }

  /* Verify that the sp and fp are in mapped memory */
  sp_seg = wad_segment_find((void *) *sp);
  fp_seg = wad_segment_find((void *) *fp);
  
  if (!(sp_seg && fp_seg && (sp_seg == fp_seg))) {
    /* Either the stack pointer or frame pointer is invalid.  Or, the stack pointer
       and frame pointer are in different memory regions. */
    return 0;
  }

  /* Check to see if the PC is valid */
  if (!wad_segment_valid((void *) *pc)) {
    return 0;
  }

  f = new_frame();
  f->pc = *pc;
  f->sp = *sp;
  f->fp = *fp;
  f->segment = wad_segment_find((void *) *pc);
  f->stack_size = *fp - *sp;
  
  /* Make a copy of the call stack */
  f->stack = (char *) wad_malloc(f->stack_size);
  memcpy(f->stack,(void *) *sp, f->stack_size);

  /* Update the sp, fp, and pc */

#ifdef WAD_SOLARIS
  *pc = *((unsigned long *) *sp+15);         /* %i7 - Return address  */
  *sp = *((unsigned long *) *sp+14);         /* %i6 - frame pointer   */
  if (wad_segment_valid((void *) *sp)) {
    *fp = *((unsigned long *) *sp+14);
  } else {
    *fp = 0;
  }
#endif

#ifdef WAD_LINUX
  if (wad_segment_valid((void *) ((unsigned long *) *fp+1))) {
    *pc = *((unsigned long *) *fp+1); 
    *sp = *fp;
  } else {
    *sp = 0;
  }
  if (wad_segment_valid((void *) ((unsigned long *) *fp))) {
    *fp = *((unsigned long *) *fp);
  } else {
    *fp = 0;
  }
#endif
  return f;
}

/* -----------------------------------------------------------------------------
 * wad_stack_trace()
 *
 * Create a stack trace of the process. Returns a linked list of stack frames
 * with a limited about debugging information and other details.
 * ----------------------------------------------------------------------------- */

WadFrame *
wad_stack_trace(unsigned long pc, unsigned long sp, unsigned long fp) {
  WadFrame        *firstframe=0, *lastframe=0, *frame=0;
  unsigned long   p_pc;
  unsigned long   p_sp;
  unsigned long   p_fp;
  int             n = 0;

  /* Try to do a stack traceback */

  p_pc = pc;
  p_sp = sp;
  p_fp = fp;

  while ((frame = stack_unwind(&p_pc, &p_sp, &p_fp))) {
    /* Got a frame successfully */
    frame->frameno = n;
    if (lastframe) {
      lastframe->next = frame;
      frame->prev = lastframe;
      lastframe = frame;
    } else {
      firstframe = frame;
      lastframe = frame;
    }
    n++;
  }
  if (lastframe)
    lastframe->last = 1;
  return firstframe;
}

/* -----------------------------------------------------------------------------
 * wad_stack_debug() 
 *
 * Make a dump of a stack trace
 * ----------------------------------------------------------------------------- */

void wad_stack_debug(WadFrame *frame) {
  if (wad_debug_mode & DEBUG_STACK) {
    /* Walk the exception frames and try to find a return point */
    while (frame) {
      /* Print out detailed stack trace information */
      printf("::: Stack frame - 0x%08x :::\n", frame);
      printf("    pc           = %x\n", frame->pc);
      printf("    sp           = %x\n", frame->sp);
      printf("    fp           = %x\n", frame->fp);
      printf("    stack        = %x\n", frame->stack);
      printf("    size         = %x\n", frame->stack_size);
      printf("    segment      = %x (%s)\n", frame->segment, frame->segment ? frame->segment->mappath : "?");
      printf("    object       = %x (%s)\n", frame->object, frame->object ? frame->object->path : "?");

      if (frame->sym_name) {
	printf("    sym_name     = %s\n", frame->sym_name);
	printf("    sym_base     = %x\n", frame->sym_base);
	printf("    sym_size     = %x\n", frame->sym_size);
	printf("    sym_bind     = %x\n", frame->sym_bind);
	printf("    sym_file     = %s\n", frame->sym_file ? frame->sym_file : "");
      }

      if (frame->loc_srcfile) {
	printf("    loc_srcfile  = %s\n", frame->loc_srcfile);
      }

      if (frame->loc_objfile) {
	printf("    loc_objfile  = %s\n", frame->loc_objfile);
      }
      printf("    loc_line     = %d\n", frame->loc_line);


      printf("    debug_nargs  = %d\n", frame->debug_nargs);
      if (frame->debug_args) {
	int i = 0;
	WadLocal *p = frame->debug_args;
	printf("    debug_args = [ \n");
	while (p) {
	  printf("        arg[%d] : name = '%s', loc = %d, type = %d, stack = %d, reg = %d, line=%d, ptr=%x(%d)\n", i, p->name, p->loc, p->type, p->stack,p->reg,p->line,p->ptr,p->size);
	  p = p->next;
	}
      }
      printf("    ]\n");

      frame = frame->next;
    }
  }
}







