/* ----------------------------------------------------------------------------- 
 * default.c
 *
 *     Default signal handler.  Just prints a stack trace and returns.
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

#include <sys/mman.h>


/* This function tries to produce some kind of sensible argument 
   string for a stack frame.  If no debugging information is available,
   we'll just dump the %i0-%i5 registers in hex.  If debugging information
   is available, we'll try to do something a little more sensible */
 
char *wad_arg_string(WadFrame *frame) {
  static char str[1024];
  WadLocal *wp;
  long    *stack;
  long    *nextstack;
  long    *prevstack;
  int     i;
  WadFrame *nf;
  WadFrame *pf;

  nf = frame->next;
  if (nf) 
    nextstack = (long *) nf->stack;
  else
    nextstack = 0;

  pf = frame->prev;
  if (pf)
    prevstack = (long *) pf->stack;
  else
    prevstack = 0;

  str[0] = 0;
  stack = (long *) frame->stack;


#ifdef WAD_LINUX
  if (!nf) {
    return "";
  }
#endif

  if ((frame->debug_nargs < 0) || (0)){
    /* No argument information is available. If we are on SPARC, we'll dump
       the %in registers since these usually hold input parameters.  On
       Linux, we do nothing */
    
#ifdef WAD_SOLARIS
    for (i = 0; i < 6; i++) {
      wad_strcat(str,"0x");
      wad_strcat(str,wad_format_hex((unsigned long) stack[8+i],0));
      if (i < 5)
	wad_strcat(str,",");
    }
#endif
  } else {
    /* We were able to get some argument information out the debugging table */
    wp = frame->debug_args;
    for (i = 0; i < frame->debug_nargs; i++, wp = wp->next) {
      wad_strcat(str,wp->name);
      wad_strcat(str,"=");
      wad_strcat(str,wad_format_var(wp));
      if (i < (frame->debug_nargs-1)) wad_strcat(str,",");
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
      src_file = 0;
      src_len = 0;
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
    wad_strcpy(src_path,path);
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

  if (f->loc_srcfile && strlen(f->loc_srcfile) && (f->loc_line > 0)) {
    char *line, *c;
    int   i;
    int   first, last;
    first = f->loc_line - window;
    last  = f->loc_line + window;
    if (first < 1) first = 1;
    line = wad_load_source(f->loc_srcfile,first);
    if (line) {
      wad_strcpy(temp,f->loc_srcfile);
      wad_strcat(temp,", line ");
      wad_strcat(temp,wad_format_signed(f->loc_line,-1));
      wad_strcat(temp,"\n\n");
      for (i = first; i <= last; i++) {
	if (i == f->loc_line) wad_strcat(temp," => ");
	else                  wad_strcat(temp,"    ");
	c = strchr(line,'\n');
	if (c) {
	  *c = 0;
	  wad_strcat(temp,line);
	  wad_strcat(temp,"\n");
	  *c = '\n';
	} else {
	  wad_strcat(temp,line);
	  wad_strcat(temp,"\n");
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
  while (f) {
    wad_strcpy(msg,"#");
    wad_strcat(msg,wad_format_signed(f->frameno,3));
    wad_strcat(msg," 0x");
    wad_strcat(msg,wad_format_hex(f->pc,1));
    wad_strcat(msg," in ");
    wad_strcat(msg, f->sym_name ? f->sym_name : "?");
    wad_strcat(msg,"(");
    wad_strcat(msg,wad_arg_string(f));
    wad_strcat(msg,")");
    if (f->loc_srcfile && strlen(f->loc_srcfile)) {
      wad_strcat(msg," in '");
      wad_strcat(msg, wad_strip_dir(f->loc_srcfile));
      wad_strcat(msg,"'");
      if (f->loc_line > 0) {
	wad_strcat(msg,", line ");
	wad_strcat(msg,wad_format_signed(f->loc_line,-1));
	/* Try to locate the source file */
	wad_debug_src_string(f, WAD_SRC_WINDOW);
      }
    } else {
      if (f->loc_objfile && strlen(f->loc_objfile)) {
	wad_strcat(msg," from '");
	wad_strcat(msg, wad_strip_dir(f->loc_objfile));
	wad_strcat(msg,"'");
      }
    }
    wad_strcat(msg,"\n");
    f->debug_str = wad_strdup(msg);
    f = f->next;
  }
}

/* Dump trace to a file */
void wad_dump_trace(int fd, int signo, WadFrame *f, char *ret) {
  static char buffer[128];
  char  *srcstr = 0;

  switch(signo) {
  case SIGSEGV:
    write(fd,"WAD: Segmentation fault.\n", 25);
    break;
  case SIGBUS:
    write(fd,"WAD: Bus error.\n",17);
    break;
  case SIGABRT:
    write(fd,"WAD: Abort.\n",12);
    break;
  case SIGFPE:
    write(fd,"WAD: Floating point exception.\n", 31);
    break;
  case SIGILL:
    write(fd,"WAD: Illegal instruction.\n", 26);
    break;
  default:
    sprintf(buffer,"WAD: Signal %d\n", signo);
    write(fd,buffer,strlen(buffer));
    break;
  }
  /* Find the last exception frame */

  while (f && !(f->last)) {
    f = f->next;
  }

  while (f) {
    write(fd,f->debug_str,strlen(f->debug_str));
    if (f->debug_srcstr) {
      srcstr = f->debug_srcstr;
    }
    f = f->prev;
  }
  if (srcstr) {
    write(fd,"\n",1);
    write(fd,srcstr,strlen(srcstr));
    write(fd,"\n",1);
  }
}

/* -----------------------------------------------------------------------------
 * Default callback
 * ----------------------------------------------------------------------------- */

void wad_default_callback(int signo, WadFrame *f, char *ret) {
  wad_dump_trace(2,signo,f,ret);
}

