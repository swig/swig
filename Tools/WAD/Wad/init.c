/* ----------------------------------------------------------------------------- 
 * init.c
 *
 *     Initialize the wad system.  This sets up a signal handler for catching
 *     SIGSEGV, SIGBUS, and SIGABRT.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"

/* Size of signal stack */
#define STACK_SIZE 4*SIGSTKSZ

/* Make the alternate signal stack part of the wad data segment as 
   opposed to putting it on the process heap */

char wad_sig_stack[STACK_SIZE];

/* Set up signal handler function for events we care about */
void wad_init() {
  struct sigaction newvec;
  static int init = 0;
  static stack_t  sigstk;

  if (!init) {
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
    newvec.sa_flags = SA_SIGINFO | SA_ONSTACK | SA_RESETHAND;
    newvec.sa_sigaction = ((void (*)(int,siginfo_t *, void *)) wad_signalhandler);
    sigaction(SIGSEGV, &newvec, NULL);
    sigaction(SIGBUS, &newvec, NULL);
    sigaction(SIGABRT, &newvec, NULL);
  }
  init = 1;
}
