/* ----------------------------------------------------------------------------- 
 * tree.c
 *
 *     This file provides some general purpose functions for manipulating 
 *     parse trees.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"

static char cvsroot[] = "$Header$";

/* Hash table mapping tag names to handler functions */
static Hash   *rules = 0;
static int     debug_emit = 0;

/* -----------------------------------------------------------------------------
 * Swig_next()
 * Swig_prev()
 *
 * Return next/prev node in a parse tree
 * ----------------------------------------------------------------------------- */

DOH *Swig_next(DOH *obj) {
  return Getattr(obj,"next");
}

DOH *Swig_prev(DOH *obj) {
  return Getattr(obj,"prev");
}

void Swig_debug_emit(int n) {
  debug_emit = n;
}

/* -----------------------------------------------------------------------------
 * Swig_dump_tags()
 *
 * Dump the tag structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

void 
Swig_dump_tags(DOH *obj, DOH *root) {
  DOH *croot, *newroot;
  DOH *cobj;

  if (!root) croot = NewString("");
  else croot = root;

  while (obj) {
    Printf(stdout,"%s . %s\n", croot, Getattr(obj,"tag"));
    cobj = Getattr(obj,"child");
    if (cobj) {
      newroot = NewStringf("%s . %s",croot,Getattr(obj,"tag"));
      Swig_dump_tags(cobj,newroot);
      Delete(newroot);
    }
    obj = Swig_next(obj);
  }
  if (!root)
    Delete(croot);
}


/* -----------------------------------------------------------------------------
 * Swig_dump_tree()
 *
 * Dump the tree structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

static int indent_level = 0;

static void print_indent(int l) {
  int i;
  for (i = 0; i < indent_level; i++) {
    fputc(' ', stdout);
  }
  if (l) {
    fputc('|', stdout);
    fputc(' ', stdout);
  }
}

void 
Swig_dump_tree(DOH *obj) {
  DOH *k;
  DOH *cobj;

  while (obj) {
    print_indent(0);
    Printf(stdout,"+++ %s ----------------------------------------\n", Getattr(obj,"tag"));
      
    k = Firstkey(obj);
    while (k) {
      if ((Cmp(k,"tag") == 0) || (Cmp(k,"child") == 0) ||
	  (Cmp(k,"parent") == 0) || (Cmp(k,"next") == 0) ||
	  (Cmp(k,"prev") == 0)) {
	/* Do nothing */
      } else if (Cmp(k,"parms") == 0) {
	print_indent(2);
	Printf(stdout,"%-12s - %s\n", k, ParmList_protostr(Getattr(obj,k)));
      } else {
	DOH *o;
	char *trunc = "";
	print_indent(2);
	o = Str(Getattr(obj,k));
	if (Len(o) > 40) {
	  trunc = "...";
	}
	Printf(stdout,"%-12s - \"%(escape)-0.40s%s\"\n", k, o, trunc);
	Delete(o);
      }
      k = Nextkey(obj);
    }
    cobj = Getattr(obj,"child");
    if (cobj) {
      indent_level += 6;
      Printf(stdout,"\n");
      Swig_dump_tree(cobj);
      indent_level -= 6;
    } else {
      print_indent(1);
      Printf(stdout,"\n");
    }
    obj = Swig_next(obj);
  }
}


/* -----------------------------------------------------------------------------
 * Swig_add_rule()
 *
 * Adds a new rule to the tree walking code.
 * ----------------------------------------------------------------------------- */

void
Swig_add_rule(const String_or_char *name,  int (*action)(DOH *node, void *clientdata))
{
  if (!rules) rules = NewHash();
  if (action)
    Setattr(rules,name,NewVoid((void *) action,0));
  else
    Delattr(rules,name);

  if (debug_emit) {
    Printf(stderr,"Swig_add_rule    : '%s' -> %x\n", name, action);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_add_rules()
 *
 * Add a complete set of rules to the rule system
 * ----------------------------------------------------------------------------- */

void
Swig_add_rules(SwigRule ruleset[]) {
  int i = 0;
  while (ruleset[i].name) {
    Swig_add_rule(ruleset[i].name, ruleset[i].action);
    i++;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_clear_rules()
 *
 * Clears all of the existing rules
 * ----------------------------------------------------------------------------- */

void
Swig_clear_rules()
{
  if (rules) Delete(rules);
  rules = NewHash();
  if (debug_emit) {
    Printf(stderr,"Swig_clear_rules :\n");
  }

}

/* -----------------------------------------------------------------------------
 * Swig_dump_rules()
 * 
 * Print out debugging information for the rules
 * ----------------------------------------------------------------------------- */

void
Swig_dump_rules() {
  String *key;
  Printf(stdout,"SWIG emit rules:::\n");
  if (!rules) {
    Printf(stdout,"    No rules defined.\n");
    return;
  }
  key = Firstkey(rules);
  while (key) {
    Printf(stdout,"    '%-15s' -> %x\n", key, GetVoid(rules,key));
    key = Nextkey(rules);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_tag_check()
 *
 * Checks the tag name of an object taking into account namespace issues.
 * For example, a check of "function" will match any object with a tag
 * of the form "xxx:function" whereas a check of "c:function" will check
 * for a more exact match.   Returns 1 if a match is found, 0 otherwise
 * ----------------------------------------------------------------------------- */

int
Swig_tag_check(DOH *obj, String_or_char *tagname) {
  String *tag;
  char   *tc;
  char   *tnc;
  tag = Getattr(obj,"tag");
  assert(tag);
  
  tc = Char(tag);
  tnc = Char(tagname);
  
  while (tnc) {
    if (strcmp(tc,tnc) == 0) return 1;
    tnc = strchr(tnc,':');
    if (tnc) tnc++;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_set_callback()
 *
 * Sets a parser callback function for a node.
 * ----------------------------------------------------------------------------- */
void
Swig_set_callback(DOH *obj, void (*cb)(void *clientdata), void *clientdata) {
  SetVoid(obj,"-callback-",(void *)cb);
  if (clientdata)
    SetVoid(obj,"-callbackarg-", clientdata);
}

/* -----------------------------------------------------------------------------
 * Swig_set_trace()
 *
 * Sets a tracing function on a parse tree node.  Returns the old tracing
 * function (if any).
 * ----------------------------------------------------------------------------- */

void (*Swig_set_trace(DOH *obj, void (*cb)(DOH *, DOH *), DOH *arg))(DOH *, DOH *) {
  void (*old)(DOH *,DOH *);
  old = (void (*)(DOH *, DOH *)) GetVoid(obj,"-trace-");
  SetVoid(obj,"-trace-", (void *) cb);
  if (arg)
    Setattr(obj,"-tracearg-", arg);
  return old;
}

/* -----------------------------------------------------------------------------
 * Swig_remove_trace()
 *
 * Removes the tracing function from a parse tree node
 * ----------------------------------------------------------------------------- */

void
Swig_remove_trace(DOH *obj) {
  Delattr(obj,"-trace-");
  Delattr(obj,"-tracearg-");
}


/* -----------------------------------------------------------------------------
 * Swig_node_temporary()
 *
 * Sets a node as being temporary (deleted immediately after it is emitted)
 * ----------------------------------------------------------------------------- */

void Swig_node_temporary(DOH *obj) {
  SetInt(obj,"-temp-",1);
}

/* -----------------------------------------------------------------------------
 * Swig_node_ignore()
 *
 * Causes a node to be ignored
 * ----------------------------------------------------------------------------- */

void Swig_node_ignore(DOH *obj) {
  SetInt(obj,"-ignore-",1);
}

/* -----------------------------------------------------------------------------
 * int Swig_emit()
 *
 * This function calls the handler function (if any) for an object.
 * ----------------------------------------------------------------------------- */

int
Swig_emit(DOH *obj, void *clientdata) {
  DOH *tag;
  DOH *actionobj;
  char  *tc;
  int (*action)(DOH *obj, void *clientdata);
  void (*callback)(void *clientdata);
  void (*tracefunc)(DOH *obj, DOH *arg);
  int  ret;

  assert(obj);

  if (!rules) {
    Printf(stderr,"No rules defined in Swig_emit()!\n");
    return SWIG_ERROR;
  }
  if (obj) {
    if (Getattr(obj,"-ignore-")) return SWIG_OK;
    tag = Getattr(obj,"tag");
    assert(tag);
    tc = Char(tag);
    while(tc) {
      actionobj = Getattr(rules,tc);
      if (actionobj) {
	if (debug_emit) {
	  Printf(stderr,"Swig_emit        : Matched tag '%s' -> rule '%s'\n", tag, tc);
	}
	/* Check for user tracing -- traces occur before any handlers are called */
	tracefunc = (void (*)(DOH *, DOH *)) GetVoid(obj,"-trace-");
	if (tracefunc) {
	  DOH *tobj = Getattr(obj,"-tracearg-");
	  (*tracefunc)(obj,tobj);
	}
	action = (int (*)(DOH *, void *)) Data(actionobj);
	ret = (*action)(obj,clientdata);
	/* Check for a parser callback */
	callback = (void (*)(void *clientdata)) GetVoid(obj,"-callback-");
	if (callback) {
	  void *cbarg;
	  cbarg = GetVoid(obj,"-callbackarg-");
	  (*callback)(cbarg);
	  Delattr(obj,"-callback-");
	  Delattr(obj,"-callbackarg-");
	}
	return ret;
      } else {
	tc = strchr(tc,':');
	if (tc) tc++;
      }
    }
    actionobj = Getattr(rules,"*");
    if (actionobj) {
      if (debug_emit) {
	Printf(stderr,"Swig_emit        : Matched tag '%s' -> rule '*'\n", tag);
      }
      /* Check for user tracing -- traces occur before any handlers are called */
      tracefunc = (void (*)(DOH *, DOH *)) GetVoid(obj,"-trace-");
      if (tracefunc) {
	DOH *tobj = Getattr(obj,"-tracearg-");
	(*tracefunc)(obj,tobj);
      }
      action = (int (*)(DOH *, void *)) Data(actionobj);
      ret = (*action)(obj,clientdata);
      /* Check for a parser callback */
      callback = (void (*)(void *clientdata)) GetVoid(obj,"-callback-");
      if (callback) {
	void *cbarg;
	cbarg = GetVoid(obj,"-callbackarg-");
	(*callback)(cbarg);
	Delattr(obj,"-callback-");
	Delattr(obj,"-callbackarg-");
      }
      return ret;
    }
    if (debug_emit) {
      Printf(stderr,"Swig_emit        : No rule defined for tag '%s'\n", tag);
    }
  }
  return SWIG_NORULE;
}

/* -----------------------------------------------------------------------------
 * Swig_emit_all()
 *
 * Emit all of the nodes at this level.
 * ----------------------------------------------------------------------------- */

int 
Swig_emit_all(DOH *obj, void *clientdata) {
  int ret;
  while (obj) {
    ret = Swig_emit(obj,clientdata);
    if (ret < 0) return ret;
    obj = Swig_next(obj);
  }
  return SWIG_OK;
}
 
/* -----------------------------------------------------------------------------
 * Swig_node_cut()
 *
 * This function cuts an object out of a parse tree.  To do this, the object
 * MUST be properly initialized with "next", "prev", and "parent" attributes.
 * ----------------------------------------------------------------------------- */

void Swig_node_cut(DOH *obj) {
  DOH *parent;
  DOH *next;
  DOH *prev;

  parent = Getattr(obj,"parent");
  assert(parent);
  next = Getattr(obj,"next");
  prev = Getattr(obj,"prev");

  DohIncref(obj);            /* Make sure object doesn't go away */
  Delattr(obj,"parent");     /* Disassociate from my parent */

  if (!next && !prev) {
    /* Well, this is a single child.  Guess we'll just tell the parent that their child is gone */
    Delattr(parent,"child");
    return;
  }

  /* If no next node, then this must be at the end of a list */
  if (!next) {
    Delattr(prev,"next");      /* Break the 'next' link in the previous node */
    Delattr(obj,"prev");       /* Break my link back to the previous object */
    return;
  }

  /* No previous node. This must be the beginning of a list */
  if (!prev) {
    Delattr(next,"prev");          /* Break the 'prev' link of the next node */
    Setattr(parent,"child",next);  /* Update parent to point at next node */
    Delattr(obj,"next");           /* Break my link to the next object */
    return;
  }

  /* In the middle of a list someplace */
  Setattr(prev,"next",next);       /* Update previous node to my next node */
  Setattr(next,"prev",prev);       /* Update next node to my previous node */
  Delattr(obj,"next");
  Delattr(obj,"prev");             
  return;
}

/* -----------------------------------------------------------------------------
 * Swig_node_insert()
 *
 * Inserts a node after a given node.  The node to be inserted should be 
 * isolated (no parent, no siblings, etc...).
 * ----------------------------------------------------------------------------- */

void
Swig_node_insert(DOH *node, DOH *newnode) {
  DOH *next; 
  next = Getattr(node,"next");

  if (next) {
    Setattr(newnode,"next", next);
    Setattr(next,"prev", newnode);
  }
  Setattr(node,"next",newnode);
  Setattr(newnode,"prev", node);
  Setattr(newnode,"parent", Getattr(node,"parent"));
}

/* -----------------------------------------------------------------------------
 * Swig_count_nodes()
 *
 * Count number of nodes at this level
 * ----------------------------------------------------------------------------- */

int Swig_count_nodes(DOH *node) {
  int n = 0;
  while (node) {
    n++;
    node = Getnext(node);
  }
  return n;
}

  



