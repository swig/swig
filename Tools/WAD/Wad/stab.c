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

/* stabs data types used by this module */

#define N_UNDF      0x0           /* undefined         */
#define N_FUN       0x24          /* function          */
#define N_OBJ       0x38          /* object file path  */
#define N_RSYM      0x40          /* Register symbol   */
#define N_SLINE     0x44          /* Source line       */
#define N_SO        0x64          /* Source file name  */
#define N_PSYM      0xa0          /* Parameter         */

/* -----------------------------------------------------------------------------
 * match_stab_symbol()
 *
 * Match a stabs symbol name against a stab string.  The stab string may contain
 * extra information delimited by a colon which is not used in the comparsion.
 * Returns 1 on match, 0 on mismatch.
 * ----------------------------------------------------------------------------- */

static int
match_stab_symbol(char *symbol, char *stabtext, int slen) {
  if (strcmp(symbol,stabtext) == 0) {
    return 1;
  }
  if ((strncmp(symbol, stabtext, slen) == 0) && (*(stabtext+slen) == ':')) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * scan_function()
 *
 * Collect stabs data for a function definition.
 * ----------------------------------------------------------------------------- */

static void
scan_function(Stab *s, int ns, WadDebug *debug) {

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
  WadLocal *arg;

  s = (Stab *) sp;            /* Stabs data      */
  ns = size/sizeof(Stab);     /* number of stabs */

  slen = strlen(wsym->name);

  /* Reset the debug information section */
  debug->found = 0;
  debug->srcfile[0] = 0;
  debug->objfile[0] = 0;
  debug->line_number = -1;
  debug->nargs = 0;
  debug->args = 0;
  debug->lastarg = 0;

  for (i = 0; i < ns; i++, s++) {
    if (wad_debug_mode & DEBUG_STABS) {
      wad_printf("   %10d %10x %10d %10d %10d: '%s'\n", s->n_strx, s->n_type, s->n_other, s->n_desc, s->n_value, 
	     stabstr+s->n_strx);
      
    }
    if ((s->n_type == N_UNDF)) { /* && (s->n_desc >= 0)) { */
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
    } else if (s->n_type == N_SO) {
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
    } else if (s->n_type == N_OBJ) {
      /* Object file specifier */
      if (debug->objfile[0]) {
	strcat(debug->objfile,"/");
      }
      strcat(debug->objfile,stabstr+s->n_strx);
    } else if (s->n_type == N_FUN) {
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
    } else if (debug->found && (s->n_type == N_SLINE) && (infunc)) {
      /* Line number location */
      if (s->n_value < offset) {
	debug->line_number = s->n_desc;
      } else return 1;
    } else if (debug->found && ((s->n_type == N_PSYM) || (s->n_type == N_RSYM)) && (infunc)) {
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

      /* Check if the argument was already used */
      /* In this case, the first stab simply identifies an argument.  The second
         one identifies its location for the debugger */

      if (debug->args) {
	/* Need to do some fix up for linux here */
	WadLocal *a = debug->args;
	while (a) {
	  if ((strncmp(a->name,pname,len) == 0) && (strlen(a->name) == len)) {
	    /* We already saw this argument.  Given a choice between a register and a stack
               argument.  We will choose the stack version */
	    if (a->loc == PARM_STACK) {
	      break;
	    }
	    /* Go ahead and use the new argument */
	    if (s->n_type == 0x40)
	      a->loc = PARM_REGISTER;
	    else
	      a->loc = PARM_STACK;
	    a->position = s->n_value;
	    break;
	  }
	  a = a->next;
	}
	if (a) continue; /* We got an argument match.  Just skip to the next stab */
      }

      arg = (WadLocal *) wad_malloc(sizeof(WadLocal));
      arg->name = (char *) wad_malloc(len+1);
      strncpy(arg->name, pname, len);
      arg->name[len] = 0;
      if (s->n_type == 0x40)
	arg->loc = PARM_REGISTER;
      else
	arg->loc = PARM_STACK;

      arg->position = s->n_value;
      arg->type = 0;
      arg->next = 0;
      if (debug->args) {
	debug->lastarg->next = arg;
	debug->lastarg = arg;
      } else {
	debug->args = arg;
	debug->lastarg = arg;
      }
      debug->nargs++;
    }
  }
  if (debug->found) return 1;
  return 0;
}
