/* ----------------------------------------------------------------------------- 
 * contract.cxx
 *
 *     Support for Wrap by Contract in SWIG
 * 
 * Author(s) : Songyan Feng (Tiger) (songyanf@cs.uchicago.edu)
 * 
 * Department of Computer Science
 * University of Chicago
 *
 * Copyright (C) 1999-2003.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_contract_cxx[] = "$Header$";

#include "swigmod.h"


/************************************************************************
 * class Contracts:
 *
 * This class defines the functions that need to be used in 
 *         "wrap by contract" module.
 *************************************************************************/

class Contracts : public Dispatcher {
public:
  int ContractSplit(Node *n);
  int AssertModify(Node *n, int flag);
  int InheritModify(Node *n);
  int InheritAssertAppend(Node *n, Node *bases); 
  int AssertAddTag(Node *n);
  int AssertAddErrorMsg(Node *n);
  int AssertSetParms(Node *n);

  int emit_contract(Node *n);
  int cDeclaration(Node *n);
  int constructorDeclaration(Node  *n);
  int destructorDeclaration(Node  *n);
  int externDeclaration(Node *n);
  int extendDirective(Node *n);
  int importDirective(Node *n);
  int includeDirective(Node *n);
  int classDeclaration(Node *n);
  int classHandler(Node *n);
  virtual int top(Node *n);
};

extern void Swig_contracts(Node *n);
extern void Swig_contract_mode_set(int flag);
extern int  Swig_contract_mode_get();

#define SWIG_PREASSERT    "require:"
#define SWIG_POSTASSERT   "ensure:"
#define SWIG_INVARIANT    "invariant:"
#define SWIG_BEFORE       "swig_before("
#define SWIG_AFTER        "swig_after("
#define SWIG_CONTRACT_SET "SET"

static int      Contract_Mode = 0;    /* contract option */

static int      InClass       = 0;    /* Parsing C++ or not */
static int      InConstructor = 0;
static int      InDestructor  = 0;
static Node    *CurrentClass  = 0;

/* Set the contract mode, default is 0 (not open) */
/* Normally set in main.cxx, when get the "-contracts" option */
void Swig_contract_mode_set(int flag) {
  Contract_Mode = flag;
}

/* Get the contract mode */
int Swig_contract_mode_get() {
  return Contract_Mode;
}

/* Apply contracts */
void Swig_contracts(Node *n) {
  Printf(stdout,"Applying contracts (experimental version)\n");

  Contracts *a = new Contracts;
  a->top(n);
  delete a;
}

/* Split the whole contract into preassertion, postassertion and others */
int Contracts::ContractSplit(Node *n) {
  String *contract   = Getattr(n, "feature:contract");  
  if (!contract)
    return SWIG_ERROR;

  String *preassert  = NewString(""); /* preassertion */
  String *postassert = NewString("");
  String *invariant  = NewString("");
  char   *mark_pre   = Strstr(contract, SWIG_PREASSERT); /* position of preassertion in whole contract */
  char   *mark_post  = Strstr(contract, SWIG_POSTASSERT);
  char   *mark_invar = Strstr(contract, SWIG_INVARIANT);
  int    len_pre     = Len(SWIG_PREASSERT); /* length of preassertion */
  int    len_post    = Len(SWIG_POSTASSERT);
  int    len_invar   = Len(SWIG_INVARIANT);
  
  if (!mark_invar) {     /* No invar- */
    if (!mark_post) {    /* No post- */
      if ( !mark_pre ) { /* No pre-, default is preassert */
	preassert = contract;
      } else {           /* with pre- only */
	mark_pre[len_pre-1]='{';
	mark_pre[len_pre]='\n';
	preassert = mark_pre+len_pre-1; /* strcpy? */
      }
    } else {             /* with post- */
      if (!mark_pre) {   /* with post- only, but maybe has preassert */
	preassert = contract;
	mark_post[0] = '}';
	mark_post[1] = '\0';	
	mark_post[len_post-2] = '{';
	mark_post[len_post-1] = '\n';
	postassert = mark_post+len_post-2;
      } else {           /* with both pre- & post- marks */
	mark_pre[len_pre-1]='{';
	mark_pre[len_pre]='\n';
	preassert = mark_pre+len_pre-1;
	mark_post[0] = '}';
	mark_post[1] = '\0';
	mark_post[len_post-2] = '{';
	mark_post[len_post-1] = '\n';
	postassert = mark_post+len_post-2;
      }
    }
  } else {               /* with invar-mark */
    if (!mark_post) {    /* No post- mark */
      if ( !mark_pre ) { /* with invar- only, but maybe has pre- */
	preassert = contract;
	mark_invar[0] = '}';
	mark_invar[1] = '\0';
	mark_invar[len_invar-2] = '{';
	mark_invar[len_invar-1] = '\n';
	invariant = mark_invar+len_invar-2;
      } else {           /* with pre- & invar-, no postassert */
	mark_pre[len_pre-1]='{';
	mark_pre[len_pre]='\n';
	preassert = mark_pre+len_pre-1;
	mark_invar[0] = '}';
	mark_invar[1] = '\0';
	mark_invar[len_invar-2] = '{';
	mark_invar[len_invar-1] = '\n';
	invariant = mark_invar+len_invar-2;
      }
    } else {             /* with invar- & post- */
      if (!mark_pre) {   /* with post- & invar- only, but maybe has preassert */
	preassert = contract;
	mark_post[0] = '}';
	mark_post[1] = '\0';	
	mark_post[len_post-2] = '{';
	mark_post[len_post-1] = '\n';
	postassert = mark_post+len_post-2;
	mark_invar[0] = '}';
	mark_invar[1] = '\0';
	mark_invar[len_invar-2] = '{';
	mark_invar[len_invar-1] = '\n';
	invariant = mark_invar+len_invar-2;
      } else {           /* with pre-, post- & invar- */
	mark_pre[len_pre-1]='{';
	mark_pre[len_pre]='\n';
	preassert = mark_pre+len_pre-1;
	mark_post[0] = '}';
	mark_post[1] = '\0';	
	mark_post[len_post-2] = '{';
	mark_post[len_post-1] = '\n';
	postassert = mark_post+len_post-2;
	mark_invar[0] = '}';
	mark_invar[1] = '\0';
	mark_invar[len_invar-2] = '{';
	mark_invar[len_invar-1] = '\n';
	invariant = mark_invar+len_invar-2;	
      }
    }
  }
  if (Len(preassert))    Setattr(n, "feature:preassert",  preassert);
  if (Len(postassert))   Setattr(n, "feature:postassert", postassert);
  if (Len(invariant))    Setattr(n, "feature:invariant",  invariant);

  Delete(contract);
  return SWIG_OK;
}

/* Modify the contract inheritance */
int Contracts::InheritModify(Node *n) {
  Node     *parent, *bases;
  String   *str_assert_pre, *str_assert_post;

  /* Set the preassert to the inherit_preassert as the basic inherit */
  str_assert_pre = Getattr(n, "feature:preassert");
  if (Len(str_assert_pre) != 0)
    Setattr(n, "feature:inherit_preassert",  str_assert_pre);
  /* Set the postassert to the inherit_postassert as the basic inherit */
  str_assert_post = Getattr(n, "feature:postassert");
  if (Len(str_assert_post) != 0)
    Setattr(n, "feature:inherit_postassert",  str_assert_post);

  parent = parentNode(n); /* class node of function node n */
  if (!parent)
    return SWIG_OK;
  
  bases = Getattr(parent, "bases"); /* base class list of current class */
  if (!bases)
    return SWIG_OK;

  InheritAssertAppend(n, bases);
  return SWIG_OK;
}

int Contracts::InheritAssertAppend(Node *n, Node *bases) {
  /* check whether the method is inherited from the base */
  /* if inherited, then AND the ancestor's preassertion to its own preassertion */
  /* OR its own postassertion to the ancestor's postassertion */ 
  String  *str_assert_pre;
  String  *str_inherit_pre;
  String  *str_assert_post;
  String  *str_inherit_post;

  Node    *b, *temp_base;
  String  *local_name, *local_type, *local_decl, *base_decl;

  int      defined = 0;

  if ( (!n) || (!bases) )
    return 0;
  if (!Getattr(n, "feature:contract"))
    return 0;
  
  local_name = Getattr(n, "name");
  local_type = Getattr(n, "type");
  local_decl = Getattr(n, "decl");
  if (local_decl) {
    local_decl = SwigType_typedef_resolve_all(local_decl);
  } else {
    return 0;
  }
  
  str_inherit_pre = NewString(Getattr(n, "feature:inherit_preassert"));
  str_assert_post = NewString(Getattr(n, "feature:postassert"));      
  if ( (Len(str_inherit_pre)==0) && ((Len(str_assert_post) ==0)) )
    return 0; /* no need to modify inheritance of assertions */
  
  /* Width first search */
  for (int i = 0; i < Len(bases); i++) {
    b = Getitem(bases,i);
    temp_base = firstChild (b); /* member function/variable of the base class */

    while (temp_base) {
      base_decl = Getattr(temp_base, "decl");
      if (base_decl) {
	base_decl = SwigType_typedef_resolve_all(base_decl);
	if ( (checkAttribute(temp_base, "name", local_name)) &&
	     (checkAttribute(temp_base, "type", local_type)) &&
	     (!Strcmp(local_decl, base_decl)) ) {
	  /* same declaration in base,  append the the base pre to the current inherit_perassertion */
	  str_assert_pre   = NewString(Getattr(temp_base, "feature:preassert"));
	  if ( (Len(str_assert_pre))  && (Len(str_inherit_pre)) ) {
	    Printf(str_inherit_pre,  " && %s", str_assert_pre);
	  }
	  str_inherit_post = NewString(Getattr(temp_base, "feature:inherit_postassert"));
	  if ( (Len(str_assert_post)) && (Len(str_inherit_post)) ) {
	    Printf(str_inherit_post, " || %s", str_assert_post);
	    Setattr(temp_base, "feature:inherit_postassert",  str_inherit_post);
	  }
	  
	  Delete(str_assert_pre);
	  Delete(str_inherit_post);
	  defined = 1;
	}
	Delete(base_decl);
      } /* end of if */
      temp_base = nextSibling(temp_base);
    } /* end of while(temp) */
  } /* end of i */

  if (Len(str_inherit_pre))
    Setattr(n, "feature:inherit_preassert",  str_inherit_pre);
  Delete(local_decl);
  Delete(str_inherit_pre);
  Delete(str_assert_post);
  
  /* recursive search */
  for (int j = 0; j < Len(bases); j++) {
    b = Getitem(bases,j);
    if (InheritAssertAppend(n, Getattr(b, "bases")))
      defined = 1;
  }
  if (defined)
    return 1;
  return 0;
}

int Contracts::AssertModify(Node *n, int flag) {
  String   *str_assert, *expr = 0, *tag_sync;
  List     *list_assert;
  
  if (flag == 1) {       /* preassert */
    str_assert = NewString(Getattr(n, "feature:preassert"));
  } else if (flag == 2){ /* postassert */
    str_assert = NewString(Getattr(n, "feature:postassert"));      
  } else if (flag == 3){ /* invariant */
    str_assert = NewString(Getattr(n, "feature:invariant"));
  } else
    return SWIG_ERROR;
  
  if (!Len(str_assert))
    return SWIG_OK;
  
  /* Omit all unuseful characters and split by ; */
  Replaceall(str_assert, "\n", "");
  Replaceall(str_assert, "{", "");
  Replaceall(str_assert, "}", "");
  Replaceall(str_assert, " ", "");
  list_assert = Split(str_assert, ';', -1);
  Delete(str_assert);
  
  /* build up new assertion */
  str_assert = NewString("");
  Iterator ei;

  for (ei = First(list_assert); ei.item; ei = Next(ei)) {
    expr = ei.item;
    if (Len(expr)) {
      /* All sync staff are not complete and only experimental */
      if (Strstr(expr, SWIG_BEFORE)) {       /* before sync assertion */
	tag_sync = NewString(" SWIG_sync(");
	Append(tag_sync, Getattr(n, "name"));
	Append(tag_sync, ", ");
	Replaceall(expr, SWIG_BEFORE, tag_sync);
	Append(str_assert, expr);
	Append(str_assert, ";\n");
	Delete(tag_sync);
      } else if (Strstr(expr, SWIG_AFTER)) { /* after sync assertion */
	tag_sync = NewString(" SWIG_sync(");
	Replaceall(expr, SWIG_AFTER, tag_sync);
	Replaceall(expr, ")", ", ");
	Append(str_assert, expr);
	Append(str_assert, Getattr(n,"name"));
	Append(str_assert, ");\n");
	Delete(tag_sync);
      } else {                               /* no sync assertion, only basic pre- post-, invar- */
	Replaceid(expr, Getattr(n,"name"), "result");
	if (Len(str_assert))
	  Append(str_assert, "&&");
	Printf(str_assert, "(%s)", expr);
      }
    }
  }

  if (flag == 1) {
    Setattr(n, "feature:preassert",  str_assert);
  } else if (flag == 2) {
    Setattr(n, "feature:postassert", str_assert);
  } else {
    Setattr(n, "feature:invariant",  str_assert);
  }
  
  Delete(str_assert);
  Delete(list_assert);
  return SWIG_OK;
}

/* Modify format into { SWIG_xxxassert(...);\n ...} */
int Contracts::AssertAddTag(Node *n) {
  String   *str_assert, *tag;
  /* preassert */
  str_assert = NewString(Getattr(n, "feature:preassert"));
  if (Len(str_assert)) {
    tag = NewString(" SWIG_preassert(");
    Append(tag, str_assert);
    Append(tag, ");\n");
    Setattr(n, "feature:preassert", tag);
    Delete(tag);
  }
  Delete(str_assert);

  /* inherit_preassert */
  str_assert = NewString(Getattr(n, "feature:inherit_preassert"));
  if (Len(str_assert)) {
    tag = NewString(" SWIG_inherit_preassert((");
    Append(tag, str_assert);
    Append(tag, "));\n");
    Setattr(n, "feature:inherit_preassert", tag);
    Delete(tag);
  }
  Delete(str_assert);
  
  /* postassert */
  str_assert = NewString(Getattr(n, "feature:postassert"));
  if (Len(str_assert)) {
    tag = NewString(" SWIG_postassert(");
    Append(tag, str_assert);
    Append(tag, ");\n");
    Setattr(n, "feature:postassert", tag);
    Delete(tag);
  }
  Delete(str_assert);
  
  /* inherit_postassert */
  str_assert = NewString(Getattr(n, "feature:inherit_postassert"));
  if (Len(str_assert)) {
    tag = NewString(" SWIG_inherit_postassert((");
    Append(tag, str_assert);
    Append(tag, "));\n");
    Setattr(n, "feature:inherit_postassert", tag);
    Delete(tag);
  }
  Delete(str_assert);
  
  /* invariant */
  str_assert = NewString(Getattr(n, "feature:invariant"));
  if (Len(str_assert)) {
    tag = NewString(" SWIG_invariant(");
    Append(tag, str_assert);
    Append(tag, ");\n");
    Setattr(n, "feature:invariant", tag);
    Delete(tag);
  }
  Delete(str_assert);
  return SWIG_OK;
}

/* Append error message */
int Contracts::AssertAddErrorMsg(Node *n) {
  String   *str_assert, *error_msg;
  /* preassert */
  str_assert = NewString(Getattr(n, "feature:preassert"));
  Replaceall(str_assert, ");\n", "");
  if (Len(str_assert)) {
    error_msg = NewString("Require assertion violation, ");
    Printf(error_msg, "in function %s", Getattr(n, "name"));
    Printf(str_assert, ", \"%s\");\n", error_msg);
    Setattr(n, "feature:preassert", str_assert);
    Delete(error_msg);
  }
  Delete(str_assert);

  /* inherit_preassert */
  str_assert = NewString(Getattr(n, "feature:inherit_preassert"));
  Replaceall(str_assert, ");\n", "");
  if (Len(str_assert)) {
    error_msg = NewString("Inherited require assertion violation, ");
    Printf(error_msg, "in function %s", Getattr(n, "name"));
    Printf(str_assert, ", \"%s\");\n", error_msg);
    Setattr(n, "feature:inherit_preassert", str_assert);
    Delete(error_msg);
  }
  Delete(str_assert);
  
  /* postassert */
  str_assert = NewString(Getattr(n, "feature:postassert"));
  Replaceall(str_assert, ");\n", "");
  if (Len(str_assert)) {
    error_msg = NewString("Ensure assertion violation, ");
    Printf(error_msg, "in function of %s", Getattr(n, "name"));
    Printf(str_assert, ", \"%s\");\n", error_msg);
    Setattr(n, "feature:postassert", str_assert);
    Delete(error_msg);
  }
  Delete(str_assert);
  
  /* inherit_postassert */
  str_assert = NewString(Getattr(n, "feature:inherit_postassert"));
  Replaceall(str_assert, ");\n", "");
  if (Len(str_assert)) {
    error_msg = NewString("Inherited ensure assertion violation, ");
    Printf(error_msg, "in function of %s", Getattr(n, "name"));
    Printf(str_assert, ", \"%s\");\n", error_msg);
    Setattr(n, "feature:inherit_postassert", str_assert);
    Delete(error_msg);
  }
  Delete(str_assert);
  
  /* invariant */
  str_assert = NewString(Getattr(n, "feature:invariant"));
  Replaceall(str_assert, ");\n", "");
  if (Len(str_assert)) {
    error_msg = NewString("Invariant assertion violation, ");
    Printf(error_msg, "in function of %s", Getattr(n, "name"));
    Printf(str_assert, ", \"%s\");\n", error_msg);
    Setattr(n, "feature:invariant", str_assert);
    Delete(error_msg);
  }
  Delete(str_assert);
  return SWIG_OK;
}

int Contracts::AssertSetParms(Node *n) {
  ParmList *list_params;
  String   *str_assert_pre,*str_assert_post,*str_assert_invar;
  String   *str_inherit_pre, *str_inherit_post;

  str_assert_pre   = NewString(Getattr(n, "feature:preassert"));
  str_assert_post  = NewString(Getattr(n, "feature:postassert"));      
  str_assert_invar = NewString(Getattr(n, "feature:invariant"));
  str_inherit_pre  = NewString(Getattr(n, "feature:inherit_preassert"));
  str_inherit_post = NewString(Getattr(n, "feature:inherit_postassert"));

  /* Set the params in preassert & postassert */
  list_params = Getmeta(Getattr(n, "feature:contract"), "parms");
  if (Getattr(n, "feature:contract_classparm")){
    /* Insert function name as parm for class member functions */
    String *type = NewString(Getattr(n,"type"));
    String *name = NewString("self");
    Parm *p = NewParm(type, name);
    set_nextSibling(p, list_params);
    list_params = p;
  }
  Setmeta(str_assert_pre,   "parms", list_params);
  Setmeta(str_assert_post,  "parms", list_params);
  Setmeta(str_assert_invar, "parms", list_params);
  Setmeta(str_inherit_pre,  "parms", list_params);
  Setmeta(str_inherit_post, "parms", list_params);
  
  if (Len(str_assert_pre))
    Setattr(n, "feature:preassert",  str_assert_pre);
  if (Len(str_assert_post))
    Setattr(n, "feature:postassert", str_assert_post);
  if (Len(str_assert_invar))
    Setattr(n, "feature:invariant",  str_assert_invar);
  if (Len(str_inherit_pre))
    Setattr(n, "feature:inherit_preassert",  str_inherit_pre);
  if (Len(str_inherit_post))
    Setattr(n, "feature:inherit_postassert",  str_inherit_post);
  
  Delete(list_params);
  Delete(str_assert_pre);
  Delete(str_assert_post);
  Delete(str_assert_invar);
  Delete(str_inherit_pre);
  Delete(str_inherit_post);
  return SWIG_OK;
}

int Contracts::emit_contract(Node *n) {
  int   ret = SWIG_OK;
  
  if (!Getattr(n, "feature:contract"))
    return SWIG_ERROR;

  /*  Split contracqt into preassert & postassert */    
  if (!ContractSplit(n))
    return SWIG_ERROR;
  
  /* Modify pre- , post- * invar- */
  ret = ret && AssertModify(n, 1);
  ret = ret && AssertModify(n, 2);
  ret = ret && AssertModify(n, 3);
  ret = ret && InheritModify(n);
  if ((InClass) && (!InConstructor) && (!InDestructor)){
    Setattr(n, "feature:contract_classparm",  SWIG_CONTRACT_SET);
  }
  /* Add tags and error msgs later when emit,
     and keep assertions as experisions in the parse tree */ 
  
  AssertAddTag(n);
  AssertAddErrorMsg(n);
  AssertSetParms(n);

  return ret;
}

int Contracts::cDeclaration(Node *n) {
  int ret = SWIG_OK;
  if (Getattr(n, "feature:contract"))
    ret = emit_contract(n);
  return ret;
}

int Contracts::constructorDeclaration(Node  *n){
  int ret = SWIG_OK;
  InConstructor = 1;
  if (Getattr(n, "feature:contract"))
    ret = emit_contract(n);
  InConstructor = 0;
  return ret;
}

int Contracts::destructorDeclaration(Node  *n){
  int ret = SWIG_OK;
  InDestructor = 1;
  if (Getattr(n, "feature:contract"))
    ret = emit_contract(n);
  InDestructor = 0;
  return ret;
}

int Contracts::externDeclaration(Node *n) { return emit_children(n); }
int Contracts::extendDirective(Node *n)   { return emit_children(n); }
int Contracts::importDirective(Node *n)   { return emit_children(n); }
int Contracts::includeDirective(Node *n)  { return emit_children(n); }

int Contracts::classDeclaration(Node *n) {
  int ret = SWIG_OK;
  InClass = 1;
  CurrentClass = n; 
  ret = classHandler(n);
  InClass = 0;
  CurrentClass = 0;
  return ret;
}

int Contracts::classHandler(Node *n) {
  emit_children(n);
  return SWIG_OK;
}

int Contracts::top(Node *n) {
  emit_children(n);
  return SWIG_OK;
}
