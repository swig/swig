/* ----------------------------------------------------------------------------- 
 * overload.cxx
 *
 *     This file is used to analyze overloaded functions and methods.
 *     It looks at signatures and tries to gather information for
 *     building a dispatch function.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swigmod.h"

#define MAX_OVERLOAD 256

extern int emit_num_required(ParmList *);

/* -----------------------------------------------------------------------------
 * Swig_overload_rank()
 *
 * This function takes an overloaded declaration and creates a list that ranks
 * all overloaded methods in an order that can be used to generate a dispatch 
 * function.
 * ----------------------------------------------------------------------------- */

struct Overloaded {
  Node      *n;          /* Node                               */
  int        argc;       /* Argument count                     */
  ParmList  *parms;      /* Parameters used for overload check */
  int        error;      /* Ambiguity error                    */
};

List *
Swig_overload_rank(Node *n) {
  Overloaded  nodes[MAX_OVERLOAD];
  int         nnodes = 0;
  Node *o = Getattr(n,"sym:overloaded");
  Node *c;

  if (!o) return 0;

  c = o;
  while (c) {
    if (Strcmp(nodeType(c),"template") == 0) {
      c = Getattr(n,"sym:nextSibling");
      continue;
    }
    if (!Getattr(c,"error") && !Getattr(c,"feature:ignore")) {
      nodes[nnodes].n = c;
      nodes[nnodes].parms = Getattr(c,"wrap:parms");
      if (!nodes[nnodes].parms) nodes[nnodes].parms = Getattr(c,"parms");
      nodes[nnodes].argc = emit_num_required(nodes[nnodes].parms);
      nodes[nnodes].error = 0;
      nnodes++;
    }
    c = Getattr(c,"sym:nextSibling");
  }

  /* Sort the declarations by argument count */
  {
    int i,j;
    for (i = 0; i < nnodes; i++) {
      for (j = i+1; j < nnodes; j++) {
	if (nodes[i].argc > nodes[j].argc) {
	  Overloaded t = nodes[i];
	  nodes[i] = nodes[j];
	  nodes[j] = t;
	}
      }
    }
  }
  
  /* For declarations with the same argument count, we have to get
     precedence levels */
#if 0
  {
    int i,j;
    for (i = 0; i < (nnodes-1); i++) {
      if (nodes[i].argc == nodes[i+1].argc) {
	for (j = i; ((j < nnodes) && (nodes[j].argc == nodes[i].argc)); j++) {
	  Parm *p = nodes[i].parms;
	  while (p) {
	    if (Getattr(p,"tmap:ignore")) {
	      p = Getattr(p,"tmap:ignore:next");
	      continue;
	    }
	    /* Get argument precedence level */
	    String *prec = Getattr(p,"tmap:typecheck:precedence");
	    if (!prec) {
	      Printf(stdout,"Can't disambiguate '%s' %s\n", Getattr(nodes[i].n,"name"),
		     ParmList_str(Getattr(nodes[i].n,"parms")));
	    } 
	    
	    //	Printf(stdout,"%s. prec = '%s'\n", Getattr(p,"type"), prec); 
	    if (!prec) {
	      Setattr(p,"tmap:typecheck:precedence","0");
	    }
	    if (Getattr(p,"tmap:in:next")) {
	      p = Getattr(p,"tmap:in:next");
	    } else {
	      p = nextSibling(p);
	    }
	  }
	}
      }
    }
  }
#endif

  /* Sort the declarations by argument types */
  {
    int i,j;
    for (i = 0; i < nnodes-1; i++) {
      if (nodes[i].argc == nodes[i+1].argc) {
	for (j = i+1; (j < nnodes) && (nodes[j].argc == nodes[i].argc); j++) {
	  Parm *p1 = nodes[i].parms;
	  Parm *p2 = nodes[j].parms;
	  int   differ = 0;
	  while (p1 && p2) {
	    //	  Printf(stdout,"p1 = '%s', p2 = '%s'\n", Getattr(p1,"type"), Getattr(p2,"type"));
	    if (Getattr(p1,"tmap:ignore")) {
	      p1 = Getattr(p1,"tmap:ignore:next");
	      continue;
	    }
	    if (Getattr(p2,"tmap:ignore")) {
	      p2 = Getattr(p2,"tmap:ignore:next");
	      continue;
	  }
	    String *t1 = Getattr(p1,"tmap:typecheck:precedence");
	    String *t2 = Getattr(p2,"tmap:typecheck:precedence");
	    if ((!t1) && (!nodes[i].error)) {
	      Printf(stdout,"No typecheck rule defined for overloaded %s(%s) at argument '%s'\n", 
		     Getattr(nodes[i].n,"name"),ParmList_str(Getattr(nodes[i].n,"parms")),
		     SwigType_str(Getattr(p1,"type"),Getattr(p1,"name")));
	    } else if ((!t2) && (!nodes[j].error)) {
	      Printf(stdout,"No typecheck rule defined for overloaded %s(%s) at argument '%s'\n", 
		     Getattr(nodes[j].n,"name"),ParmList_str(Getattr(nodes[j].n,"parms")),
		     SwigType_str(Getattr(p2,"type"),Getattr(p2,"name")));
	    }
	    if (t1 && t2) differ = Strcmp(t1,t2);
	    else if (!t1 && t2) differ = 1;
	    else if (t2 && !t1) differ = -1;
	    if (differ > 0) {
	      Overloaded t = nodes[i];
	      nodes[i] = nodes[j];
	      nodes[j] = t;
	      break;
	    } else if ((differ == 0) && (Strcmp(t1,"0") == 0)) {
	      t1 = Getattr(p1,"type");
	      t2 = Getattr(p2,"type");
	      if (Strcmp(t1,t2) != 0) {
		differ = 1;
		break;
	      }
	    }
	    if (Getattr(p1,"tmap:in:next")) {
	      p1 = Getattr(p1,"tmap:in:next");
	    } else {
	      p1 = nextSibling(p1);
	    }
	    if (Getattr(p2,"tmap:in:next")) {
	      p2 = Getattr(p2,"tmap:in:next");
	    } else {
	      p2 = nextSibling(p2);
	    }
	  }
	  if (!differ) {
	    if (!nodes[j].error) {
	      Printf(stdout,"Overloaded %s(%s) is ambiguous\n",
		     Getattr(nodes[j].n,"name"), ParmList_str(Getattr(nodes[j].n,"parms")));
	      nodes[j].error = 1;
	    }
	  }
	}
      }
    }
  }
  List *result = NewList();
  {
    int i;
    for (i = 0; i < nnodes; i++) {
      Append(result,nodes[i].n);
      //      Printf(stdout,"[ %d ] %s\n", i, ParmList_str(nodes[i].parms));
      //      Swig_print_node(nodes[i].n);
    }
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * Swig_overload_dispatch()
 *
 * Generate a dispatch function.  argc is assumed to hold the argument count.
 * argv is the argument vector.
 * ----------------------------------------------------------------------------- */

String *
Swig_overload_dispatch(Node *n, int *maxargs) {
  int i,j;
  char tmp[256];
  *maxargs = 1;

  String *f = NewString("");

  /* Get a list of methods ranked by precedence values and argument count */
  List *dispatch = Swig_overload_rank(n);
  int   nfunc = Len(dispatch);

  /* Loop over the functions */

  for (i = 0; i < nfunc; i++) {
    Node *ni = Getitem(dispatch,i);
    Parm *pi = Getattr(ni,"wrap:parms");
    int num_required = emit_num_required(pi);
    int num_arguments = emit_num_arguments(pi);
    if (num_arguments > *maxargs) *maxargs = num_arguments;
    int varargs = emit_isvarargs(pi);    
    
    if (!varargs) {
      Printf(f,"if ((argc >= %d) && (argc <= %d)) {\n", num_required, num_arguments);
    } else {
      Printf(f,"if (argc >= %d) {\n", num_required);
    }

    Printf(f,"int _m = 1;\n");
    Printf(f,"int _v = 1;\n");

    j = 0;
    Parm *pj = pi;
    while (pj) {
      sprintf(tmp,"argv[%d]",j);
      if (Getattr(pj,"tmap:ignore")) {
	pj = Getattr(pj,"tmap:ignore:next");
	continue;
      }
      String *tm = Getattr(pj,"tmap:typecheck");
      if (tm) {
	Replaceid(tm,Getattr(pj,"lname"),"_v");
	Replaceall(tm,"$input", tmp);
	Printv(f,tm,"\n",NULL);
	Printf(f,"_m &= _v;\n");
      }
      Parm *pk = Getattr(pj,"tmap:in:next");
      if (pk) pj = pk;
      else pj = nextSibling(pj);
      j++;
    }
    Printf(f,"if (_m) {\n");
    Printf(f,"return %s($args);\n", Getattr(ni,"wrap:name"));
    Printf(f,"}\n");
    Printf(f,"}\n");
  }
  Delete(dispatch);
  return f;
}


