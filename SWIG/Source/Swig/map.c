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


typedef struct MatchObject {
  DOH     *ruleset;             /* Hash table of rules */
  DOHHash *p;                   /* Parameter on which checking starts */
  int  depth;                   /* Depth of the match  */
  struct MatchObject *next;     /* Next match object   */
} MatchObject;


static MatchObject *matchstack = 0;

/* -----------------------------------------------------------------------------
 * Swig_map_match()
 *
 * Perform a longest map match for a list of parameters and a set of mapping rules.
 * Returns the corresponding rule object and the number of parameters that were
 * matched.
 * ----------------------------------------------------------------------------- */

DOH *
Swig_map_match(DOHHash *ruleset, DOHString_or_char *rulename, DOHHash *parms, int *nmatch)
{
  DOHHash *nameset;
  MatchObject *mo;

  DOH    *bestobj = 0;
  int    bestdepth = -1;

  /* Get the nameset */
  nameset = Getattr(ruleset,rulename);
  if (!nameset) return 0;

  mo = (MatchObject *) malloc(sizeof(MatchObject));
  mo->ruleset = nameset;
  mo->depth = 0;
  mo->p = parms;
  mo->next = 0;

  matchstack = mo;

  /* Loop over all candidates until we find the best one */

  while (matchstack) {
    DOHHash   *rs;
    DOHHash   *p;
    int        depth = 0;
    DOH       *obj;
    DOHString *key;
    DOHString *ty;
    DOHString *name;
    DOHString *nm;
    int       matched = 0;

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
      key = NewStringf("-%s",ty);
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
      Printf(key,"%s-%s",name,ty);
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
      int i, j, k, n;
      int ncheck;
      DOHString  *ntype;

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
	Printf(key,"-%s",ntype);
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
	Printf(key,"%s-%s",name,ntype);
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
  }
  return bestobj;
}

#ifdef OLD

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

#endif




