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
static char  src_path[1024] = "";

/* Opens up a source file and tries to locate a specific line number */

char *wad_load_source(char *path, int line) {
  int fd;
  char *c;
  char *start;
  int   n;

  if (strcmp(src_path,path)) {
    if (src_file) {
      munmap(src_file, src_len);
    }
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
    strcpy(src_path,path);
  } 
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
  return 0;
}

void wad_release_source() {
  if (src_file) {
    munmap(src_file,src_len);
    src_file = 0;
    src_len = 0;
    src_path[0] = 0;
  }
}

/* -----------------------------------------------------------------------------
 * wad_debug_src_code(WadFrame *f)
 *
 * Get source code for a frame 
 * ----------------------------------------------------------------------------- */

char *wad_debug_src_string(WadFrame *f, int window) {
  static char temp[16384];
  char ntemp[64];

  if (f->loc_srcfile && strlen(f->loc_srcfile) && (f->loc_line > 0)) {
    char *line, *c;
    int   i;
    int   first, last;
    first = f->loc_line - window;
    last  = f->loc_line + window;
    if (first < 1) first = 1;
    line = wad_load_source(f->loc_srcfile,first);
    if (line) {
      strcpy(temp,f->loc_srcfile);
      strcat(temp,", line ");
      sprintf(ntemp,"%d\n\n", f->loc_line);
      strcat(temp,ntemp);
      for (i = first; i <= last; i++) {
	if (i == f->loc_line) strcat(temp," => ");
	else                  strcat(temp,"    ");
	c = strchr(line,'\n');
	if (c) {
	  *c = 0;
	  strcat(temp,line);
	  strcat(temp,"\n");
	  *c = '\n';
	} else {
	  strcat(temp,line);
	  strcat(temp,"\n");
	  break;
	}
	line = c+1;
      }
      f->debug_srcstr = wad_strdup(temp);
      return f->debug_srcstr;
    }
  }
  f->debug_srcstr = 0;
  return 0;
}

/* -----------------------------------------------------------------------------
 * wad_debug_make_strings(WadFrame *f)
 *
 * This function walks the stack trace and tries to generate a debugging string
 * ----------------------------------------------------------------------------- */

void 
wad_debug_make_strings(WadFrame *f) {
  static char msg[16384];
  char temp[1024];
  while (f) {
    sprintf(msg,"#%-3d 0x%08x in ", f->frameno, f->pc);
    strcat(msg, f->sym_name ? f->sym_name : "?");
    strcat(msg,"(");
    strcat(msg,wad_arg_string(f));
    strcat(msg,")");
    if (f->loc_srcfile && strlen(f->loc_srcfile)) {
      strcat(msg," in '");
      strcat(msg, wad_strip_dir(f->loc_srcfile));
      strcat(msg,"'");
      if (f->loc_line > 0) {
	sprintf(temp,", line %d", f->loc_line);
	strcat(msg,temp);
	/* Try to locate the source file */
	wad_debug_src_string(f, WAD_SRC_WINDOW);
      }
    } else {
      if (f->loc_objfile && strlen(f->loc_objfile)) {
	strcat(msg," from '");
	strcat(msg, wad_strip_dir(f->loc_objfile));
	strcat(msg,"'");
      }
    }
    strcat(msg,"\n");
    f->debug_str = wad_strdup(msg);
    f = f->next;
  }
}

/* -----------------------------------------------------------------------------
 * Default callback
 * ----------------------------------------------------------------------------- */

void wad_default_callback(int signo, WadFrame *f, char *ret) {
  char *fd;
  WadFrame *fline = 0;
  char  *srcstr = 0;

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
    fputs(f->debug_str, stderr);
    if (f->debug_srcstr) {
      srcstr = f->debug_srcstr;
    }
    f = f->prev;
  }
  if (srcstr) {
    fputs("\n", stderr);
    fputs(srcstr,stderr);
    fputs("\n", stderr);
  }
}

