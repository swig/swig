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
      nnodes++;
    }
    c = Getattr(c,"sym:nextSibling");
  }

  /* Convert arguments to default promotions */
  {
    int i;
    for (i = 0; i < nnodes; i++) {
      Parm *p = nodes[i].parms;
      while (p) {
	if (Getattr(p,"tmap:ignore")) {
	  p = Getattr(p,"tmap:ignore:next");
	  continue;
	}
	/* Get argument precedence level */
	String *prec = Getattr(p,"tmap:typecheck:precedence");
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

  /* Sort the declarations by argument types */
  {
    int i,j;
    for (i = 0; i < nnodes; i++) {
      for (j = i+1; (j < nnodes) && (nodes[j].argc == nodes[i].argc); j++) {
	Parm *p1 = nodes[i].parms;
	Parm *p2 = nodes[j].parms;
	int   differ = 0;
	//	Printf(stdout,"---- [%d,%d]\n", i,j);
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
	  differ = Strcmp(t1,t2);
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
	  Printf(stdout,"Ambiguous overloading.\n");
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




