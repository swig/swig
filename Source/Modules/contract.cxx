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

#define SWIG_PREASSERT   "require:"
#define SWIG_POSTASSERT  "ensure:"
#define SWIG_INVARIANT   "invariant:"
#define SWIG_BEFORE      "swig_before("
#define SWIG_AFTER       "swig_after("

static int      Contract_Mode = 0;    /* contract option */

static int      InClass = 0;          /* Parsing C++ or not */
static Node    *CurrentClass = 0;
static int      InConstructor = 0;
static int      InDestructor = 0;

void Swig_contract_mode_set(int flag) {
  Contract_Mode = flag;
}

int Swig_contract_mode_get() {
  return Contract_Mode;
}

class Contracts : public Dispatcher {

public: 
  
  int SliptContract(Node *n) {
    String *contract   = Getattr(n, "feature:contract");  
    if (!contract)
      return SWIG_ERROR;
    String *preassert  = NewString("");
    String *postassert = NewString("");
    String *invariant  = NewString("");
    char   *mark_pre   = Strstr(contract, SWIG_PREASSERT);
    char   *mark_post  = Strstr(contract, SWIG_POSTASSERT);
    char   *mark_invar = Strstr(contract, SWIG_INVARIANT);
    int    len_pre     = Len(SWIG_PREASSERT);
    int    len_post    = Len(SWIG_POSTASSERT);
    int    len_invar   = Len(SWIG_INVARIANT);
    
    if (!mark_invar) { /* No invar- */
      if (!mark_post) { /* No post- */
	if ( !mark_pre ) { /* No pre-, default is preassert */
	  preassert = contract;
	} else { /* with pre- only */
	  mark_pre[len_pre-1]='{';
	  mark_pre[len_pre]='\n';
	  preassert = mark_pre+len_pre-1;
	}
      } else { /* with post- */
	if (!mark_pre) { /* with post- only, but maybe has preassert */
	  preassert = contract;
	  mark_post[0] = '}';
	  mark_post[1] = '\0';	
	  mark_post[len_post-2] = '{';
	  mark_post[len_post-1] = '\n';
	  postassert = mark_post+len_post-2;
	} else { /* with both pre- & post- marks */
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
    } else { /* with invar-mark */
      if (!mark_post) { /* No post- mark */
	if ( !mark_pre ) { /* with invar- only, but maybe has pre- */
	  preassert = contract;
	  mark_invar[0] = '}';
	  mark_invar[1] = '\0';
	  mark_invar[len_invar-2] = '{';
	  mark_invar[len_invar-1] = '\n';
	  invariant = mark_invar+len_invar-2;
	} else { /* with pre- & invar-, no postassert */
	  mark_pre[len_pre-1]='{';
	  mark_pre[len_pre]='\n';
	  preassert = mark_pre+len_pre-1;
	  mark_invar[0] = '}';
	  mark_invar[1] = '\0';
	  mark_invar[len_invar-2] = '{';
	  mark_invar[len_invar-1] = '\n';
	  invariant = mark_invar+len_invar-2;
	}
      } else { /* with invar- & post- */
	if (!mark_pre) { /* with post- & invar- only, but maybe has preassert */
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
	} else { /* with pre-, post- & invar- */
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
    
    Setattr(n, "feature:preassert",  preassert);
    Setattr(n, "feature:postassert", postassert);
    Setattr(n, "feature:invariant",  invariant);
    Delete(contract);
    return SWIG_OK;
  }

  int AssertModify(Node *n, int flag) {
    String   *str_assert, *expr, *tag_sync;
    List     *list_assert;
 
    if (flag == 1) { /* preassert */
      str_assert = NewString(Getattr(n, "feature:preassert"));
    } else if (flag == 2){ /* postassert */
      str_assert = NewString(Getattr(n, "feature:postassert"));      
    } else if (flag == 3){ /* invariant */
      str_assert = NewString(Getattr(n, "feature:invariant"));
    } else
      return SWIG_ERROR;
    
    /* Omit all unuseful characters and split by ; */
    Replaceall(str_assert, "\n", "");
    Replaceall(str_assert, "{", "");
    Replaceall(str_assert, "}", "");
    Replaceall(str_assert, " ", "");
    list_assert = Split(str_assert, ';', -1);
    Delete(str_assert);

    /* build up new assertion */
    str_assert = NewString("");
    for (expr = Firstitem(list_assert); expr; expr = Nextitem(list_assert)) {
      if (Len(expr)) {
	/* All sync staff are not complete and only experimental */
	if (Strstr(expr, SWIG_BEFORE)) { /* before sync assertion */
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
	} else { /* no sync assertion, only basic pre- post-, invar- */
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
    Delete(expr);
    return SWIG_OK;
  }

  /* Modify format into { SWIG_xxxassert(...);\n ...} */
  int AssertAddTag(Node *n) {
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
  int AssertAddErrorMsg(Node *n) {
    String   *str_assert, *error_msg;
    /* preassert */
    str_assert = NewString(Getattr(n, "feature:preassert"));
    Replaceall(str_assert, ");\n", "");
    if (Len(str_assert)) {
      error_msg = NewString("\\nRequire assertion violation,");
      Printf(error_msg, "in function of <<%s>>\\n", Getattr(n, "name"));
      Printf(str_assert, ", \"%s\");\n", error_msg);
      Setattr(n, "feature:preassert", str_assert);
      Delete(error_msg);
    }
    Delete(str_assert);

    /* postassert */
    str_assert = NewString(Getattr(n, "feature:postassert"));
    Replaceall(str_assert, ");\n", "");
    if (Len(str_assert)) {
      error_msg = NewString("\\nEnsure assertion violation,");
      Printf(error_msg, "in function of <<%s>>\\n", Getattr(n, "name"));
      Printf(str_assert, ", \"%s\");\n", error_msg);
      Setattr(n, "feature:postassert", str_assert);
      Delete(error_msg);
    }
    Delete(str_assert);

   /* invariant */
    str_assert = NewString(Getattr(n, "feature:invariant"));
    Replaceall(str_assert, ");\n", "");
    if (Len(str_assert)) {
      error_msg = NewString("\\nInvariant assertion violation,");
      Printf(error_msg, "in function of <<%s>>\\n", Getattr(n, "name"));
      Printf(str_assert, ", \"%s\");\n", error_msg);
      Setattr(n, "feature:invariant", str_assert);
      Delete(error_msg);
    }
    Delete(str_assert);
    return SWIG_OK;
  }
  
  int AssertSetParms(Node *n) {
    ParmList *list_params;
    String   *str_assert_pre,*str_assert_post,*str_assert_invar;
    
    str_assert_pre   = NewString(Getattr(n, "feature:preassert"));
    str_assert_post  = NewString(Getattr(n, "feature:postassert"));      
    str_assert_invar = NewString(Getattr(n, "feature:invariant"));

    /* Set the params in preassert & postassert */
    list_params = Getmeta(Getattr(n, "feature:contract"), "parms");
    if ((InClass) && (!InConstructor) && (!InDestructor)){
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

    Setattr(n, "feature:preassert",  str_assert_pre);
    Setattr(n, "feature:postassert", str_assert_post);
    Setattr(n, "feature:invariant",  str_assert_invar);
    
    Delete(list_params);
    Delete(str_assert_pre);
    Delete(str_assert_post);
    Delete(str_assert_invar);
    return SWIG_OK;
  }

  int emit_contract(Node *n) {
    int   ret = SWIG_OK;
    if (!Getattr(n, "feature:contract"))
      return SWIG_ERROR;
    /* Printf(stdout, "--------In emit_contract code:\nname is : %s\n",
       Getattr(n,"name")); */

    /*  Split contracqt into preassert & postassert */    
    if (!SliptContract(n))
      return SWIG_ERROR;
    
    /* Modify pre- , post- * invar- */
    ret = ret && AssertModify(n, 1);
    ret = ret && AssertModify(n, 2);
    ret = ret && AssertModify(n, 3);
    ret = ret && AssertAddTag(n);
    ret = ret && AssertAddErrorMsg(n);
    ret = ret && AssertSetParms(n);
    return ret;
  }

  int cDeclaration(Node *n) {
    int ret = SWIG_OK;
    if (Getattr(n, "feature:contract"))
      ret = emit_contract(n);
    return ret;
  }

  int constructorDeclaration(Node  *n){
    int ret = SWIG_OK;
    InConstructor = 1;
    if (Getattr(n, "feature:contract"))
      ret = emit_contract(n);
    InConstructor = 0;
    return ret;
  }

  int destructorDeclaration(Node  *n){
    int ret = SWIG_OK;
    InDestructor = 1;
    if (Getattr(n, "feature:contract"))
      ret = emit_contract(n);
    InDestructor = 0;
    return ret;
  }

  int externDeclaration(Node *n) { return emit_children(n); }
  int extendDirective(Node *n) { return emit_children(n); }
  int importDirective(Node *n) { return emit_children(n); }
  int includeDirective(Node *n) { return emit_children(n); }

  int classDeclaration(Node *n) {
    int ret = SWIG_OK;
    InClass = 1;
    CurrentClass = n; 
    ret = classHandler(n);
    InClass = 0;
    CurrentClass = 0;
    return ret;
  }

  int classHandler(Node *n) {
    emit_children(n);
    return SWIG_OK;
  }

  virtual int top(Node *n) {
    emit_children(n);
    return SWIG_OK;
  }
};

void Swig_contracts(Node *n) {
  Printf(stdout,"Applying contracts (experimental version)\n");

  Contracts *a = new Contracts;
  a->top(n);
  delete a;
}
