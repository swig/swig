/* ----------------------------------------------------------------------------- 
 * wadtcl.cxx
 *
 *     Dynamically loadable Tcl module for wad.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include <tcl.h>
#include "wad.h"
#include <signal.h>

/* Handler function */	
static void handler(int signo, WadFrame *frame, char *ret) {
  static char message[65536];
  static char temp[1024];
  int  len = 0;
  char *name;
  char *fd;
  WadFrame *f;
  WadFrame *fline = 0;
  Tcl_Interp *interp;
  int err;
  char  *type;

  if (!ret) {
    wad_default_callback(signo, frame, ret);
    return;
  }

  strcpy(message,"[ C stack trace ]\n\n");
  switch(signo) {
  case SIGSEGV:
    type = (char*)"Segmentation fault.";
    break;
  case SIGBUS:
    type = (char*)"Bus error.";
    break;
  case SIGABRT:
    type = (char*)"Abort.";
    break;
  case SIGFPE:
    type = (char*)"Floating point exception.";
    break;
  default:
    type = (char*)"Unknown.";
    break;
  }
  fd = (char *) frame;
  f = (WadFrame *) fd;

  /* Find the last exception frame */
  while (!f->last) {
    fd = fd + f->size;
    f = (WadFrame *) fd;
  }
  /* Now work backwards */
  fd = fd - f->lastsize;
  f = (WadFrame *) fd;
  while (1) {
    sprintf(temp,"#%-3d 0x%08x in ", f->frameno, f->pc);
    strcat(message,temp);
    strcat(message,*(fd + f->sym_off) ? fd+f->sym_off : "?");
    strcat(message,"()");
    if (strlen(SRCFILE(f))) {
      strcat(message," in '");
      strcat(message, wad_strip_dir(SRCFILE(f)));
      strcat(message,"'");
      if (f->line_number > 0) {
	sprintf(temp,", line %d", f->line_number);
	strcat(message,temp);
	{
	  int fd;
	  fd = open(SRCFILE(f), O_RDONLY);
	  if (fd > 0) {
	    fline = f;
	  } 
	  close(fd);
	}
      }
    } else {
      if (strlen(fd+f->obj_off)) {
	strcat(message," from '");
	strcat(message, wad_strip_dir(OBJFILE(f)));
	strcat(message,"'");
      }
    }
    strcat(message,"\n");
    if (!f->lastsize) break;
    fd = fd - f->lastsize;
    f = (WadFrame *) fd;
  }
  if (fline) {
    int first;
    int last;
    char *line, *c;
    int i;
    first = fline->line_number - 2;
    last  = fline->line_number + 2;
    if (first < 1) first = 1;
    
    line = wad_load_source(SRCFILE(fline),first);
    if (line) {
      strcat(message,"\n");
      strcat(message, SRCFILE(fline));
      sprintf(temp,", line %d\n\n", fline->line_number);
      strcat(message, temp);
      for (i = first; i <= last; i++) {
	if (i == fline->line_number) strcat(message," => ");
	else                         strcat(message,"    ");
	c = strchr(line,'\n');
	if (c) {
	  *c = 0;
	  strcat(message,line);
	  strcat(message,"\n");
	  *c = '\n';
	} else {
	  strcat(message,line);
	  strcat(message,"\n");
	  break;
	}
	line = c+1;
      }
      wad_release_source();
      strcat(message,"\n");
    }
  }

  if (wad_heap_overflow) {
    write(2, "WAD: Heap overflow detected.\n", 30);
    wad_default_callback(signo, frame, ret);
  }

  /* Note: if the heap is blown, there is a very good chance that this
  function will not succeed and we'll dump core.  However, the check
  above should dump a stack trace to stderr just in case we don't make it
  back. */

  /* Try to get the Tcl interpreter through magic */
  if (ret) {
    interp = (Tcl_Interp *) wad_steal_outarg(frame,ret,1,&err);
    if (err == 0) {
      Tcl_SetResult(interp,type,TCL_STATIC);
      Tcl_AddErrorInfo(interp,message);
    }
  }
  wad_release_trace();
}

static void tclwadinit() {
  printf("WAD Enabled\n");
  wad_init();
  wad_set_callback(handler);
  wad_set_return("TclExecuteByteCode", TCL_ERROR);
  wad_set_return("EvalObjv", TCL_ERROR);
}

/* This hack is used to auto-initialize wad regardless of whether we are
   used as an imported module or as a link-library for another module */
   
class wadinitializer {
public:
  wadinitializer() {
    tclwadinit();
  }
};

static wadinitializer wi;

extern "C"
int Wad_Init(Tcl_Interp *interp) {
  return TCL_OK;
}
