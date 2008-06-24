/* ----------------------------------------------------------------------------- 
 * wadpl.cxx
 *
 *     Dynamically loadable module for Perl.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "wad.h"
#ifdef __cplusplus
}
#endif

#include <signal.h>

#include "wad_perl_handler.c"

/* Error message returned to perl */

static char message[65536];
static int  global_signo = 0;

static void returnfunc(void) {
  SV     *s;
  s = perl_eval_pv((char*)"libwadpl::wad_handler_traceback(0)", 0);
  croak("%s\n%s",SvPV(s,PL_na),message);
  return;
}

/* Handler function */	
static void handler(int signo, WadFrame *frame, char *ret) {

  static char temp[1024];
  int  len = 0;
  char *name;
  char *fd;
  WadFrame *f;
  WadFrame *fline = 0;
  int err;
  char  *type;

  if (!ret) {
    wad_default_callback(signo, frame, ret);
    return;
  }


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
    type = (char*)"Math.";
  default:
    break;
  }
  strcpy(message,type);
  strcat(message,"\n[ C stack trace ]\n\n");
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
	fline = f;
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
  wad_set_return_func(returnfunc);
  wad_release_trace();
}

static void perlwadinit() {
  printf("WAD Enabled\n");
  wad_init();
  wad_set_callback(handler);
  wad_set_return("Perl_pp_entersub", 0);
  perl_eval_pv(wad_perl_handler, 0);
}

/* This hack is used to auto-initialize wad regardless of whether we are
   used as an imported module or as a link-library for another module */
   
class wadinitializer {
public:
  wadinitializer() {
    perlwadinit();
  }
};

static wadinitializer wi;

extern "C"
XS(boot_libwadpl) {
  dXSARGS;
  ST(0) = &PL_sv_yes;
  XSRETURN(1);
}
