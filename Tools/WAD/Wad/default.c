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
  WadParm *wp;
  long    *stack;
  long    *nextstack;
  int     i;
  WadFrame *nf;

  if (frame->size) {
    nf = (WadFrame *) (((char *) frame) + frame->size);
    if (nf->size == 0) nf = 0;
  } else {
    nf = 0;
  }
  if (nf) 
    nextstack = STACK(nf);
  else
    nextstack = 0;

  str[0] = 0;
  stack = STACK(frame);

#ifdef WAD_LINUX
  if (!nf) {
    return "";
  }
#endif

  if (frame->nargs < 0) {
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
    wp = ARGUMENTS(frame);
    for (i = 0; i < frame->nargs; i++, wp++) {
      strcat(str,wp->name);
      strcat(str,"=");

      /* Try to figure out where the value is */
      if ((wp->loc == PARM_STACK) && nf) {
	/* Parameter is located on the call stack */
	unsigned long argloc = wp->value;    /* Location relative to frame pointer */
	if ((argloc & 0x3) == 0) {
	  if (argloc >= 0) {
	    /* Is word aligned, make some kind of attempt to print this out */
	    unsigned long *p = (unsigned long *) (((char *) nextstack) + argloc);
	    sprintf(temp,"0x%x", *p);
	    strcat(str,temp);
	  } else {
	    unsigned long *p = (unsigned long *) (((char *) stack) + frame->stack_size + argloc);
	    sprintf(temp,"0x%x", *p);
	    strcat(str,temp);
	  }
	}
      } else if (wp->loc == PARM_REGISTER) {
#ifdef WAD_SOLARIS
	if ((wp->value >= 24) && (wp->value < 32)) {
	  /* Value is located in the %in registers */
	  sprintf(temp,"0x%x", stack[wp->value - 16]);
	  strcat(str,temp);
	} else if ((wp->value >= 8) && (wp->value < 16)) {
	  /* Value is located in the %on registers */
	  sprintf(temp,"0x%x", frame->regs[wp->value]);
	  strcat(str,temp);
	} else if ((wp->value >= 16) && (wp->value < 24)) {
	  /* Value has been placed in the %ln registers */
	  sprintf(temp,"0x%x", frame->regs[wp->value - 16]);
	  strcat(str,temp);
	}
#endif
#ifdef WAD_LINUX
	strcat(str,"?");
#endif
      }
      if (i < (frame->nargs-1)) strcat(str,",");
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

void wad_default_callback(int signo, WadFrame *framedata, char *ret) {
  char *fd;
  WadFrame *f;
  WadFrame *fline = 0;

  switch(signo) {
  case SIGSEGV:
    fprintf(stderr,"Segmentation fault.\n");
    break;
  case SIGBUS:
    fprintf(stderr,"Bus error.\n");
    break;
  case SIGABRT:
    fprintf(stderr,"Abort.\n");
    break;
  case SIGFPE:
    fprintf(stderr,"Floating point exception.\n");
    break;
  case SIGILL:
    fprintf(stderr,"Illegal instruction.\n");
    break;
  default:
    fprintf(stderr,"Signal %d\n", signo);
    break;
  }
  fd = (char *) framedata;
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
    fprintf(stderr,"#%-3d 0x%08x in %s(%s)", f->frameno, f->pc, *(fd + f->sym_off) ? fd+f->sym_off : "?", 
	   wad_arg_string(f));
    if (strlen(fd+f->src_off)) {
      fprintf(stderr," in '%s'", wad_strip_dir(fd+f->src_off));
      if (f->line_number > 0) {
	fprintf(stderr,", line %d", f->line_number);
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
	fprintf(stderr," from '%s'", fd+f->obj_off);
      }
    }
    fprintf(stderr,"\n");
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
      fprintf(stderr,"\n%s, line %d\n\n", SRCFILE(fline),fline->line_number);
      for (i = first; i <= last; i++) {
	if (i == fline->line_number) fprintf(stderr," => ");
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

