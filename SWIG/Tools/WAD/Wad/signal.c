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

/* Signal handling stack */
#define STACK_SIZE 4*SIGSTKSZ
char wad_sig_stack[STACK_SIZE];

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

  wad_object_init();

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
    WadReturnFunc *wr = wad_check_return(framedata+frame->sym_off);
    if (wr) {
      found = 1;
      nlr_value = wr->value;
      retname = wr->name;
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

  if (wad_debug_mode & DEBUG_HOLD) while(1);

  wad_object_cleanup();

  /* If we found a function to which we should return, we jump to
     an alternative piece of code that unwinds the stack and 
     initiates a non-local return. */

  if (nlr_levels > 0) {
    *(pc) = (greg_t) _returnsignal;
    *(npc) = *(pc) + 4;
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
  /* Set up an alternative stack */
  sigstk.ss_sp = (char *) wad_sig_stack;
  sigstk.ss_size = STACK_SIZE;
  sigstk.ss_flags = 0;
  if (sigaltstack(&sigstk, (stack_t*)0) < 0) {
    perror("sigaltstack");
  }
  sigemptyset(&newvec.sa_mask);
  sigaddset(&newvec.sa_mask, SIGSEGV);
  sigaddset(&newvec.sa_mask, SIGBUS);
  sigaddset(&newvec.sa_mask, SIGABRT);
  sigaddset(&newvec.sa_mask, SIGILL);
  sigaddset(&newvec.sa_mask, SIGFPE);
  newvec.sa_flags = SA_SIGINFO | SA_ONSTACK | SA_RESETHAND;
  newvec.sa_sigaction = ((void (*)(int,siginfo_t *, void *)) wad_signalhandler);
  sigaction(SIGSEGV, &newvec, NULL);
  sigaction(SIGBUS, &newvec, NULL);
  sigaction(SIGABRT, &newvec, NULL);
  sigaction(SIGFPE, &newvec, NULL);
  sigaction(SIGILL, &newvec, NULL);
}
