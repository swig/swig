/* ----------------------------------------------------------------------------- 
 * default.c
 *
 *     Default signal handler.  Just prints a stack trace and returns.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"
#include <sys/mman.h>


/* This function tries to produce some kind of sensible argument 
   string for a stack frame.  If no debugging information is available,
   we'll just dump the %i0-%i5 registers in hex.  If debugging information
   is available, we'll try to do something a little more sensible */
 
char *wad_arg_string(WadFrame *frame) {
  static char str[1024];
  static char temp[64];
  WadLocal *wp;
  long    *stack;
  long    *nextstack;
  int     i;
  WadFrame *nf;
  
  nf = frame->next;
  if (nf) 
    nextstack = (long *) nf->stack;
  else
    nextstack = 0;

  str[0] = 0;
  stack = (long *) frame->stack;

#ifdef WAD_LINUX
  if (!nf) {
    return "";
  }
#endif

  if (frame->debug_nargs < 0) {
    /* No argument information is available. If we are on SPARC, we'll dump
       the %in registers since these usually hold input parameters.  On
       Linux, we do nothing */
    
#ifdef WAD_SOLARIS
    for (i = 0; i < 6; i++) {
      sprintf(temp,"0x%x", stack[8+i]);
      strcat(str,temp);
      if (i < 5)
	strcat(str,",");
    }
#endif
  } else {
    /* We were able to get some argument information out the debugging table */
    wp = frame->debug_args;
    for (i = 0; i < frame->debug_nargs; i++, wp = wp->next) {
      strcat(str,wp->name);
      strcat(str,"=");
      strcat(str,wad_format_var(wp));
      if (i < (frame->debug_nargs-1)) strcat(str,",");
    }
  }
  return str;

}

char *wad_strip_dir(char *name) {
  char *c;
  /*  printf("strip: '%s'\n", name); */
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

static char *src_file = 0;
static int   src_len = 0;

/* Opens up a source file and tries to locate a specific line number */

char *wad_load_source(char *path, int line) {
  int fd;
  char *c;
  char *start;
  int   n;

  fd = open(path, O_RDONLY);
  if (fd < 0) return 0;
  src_len = lseek(fd, 0, SEEK_END);
  lseek(fd,0,SEEK_SET);
  src_file = (char *)mmap(NULL,src_len, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
  if (src_file == MAP_FAILED) {
    close(fd);
    return 0;
  }
  close(fd);
  n = 0;
  start = src_file;
  c = src_file;
  while (n < src_len) {
    if (*c == '\n') {
      line--;
      if (line == 0) {
	return start;
      }
      start = c+1;
    }
    c++;
    n++;
  }
  munmap(src_file,src_len);
  src_file = 0;
  return 0;
}

void wad_release_source() {
  if (src_file)
    munmap(src_file,src_len);
}

/* -----------------------------------------------------------------------------
 * Default callback
 * ----------------------------------------------------------------------------- */

void wad_default_callback(int signo, WadFrame *f, char *ret) {
  char *fd;
  WadFrame *fline = 0;

  switch(signo) {
  case SIGSEGV:
    fprintf(stderr,"WAD: Segmentation fault.\n");
    break;
  case SIGBUS:
    fprintf(stderr,"WAD: Bus error.\n");
    break;
  case SIGABRT:
    fprintf(stderr,"WAD: Abort.\n");
    break;
  case SIGFPE:
    fprintf(stderr,"WAD: Floating point exception.\n");
    break;
  case SIGILL:
    fprintf(stderr,"WAD: Illegal instruction.\n");
    break;
  default:
    fprintf(stderr,"WAD: Signal %d\n", signo);
    break;
  }
  /* Find the last exception frame */

  while (f && !(f->last)) {
    f = f->next;
  }
  while (f) {
    fprintf(stderr,"#%-3d 0x%08x in %s(%s)", f->frameno, f->pc, f->sym_name ? f->sym_name : "?", 
	   wad_arg_string(f));
    if (f->loc_srcfile && strlen(f->loc_srcfile)) {
      fprintf(stderr," in '%s'", wad_strip_dir(f->loc_srcfile));
      if (f->loc_line > 0) {
	fprintf(stderr,", line %d", f->loc_line);
	{
	  int fd;
	  fd = open(f->loc_srcfile, O_RDONLY);
	  if (fd > 0) {
	    fline = f;
	  } 
	  close(fd);
	}
      }
    } else {
      if (f->loc_objfile && strlen(f->loc_objfile)) {
	fprintf(stderr," from '%s'", f->loc_objfile);
      }
    }
    fprintf(stderr,"\n");
    f = f->prev;
  }

  if (fline) {
    int first;
    int last;
    char *line, *c;
    int i;
    first = fline->loc_line - 2;
    last  = fline->loc_line + 2;
    if (first < 1) first = 1;
    
    line = wad_load_source(fline->loc_srcfile,first);
    if (line) {
      fprintf(stderr,"\n%s, line %d\n\n", fline->loc_srcfile,fline->loc_line);
      for (i = first; i <= last; i++) {
	if (i == fline->loc_line) fprintf(stderr," => ");
	else                         fprintf(stderr,"    ");
	c = strchr(line,'\n');
	if (c) {
	  *c = 0;
	  fprintf(stderr,"%s\n",line);
	  *c = '\n';
	} else {
	  fprintf(stderr,"%s\n",line);
	  break;
	}
	line = c+1;
      }
      wad_release_source();
      fprintf(stderr,"\n");
    }
  }
}

