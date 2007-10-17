/* ----------------------------------------------------------------------------- 
 * stack.c
 *
 *     This file unwinds the C call stack and creates a list of stack frames.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago. 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * See the file COPYING for a complete copy of the LGPL.
 * ----------------------------------------------------------------------------- */

#include "wad.h"

static char cvs[] = "$Id$";

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
  f->sym_nlen = 0;
  f->sym_file = 0;
  f->sym_base = 0;
  f->sym_size = 0;
  f->sym_type = 0;
  f->sym_bind = 0;

  f->loc_objfile = 0;
  f->loc_srcfile = 0;
  f->loc_line = 0;

  f->debug_check = 0;
  f->debug_nargs = -1;
  f->debug_args = 0;
  f->debug_lastarg = 0;
  f->debug_nlocals = 0;
  f->debug_locals = 0;
  f->debug_lastlocal = 0;
  f->debug_str = 0;
  f->debug_srcstr = 0;

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
  unsigned   long fake_fp;

  if (wad_debug_mode & DEBUG_UNWIND) {
    wad_printf("::: stack unwind :  pc = %x, sp = %x, fp = %x\n", *pc, *sp, *fp);
  }

  /* Verify that the sp and fp are in mapped memory */
  sp_seg = wad_segment_find((void *) *sp);
  fp_seg = wad_segment_find((void *) *fp);

  /* Make sure the stack pointer is in memory */
  if (!sp_seg) {
    return 0;
  }

  if (!fp_seg) {
    /* Hmmm. If no frame pointer, we must be off the top of the call stack */
    fake_fp = (unsigned long) (sp_seg->vaddr + sp_seg->size);
    fp_seg = sp_seg;
  } else {
    fake_fp = *fp;
  }
  if (sp_seg != fp_seg) {
    /* Whoa. Stack pointer and frame pointer are in different memory segments. */
    wad_printf("WAD: Warning. Stack pointer and frame pointer are in different regions.\n");
    return 0;
  }

  /* Check to see if the PC is valid */
  if (!wad_segment_valid((void *) *pc)) {
    return 0;
  }

  f = new_frame();
  f->pc = *pc;
  f->sp = *sp;
  f->fp = fake_fp;
  f->segment = wad_segment_find((void *) *pc);
  f->stack_size = fake_fp - *sp;
  /* Make a copy of the call stack */
  f->stack = (char *) wad_malloc(f->stack_size);
  wad_memcpy(f->stack,(void *) *sp, f->stack_size);

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
      wad_printf("::: Stack frame - 0x%08x :::\n", frame);
      wad_printf("    pc           = %x\n", frame->pc);
      wad_printf("    sp           = %x\n", frame->sp);
      wad_printf("    fp           = %x\n", frame->fp);
      wad_printf("    stack        = %x\n", frame->stack);
      wad_printf("    size         = %x\n", frame->stack_size);
      wad_printf("    segment      = %x (%s)\n", frame->segment, frame->segment ? frame->segment->mappath : "?");
      wad_printf("    object       = %x (%s)\n", frame->object, frame->object ? frame->object->path : "?");

      if (frame->sym_name) {
	wad_printf("    sym_name     = %s\n", frame->sym_name);
	wad_printf("    sym_base     = %x\n", frame->sym_base);
	wad_printf("    sym_size     = %x\n", frame->sym_size);
	wad_printf("    sym_bind     = %x\n", frame->sym_bind);
	wad_printf("    sym_file     = %s\n", frame->sym_file ? frame->sym_file : "");
      }

      if (frame->loc_srcfile) {
	wad_printf("    loc_srcfile  = %s\n", frame->loc_srcfile);
      }

      if (frame->loc_objfile) {
	wad_printf("    loc_objfile  = %s\n", frame->loc_objfile);
      }
      wad_printf("    loc_line     = %d\n", frame->loc_line);


      wad_printf("    debug_nargs  = %d\n", frame->debug_nargs);
      if (frame->debug_args) {
	int i = 0;
	WadLocal *p = frame->debug_args;
	wad_printf("    debug_args = [ \n");
	while (p) {
	  wad_printf("        arg[%d] : name = '%s', loc = %d, type = %d, stack = %d, reg = %d, line=%d, ptr=%x(%d)\n", i, p->name, p->loc, p->type, p->stack,p->reg,p->line,p->ptr,p->size);
	  p = p->next;
	}
      }
      wad_printf("    ]\n");

      wad_printf("    debug_nlocal  = %d\n", frame->debug_nlocals);
      if (frame->debug_locals) {
	int i = 0;
	WadLocal *p = frame->debug_locals;
	wad_printf("    debug_locals = [ \n");
	while (p) {
	  wad_printf("        loc[%d] : name = '%s', loc = %d, type = %d, stack = %d, reg = %d, line=%d, ptr=%x(%d)\n", i, p->name, p->loc, p->type, p->stack,p->reg,p->line,p->ptr,p->size);
	  p = p->next;
	}
      }
      wad_printf("    ]\n");

      frame = frame->next;
    }
  }
}


/* -----------------------------------------------------------------------------
 * wad_steal_outarg()
 *
 * Steal an output argument
 * ----------------------------------------------------------------------------- */

long 
wad_steal_outarg(WadFrame *f, char *symbol, int argno, int *error) {
  long *regs;
  WadFrame *lastf = 0;

  *error = 0;
  /* Start searching */
  while (f) {
    if (f->sym_name && (strcmp(f->sym_name,symbol) == 0)) {
      /* Got a match */
      if (lastf) {
#ifdef WAD_SOLARIS
	regs = (long *) lastf->stack;
	return regs[8+argno];
#endif
#ifdef WAD_LINUX
	regs = (long *) f->stack;
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







