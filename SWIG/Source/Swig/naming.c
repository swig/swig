/* ----------------------------------------------------------------------------- 
 * naming.c
 *
 *     Functions for generating various kinds of names during code generation
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_naming_c[] = "$Header$";

#include "swig.h"
#include "cparse.h"
#include "swigkeys.h"
#include <ctype.h>

/* Hash table containing naming data */

static Hash *naming_hash = 0;

#if 0
#define SWIG_DEBUG 
#endif

/* -----------------------------------------------------------------------------
 * Swig_name_register()
 *
 * Register a new naming format.
 * ----------------------------------------------------------------------------- */

void
Swig_name_register(const String_or_char *method, const String_or_char *format) {
  if (!naming_hash) naming_hash = NewHash();
  Setattr(naming_hash,method,format);
}

void
Swig_name_unregister(const String_or_char *method) {
  if (naming_hash) {
    Delattr(naming_hash,method);
  }
}

static int name_mangle(String *r) {
  char  *c;
  int    special;
  special = 0;
  Replaceall(r,"::","_");
  c = Char(r);
  while (*c) {
    if (!isalnum((int) *c) && (*c != '_')) {
      special = 1;
      switch(*c) {
      case '+':
	*c = 'a';
	break;
      case '-':
	*c = 's';
	break;
      case '*':
	*c = 'm';
	break;
      case '/':
	*c = 'd';
	break;
      case '<':
	*c = 'l';
	break;
      case '>':
	*c = 'g';
	break;
      case '=':
	*c = 'e';
	break;
      case ',':
	*c = 'c';
	break;
      case '(':
	*c = 'p';
	break;
      case ')':
	*c = 'P';
	break;
      case '[':
	*c = 'b';
	break;
      case ']':
	*c = 'B';
	break;
      case '^':
	*c = 'x';
	break;
      case '&':
	*c = 'A';
	break;
      case '|':
	*c = 'o';
	break;
      case '~':
	*c = 'n';
	break;
      case '!':
	*c = 'N';
	break;
      case '%':
	*c = 'M';
	break;
      case '.':
	*c = 'f';
	break;
      case '?':
	*c = 'q';
	break;
      default:
	*c = '_';
	break;
      }
    }
    c++;
  }
  if (special) Append(r,"___");
  return special;
}

/* -----------------------------------------------------------------------------
 * Swig_name_mangle()
 *
 * Converts all of the non-identifier characters of a string to underscores.
 * ----------------------------------------------------------------------------- */

String *
Swig_name_mangle(const String_or_char *s) {
#if 0
  String *r = NewString(s);
  name_mangle(r);
  return r;
#else
  return Swig_string_mangle(s);
#endif
}

/* -----------------------------------------------------------------------------
 * Swig_name_wrapper()
 *
 * Returns the name of a wrapper function.
 * ----------------------------------------------------------------------------- */

String *
Swig_name_wrapper(const String_or_char *fname) {
  String *r;
  String *f;

  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = HashGetAttr(naming_hash,k_wrapper);
  if (!f) {
    Append(r,"_wrap_%f");
  } else {
    Append(r,f);
  }
  Replace(r,"%f",fname, DOH_REPLACE_ANY);
  name_mangle(r);
  return r;
}


/* -----------------------------------------------------------------------------
 * Swig_name_member()
 *
 * Returns the name of a class method.
 * ----------------------------------------------------------------------------- */

String *
Swig_name_member(const String_or_char *classname, const String_or_char *mname) {
  String *r;
  String *f;
  String *rclassname;
  char   *cname;

  rclassname = SwigType_namestr(classname);
  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = HashGetAttr(naming_hash,k_member);
  if (!f) {
    Append(r,"%c_%m");
  } else {
    Append(r,f);
  }
  cname = Char(rclassname);
  if ((strncmp(cname,"struct ", 7) == 0) ||
      ((strncmp(cname,"class ", 6) == 0)) ||
      ((strncmp(cname,"union ", 6) == 0))) {
    cname = strchr(cname, ' ')+1;
  }
  Replace(r,"%c",cname, DOH_REPLACE_ANY);
  Replace(r,"%m",mname, DOH_REPLACE_ANY);
  /*  name_mangle(r);*/
  Delete(rclassname);
  return r;
}

/* -----------------------------------------------------------------------------
 * Swig_name_get()
 *
 * Returns the name of the accessor function used to get a variable.
 * ----------------------------------------------------------------------------- */

String *
Swig_name_get(const String_or_char *vname) {
  String *r;
  String *f;

#ifdef SWIG_DEBUG
  Printf(stderr,"Swig_name_get:  '%s'\n", vname); 
#endif

  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = Getattr(naming_hash,k_get);
  if (!f) {
    Append(r,"%v_get");
  } else {
    Append(r,f);
  }
  Replace(r,"%v",vname, DOH_REPLACE_ANY);
  /* name_mangle(r); */
  return r;
}

/* ----------------------------------------------------------------------------- 
 * Swig_name_set()
 *
 * Returns the name of the accessor function used to set a variable.
 * ----------------------------------------------------------------------------- */

String *
Swig_name_set(const String_or_char *vname) {
  String *r;
  String *f;

  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = HashGetAttr(naming_hash,k_set);
  if (!f) {
    Append(r,"%v_set");
  } else {
    Append(r,f);
  }
  Replace(r,"%v",vname, DOH_REPLACE_ANY);
  /* name_mangle(r); */
  return r;
}

/* -----------------------------------------------------------------------------
 * Swig_name_construct()
 *
 * Returns the name of the accessor function used to create an object.
 * ----------------------------------------------------------------------------- */

String *
Swig_name_construct(const String_or_char *classname) {
  String *r;
  String *f;
  String *rclassname;
  char *cname;

  rclassname = SwigType_namestr(classname);
  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = HashGetAttr(naming_hash,k_construct);
  if (!f) {
    Append(r,"new_%c");
  } else {
    Append(r,f);
  }

  cname = Char(rclassname);
  if ((strncmp(cname,"struct ", 7) == 0) ||
      ((strncmp(cname,"class ", 6) == 0)) ||
      ((strncmp(cname,"union ", 6) == 0))) {
    cname = strchr(cname, ' ')+1;
  }
  Replace(r,"%c",cname, DOH_REPLACE_ANY);
  Delete(rclassname);
  return r;
}


/* -----------------------------------------------------------------------------
 * Swig_name_copyconstructor()
 *
 * Returns the name of the accessor function used to copy an object.
 * ----------------------------------------------------------------------------- */

String *
Swig_name_copyconstructor(const String_or_char *classname) {
  String *r;
  String *f;
  String *rclassname;
  char *cname;

  rclassname = SwigType_namestr(classname);
  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = HashGetAttr(naming_hash,k_copy);
  if (!f) {
    Append(r,"copy_%c");
  } else {
    Append(r,f);
  }

  cname = Char(rclassname);
  if ((strncmp(cname,"struct ", 7) == 0) ||
      ((strncmp(cname,"class ", 6) == 0)) ||
      ((strncmp(cname,"union ", 6) == 0))) {
    cname = strchr(cname, ' ')+1;
  }

  Replace(r,"%c",cname, DOH_REPLACE_ANY);
  Delete(rclassname);
  return r;
}

/* -----------------------------------------------------------------------------
 * Swig_name_destroy()
 *
 * Returns the name of the accessor function used to destroy an object.
 * ----------------------------------------------------------------------------- */

String *Swig_name_destroy(const String_or_char *classname) {
  String *r;
  String *f;
  String *rclassname;
  char *cname;
  rclassname = SwigType_namestr(classname);
  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = HashGetAttr(naming_hash,k_destroy);
  if (!f) {
    Append(r,"delete_%c");
  } else {
    Append(r,f);
  }

  cname = Char(rclassname);
  if ((strncmp(cname,"struct ", 7) == 0) ||
      ((strncmp(cname,"class ", 6) == 0)) ||
      ((strncmp(cname,"union ", 6) == 0))) {
    cname = strchr(cname, ' ')+1;
  }
  Replace(r,"%c",cname, DOH_REPLACE_ANY);
  Delete(rclassname);
  return r;
}


/* -----------------------------------------------------------------------------
 * Swig_name_disown()
 *
 * Returns the name of the accessor function used to disown an object.
 * ----------------------------------------------------------------------------- */

String *Swig_name_disown(const String_or_char *classname) {
  String *r;
  String *f;
  String *rclassname;
  char *cname;
  rclassname = SwigType_namestr(classname);
  r = NewStringEmpty();
  if (!naming_hash) naming_hash = NewHash();
  f = HashGetAttr(naming_hash,k_disown);
  if (!f) {
    Append(r,"disown_%c");
  } else {
    Append(r,f);
  }

  cname = Char(rclassname);
  if ((strncmp(cname,"struct ", 7) == 0) ||
      ((strncmp(cname,"class ", 6) == 0)) ||
      ((strncmp(cname,"union ", 6) == 0))) {
    cname = strchr(cname, ' ')+1;
  }
  Replace(r,"%c",cname, DOH_REPLACE_ANY);
  Delete(rclassname);
  return r;
}


/* -----------------------------------------------------------------------------
 * Swig_name_object_set()
 *
 * Sets an object associated with a name and optional declarators. 
 * ----------------------------------------------------------------------------- */

void 
Swig_name_object_set(Hash *namehash, String *name, SwigType *decl, DOH *object) {
  DOH *n;

#ifdef SWIG_DEBUG
  Printf(stderr,"Swig_name_object_set:  '%s', '%s'\n", name, decl); 
#endif
  n = HashGetAttr(namehash,name);
  if (!n) {
    n = NewHash();
    Setattr(namehash,name,n);
    Delete(n);
  }
  /* Add an object based on the declarator value */
  if (!decl) {
    Setattr(n,k_start,object);
  } else {
    SwigType *cd = Copy(decl);
    Setattr(n,cd,object);
    Delete(cd);
  }
}


/* -----------------------------------------------------------------------------
 * Swig_name_object_get()
 *
 * Return an object associated with an optional class prefix, name, and 
 * declarator.   This function operates according to name matching rules
 * described for the %rename directive in the SWIG manual.
 * ----------------------------------------------------------------------------- */

static DOH *get_object(Hash *n, String *decl) {
  DOH *rn = 0;
  if (!n) return 0;
  if (decl) {
    rn = Getattr(n,decl);
  } else {
    rn = Getattr(n,k_start);
  }
  return rn;
}

static
DOH *
name_object_get(Hash *namehash, String *tname, SwigType *decl, SwigType *ncdecl) {
  DOH* rn = 0;
  Hash   *n = Getattr(namehash,tname);
  if (n) {
    rn = get_object(n,decl);
    if ((!rn) && ncdecl) rn = get_object(n,ncdecl);
    if (!rn) rn = get_object(n,0);
  }
  return rn;
}

DOH *
Swig_name_object_get(Hash *namehash, String *prefix, String *name, SwigType *decl) {
  String *tname = NewStringEmpty();
  DOH    *rn = 0;
  char   *ncdecl = 0;

  if (!namehash) return 0;

  /* DB: This removed to more tightly control feature/name matching */
  /*  if ((decl) && (SwigType_isqualifier(decl))) {
    ncdecl = strchr(Char(decl),'.');
    ncdecl++;
  }
  */
#ifdef SWIG_DEBUG
  Printf(stderr,"Swig_name_object_get:  '%s', '%s'\n", name, decl); 
#endif


  /* Perform a class-based lookup (if class prefix supplied) */
  if (prefix) {
    if (Len(prefix)) {
      Printf(tname,"%s::%s", prefix, name);
      rn = name_object_get(namehash, tname, decl, ncdecl);
      if (!rn) {
	String *cls = Swig_scopename_last(prefix);
	if (!Equal(cls,prefix)) {
	  Clear(tname);
	  Printf(tname,"*::%s::%s",cls,name);
	  rn = name_object_get(namehash, tname, decl, ncdecl);
	}
	Delete(cls);
      }
      /* A template-based class lookup, check name first */
      if (!rn && SwigType_istemplate(name)) {
	String *t_name = SwigType_templateprefix(name);
	if (!Equal(t_name,name)) {
	  rn = Swig_name_object_get(namehash, prefix, t_name, decl);
	}
	Delete(t_name);
      }
      /* A template-based class lookup */
      if (0 && !rn && SwigType_istemplate(prefix)) {
	String *t_prefix = SwigType_templateprefix(prefix);
	if (Strcmp(t_prefix,prefix) != 0) {
	  String *t_name = SwigType_templateprefix(name);
	  rn = Swig_name_object_get(namehash, t_prefix, t_name, decl);
	  Delete(t_name);
	}
	Delete(t_prefix);
      }
    } 
    /* A wildcard-based class lookup */
    if (!rn) {
      Clear(tname);
      Printf(tname,"*::%s",name);
      rn = name_object_get(namehash, tname, decl, ncdecl);
    }
  } else {
    /* Lookup in the global namespace only */
    Clear(tname);
    Printf(tname,"::%s",name);
    rn = name_object_get(namehash, tname, decl, ncdecl);
  }
  /* Catch-all */
  if (!rn) {
    rn = name_object_get(namehash, name, decl, ncdecl);
  }
  if (!rn && Swig_scopename_check(name)) {
    String *nprefix = NewStringEmpty();
    String *nlast = NewStringEmpty();
    Swig_scopename_split(name, &nprefix, &nlast);
    rn = name_object_get(namehash, nlast, decl, ncdecl);
    Delete(nlast);
    Delete(nprefix);
  }
  
  Delete(tname);

#ifdef SWIG_DEBUG
  Printf(stderr,"Swig_name_object_get:  found %d\n", rn ? 1 : 0); 
#endif

  return rn;
}

/* -----------------------------------------------------------------------------
 * Swig_name_object_inherit()
 *
 * Implements name-based inheritance scheme. 
 * ----------------------------------------------------------------------------- */

void
Swig_name_object_inherit(Hash *namehash, String *base, String *derived) {
  Iterator ki;
  String *bprefix;
  String *dprefix;
  char *cbprefix;
  int   plen;

  if (!namehash) return;
  
  bprefix = NewStringf("%s::",base);
  dprefix = NewStringf("%s::",derived);
  cbprefix = Char(bprefix);
  plen = strlen(cbprefix);
  for (ki = First(namehash); ki.key; ki = Next(ki)) {
    char *k = Char(ki.key);
    if (strncmp(k,cbprefix,plen) == 0) {
      Iterator oi;
      String *nkey = NewStringf("%s%s",dprefix,k+plen);
      Hash *n = ki.item;
      Hash *newh = HashGetAttr(namehash,nkey);
      if (!newh) {
	newh = NewHash();
	Setattr(namehash,nkey,newh);
	Delete(newh);
      }
      for (oi = First(n); oi.key; oi = Next(oi)) {
	if (!Getattr(newh,oi.key)) {
	  String *ci = Copy(oi.item);
	  Setattr(newh,oi.key,ci);
	  Delete(ci);
	}
      }
      Delete(nkey);
    }
  }
  Delete(bprefix);
  Delete(dprefix);
}

/* -----------------------------------------------------------------------------
 * merge_features()
 *
 * Given a hash, this function merges the features in the hash into the node.
 * ----------------------------------------------------------------------------- */

static void merge_features(Hash *features, Node *n) {
  Iterator ki;

  if (!features) return;
  for (ki = First(features); ki.key; ki = Next(ki)) {
    String *ci = Copy(ki.item);    
    Setattr(n,ki.key,ci);
    Delete(ci);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_features_get()
 *
 * Attaches any features in the features hash to the node that matches
 * the declaration, decl.
 * ----------------------------------------------------------------------------- */

static 
void features_get(Hash *features, String *tname, SwigType *decl, SwigType *ncdecl, Node *node)
{
  Node *n = Getattr(features,tname);
#ifdef SWIG_DEBUG
  Printf(stderr,"  features_get: %s\n", tname);
#endif
  if (n) {
    merge_features(get_object(n,0),node);
    if (ncdecl) merge_features(get_object(n,ncdecl),node);
    merge_features(get_object(n,decl),node);
  }
}

void
Swig_features_get(Hash *features, String *prefix, String *name, SwigType *decl, Node *node) {
  char   *ncdecl = 0;
  String *rdecl = 0;
  String *rname = 0;
  if (!features) return;

  /* MM: This removed to more tightly control feature/name matching */
  /*
  if ((decl) && (SwigType_isqualifier(decl))) {
    ncdecl = strchr(Char(decl),'.');
    ncdecl++;
  }
  */

  /* very specific hack for template constructors/destructors */
  if (name && SwigType_istemplate(name)) {
    String *nodetype = Getattr(node, k_nodetype);
    if (nodetype && (Equal(nodetype,k_constructor) || Equal(nodetype,k_destructor))) {
      String *nprefix = NewStringEmpty();
      String *nlast = NewStringEmpty();
      String *tprefix;
      Swig_scopename_split(name, &nprefix, &nlast);    
      tprefix = SwigType_templateprefix(nlast);
      Delete(nlast);
      if (Len(nprefix)) {
	Append(nprefix,"::");
	Append(nprefix,tprefix);
	Delete(tprefix);
	rname = nprefix;      
      } else {
	rname = tprefix;
	Delete(nprefix);
      }
      rdecl = Copy(decl);
      Replaceall(rdecl,name,rname);
      decl = rdecl;
      name = rname;
    }
  }

  
#ifdef SWIG_DEBUG
  Printf(stderr,"Swig_features_get: %s %s %s\n", prefix, name, decl);
#endif

  /* Global features */
  features_get(features, empty_string, 0, 0, node);
  if (name) {
    String *tname = NewStringEmpty();
    /* add features for 'root' template */
    if (SwigType_istemplate(name)) {
      String *dname = SwigType_templateprefix(name);
      features_get(features, dname, decl, ncdecl, node);
      Delete(dname);
    }
    /* Catch-all */
    features_get(features, name, decl, ncdecl, node);
    /* Perform a class-based lookup (if class prefix supplied) */
    if (prefix) {
      /* A class-generic feature */
      if (Len(prefix)) {
	Printf(tname,"%s::",prefix);
	features_get(features, tname, decl, ncdecl, node);
      }
      /* A wildcard-based class lookup */
      Clear(tname);
      Printf(tname,"*::%s",name);
      features_get(features, tname, decl, ncdecl, node);
      /* A specific class lookup */
      if (Len(prefix)) {
	/* A template-based class lookup */
	if (SwigType_istemplate(prefix)) {
	  String *tprefix = SwigType_templateprefix(prefix);
	  Clear(tname);
	  Printf(tname,"%s::%s",tprefix,name);
	  features_get(features, tname, decl, ncdecl, node);
	  Delete(tprefix);
	}
	Clear(tname);
	Printf(tname,"%s::%s",prefix,name);
	features_get(features, tname, decl, ncdecl, node);
      }
    } else {
      /* Lookup in the global namespace only */
      Clear(tname);
      Printf(tname,"::%s",name);
      features_get(features, tname, decl, ncdecl, node);
    }
    Delete(tname);
  }
  if (name && SwigType_istemplate(name)) {
    /* add features for complete template type */
    String *dname = Swig_symbol_template_deftype(name,0);
    if (!Equal(dname,name)) {    
      Swig_features_get(features, prefix, dname, decl, node);
    }
    Delete(dname);
  }

  if (rname) Delete(rname);
  if (rdecl) Delete(rdecl);
}


/* -----------------------------------------------------------------------------
 * Swig_feature_set()
 *
 * Sets a feature name and value. Also sets optional feature attributes as
 * passed in by featureattribs. Optional feature attributes are given a full name
 * concatenating the feature name plus ':' plus the attribute name.
 * ----------------------------------------------------------------------------- */

void 
Swig_feature_set(Hash *features, const String_or_char *name, SwigType *decl, const String_or_char *featurename, String *value, Hash *featureattribs) {
  Hash *n;
  Hash *fhash;

#ifdef SWIG_DEBUG
  Printf(stderr,"Swig_feature_set: %s %s %s %s\n", name, decl, featurename,value);  
#endif

  n = Getattr(features,name);
  if (!n) {
    n = NewHash();
    Setattr(features,name,n);
    Delete(n);
  }
  if (!decl) {
    fhash = Getattr(n,k_start);
    if (!fhash) {
      fhash = NewHash();
      Setattr(n,k_start,fhash);
      Delete(fhash);
    }
  } else {
    fhash = Getattr(n,decl);
    if (!fhash) {
      String *cdecl_ = Copy(decl);
      fhash = NewHash();
      Setattr(n,cdecl_,fhash);
      Delete(cdecl_);
      Delete(fhash);
    }
  }
  if (value) {
    Setattr(fhash,featurename,value);
  } else {
    Delattr(fhash,featurename);
  }

  {
    /* Add in the optional feature attributes */
    Hash *attribs = featureattribs;
    while(attribs) {
      String *attribname = Getattr(attribs,k_name);
      String *featureattribname = NewStringf("%s:%s", featurename, attribname);
      if (value) {
        String *attribvalue = Getattr(attribs,k_value);
        Setattr(fhash,featureattribname,attribvalue);
      } else {
        Delattr(fhash,featureattribname);
      }
      attribs = nextSibling(attribs);
      Delete(featureattribname);
    }
  }

  if (name && SwigType_istemplate(name)) {
    String *dname = Swig_symbol_template_deftype(name,0);
    if (Strcmp(dname,name)) {    
      Swig_feature_set(features, dname, decl, featurename, value, featureattribs);
    }
    Delete(dname);
  }
}

/* -----------------------------------------------------------------------------
 * The rename/namewarn engine
 *
 * Code below was in parser.y for a while
 * ----------------------------------------------------------------------------- */

static Hash   *namewarn_hash = 0;
Hash *Swig_name_namewarn_hash() {
  if (!namewarn_hash) namewarn_hash = NewHash();
  return namewarn_hash;
}

static Hash   *rename_hash = 0;
Hash *Swig_name_rename_hash() {
  if (!rename_hash) rename_hash = NewHash();
  return rename_hash;
}

static List   *namewarn_list = 0;
List *Swig_name_namewarn_list() {
  if (!namewarn_list) namewarn_list = NewList();
  return namewarn_list;
}

static List   *rename_list = 0;
List *Swig_name_rename_list() {
  if (!rename_list) rename_list = NewList();
  return rename_list;
}

/* -----------------------------------------------------------------------------
 * int Swig_need_name_warning(Node *n)
 *
 * Detects if a node needs name warnings 
 *
 * ----------------------------------------------------------------------------- */

int Swig_need_name_warning(Node *n)
{
  int need = 1;
  /* 
     we don't use name warnings for:
     - class forwards, no symbol is generated at the target language.
     - template declarations, only for real instances using %template(name).
     - typedefs, they have no effect at the target language.
  */
  if (checkAttribute(n,k_nodetype,k_classforward)) {
    need = 0;
  } else if (checkAttribute(n,k_storage,k_typedef))  {
    need = 0;
  } else if (Getattr(n,k_hidden)) {
    need = 0;
  } else if (Getattr(n,k_ignore)) {
    need = 0;
  } else if (Getattr(n,k_templatetype)) {
    need = 0;
  }
  return need;
}

/* -----------------------------------------------------------------------------
 * int Swig_need_redefined_warn()
 *
 * Detects when a redefined object needs a warning
 * 
 * ----------------------------------------------------------------------------- */

static int nodes_are_equivalent(Node* a, Node* b, int a_inclass)
{
  /* they must have the same type */
  String *ta = Getattr(a,k_nodetype);
  String *tb = Getattr(b,k_nodetype);  
  if (Cmp(ta, tb) != 0) return 0;
  
  /* cdecl case */
  if (Cmp(ta, k_cdecl) == 0) {
    /* typedef */
    String *a_storage = Getattr(a,k_storage);
    String *b_storage = Getattr(b,k_storage);

    if ((Cmp(a_storage,k_typedef) == 0)
	|| (Cmp(b_storage,k_typedef) == 0)) {	
      if (Cmp(a_storage, b_storage) == 0) {
	String *a_type = (Getattr(a,k_type));
	String *b_type = (Getattr(b,k_type));
	if (Cmp(a_type, b_type) == 0) return 1;
      }
      return 0;
    }

    /* static functions */
    if ((Cmp(a_storage, k_static) == 0) 
	|| (Cmp(b_storage, k_static) == 0)) {
      if (Cmp(a_storage, b_storage) != 0) return 0;
    }

    /* friend methods */
    
    if (!a_inclass || (Cmp(a_storage,k_friend) == 0)) {
      /* check declaration */

      String *a_decl = (Getattr(a,k_decl));
      String *b_decl = (Getattr(b,k_decl));
      if (Cmp(a_decl, b_decl) == 0) {
	/* check return type */
	String *a_type = (Getattr(a,k_type));
	String *b_type = (Getattr(b,k_type));
	if (Cmp(a_type, b_type) == 0) {
	  /* check parameters */
	  Parm *ap = (Getattr(a,k_parms));
	  Parm *bp = (Getattr(b,k_parms));
	  while (ap && bp) {
	    SwigType *at = Getattr(ap,k_type);
	    SwigType *bt = Getattr(bp,k_type);
	    if (Cmp(at, bt) != 0) return 0;
	    ap = nextSibling(ap);
	    bp = nextSibling(bp);
	  }
	  if (ap || bp) {
	    return 0;
	  } else {
            Node *a_template = Getattr(a,k_template);
            Node *b_template = Getattr(b,k_template);
            /* Not equivalent if one is a template instantiation (via %template) and the other is a non-templated function */
            if ((a_template && !b_template) || (!a_template && b_template)) return 0;
          }
	  return 1;
	}
      }
    }
  } else {
    /* %constant case */  
    String *a_storage = Getattr(a,k_storage);
    String *b_storage = Getattr(b,k_storage);
    if ((Cmp(a_storage, "%constant") == 0) 
	|| (Cmp(b_storage, "%constant") == 0)) {
      if (Cmp(a_storage, b_storage) == 0) {
	String *a_type = (Getattr(a,k_type));
	String *b_type = (Getattr(b,k_type));
	if ((Cmp(a_type, b_type) == 0)
	    && (Cmp(Getattr(a,k_value), Getattr(b,k_value)) == 0))
	  return 1;
      }
      return 0;
    }
  }
  return 0;
}

int Swig_need_redefined_warn(Node* a, Node* b, int InClass)
{
  String *a_name = Getattr(a,k_name);
  String *b_name = Getattr(b,k_name);
  String *a_symname = Getattr(a,k_symname);
  String *b_symname = Getattr(b,k_symname);
  /* always send a warning if a 'rename' is involved */
  if ((a_symname && !Equal(a_symname,a_name))
      || (b_symname && !Equal(b_symname,b_name))) {
    if (!Equal(a_name,b_name)) {
      return 1;
    }
  }
  

  return !nodes_are_equivalent(a, b, InClass);
}


/* -----------------------------------------------------------------------------
 * int Swig_need_protected(Node* n)
 *
 * Detects when we need to fully register the protected member.
 * 
 * ----------------------------------------------------------------------------- */

int Swig_need_protected(Node* n)
{
  /* First, 'n' looks like a function */
  /* if (!Swig_director_mode()) return 0; */
  String *nodetype = Getattr(n,k_nodetype);
  if ((Equal(nodetype,k_cdecl)) && SwigType_isfunction(Getattr(n,k_decl))) {
    String *storage = Getattr(n,k_storage);
    /* and the function is declared like virtual, or it has no
       storage. This eliminates typedef, static and so on. */ 
    return !storage || Equal(storage,k_virtual);
  } else if (Equal(nodetype,k_constructor) || Equal(nodetype,k_destructor)) {
    return 1;
  }

  return 0;
}

/* -----------------------------------------------------------------------------
 * void Swig_name_nameobj_add()
 *
 * Add nameobj (rename/namewarn)
 * 
 * ----------------------------------------------------------------------------- */

static List *Swig_make_attrlist(const char *ckey) {
  List *list = NewList();
  const char *cattr = strstr(ckey,"$");
  if (cattr) {
    String *nattr;
    const char *rattr = strstr(++cattr,"$");
    while (rattr) {
      nattr = NewStringWithSize(cattr, rattr-cattr);
      Append(list,nattr);
      Delete(nattr);
      cattr = rattr + 1;
      rattr = strstr(cattr,"$");
    }
    nattr = NewString(cattr);
    Append(list,nattr);
    Delete(nattr);
  } else {
    Append(list,k_nodetype);
  }
  return list;
}

static void Swig_name_object_attach_keys(const char *keys[], Hash *nameobj) 
{
  Node *kw = nextSibling(nameobj);
  List *matchlist = 0;
  while (kw) {
    Node *next = nextSibling(kw);
    String *kname = Getattr(kw,k_name);
    char *ckey = kname ? Char(kname) :  0;
    if (ckey) {
      const char **rkey;
      int isnotmatch = 0;
      int isrxsmatch = 0;      
      if ((strncmp(ckey,"match",5) == 0) 
	  || (isnotmatch = (strncmp(ckey,"notmatch",8) == 0))
	  || (isrxsmatch = (strncmp(ckey,"rxsmatch",8) == 0))
	  || (isnotmatch = isrxsmatch = (strncmp(ckey,"notrxsmatch",11) == 0))) {
	Hash *mi = NewHash();
	List *attrlist = Swig_make_attrlist(ckey);
	if (!matchlist) matchlist = NewList();
	Setattr(mi,k_value,Getattr(kw,k_value));
	Setattr(mi,k_attrlist,attrlist);
#ifdef SWIG_DEBUG 
	if (isrxsmatch) Printf(stderr,"rxsmatch to use: %s %s %s\n", ckey, Getattr(kw,k_value), attrlist);
#endif
	if (isnotmatch) SetFlag(mi,k_notmatch);
	if (isrxsmatch) SetFlag(mi,k_rxsmatch);
	Delete(attrlist);
	Append(matchlist,mi);
	Delete(mi);
	deleteNode(kw);
      } else {
	for (rkey = keys; *rkey != 0; ++rkey) {
	  if (strcmp(ckey,*rkey) == 0) {
	    Setattr(nameobj, *rkey, Getattr(kw,k_value));
	    deleteNode(kw);
	  }
	}
      }
    }
    kw = next;
  }
  if (matchlist) {
    Setattr(nameobj,k_matchlist,matchlist);
    Delete(matchlist);
  }
}

void Swig_name_nameobj_add(Hash *name_hash, List *name_list,
			   String *prefix, String *name, SwigType *decl, Hash *nameobj) {
  String *nname = 0;
  if (name && Len(name)) {
    String *target_fmt = Getattr(nameobj,k_targetfmt);
    nname = prefix ? NewStringf("%s::%s",prefix, name) : NewString(name);
    if (target_fmt) {
      String *tmp = NewStringf(target_fmt, nname);
      Delete(nname);
      nname = tmp;
    }
  }  
  
  if (!nname || !Len(nname) || 
      Getattr(nameobj,k_fullname)  ||  /* any of these options trigger a 'list' nameobj */
      Getattr(nameobj,k_sourcefmt) || 
      Getattr(nameobj,k_matchlist)) {
    if (decl) Setattr(nameobj,k_decl, decl);
    if (nname && Len(nname)) Setattr(nameobj,k_targetname, nname);
    /* put the new nameobj at the beginnig of the list, such that the
       last inserted rule take precedence */
    Insert(name_list, 0, nameobj);
  } else {
    /* here we add an old 'hash' nameobj, simple and fast */
    Swig_name_object_set(name_hash,nname,decl,nameobj);
  }
  Delete(nname);
}

/* -----------------------------------------------------------------------------
 * int Swig_name_match_nameobj()
 *
 * Apply and check the nameobj's math list to the node
 * 
 * ----------------------------------------------------------------------------- */

static DOH *Swig_get_lattr(Node *n, List *lattr)
{
  DOH *res = 0;
  int ilen = Len(lattr);
  int i;
  for (i = 0; n && (i < ilen); ++i) {
    String *nattr = Getitem(lattr,i);
    res = Getattr(n,nattr);
#ifdef SWIG_DEBUG 
    if (!res) {
      Printf(stderr,"missing %s %s %s\n",nattr, Getattr(n,k_name), Getattr(n,"member"));
    } else {    
      Printf(stderr,"lattr %d %s %s\n",i, nattr, DohIsString(res) ? res : Getattr(res,k_name));
    }
#endif
    n = res;
  }
  return res;
}

#if defined(HAVE_RXSPENCER)
#include <sys/types.h>
#include <rxspencer/regex.h>
#define USE_RXSPENCER
#endif

#if defined(USE_RXSPENCER)
int Swig_name_rxsmatch_value(String *mvalue, String *value)
{
  int match = 0;
  char *cvalue = Char(value);
  char *cmvalue = Char(mvalue);
  regex_t compiled;
  int retval = regcomp(&compiled, cmvalue, REG_EXTENDED|REG_NOSUB);
  if(retval != 0) return 0;
  retval = regexec(&compiled,cvalue,0,0,0);
  match = (retval == REG_NOMATCH) ? 0 : 1;
#ifdef SWIG_DEBUG
  Printf(stderr,"rxsmatch_value: %s %s %d\n",cvalue,cmvalue, match);
#endif
  regfree(&compiled);
  return match;
}
#else
int Swig_name_rxsmatch_value(String *mvalue, String *value)
{
  (void)mvalue;
  (void)value;  
  return 0;
}
#endif

int Swig_name_match_value(String *mvalue, String *value)
{
#if defined(SWIG_USE_SIMPLE_MATCHOR)
  int match = 0;
  char *cvalue = Char(value);
  char *cmvalue = Char(mvalue);
  char *sep = strstr(cmvalue,"|");
  while (sep && !match) {
    match = strncmp(cvalue,cmvalue, sep - cmvalue) == 0;
#ifdef SWIG_DEBUG 
    Printf(stderr,"match_value: %s %s %d\n",cvalue,cmvalue, match);
#endif
    cmvalue = sep + 1;
    sep = strstr(cmvalue,"|");
  }
  if (!match) {
    match = strcmp(cvalue,cmvalue) == 0;    
#ifdef SWIG_DEBUG 
    Printf(stderr,"match_value: %s %s %d\n",cvalue,cmvalue, match);
#endif
  }
  return match;
#else
  return StringEqual(mvalue,value);
#endif
}


int Swig_name_match_nameobj(Hash *rn, Node *n) {
  int match = 1;
  List *matchlist = HashGetAttr(rn,k_matchlist);
#ifdef SWIG_DEBUG 
  Printf(stderr,"Swig_name_match_nameobj: %s\n",Getattr(n,"name"));
#endif
  if (matchlist) {
    int ilen = Len(matchlist);
    int i;
    for (i = 0; match && (i < ilen); ++i) {
      Node *mi = Getitem(matchlist,i);
      List *lattr = Getattr(mi,k_attrlist);
      String *nval = Swig_get_lattr(n,lattr);
      int notmatch = GetFlag(mi,k_notmatch);
      int rxsmatch = GetFlag(mi,k_rxsmatch);
#ifdef SWIG_DEBUG 
      Printf(stderr,"mi %d %s re %d not %d \n", i, nval, notmatch, rxsmatch);
      if (rxsmatch) {
	Printf(stderr,"rxsmatch %s\n",lattr);
      }      
#endif
      match = 0;
      if (nval) {
	String *kwval = Getattr(mi,k_value);
	match = rxsmatch ? Swig_name_rxsmatch_value(kwval, nval) 
	  : Swig_name_match_value(kwval, nval);
#ifdef SWIG_DEBUG 
	Printf(stderr,"val %s %s %d %d \n",nval, kwval,match, ilen);
#endif
      }
      if (notmatch) match = !match;
    }
  }
#ifdef SWIG_DEBUG 
  Printf(stderr,"Swig_name_match_nameobj: %d\n",match);
#endif
  return match;
}

/* -----------------------------------------------------------------------------
 * Hash *Swig_name_nameobj_lget()
 *
 * Get a nameobj (rename/namewarn) from the list of filters
 * 
 * ----------------------------------------------------------------------------- */

Hash *Swig_name_nameobj_lget(List *namelist, Node *n, String *prefix, String *name, String *decl) {
  Hash *res = 0;
  if (namelist) {
    int len = Len(namelist);
    int i;
    int match = 0;
    for (i = 0; !match && (i < len); i++) {
      Hash *rn = Getitem(namelist,i);
      String *rdecl = HashGetAttr(rn,k_decl);
      if (rdecl && (!decl || !Equal(rdecl,decl))) {
	continue;
      } else if (Swig_name_match_nameobj(rn, n)) {
	String *tname = HashGetAttr(rn,k_targetname);
	if (tname) {
	  String *sfmt = HashGetAttr(rn,k_sourcefmt);
	  String *sname = 0;
	  int fullname = GetFlag(rn,k_fullname);
	  int rxstarget = GetFlag(rn,k_rxstarget);
	  if (sfmt) {
	    if (fullname && prefix) {
	      String *pname= NewStringf("%s::%s", prefix, name);
	      sname = NewStringf(sfmt, pname);
	      Delete(pname);
	    } else {
	      sname = NewStringf(sfmt, name);
	    }
	  } else {
	    if (fullname && prefix) {
	      sname = NewStringf("%s::%s", prefix, name);
	    } else {
	      sname = name;
	      DohIncref(name);
	    }
	  }
	  match = rxstarget ? Swig_name_rxsmatch_value(tname,sname) :
	    Swig_name_match_value(tname,sname);
	  Delete(sname);
	} else {
	  match = 1;
	}
      }
      if (match) {
	res = rn;
	break;
      }
    }
  }
  return res;
}

/* -----------------------------------------------------------------------------
 * Swig_name_namewarn_add
 *
 * Add a namewarn objects
 * 
 * ----------------------------------------------------------------------------- */

void Swig_name_namewarn_add(String *prefix, String *name, SwigType *decl, Hash *namewrn) {
  const char *namewrn_keys[] = {"rename", "error", "fullname", "sourcefmt", "targetfmt", 0};
  Swig_name_object_attach_keys(namewrn_keys, namewrn);
  Swig_name_nameobj_add(Swig_name_namewarn_hash(), Swig_name_namewarn_list(),
			prefix, name, decl, namewrn);
}

/* -----------------------------------------------------------------------------
 * Hash *Swig_name_namewarn_get()
 *
 * Return the namewarn object, if there is one.
 * 
 * ----------------------------------------------------------------------------- */

Hash *Swig_name_namewarn_get(Node *n, String *prefix, String *name,SwigType *decl) {
  if (!namewarn_hash && !namewarn_list) return 0;
  if (n) {
    /* Return in the obvious cases */
    if (!name || !Swig_need_name_warning(n)) {
      return 0;
    } else {
      String *access = Getattr(n,k_access);	
      int is_public = !access || Equal(access,k_public);
      if (!is_public && !Swig_need_protected(n)) {
	return 0;
      }
    }
  }
  if (name) {
    /* Check to see if the name is in the hash */
    Hash *wrn = Swig_name_object_get(Swig_name_namewarn_hash(),prefix,name,decl);
    if (wrn && !Swig_name_match_nameobj(wrn, n)) wrn = 0;
    if (!wrn) {
      wrn = Swig_name_nameobj_lget(Swig_name_namewarn_list(), n, prefix, name, decl);
    }
    if (wrn && HashGetAttr(wrn,k_error)) {
      if (n) {
	Swig_error(Getfile(n), Getline(n), "%s\n", HashGetAttr(wrn,k_name));
      } else {
	Swig_error(cparse_file, cparse_line,"%s\n", HashGetAttr(wrn,k_name));
      }
    } 
    return wrn;
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * String *Swig_name_warning()
 *
 * Return the name warning, if there is one.
 * 
 * ----------------------------------------------------------------------------- */

String *Swig_name_warning(Node *n, String *prefix, String *name,SwigType *decl) {
  Hash *wrn = Swig_name_namewarn_get(n, prefix, name,decl);
  return (name && wrn) ? HashGetAttr(wrn,k_name) : 0;
}

/* -----------------------------------------------------------------------------
 * Swig_name_rename_add()
 *
 * Manage the rename objects
 * 
 * ----------------------------------------------------------------------------- */

static void single_rename_add(String *prefix, String *name, SwigType *decl, Hash *newname) {
  Swig_name_nameobj_add(Swig_name_rename_hash(), Swig_name_rename_list(),
			prefix, name, decl, newname);
}

/* Add a new rename. Works much like new_feature including default argument handling. */
void Swig_name_rename_add(String *prefix, String *name, SwigType *decl, Hash *newname, 
			  ParmList *declaratorparms) {
  
  ParmList *declparms = declaratorparms;
  
  const char *rename_keys[] = {"fullname", "sourcefmt", "targetfmt", "continue", "rxstarget",0};
  Swig_name_object_attach_keys(rename_keys, newname);
  
  /* Add the name */
  single_rename_add(prefix, name, decl, newname);
  
  /* Add extra names if there are default parameters in the parameter list */
  if (decl) {
    int constqualifier = SwigType_isconst(decl);
    while (declparms) {
      if (ParmList_has_defaultargs(declparms)) {
	
        /* Create a parameter list for the new rename by copying all
           but the last (defaulted) parameter */
        ParmList* newparms = ParmList_copy_all_except_last_parm(declparms);
	
        /* Create new declaration - with the last parameter removed */
        SwigType *newdecl = Copy(decl);
        Delete(SwigType_pop_function(newdecl)); /* remove the old parameter list from newdecl */
        SwigType_add_function(newdecl,newparms);
        if (constqualifier)
          SwigType_add_qualifier(newdecl,"const");
	
        single_rename_add(prefix, name, newdecl, newname);
        declparms = newparms;
        Delete(newdecl);
      } else {
        declparms = 0;
      }
    }
  }
}

/* -----------------------------------------------------------------------------
 * String *Swig_name_make()
 *
 * Make a name after applying all the rename/namewarn objects
 * 
 * ----------------------------------------------------------------------------- */

/* Create a name applying rename/namewarn if needed */
static String *apply_rename(String *newname, int fullname, String *prefix, String *name)
{
  String *result = 0;
  if (newname && Len(newname)) {
    if (Strcmp(newname,"$ignore") == 0) {
      result = Copy(newname);
    } else {
      char *cnewname = Char(newname);
      if (cnewname) {
	int destructor = name && (*(Char(name)) == '~');
	String *fmt = newname;
	/* use name as a fmt, but avoid C++ "%" and "%=" operators */
	if (Len(newname) > 1 && strstr(cnewname,"%") && !(strcmp(cnewname,"%=") == 0)) { 
 	  if (fullname && prefix) {
	    result = NewStringf(fmt,prefix,name);
	  } else {
	    result = NewStringf(fmt,name);
	  }
	} else {
	  result = Copy(newname);
	}
	if (destructor && result && (*(Char(result)) != '~')) {
	  Insert(result,0,"~");
	}
      }
    }
  }
  
  return result;
}

String *
Swig_name_make(Node *n, String *prefix, String_or_char *cname, SwigType *decl, String *oldname) {
  String *nname = 0;
  String *result = 0;
  String *name = NewString(cname);
  Hash *wrn = 0;
  String *rdecl = 0;
  String *rname = 0;

  /* very specific hack for template constructors/destructors */
#ifdef SWIG_DEBUG
  Printf(stderr,"SWIG_name_make: looking for %s %s %s %s\n", prefix, name, decl, oldname);
#endif

  if (name && n && SwigType_istemplate(name)) {
    String *nodetype = Getattr(n, k_nodetype);
    if (nodetype && (Equal(nodetype,k_constructor) || Equal(nodetype,k_destructor))) {
      String *nprefix = NewStringEmpty();
      String *nlast = NewStringEmpty();
      String *tprefix;
      Swig_scopename_split(name, &nprefix, &nlast);    
      tprefix = SwigType_templateprefix(nlast);
      Delete(nlast);
      if (Len(nprefix)) {
	Append(nprefix,"::");
	Append(nprefix,tprefix);
	Delete(tprefix);
	rname = nprefix;      
      } else {
	rname = tprefix;
	Delete(nprefix);
      }
      rdecl = Copy(decl);
      Replaceall(rdecl,name,rname);
#ifdef SWIG_DEBUG
      Printf(stderr,"SWIG_name_make: use new name %s %s : %s %s\n",name, decl, rname, rdecl);
#endif
      decl = rdecl;
      Delete(name);
      name = rname;
    }
  }
  

  if (rename_hash || rename_list) {
    Hash *rn =  Swig_name_object_get(Swig_name_rename_hash(), prefix, name, decl);
    if (!rn || !Swig_name_match_nameobj(rn,n)) {
      rn = Swig_name_nameobj_lget(Swig_name_rename_list(), n, prefix, name, decl);
      if (rn) {
	String *sfmt = HashGetAttr(rn,k_sourcefmt);
	int fullname = GetFlag(rn,k_fullname);
	if (fullname && prefix) {
	  String *sname = NewStringf("%s::%s", prefix, name);
	  Delete(name);
	  name = sname;
	  prefix = 0;
	}
	if (sfmt) {
	  String *sname = NewStringf(sfmt, name);
	  Delete(name);
	  name = sname;
	}
      }
    }
    if (rn) {
      String *newname = HashGetAttr(rn,k_name);
      int fullname = GetFlag(rn,k_fullname);
      result = apply_rename(newname, fullname, prefix, name);
    }
    if (result && !Equal(result,name)) {
      /* operators in C++ allow aliases, we look for them */
      char *cresult = Char(result);
      if (cresult && (strncmp(cresult,"operator ",9) == 0)) {
	String *nresult = Swig_name_make(n, prefix, result, decl, oldname);
	if (!Equal(nresult,result)) {
	  Delete(result);
	  result = nresult;
	} else {
	  Delete(nresult);
	}
      }
    }
    nname = result ? result : name;
    wrn = Swig_name_namewarn_get(n, prefix, nname, decl);
    if (wrn) {
      String *rename = HashGetAttr(wrn,k_rename);
      if (rename) {
	String *msg = HashGetAttr(wrn,k_name);
	int fullname = GetFlag(wrn,k_fullname);
	if (result) Delete(result);
	result = apply_rename(rename, fullname, prefix, name);
	if ((msg) && (Len(msg))) {
	  if (!Getmeta(nname,"already_warned")) {
	    if (n)  {
	      SWIG_WARN_NODE_BEGIN(n);
	      Swig_warning(0,Getfile(n), Getline(n), "%s\n", msg);
	      SWIG_WARN_NODE_END(n);
	    } else {
	      Swig_warning(0,Getfile(name),Getline(name), "%s\n", msg);
	    }
	    Setmeta(nname,"already_warned","1");
	  }
	}
      }
    }
  }
  if (!result || !Len(result)) {
    if (result) Delete(result);
    if (oldname) {
      result = NewString(oldname);
    } else {
      result = NewString(cname);
    }
  }
  Delete(name);
  
#ifdef SWIG_DEBUG
  Printf(stderr,"Swig_name_make: result  '%s' '%s'\n", cname, result); 
#endif

  return result;
}

/* -----------------------------------------------------------------------------
 * void Swig_name_inherit()
 *
 * Inherit namewarn,rename, and feature objects
 * 
 * ----------------------------------------------------------------------------- */

void Swig_name_inherit(String *base, String *derived) {
  /*  Printf(stderr,"base = '%s', derived = '%s'\n", base, derived); */
  Swig_name_object_inherit(Swig_name_rename_hash(),base,derived);
  Swig_name_object_inherit(Swig_name_namewarn_hash(),base,derived);
  Swig_name_object_inherit(Swig_cparse_features(),base,derived);
}
