/* ----------------------------------------------------------------------------- 
 * stab.c
 *
 *     This file reads stabs data and looks for various properties of a 
 *     given symbol.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"


/* stabs data structure.   This appears to be somewhat universal.  I ripped
   it out of the Sun C compiler include directory */

typedef struct Stab {
  unsigned        n_strx;         /* index into file string table */
  unsigned char   n_type;         /* type flag (N_TEXT,..)  */
  char            n_other;        /* used by N_SLINE stab */
  short           n_desc;         /* see stabs documentation */
  unsigned        n_value;        /* value of symbol (or sdb offset) */ 
} Stab;

/* Match a stabs symbol name against a stab string (which may contain 
   extra information delimetered by a colon */

int match_stab_symbol(char *symbol, char *stabtext, int slen) {
  /*  printf("matching: %s -> %s\n", symbol, stabtext); */
  if (strcmp(symbol,stabtext) == 0) {
    return 1;
  }
  if ((strncmp(symbol, stabtext, slen) == 0) && (*(stabtext+slen) == ':')) return 1;
  return 0;
}

/* Given a stabs data segment (obtained somehow), this function tries to
   collect as much information as it can about a given symbol. 

   s points to the stab data.  stabstr points to the stab string section,
   ns is the size of the stab section, symbol is the item of interest,
   and offset is the offset in the object file of the symbol

   Note: this function may recurse upon itself if there are multiple
   stabs sections
 */

static WadDebug debug;

WadDebug *
wad_search_stab(void *sp, int size, char *stabstr, char *symbol, unsigned long offset) {
  Stab *s;
  int   ns;
  int   infunc;
  int   slen;
  int   i;
  char  *file;
  int   chk = 0;

  s = (Stab *) sp;            /* Stabs data      */
  ns = size/sizeof(Stab);     /* number of stabs */
  slen = strlen(symbol);

  /* Reset the debug information section */
  debug.found = 0;
  debug.srcfile[0] = 0;
  debug.objfile[0] = 0;
  debug.line_number = -1;
  debug.nargs = 0;
  for (i = 0; i < ns; i++, s++) {
    /*#define DEBUG_DEBUG */
#ifdef DEBUG_DEBUG
    printf("   %10d %10x %10d %10d %10d: '%s'\n", s->n_strx, s->n_type, s->n_other, s->n_desc, s->n_value, 
		    stabstr+s->n_strx);
#endif
#undef DEBUG_DEBUG
    if (s->n_type == 0) {
      /* New stabs section.  We need to be a little careful here. Do a recursive 
	 search of the subsection. */
      WadDebug *wd;
#ifdef DEBUG_DEBUG
      printf("Section: %d stabs.\n", s->n_desc);
#endif
      wd = wad_search_stab(s+1,s->n_desc*sizeof(Stab), stabstr, symbol, offset);
      if (wd) return wd;
      stabstr += s->n_value;     /* Update the string table location*/
      i += s->n_desc;
      s += s->n_desc;
      debug.objfile[0] = 0;
      debug.srcfile[0] = 0;
      debug.line_number = -1;
      debug.found = 0;
    } else if (s->n_type == 0x64) {
      if (debug.found) return &debug;    /* New file and we already found what we wanted */
      /* Source file specification */
      /* Look for directory */
      file = stabstr+s->n_strx;
      if (file[strlen(file)] == '/') {
	strcpy(debug.srcfile,file);
      } else {
	strcat(debug.srcfile,file);
      }
      debug.objfile[0] = 0;
    } else if (s->n_type == 0x38) {
      /* Object file specifier */
      if (debug.objfile[0]) {
	strcat(debug.objfile,"/");
      }
      strcat(debug.objfile,stabstr+s->n_strx);
    } else if (s->n_type == 0x24) {
      if (match_stab_symbol(symbol, stabstr+s->n_strx, slen)) {
	infunc = 1;
	debug.found = 1;
	debug.nargs = 0;
      } else {
	infunc = 0;
      }
    } else if (debug.found && (s->n_type == 0x44) && (infunc)) {

      /* Line number location */

      if (s->n_value <= offset) {
	debug.line_number = s->n_desc;
      } else return &debug;
    } else if (debug.found && ((s->n_type == 0xa0) || (s->n_type == 0x40)) && (infunc)) {
      /* Parameter counting */
      char *pname;
      char *c;
      int   len;
      pname = stabstr+s->n_strx;
      c = strchr(pname,':');
      if (c) {
	len = (c-pname);
      } else {
	len = strlen(pname);
      }

      /* Check if already used */
      /* In this case, the first stab simply identifies an argument.  The second
         one identifies its location for the debugger */

      if (debug.nargs > 0) {
	if (strcmp(debug.parms[debug.nargs-1].name, pname) == 0)
	  debug.nargs--;
      }
      strncpy(debug.parms[debug.nargs].name,pname,len);
      debug.parms[debug.nargs].name[len] = 0;

      if (s->n_type == 0x40)
	debug.parms[debug.nargs].loc = PARM_REGISTER;
      else
	debug.parms[debug.nargs].loc = PARM_STACK;

      debug.parms[debug.nargs].value = s->n_value;
      /*      printf("%s : %d: %d : %s\n", debug.parms[debug.nargs].name, s->n_type, debug.parms[debug.nargs].value,pname); */
	     
      debug.nargs++;
    }
  }
  if (debug.found) return &debug;
  return 0;
}
