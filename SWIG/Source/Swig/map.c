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

static char cvsroot[] = "$Header$";

#include "swig.h"

/* -----------------------------------------------------------------------------
 * Synopsis
 *
 * One of the problems in creating wrappers is that of defining rules for
 * managing various datatypes and function parameters.   In SWIG1.1,
 * this sort of customization was managed using a mechanism known as 
 * "typemaps".   This module generalizes the idea even further and provides
 * generic set of functions that can be used to define and match rules
 * that are associated with lists of datatypes.
 *
 * The functions in this file are intended to be rather generic.  They are only
 * responsible for the storage and matching of rules.   Other parts of the
 * code can use these to implement typemaps, argmaps, or anything else.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * Swig_map_add_parmrule()
 *
 * Adds a new mapping rule for a list of parameters. The parms input to this 
 * function should be a properly constructed parameter list with associated
 * attributes (type and name).  The 'obj' attribute can be any DOH object.
 *
 * The structure of how data might be stored is as follows:
 *
 *    ruleset (hash)
 *    --------------
 *    parm1   ---------> rule (hash)
 *                       -------------
 *                       parm2  -----------> rule (hash)
 *                       *obj*  --> obj      ------------
 *                                           parm3
 *                                           *obj* -->obj
 *                           
 * For multiple arguments, we end up building a large tree of hash tables.
 * The object will be stored in the *obj* attribute of the last hash table.
 * ----------------------------------------------------------------------------- */

void
Swig_map_add_parmrule(Hash *ruleset, Hash *parms, DOH *obj)
{
  Hash *p, *n;

  /* Walk down the parms list and create a series of hash tables */
  p = parms;
  n = ruleset;

  while (p) {
    String *ty, *name, *key;
    Hash *nn;
    ty = Getattr(p,"type");
    name = Getattr(p,"name");
    
    /* Create a hash table key */
    
    key = NewStringf("*map:%s-%s",name,ty);

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
}

/* -----------------------------------------------------------------------------
 * Swig_map_add_typerule()
 *
 * Adds a rule for a single type and name.
 * ----------------------------------------------------------------------------- */

void
Swig_map_add_typerule(Hash *ruleset, DOH *type, String_or_char *name, DOH *obj) {
  Hash *p;

  p = NewHash();
  Setattr(p,"type",type);
  if (name)
    Setattr(p,"name", name);
  
  Swig_map_add_parmrule(ruleset,p,obj);
  Delete(p);
}


typedef struct MatchObject {
  Hash    *ruleset;             /* Hash table of rules */
  Hash    *p;                   /* Parameter on which checking starts */
  int      depth;               /* Depth of the match  */
  struct MatchObject *next;     /* Next match object   */
} MatchObject;


static MatchObject *matchstack = 0;

/* -----------------------------------------------------------------------------
 * Swig_map_match_parms()
 *
 * Perform a longest map match for a list of parameters and a set of mapping rules.
 * Returns the corresponding rule object and the number of parameters that were
 * matched.
 *
 * Note: If the ruleset has a 'parent' attribute, this function will walk its
 * way up and try to find a match.  This can be used to implement scoped
 * mappings.
 * ----------------------------------------------------------------------------- */

DOH *
Swig_map_match_parms(Hash *ruleset, Hash *parms, int *nmatch)
{
  MatchObject *mo;

  DOH    *bestobj = 0;
  int    bestdepth = -1;

  *nmatch = 0;

  mo = (MatchObject *) malloc(sizeof(MatchObject));
  mo->ruleset = ruleset;
  mo->depth = 0;
  mo->p = parms;
  mo->next = 0;

  matchstack = mo;

  /* Loop over all candidates until we find the best one */

  while (matchstack) {
    Hash   *rs;
    Hash   *p;
    int     depth = 0;
    DOH    *obj;
    String *key;
    String *ty;
    String *name;
    String *nm;
    int     matched = 0;

    mo = matchstack;
    /* See if there is a match at this level */
    rs = mo->ruleset;
    obj = Getattr(rs,"*obj*");
    if (obj) {
      if (mo->depth > bestdepth) {
	bestdepth = mo->depth;
	bestobj = obj;
      }
    }
    p = mo->p;

    /* No more parameters.  Oh well */
    if (!p) {
      matchstack = mo->next;
      free(mo);
      continue;
    }

    /* Generate some keys for checking the next parameter */

    depth = mo->depth;
    name = Getattr(p,"name");
    ty = Getattr(p,"type");


    if (!SwigType_isarray(ty)) {
      key = NewStringf("*map:-%s",ty);
      /* See if there is a generic name match for this type */
      nm = Getattr(rs,key);
      if (nm) {
	/* Yes! Add to our stack. Just reuse mo for this */
	mo->ruleset = nm;
	mo->p = Swig_next(p);
	mo->depth++;
	mo = 0;
	matched++;
      }
      
      /* See if there is a specific name match for this type */
      Clear(key);
      Printf(key,"*map:%s-%s",name,ty);
      nm = Getattr(rs,key);
      if (nm) {
	if (!mo) {
	  mo = (MatchObject *) malloc(sizeof(MatchObject));
	  mo->next = matchstack;
	  matchstack = mo;
	}
	mo->ruleset = nm;
	mo->p = Swig_next(p);
	mo->depth = depth+1;
	matched++;
      }
      Delete(key);
    } else {
      /* The next parameter is an array.  This is pretty nasty because we have to do a bunch of checks
         related to array indices */

      int ndim;
      int i, j, n;
      int ncheck;
      String  *ntype;

      key = NewString("");

      /* Drop the mo record.  This is too complicated */
      matchstack = mo->next;
      free(mo);
      mo = 0;

      /* Get the number of array dimensions */
      ndim = SwigType_array_ndim(ty);

      /* First, we test all of the generic-unnamed parameters */
      ncheck = 1 << ndim;

      j = ncheck-1;
      for (i = 0; i < ncheck; i++, j--) {
	int k = j;
	ntype = Copy(ty);
	for (n = 0; n < ndim; n++, k = k >> 1) {
	  if (k & 1) {
	    SwigType_array_setdim(ntype,n,"");
	  }
	}
	Clear(key);
	Printf(key,"*map:-%s",ntype);
	Printf(stdout,"matcharray : %s\n", key);
	nm = Getattr(rs,key);
	if (nm) {
	  mo = (MatchObject *) malloc(sizeof(MatchObject));
	  mo->ruleset = nm;
	  mo->p = Swig_next(p);
	  mo->depth = depth+1;
	  mo->next = matchstack;
	  matchstack = mo;
	  matched++;
	  mo = 0;
	}
	Delete(ntype);
      }

      /* Next check all of the named parameters */
      ncheck = 1 << ndim;

      j = ncheck-1;
      for (i = 0; i < ncheck; i++, j--) {
	int k = j;
	ntype = Copy(ty);
	for (n = 0; n < ndim; n++, k = k >> 1) {
	  if (k & 1) {
	    SwigType_array_setdim(ntype,n,"");
	  }
	}
	Clear(key);
	Printf(key,"*map:%s-%s",name,ntype);
	Printf(stdout,"matcharray : %s\n", key);
	nm = Getattr(rs,key);
	if (nm) {
	  mo = (MatchObject *) malloc(sizeof(MatchObject));
	  mo->ruleset = nm;
	  mo->p = Swig_next(p);
	  mo->depth = depth+1;
	  mo->next = matchstack;
	  matchstack = mo;
	  matched++;
	  mo = 0;
	}
	Delete(ntype);
      }
      Delete(key);
    }
    if ((!matched) && mo) {
      matchstack = mo->next;
      free(mo);
    }
  }
  if (bestobj) {
    *nmatch = bestdepth;
  } else {
    /* If there is no match at all.  I guess we can check for a default type */
    DOH  *rs;
    String *key;
    String *dty = SwigType_default(Getattr(parms,"type"));
    key = NewStringf("*map:-%s",dty);
    
    rs = Getattr(ruleset,key);
    if (rs) {
      bestobj = Getattr(rs,"*obj*");
      if (bestobj) *nmatch = 1;
    }
    Delete(key);
    Delete(dty);
  }
  if (!bestobj) {
    DOH *prules = Getattr(ruleset,"parent");
    if (prules) {
      bestobj = Swig_map_match_parms(prules,parms,nmatch);
    }
  }
  return bestobj;
}

/* -----------------------------------------------------------------------------
 * Swig_map_match_type()
 *
 * Match a rule for a single type
 * ----------------------------------------------------------------------------- */

DOH *
Swig_map_match_type(Hash *ruleset, DOH *type, String_or_char *name) {
  Hash *p;
  DOH     *obj;
  int nmatch;

  p = NewHash();
  Setattr(p,"type",type);
  if (name)
    Setattr(p,"name",name);

  obj = Swig_map_match_parms(ruleset,p,&nmatch);
  Delete(p);
  return obj;
}





