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


/* stabs data structure.   This appears to be somewhat universal. */

typedef struct Stab {
  unsigned        n_strx;         /* index into file string table */
  unsigned char   n_type;         /* type flag (N_TEXT,..)  */
  char            n_other;        /* used by N_SLINE stab */
  unsigned short  n_desc;         /* see stabs documentation */
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
   stabs sections.

   Note: If a symbol corresponds to a local symbol, it's entirely possible
   that the only stabs data we will find is a file specifier. In this case,
   
 */

int
wad_search_stab(void *sp, int size, char *stabstr, WadSymbol *wsym, unsigned long offset, WadDebug *debug) {
  Stab *s;
  int   ns;
  int   infunc;
  int   slen;
  int   i;
  char  *file, *lastfile = 0;
  int   chk = 0;

  s = (Stab *) sp;            /* Stabs data      */
  ns = size/sizeof(Stab);     /* number of stabs */

  slen = strlen(wsym->name);

  /* Reset the debug information section */
  debug->found = 0;
  debug->srcfile[0] = 0;
  debug->objfile[0] = 0;
  debug->line_number = -1;
  debug->nargs = 0;
  for (i = 0; i < ns; i++, s++) {
    /*#define DEBUG_DEBUG */
    if (wad_debug_mode & DEBUG_STABS) {
      /*      printf("   %10d %10x %10d %10d %10d: '%x'\n", s->n_strx, s->n_type, s->n_other, s->n_desc, s->n_value, 
	      stabstr+s->n_strx); */
      printf("   %10d %10x %10d %10d %10d: '%s'\n", s->n_strx, s->n_type, s->n_other, s->n_desc, s->n_value, 
	     stabstr+s->n_strx);
      
    }
    if ((s->n_type == 0)) { /* && (s->n_desc >= 0)) { */
      /* New stabs section.  We need to be a little careful here. Do a recursive 
	 search of the subsection. */

      if (wad_search_stab(s+1,s->n_desc*sizeof(Stab), stabstr, wsym, offset,debug)) return 1;

      /* On solaris, each stabs section seem to increment the stab string pointer.  On Linux,
         the linker seems to do a certain amount of optimization that results in a single
         string table. */

#ifdef WAD_SOLARIS
      stabstr += s->n_value;     /* Update the string table location*/
#endif
      i += s->n_desc;
      s += s->n_desc;
      debug->objfile[0] = 0;
      debug->srcfile[0] = 0;
      debug->line_number = -1;
      debug->found = 0;
      continue;
    } else if (s->n_type == 0x64) {
      if (debug->found) return 1;    /* New file and we already found what we wanted */
      /* Source file specification */
      /* Look for directory */
      file = stabstr+s->n_strx;
      if (strlen(file) && (file[strlen(file)-1] == '/')) {
	strcpy(debug->srcfile,file);
      } else {
	strcat(debug->srcfile,file);
      }
      debug->objfile[0] = 0;
      /* We're going to check for a file match. Maybe we're looking for a local symbol */
      if (wsym->file && strcmp(wsym->file,file) == 0) {
	debug->found = 1;
      }
      lastfile = file;
    } else if (s->n_type == 0x38) {
      /* Object file specifier */
      if (debug->objfile[0]) {
	strcat(debug->objfile,"/");
      }
      strcat(debug->objfile,stabstr+s->n_strx);
    } else if (s->n_type == 0x24) {
      if (match_stab_symbol(wsym->name, stabstr+s->n_strx, slen)) {
	if (!wsym->file || (strcmp(wsym->file,lastfile) == 0)) {
	  infunc = 1;
	  debug->found = 1;
	  debug->nargs = 0;
	} else {
	  infunc = 0;
	}
      } else {
	infunc = 0;
      }
    } else if (debug->found && (s->n_type == 0x44) && (infunc)) {

      /* Line number location */
      if (s->n_value < offset) {
	debug->line_number = s->n_desc;
      } else return 1;
    } else if (debug->found && ((s->n_type == 0xa0) || (s->n_type == 0x40)) && (infunc)) {
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

      if (debug->nargs > 0) {
	if (strcmp(debug->parms[debug->nargs-1].name, pname) == 0)
	  debug->nargs--;
      }
      strncpy(debug->parms[debug->nargs].name,pname,len);
      debug->parms[debug->nargs].name[len] = 0;

      if (s->n_type == 0x40)
	debug->parms[debug->nargs].loc = PARM_REGISTER;
      else
	debug->parms[debug->nargs].loc = PARM_STACK;

      debug->parms[debug->nargs].value = s->n_value;
      debug->nargs++;
    }
  }
  if (debug->found) return 1;
  return 0;
}
