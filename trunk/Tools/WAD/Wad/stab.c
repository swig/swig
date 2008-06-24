/* ----------------------------------------------------------------------------- 
 * stab.c
 *
 *     This file reads stabs data and looks for various properties of a 
 *     given symbol.
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
#define N_LSYM      0x80          /* Local symbol      */
#define N_PSYM      0xa0          /* Parameter         */
#define N_LBRAC     0xc0          /* Left brace        */
#define N_RBRAC     0xe0          /* Right brace       */

/* -----------------------------------------------------------------------------
 * stabs type handler
 *
 * Type names are defined as N_LSYM types.   We need to keep a hash table of
 * logical type names and stabs type names.
 *
 * We also need to keep a hash table of stabs types.
 * ----------------------------------------------------------------------------- */

typedef struct stabtype {
  char             *name;
  char             *value;
  struct stabtype  *next;
  int               visit;
} stabtype;

#define HASH_SIZE    113

static int       stab_type_init = 0;
static stabtype *lnames[HASH_SIZE];      /* Hash of local names */
static stabtype  *deadnames[HASH_SIZE];  /* Hash of dead names */

/* Initialize the hash table */

static void init_hash() {
  int i;
  stabtype *s, *sp = 0;

  for (i = 0; i < HASH_SIZE; i++) {
    if (stab_type_init) {
      /* Add stabs to dead list */
      s = lnames[i];
      sp = 0;
      while (s) {
	sp = s;
	s = s->next;
      }
      if (sp) {
	sp->next = deadnames[i];
	deadnames[i] = lnames[i];
      }
    }
    lnames[i] = 0;
  }
  stab_type_init = 1;
}

static int thash(char *name) {
  unsigned int h = 0;
  int i;
  for (i = 0; i < 8 && (*name); i++, name++) {
    h = ((h << 7) + *name);
  }
  return (h % HASH_SIZE);
}

/* Add a symbol to the hash */

static void type_add(char *name, char *value) {
  int h;
  stabtype *s;
  char      sc =0;
  char     *v;
  char     *vr;
  char     *split;

  if (!stab_type_init) {
    init_hash();
    stab_type_init = 1;
  }

  /* Split the "value" up into a type name and a value */
  
  split = strchr(value,'=');
  if (value[0] != '(') split = 0;
  if (split) {
    sc = *split;
    v = value;
    *split = 0;
    vr = split+1;
  } else {
    v = value;
    sc = 0;
    vr = 0;
  }

  h = thash(name);
  s = lnames[h];
  while (s) {
    if (strcmp(s->name,name) == 0) {
      if (strcmp(s->value,v)) {
	s->value = wad_string_lookup(v);
      }
      goto add_more;
    }
    s = s->next;
  }
  s = deadnames[h];
  if (!s) {
    s = (stabtype *) wad_malloc(sizeof(stabtype));
  } else {
    deadnames[h] = s->next; 
  }
  s->name = wad_string_lookup(name);
  s->value = wad_string_lookup(v);
  s->next = lnames[h];
  s->visit = 0;
  lnames[h] = s;

  /* Now take a look at the value.   If it is contains other types, we might be able to define more stuff */
 add_more:
  if (vr) {
    /* There is a mapping to another type */
    type_add(v,vr);
  }
}

static
char *type_resolve(char *name) {
  int h;
  stabtype *s;
  h = thash(name);
  s = lnames[h];
  while(s) {
    if (strcmp(s->name,name) == 0) {
      if (!s->visit) {
	char *c;
	/* The visit flag is set so that we don't get in infinite loops */
	s->visit = 1;
	c = type_resolve(s->value);
	s->visit = 0;
	return c;
      } else {
	return name;
      }
    }
    s = s->next;
  }
  return name;
}  

/* This function tries to resolve base stabs types into a machine equivalent */
static
int type_typecode(char *name) {
  char *range;

  if (name[0] == '*') {
    return WAD_TYPE_POINTER;
  }

  range = strchr(name,';');
  if (!range) return WAD_TYPE_UNKNOWN;
  range++;

  if (name[0] == 'r') {
    /* GNU-style range specifiers */
    if (
	(strcmp(range,"0000000000000;0037777777777;") == 0)
	) {
      return WAD_TYPE_UINT32;
    }
    if (
	(strcmp(range,"0020000000000;0017777777777;") == 0)
	) {
      return WAD_TYPE_INT32;
    }
    if (
	(strcmp(range,"-32768;32767;") == 0)
	) {
      return WAD_TYPE_INT16;
    }
    if (
	(strcmp(range,"0;65535;") == 0) 
	) {
      return WAD_TYPE_UINT16;
    }
    if (
	(strcmp(range,"0;127;") == 0)
	) {
      return WAD_TYPE_CHAR;
    }
    if (
	(strcmp(range,"-128;127;") == 0)
	) {
      return WAD_TYPE_INT8;
    }
    if (
	(strcmp(range,"0;255;") == 0) 
	) {
      return WAD_TYPE_UINT8;
    }
    if (
	(strcmp(range,"4;0;") == 0)
	) {
      return WAD_TYPE_FLOAT;
    }
    if (
	(strcmp(range,"8;0;") == 0)
	) {
      return WAD_TYPE_DOUBLE;
    }
  }
  /* Traditional built-in types */
  if (strcmp(name,"bs4;0;32;") == 0) {
    return WAD_TYPE_INT32;
  } 
  if (strcmp(name,"bs2;0;16;") == 0) {
    return WAD_TYPE_INT16;
  }
  if (strcmp(name,"bs1;0;8;") == 0) {
    return WAD_TYPE_INT8;
  }
  if (strcmp(name,"bsc1;0;8;") == 0) {
    return WAD_TYPE_CHAR;
  }
  if (strcmp(name,"bu4;0;32;") == 0) {
    return WAD_TYPE_UINT32;
  }
  if (strcmp(name,"bu2;0;16;") == 0) {
    return WAD_TYPE_UINT16;
  }
  if (strcmp(name,"bu1;0;8;") == 0) {
    return WAD_TYPE_UINT8;
  }
  if (strcmp(name,"R1;4;") == 0) {
    return WAD_TYPE_FLOAT;
  }
  if (strcmp(name,"R2;8;") == 0) {
    return WAD_TYPE_DOUBLE;
  }
  return WAD_TYPE_UNKNOWN;
}

static void types_print() {
  stabtype *s;
  int i;
  for (i = 0; i < HASH_SIZE; i++) {
    s = lnames[i];
    while (s) {
      wad_printf("%20s  %s\n", s->name, s->value);
      s = s->next;
    }
  }
}

void wad_stab_debug() {
  /*  types_print();*/
}

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

static char *
stab_string_parm(char *str) {
  return strchr(str,':');
}

/* -----------------------------------------------------------------------------
 * stab_symbol(Stab *s, char *stabstr)
 *
 * Process stab symbol specifier N_LSYM
 * ----------------------------------------------------------------------------- */

static void
stab_symbol(Stab *s, char *stabstr) {
  char *str;
  char *pstr;
  char name[1024]; 
  char value[65536];

  str = stabstr+s->n_strx;
  pstr = stab_string_parm(str);
  if (!pstr) return;
  
  strncpy(name,str, pstr-str);
  name[(int)(pstr-str)] = 0;
  if ((pstr[1] == 't') || (pstr[1] == 'p') || (pstr[1] == 'r')) {
    /* A stabs type definition */
    /*    printf("stab lsym:  other=%d, desc=%d, value=%d, str='%s'\n", s->n_other,s->n_desc,s->n_value,
	  stabstr+s->n_strx); */
    /*    wad_printf("name = '%s', pstr='%s'\n", name, pstr+2); */
    wad_strcpy(value,pstr+2);
    type_add(name,value);
  }
}


/* -----------------------------------------------------------------------------
 * scan_function()
 *
 * Collect stabs data for a function definition.
 * ----------------------------------------------------------------------------- */

static int
scan_function(Stab *s, char *stabstr, int ns, WadFrame *f) {
  int i;
  unsigned long offset;
  int      get_parms = 1;
  int      nbrace = 0;

  offset = f->pc - f->sym_base;
  if (wad_debug_mode & DEBUG_STABS) {
    wad_printf("---[ %s ] --------------\n", f->sym_name);
  }
  
  for (i = 0; i < ns; i++,s++) {
    if (wad_debug_mode & DEBUG_STABS) {
      wad_printf("   %10d %10x %10d %10d %10d: '%s'\n", s->n_strx, s->n_type, s->n_other, s->n_desc, s->n_value, 
	     stabstr+s->n_strx);
      
    }
    
    if ((s->n_type == N_UNDF) || (s->n_type == N_SO) || /* (s->n_type == N_FUN) || */
	(s->n_type == N_OBJ)) return i;

    if ((s->n_type == N_FUN) && !(strlen(stabstr+s->n_strx))) return 1;

    if (s->n_type == N_LBRAC) {
      nbrace++;
      get_parms = 0;
    }
    if (s->n_type == N_RBRAC) {
      nbrace--;
      if (nbrace <= 0) return i;
    }
    /* Local variable declaration */

    if (s->n_type == N_LSYM) {
      /* This might be a local variable definition */
      /*      wad_printf("local: n_value = %d, offset = %d\n", s->n_value, offset);*/
      if (s->n_desc <= f->loc_line)
      {
	/* Okay. We can pay attention to it */
	char *pname;
	char *c;
	int   len;
	WadLocal *arg, *a;
	pname = stabstr+s->n_strx;
	c = strchr(pname,':');
	if (*(c+1) != '(') continue;
	if (c) {
	  len = (c-pname);
	} else {
	  len = strlen(pname);
	}
	/*	printf("local\n"); */
	stab_symbol(s,stabstr);
	a = f->debug_locals;
	while (a) {
	  if ((strncmp(a->name,pname,len) == 0) && (strlen(a->name) == len)) {
	    /* We already saw this argument.  Given a choice between a register and a stack
	       argument.  We will choose the stack version */
	    a->loc = PARM_STACK;
	    a->stack = s->n_value;
	    break;
	  }
	  a = a->next;
	}
	if (a) continue; /* We got an argument match.  Just skip to the next stab */
	arg = (WadLocal *) wad_malloc(sizeof(WadLocal));
	{
	  char t = pname[len];
	  pname[len] = 0;
	  arg->name = wad_string_lookup(pname);
	  pname[len] = t;
	}
	arg->loc = PARM_STACK;
	arg->line = s->n_desc;
	arg->stack = s->n_value;
	arg->type = 0;
	arg->next = 0;
	{
	  char tname[128];
	  char *t = tname;
	  
	  c+=1;
	  while ((*c) && (*c != '=')) {
	    *t++ = *c++;
	  }
	  *t = 0;
	  t = type_resolve(tname);
	  arg->type = type_typecode(t);
	  if (wad_debug_mode & DEBUG_STABS) {
	    wad_printf("type_resolve '%s' -> '%s' (%d)\n", tname, t, arg->type);
	  }
	}
	if (f->debug_locals) {
	  f->debug_lastlocal->next = arg;
	  f->debug_lastlocal = arg;
	} else {
	  f->debug_locals = arg;
	  f->debug_lastlocal = arg;
	  f->debug_nlocals= 0;
	}
	f->debug_nlocals++;
      }
    }

    if (s->n_type == N_SLINE) {
      get_parms = 0;
      if (s->n_value <= offset) {
	f->loc_line = s->n_desc;
      }
    } else if (((s->n_type == N_PSYM) || (s->n_type == N_RSYM)) && get_parms) {
      /* Parameter counting */
      char *pname;
      char *c;
      int   len;
      WadLocal *arg;
      pname = stabstr+s->n_strx;
      c = strchr(pname,':');
      if (c) {
	len = (c-pname);
      } else {
	len = strlen(pname);
      }
      /* Get type information */
      
      stab_symbol(s,stabstr);
      
      /* Check if the argument was already used */
      /* In this case, the first stab simply identifies an argument.  The second
	 one identifies its location for the debugger */
      
      {
	/* Need to do some fix up for linux here */
	WadLocal *a = f->debug_args;
	while (a) {
	  if ((strncmp(a->name,pname,len) == 0) && (strlen(a->name) == len)) {
	    /* We already saw this argument.  Given a choice between a register and a stack
	       argument.  We will choose the stack version */
	    
	    if (a->loc == PARM_STACK) {
	      break;
	    }
	    /* Go ahead and use the new argument */
	    if (s->n_type == N_RSYM) {
	      a->loc = PARM_REGISTER;
	      a->reg = s->n_value;
	    } else {
	      a->loc = PARM_STACK;
	      a->stack = s->n_value;
	    }
	    break;
	  }
	  a = a->next;
	}
	if (a) continue; /* We got an argument match.  Just skip to the next stab */
      }
	
      arg = (WadLocal *) wad_malloc(sizeof(WadLocal));
      {
	char t = pname[len];
	pname[len] = 0;
	arg->name = wad_string_lookup(pname);
	pname[len] = t;
      }
      if (s->n_type == N_RSYM) {
	arg->loc = PARM_REGISTER;
	arg->reg = s->n_value;
	arg->stack = 0;
      } else {
	arg->loc = PARM_STACK;
	arg->line = s->n_desc;
	arg->stack = s->n_value;
      }
      arg->type = 0;
      arg->next = 0;
      {
	char tname[128];
	char *t = tname;
	
	c+=2;
	while ((*c) && (*c != '=')) {
	  *t++ = *c++;
	}
	*t = 0;
	t = type_resolve(tname);
	arg->type = type_typecode(t);
	if (wad_debug_mode & DEBUG_STABS) {
	  wad_printf("type_resolve '%s' -> '%s' (%d)\n", tname, t, arg->type);
	}
      }
      if (f->debug_args) {
	f->debug_lastarg->next = arg;
	f->debug_lastarg = arg;
      } else {
	f->debug_args = arg;
	f->debug_lastarg = arg;
	f->debug_nargs= 0;
      }
      f->debug_nargs++;
    }
  }
  return i;
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
wad_search_stab(void *sp, int size, char *stabstr, WadFrame *f) {
  Stab *s;
  int   ns;
  int   i;
  int   found = 0;

  char  *file, *lastfile = 0;

  char   srcfile[MAX_PATH];
  char   objfile[MAX_PATH];

  /* It appears to be necessary to clear the types table on each new stabs section */

  init_hash();

  if (!f->sym_name) return 0;

  s = (Stab *) sp;            /* Stabs data      */
  ns = size/sizeof(Stab);     /* number of stabs */

  srcfile[0] = 0;
  objfile[0] = 0;

  for (i = 0; i < ns; i++, s++) {
    if (wad_debug_mode & DEBUG_STABS) {
      /*      wad_printf("   %10d %10x %10d %10d %10d: '%s'\n", s->n_strx, s->n_type, s->n_other, s->n_desc, s->n_value, 
	      stabstr+s->n_strx); */
      
	     }
    if (s->n_type == N_LSYM) {
      stab_symbol(s,stabstr);
      continue;
    }
    if ((s->n_type == N_UNDF)) { /* && (s->n_desc >= 0)) { */
      /* New stabs section.  We need to be a little careful here. Do a recursive 
	 search of the subsection. */

      if (wad_search_stab(s+1,s->n_desc*sizeof(Stab), stabstr, f)) {
	return 1;
      }

      /* On solaris, each stabs section seems to increment the stab string pointer.  On Linux,
         the linker seems to do a certain amount of optimization that results in a single
         string table. */

#ifdef WAD_SOLARIS
      stabstr += s->n_value;     /* Update the string table location*/
#endif
      i += s->n_desc;
      s += s->n_desc;
      objfile[0] = 0;
      srcfile[0] = 0;
      continue;
    } else if (s->n_type == N_SO) {
      /* Source file specification */
      /* Look for directory */
      file = stabstr+s->n_strx;
      if (strlen(file) && (file[strlen(file)-1] == '/')) {
	wad_strcpy(srcfile,file);
      } else {
	wad_strcat(srcfile,file);
      }
      objfile[0] = 0;
      /* If we have a file match, we might be looking for a local symbol.   If so,
         we'll go ahead and set the srcfile field of the frame */

      /* We're going to check for a file match. Maybe we're looking for a local symbol */
      if (f->sym_file && strcmp(f->sym_file,file) == 0) {
	found = 1;
      }
      lastfile = file;
    } else if (s->n_type == N_OBJ) {
      /* Object file specifier */
      if (objfile[0]) {
	wad_strcat(objfile,"/");
      }
      wad_strcat(objfile,stabstr+s->n_strx);
    } else if (s->n_type == N_FUN) {
      if (match_stab_symbol(f->sym_name, stabstr+s->n_strx, f->sym_nlen)) {
	  if (!f->sym_file || (strcmp(f->sym_file,lastfile) == 0)) {
	    int n;
	    /* Go find debugging information for the function */
	    n = scan_function(s+1, stabstr, ns -i - 1, f);
	    f->loc_srcfile = wad_string_lookup(srcfile);
	    f->loc_objfile = wad_string_lookup(objfile);
	    return 1;
	  }
      }
    }
  }
  /* If found, but no other debugging information was filled in, go ahead and copy the
     source and objfile information */
  
  if ((found) && (!f->debug_check)) {
    f->loc_srcfile = wad_string_lookup(srcfile);
    f->loc_objfile = wad_string_lookup(objfile);
  }
  return found;
}




