/* ----------------------------------------------------------------------------- 
 * signal.c
 *
 *     WAD signal handler. 
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

static char cvs[] = "$Header$";

extern void wad_stab_debug();

/* For some odd reason, certain linux distributions do not seem to define the
   register constants in a way that is easily accessible to us.  This is a hack */

#ifdef WAD_LINUX
#ifndef ESP
#define ESP      7
#endif
#ifndef EBP
#define EBP      6
#endif
#ifndef EIP
#define EIP      14
#endif
#ifndef ESI
#define ESI      5
#endif
#ifndef EDI
#define EDI      4
#endif
#ifndef EBX
#define EBX      8
#endif

#endif

/* Signal handling stack */
#define STACK_SIZE 4*SIGSTKSZ
char wad_sig_stack[STACK_SIZE];

/* This variable is set if the signal handler thinks that the
   heap has overflowed */

int wad_heap_overflow = 0;

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

int            wad_nlr_levels = 0;
static volatile int  *volatile nlr_p = &wad_nlr_levels;
long           wad_nlr_value = 0;
void          (*wad_nlr_func)(void) = 0;

/* Set the return value from another module */
void wad_set_return_value(long value) {
  wad_nlr_value = value;
}

/* Set the return function */
void wad_set_return_func(void(*f)(void)) {
  wad_nlr_func = f;
}

#ifdef WAD_SOLARIS
static void nonlocalret() {
  long a;
  
  a = wad_nlr_value;
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

  asm("sethi %hi(wad_nlr_value), %o0");
  asm("or %o0, %lo(wad_nlr_value), %o0");
  asm("ld [%o0], %i0");

  /* If there is a non-local return function.  We're going to go ahead
     and transfer control to it */
  
  if (wad_nlr_func) 
    (*wad_nlr_func)();

  asm("jmp %i7 + 8");
  asm("restore");
  asm(".size	_returnsignal,(.-_returnsignal)");
}
#endif

#ifdef WAD_LINUX

/* Saved values of the machine registers */

long   wad_saved_esi = 0;
long   wad_saved_edi = 0;
long   wad_saved_ebx = 0;

static void nonlocalret() {
  asm("_returnsignal:");
  while (*nlr_p > 0) {
    (*nlr_p)--;
    asm("leave");
  }

  if (wad_nlr_func) 
    (*wad_nlr_func)();

  /* Restore the registers */
  asm("movl wad_saved_esi, %esi");
  asm("movl wad_saved_edi, %edi");
  asm("movl wad_saved_ebx, %ebx");
  asm("movl wad_nlr_value, %eax");
  asm("leave");
  asm("ret");
}

/* This function uses a heuristic to restore the callee-save registers on i386.
   According to the Linux Assembly HOWTO, the %esi, %edi, %ebx, and %ebp registers
   are callee-saved.  All others are caller saved.    To restore the callee-save
   registers, we use the fact that the C compiler saves the callee-save registers
   (if any) at the beginning of function execution.   Therefore, we can scan the
   instructions at the start of each function in the stack trace to try and find
   where they are. 

   The following heuristic is used:

   1. Each function starts with a preamble like this which saves the %ebp 
      register:

          55 89 e5       --->   push %ebp
                                mov  %esp, %ebp

   2. Next, space is allocated for local variables, using one of two schemes:
 
          83 ec xx       --->  Less than 256 bytes of local storage
                ^^^
                length

          81 ec xx xx xx xx  --> More than 256 bytes of local storage
                ^^^^^^^^^^^
                   length

   3. After this, a collection of 1-byte stack push op codes might appear
          
          56      = pushl %esi
          57      = pushl %edi
          53      = pushl %ebx


   Based on the size of local variable storage and the order in which 
   the %esi, %edi, and %ebx registers are pushed on the stack, we can
   determine where in memory the registers are saved and restore them to
   their proper values.
*/

void wad_restore_i386_registers(WadFrame *f, int nlevels) {
  WadFrame *lastf = f;
  int       localsize = 0;
  unsigned char     *pc;
  unsigned long     *saved;
  int i, j;
  int pci;
  for (i = 0; i <= nlevels; i++, f=f->next) {

    /* This gets the starting instruction for the stack frame */
    pc = (unsigned char *) f->sym_base;
    /*    printf("pc = %x, base = %x, %s\n", f->pc, f->sym_base, SYMBOL(f)); */
    if (!pc) continue;

    /* Look for the standard prologue 0x55 0x89 0xe5 */
    if ((pc[0] == 0x55) && (pc[1] == 0x89) && (pc[2] == 0xe5)) {
      /* Determine the size */
      pci = 3;
      if ((pc[3] == 0x83) && (pc[4] == 0xec)) {
	/*	printf("8-bit size\n");*/
	localsize = (int) pc[5];
	pci = 6;
      } 
      if ((pc[3] == 0x81) && (pc[4] == 0xec)) {
	/*	printf("32-bit size\n"); */
	localsize = (int) *((long *) (pc+5));
	pci = 10;
      }
      saved = (long *) (f->fp - localsize - sizeof(long));
      /*      printf("saved = %x, fp = %x\n", saved, f->fp);
      printf("localsize = %d\n", localsize);
      */
      for (j = 0; j < 3; j++, saved--, pci++) {
	if (pc[pci] == 0x57) {
	  wad_saved_edi = *saved;
	  /*	  printf("restored edi = %x\n", wad_saved_edi); */
	}
	else if (pc[pci] == 0x56) {
	  wad_saved_esi = *saved;
	  /*	  printf("restored esi = %x\n", wad_saved_esi); */
	}
	else if (pc[pci] == 0x53) {
	  wad_saved_ebx = *saved;
	  /*	  printf("restored ebx = %x\n", wad_saved_ebx); */
	}
	else break;
      }
    }
  }
}

#endif

void wad_signalhandler(int sig, siginfo_t *si, void *vcontext) {
  greg_t  *pc;
  greg_t  *npc;
  greg_t  *sp;
  greg_t  *fp;
#ifdef WAD_LINUX
  greg_t  *esi;
  greg_t  *edi;
  greg_t  *ebx;
#endif

  unsigned long   addr;
  ucontext_t      *context;
  unsigned long   p_sp;        /* process stack pointer   */
  unsigned long   p_pc;        /* Process program counter */
  unsigned long   p_fp;        /* Process frame pointer   */
  int      nlevels = 0;
  int      found = 0;
  void     _returnsignal();
  WadFrame  *frame, *origframe;
  char      *framedata;
  char      *retname = 0;
  unsigned long current_brk;

  /* Reset all of the signals while running WAD */
  wad_signal_clear();

  wad_nlr_func = 0;

  context = (ucontext_t *) vcontext;

  wad_printf("WAD: Collecting debugging information...\n");

  /* Read the segments */
  if (wad_segment_read() < 0) {
    wad_printf("WAD: Unable to read segment map\n");
    return;
  }
 
  if (wad_debug_mode & DEBUG_SIGNAL) {
    wad_printf("WAD: siginfo = %x, context = %x\n", si, vcontext);
  }
  
  current_brk = (long) sbrk(0);

  /* Get some information about the current context */

#ifdef WAD_SOLARIS
  pc = &((context->uc_mcontext).gregs[REG_PC]);
  npc = &((context->uc_mcontext).gregs[REG_nPC]);
  sp = &((context->uc_mcontext).gregs[REG_SP]);
#endif

#ifdef WAD_LINUX
  sp = &((context->uc_mcontext).gregs[ESP]);        /* Top of stack */
  fp = &((context->uc_mcontext).gregs[EBP]);        /* Stack base - frame pointer */
  pc = &((context->uc_mcontext).gregs[EIP]);        /* Current instruction */
  esi = &((context->uc_mcontext).gregs[ESI]);       
  edi = &((context->uc_mcontext).gregs[EDI]);       
  ebx = &((context->uc_mcontext).gregs[EBX]);       
  
  wad_saved_esi = (unsigned long) (*esi);
  wad_saved_edi = (unsigned long) (*edi);
  wad_saved_ebx = (unsigned long) (*ebx);

  /*  printf("esi = %x, edi = %x, ebx = %x\n", wad_saved_esi, wad_saved_edi, wad_saved_ebx); */

  /*   printf("&sp = %x, &pc = %x\n", sp, pc); */
#endif
  
  /* Get some information out of the signal handler stack */
  addr = (unsigned long) si->si_addr;

  /* See if this might be a stack overflow */

  p_pc = (unsigned long) (*pc);
  p_sp = (unsigned long) (*sp);
#ifdef WAD_LINUX
  p_fp = (unsigned long) (*fp);
#endif
#ifdef WAD_SOLARIS
  p_fp = (unsigned long) *(((long *) p_sp) + 14);
#endif
  
  if (wad_debug_mode & DEBUG_SIGNAL) {
    wad_printf("fault at address %x, pc = %x, sp = %x, fp = %x\n", addr, p_pc, p_sp, p_fp);
  }
  frame = wad_stack_trace(p_pc, p_sp, p_fp);

  if (!frame) {
    /* We're really hosed.  Not possible to generate a stack trace */
    wad_printf("WAD: Unable to generate stack trace.\n");
    wad_printf("WAD: Maybe the call stack has been corrupted by buffer overflow.\n");
    wad_signal_clear();
    return;
  }

  {
    WadFrame *f = frame;
    while (f) {
      wad_find_object(f);
      wad_find_symbol(f);
      f = f->next;
    }
    f = frame;
    while (f) {
      wad_find_debug(f);
      wad_build_vars(f);
      f = f->next;
    }
  }
  wad_heap_overflow = 0;
  if (sig == SIGSEGV) {
    if (addr >= current_brk) wad_heap_overflow = 1;
  }

  wad_stack_debug(frame);

  /* Generate debugging strings */
  wad_debug_make_strings(frame);
  
  wad_stab_debug();

  /* Walk the exception frames and try to find a return point */
  origframe = frame;
  while (frame) {
    WadReturnFunc *wr = wad_check_return(frame->sym_name);
    if (wr) {
      found = 1;
      wad_nlr_value = wr->value;
      retname = wr->name;
    }
    if (found) {
      frame->last = 1;   /* Cut off top of the stack trace */
      break;
    }
    frame = frame->next;
    nlevels++;
  }
  

  if (found) {
    wad_nlr_levels = nlevels - 1;
#ifdef WAD_LINUX
    wad_restore_i386_registers(origframe, wad_nlr_levels);
#endif
  } else {
    wad_nlr_levels = -1;
  }

  wad_string_debug();
  wad_memory_debug();

  /* Before we do anything with callbacks, we are going
     to attempt to dump a wad-core */
  
  {
    int fd;
    static int already = 0;
    fd = open("wadtrace",O_WRONLY | O_CREAT | (already*O_APPEND) | ((already==0)*O_TRUNC),0666);
    if (fd > 0) {
      wad_dump_trace(fd,sig,origframe,retname);
      close(fd);
      already=1;
    }
  }

  if (sig_callback) {
    (*sig_callback)(sig,origframe,retname);
  } else {
    /* No signal handler defined.  Go invoke the default */

    wad_default_callback(sig, origframe,retname);
  }

  if (wad_debug_mode & DEBUG_HOLD) while(1);

  /* If we found a function to which we should return, we jump to
     an alternative piece of code that unwinds the stack and 
     initiates a non-local return. */

  if (wad_nlr_levels >= 0) {
    *(pc) = (greg_t) _returnsignal;
#ifdef WAD_SOLARIS
    *(npc) = *(pc) + 4;
#endif
    if (!(wad_debug_mode & DEBUG_ONESHOT)) {
      wad_signal_init();
    }
    return;
  }
  exit(1);
}


/* -----------------------------------------------------------------------------
 * wad_signal_init()
 *
 * Resets the signal handler.
 * ----------------------------------------------------------------------------- */

void wad_signal_init() {
  struct sigaction newvec;
  static stack_t  sigstk;
  static int      initstack = 0;

  if (wad_debug_mode & DEBUG_INIT) {
    wad_printf("WAD: Initializing signal handler.\n");
  }
  /* This is buggy in Linux and threads.  disabled by default */

#ifndef WAD_LINUX

  if (!initstack) {
    /* Set up an alternative stack */
    
    sigstk.ss_sp = (char *) wad_sig_stack;
    sigstk.ss_size = STACK_SIZE;
    sigstk.ss_flags = 0;
    if (!(wad_debug_mode & DEBUG_NOSTACK)) {
      if (sigaltstack(&sigstk, (stack_t*)0) < 0) {
	perror("sigaltstack");
      }
    }
    initstack=1;
  }
#endif

  sigemptyset(&newvec.sa_mask);
  sigaddset(&newvec.sa_mask, SIGSEGV);
  sigaddset(&newvec.sa_mask, SIGBUS);
  sigaddset(&newvec.sa_mask, SIGABRT);
  sigaddset(&newvec.sa_mask, SIGILL);
  sigaddset(&newvec.sa_mask, SIGFPE);
  newvec.sa_flags = SA_SIGINFO;

  if (wad_debug_mode & DEBUG_ONESHOT) {
    newvec.sa_flags |= SA_RESETHAND;
  }
#ifndef WAD_LINUX
  if (!(wad_debug_mode & DEBUG_NOSTACK)) {
    newvec.sa_flags |= SA_ONSTACK;
  } 
#endif
  newvec.sa_sigaction = ((void (*)(int,siginfo_t *, void *)) wad_signalhandler);
  if (sigaction(SIGSEGV, &newvec, NULL) < 0) goto werror;
  if (sigaction(SIGBUS, &newvec, NULL) < 0) goto werror;
  if (sigaction(SIGABRT, &newvec, NULL) < 0) goto werror;
  if (sigaction(SIGFPE, &newvec, NULL) < 0) goto werror;
  if (sigaction(SIGILL, &newvec, NULL) < 0) goto werror;
  
  return;
 werror:
  wad_printf("WAD: Couldn't install signal handler!\n");
}

/* -----------------------------------------------------------------------------
 * clear signals 
 * ----------------------------------------------------------------------------- */

void wad_signal_clear() {
  signal(SIGSEGV, SIG_DFL);
  signal(SIGBUS, SIG_DFL);
  signal(SIGILL, SIG_DFL);
  signal(SIGFPE, SIG_DFL);
  signal(SIGABRT, SIG_DFL);  
}



