/* -----------------------------------------------------------------------------
 * map.c
 *
 *     This file provides support for defining %map rules that match lists of
 *     parameters to objects defining code generation rules.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

#include "swig.h"

/* -----------------------------------------------------------------------------
 * Synopsis
 *
 * One of the biggest problems in wrapper generation is that of defining
 * the handling of various datatypes and function parameters.   This module
 * provides support for a generic object known as a 'mapping rule' that is
 * defined using the %map directive like this:
 *
 *   %map rulename(typelist) {
 *        vars;
 *        rule1 { ... }
 *        rule2 { ... }
 *        rule3 { ... }
 *        rule4 { ... }
 *        ...
 *   }
 *
 * A mapping rule is somewhat similar to a class or structure definition.  The
 * "vars" field is a list of variable declarations that will be local to the
 * mapping rule when it is used.   The "rulen" fields simply define code
 * fragments and other information that language specific modules can examine
 * for their own nefarious purposes.
 * 
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * Swig_map_add()
 *
 * Adds a new mapping rule.  The parms input to this function should be a
 * properly constructed parameter list with associated attributes.  The rules
 * field can technically be any valid object.
 *
 * The structure of how data is stored is as follows:
 *
 *    ruleset (hash)
 *    --------------
 *       rulename ------>  nameset (hash)
 *                         --------------
 *                         parm1   ---------> rule (hash)
 *                                            -------------
 *                                            parm2  -----------> rule (hash)
 *                                            *obj*  --> obj
 *                           
 *
 * For multiple arguments, we end up building a large tree of hash tables.
 * The object will be stored in the *obj* attribute of the last hash table.
 * ----------------------------------------------------------------------------- */

void
Swig_map_add(DOHHash *ruleset, DOHString_or_char *rulename, DOHHash *parms, DOH *obj)
{
     
  DOHHash *nameset;
  DOHHash *p, *n;
  /* Locate the appropriate nameset */
  
  nameset = Getattr(ruleset,rulename);
  if (!nameset) {
    /* Hmmm.  First time we've seen this.  Let's add it to our mapping table */
    nameset = NewHash();
    Setattr(ruleset,rulename,nameset);
  }
  
  /* Now, we walk down the parms list and create a series of hash tables */
  
  p = parms;
  n = nameset;
  while (p) {
    DOHString *ty, *name, *key;
    DOHHash *nn;
    ty = Getattr(p,"type");
    name = Getattr(p,"name");
    
    /* Create a hash table key */
    
    key = NewStringf("%s-%s",name,ty);

    /* See if there is already a entry with this type in the table */
    nn = Getattr(n,key);
    if (!nn) {
      /* No.  Go ahead and create it */
      nn = NewHash();
      Setattr(n,key,nn);
    }
    Delete(key);
    n = nn;
    p = Swig_next(p);
  }

  /* No more parameters.  At this point, n points to the very last hash table in our search.
     We'll stick our object there */

  Setattr(n,"*obj*",obj);
  return;
}

/* -----------------------------------------------------------------------------
 * Swig_map_match()
 *
 * Perform a longest map for a list of parameters and a set of mapping rules.
 * Returns the corresponding rule object and the number of parameters that
 * were matched.
 * ----------------------------------------------------------------------------- */

/* Internal function used for recursively searching rulesets */
static DOH *
Swig_map_match_internal(DOHHash *nameset, DOHHash *parms, int *nmatch) {
  DOHHash *nn1, *nn2;
  DOHString *ty;
  DOHString *name;
  DOHString *key;
  int    mlen1 = 0, mlen2 = 0, bestlen = 0;
  DOH    *obj1 = 0, *obj2 = 0;
  DOH    *bestobj, *bestn;
  DOHHash *nextp;

  if (!parms) {
    bestobj = Getattr(nameset,"*obj*");
    if (bestobj) *nmatch++;
    return bestobj;
  }

  ty = Getattr(parms,"type");
  name = Getattr(parms,"name");
  key = NewStringf("%s-%s",name,ty);

  /* See if there is an exact name match */
  nn1 = Getattr(nameset,key);
  if (nn1) {
    mlen1++;
    obj1 = Swig_map_match_internal(nn1,Swig_next(parms), &mlen1);
  }

  /* See if there is a generic name match */
  Clear(key);
  Printf(key,"-%s",ty);
  nn2 = Getattr(nameset,key);
  if (nn2) {
    mlen2++;
    obj2 = Swig_map_match_internal(nn2, Swig_next(parms), &mlen2);
  }
  /* Pick the best match.  Note: an exact name match is preferred */
  if (obj1 && obj2) {
    if (mlen2 > mlen1) {
      bestlen = mlen2;
      bestobj = obj2;
    } else {
      bestlen = mlen1;
      bestobj = obj1;
    }
  } else if (obj1) {
    bestobj = obj1;
    bestlen = mlen1;
  } else if (obj2) {
    bestobj = obj2;
    bestlen = mlen2;
  }
  if (!bestobj) {
    bestobj = Getattr(nameset,"*obj*");
    if (bestobj) bestlen = 1;
  }
  Delete(key);
  *nmatch = *nmatch + bestlen;
  return bestobj;
}

DOH *
Swig_map_match(DOHHash *ruleset, DOHString_or_char *rulename, DOHHash *parms, int *nmatch)
{
  DOHHash *nameset;
  int      mlen = 0;
  DOH     *best;

  /* Get the nameset */
  nameset = Getattr(ruleset,rulename);
  if (!nameset) return 0;

  best = Swig_map_match_internal(nameset,parms,&mlen);
  *nmatch = mlen;
  return best;
}





