/* ----------------------------------------------------------------------------- 
 * tree.c
 *
 *     This file provides some general purpose functions for manipulating
 *     parse trees. Note: This is primarily a debugging module at this
 *     point.  Maybe it will evolve into something else later.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"

static char cvsroot[] = "$Header$";

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
    Printf(stdout,"%s.%s\n", croot, Getattr(obj,"tag"));
    cobj = Getattr(obj,"child");
    if (cobj) {
      newroot = NewStringf("%s.%s",croot,Getattr(obj,"tag"));
      Swig_dump_tags(cobj,newroot);
      Delete(newroot);
    }
    obj = Getattr(obj,"sibling");
  }
  if (!root)
    Delete(croot);
}

/* -----------------------------------------------------------------------------
 * Swig_add_rule()
 *
 * Adds a new rule to a ruleset.  Rules are specified using a subset of CSS2
 * (Cascading Style Sheet) syntax.  For example:
 *
 *      "function"             - Applies to a function
 *      "class function"       - Applies to any function inside a class
 *      "class > function"     - Applies to an immediate child.
 *      "foo * bar"            - Wildcard. Matches zero or more tags in between.
 *
 * Note: "foo * bar" is the same as "foo bar".
 * ----------------------------------------------------------------------------- */

void 
Swig_add_rule(DOH *ruleset, DOH *ruleobj, DOH *action) {
  DOH *rule, *rulelist, *nextruleset, *r, *robj;
  int c, i, ntags = 0, lastid = 0, isid = 0;
  rule = NewString(ruleobj);
  /* Split the rule into a list */
  rulelist = NewList();
  Seek(rule,0,SEEK_SET);
  r = NewString("");
  while ((c = Getc(rule)) != EOF) {
    if (c == ' ') {
      if (lastid && isid) {
	Insert(rulelist,0,"*");
	ntags++;
      }
      ntags++;
      Insert(rulelist,0,r);
      r = NewString("");
      lastid = isid;
      isid = 0;
    } else if (isalnum(c)) {
      isid = 1;
      Putc(c,r);
    } else {
      Putc(c,r);
    }
  }
  if (lastid && isid) {
    Insert(rulelist,0,"*");
    ntags++;
  }
  ntags++;
  Insert(rulelist,0,r);

  nextruleset = ruleset;
  /* Now, try to insert the rule into the table */
  for (i = 0; i < ntags; i++) {
    ruleset = nextruleset;
    r = Getitem(rulelist,i);
    if (Cmp(r,">")) {
      robj = Getattr(ruleset,r);     /* Get a rule entry (if any) */
      if (robj) {
	/* If the rule already exists, extract the next ruleset in case we need it */
	nextruleset = Getattr(robj,"ruleset");
      } else {
	/* No rule exists.  Create an entry and store it in the ruleset */
	robj = NewHash();
	nextruleset = NewHash();
	Setattr(robj,"ruleset",nextruleset);
	Setattr(ruleset, r, robj);
      }
    }
  }
  
  /* For the last rule, insert the action into robj */
  Setattr(robj,"action",action);
    
  /* Printf(stdout,"%s\n", rulelist); */
  Delete(rule);
  Delete(rulelist);
}

/* -----------------------------------------------------------------------------
 * Swig_match_rule()
 *
 * Given a ruleset and a list of nodes, this function tries to find the longest
 * matching rule.  
 * ----------------------------------------------------------------------------- */

DOH *
Swig_match_rule(DOH *ruleset, DOH *nodelist)
{
  DOH *tag, *action = 0, *robj = 0, *wobj = 0, *bestobj = 0, *candidates;
  int i, ntags, bestlen = 0, wildcard = 0;
  ntags = Len(nodelist);
  if (ntags <= 0) return 0;

  i = ntags - 1;

  while (i >= 0) {
    tag = Getattr(Getitem(nodelist,i),"tag");

    /* See if there is any matching tag at all */
    robj = Getattr(ruleset,tag);
    if (robj) {
      wobj = 0;
      wildcard = 0;
    } else if (!robj && wildcard) {
      robj = wobj;
      wildcard++;
    } else if (!robj) {
      robj = Getattr(ruleset,"*");
      if (robj) {
	wildcard = 1;
	wobj = robj;
      }
    }
    if (!robj)
      return bestobj;
  
    /* Got at least one match. Search for others */
    action = Getattr(robj,"action");
    if (action) {
      bestobj = action;
    }
    if (wildcard != 1)
      i--;
    ruleset = Getattr(robj,"ruleset");
  }
  return bestobj;
}

/* -----------------------------------------------------------------------------
 * Swig_emit_rules()
 *
 * Given a node, this function fires all of the rules for its siblings by
 * invoking a user-supplied callback function.  The ruleset is a set of
 * handling rules as created by Swig_add_rule.  context is a list containing
 * the context of node (all enclosing parent nodes).
 *
 * Note: child nodes are not processed (as a handler function might want to
 * take special action or ignore the children).
 * ----------------------------------------------------------------------------- */

void 
Swig_emit_rules(DOH *ruleset, DOH *context, DOH *node, 
	  int (*actionhandler)(DOH *ruleset, DOH *context, DOH *node, DOH *action)) {
  
  DOH *act;
  DOH *next;

  while (node) {
    Append(context,node);
    act = Swig_match_rule(ruleset,context);
    if (act) {
      (*actionhandler)(ruleset,context,node,act);
    }
    Delitem(context, DOH_END);
    node = Getattr(node,"sibling");
  }
}

#ifdef TEST

int main() {
  DOH *a;
  DOH *tags;
  DOH *action = NewString("*action*");
  DOH *ruleset = NewHash();
  Swig_add_rule(ruleset,"function","*function*");
  Swig_add_rule(ruleset,"class *","*memberfunction*");
  Swig_add_rule(ruleset,"foo","*foo*");
  tags = NewList();
  Append(tags,"includefile");
  Append(tags,"class");
  Append(tags,"function");
  Append(tags,"foo");
  a = Swig_match_rule(ruleset, tags);
  if (a)
    Printf(stdout,"%s\n", a);

}

#endif
