/* ----------------------------------------------------------------------------- 
 * contract.cxx
 *
 *     Support for Design by Contract in SWIG
 * 
 * Author(s) : Songyan Feng (Tiger) (songyanf@cs.uchicago.edu)
 * 
 * Department of Computer Science
 * University of Chicago
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_contract_cxx[] = "$Header$";

#include "swigmod.h"

#define SWIG_PREASSERT "require:"
#define SWIG_POSTASSERT "ensure:"
#define SWIG_INVARIANT "invariant:"
#define SWIG_BEFORE "swig_before("
#define SWIG_AFTER "swig_after("

static int      InClass = 0;          /* Parsing C++ or not */
static Node    *CurrentClass = 0;
static int      InConstructor = 0;
static int      InDestructor = 0;

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
    
    if (!mark_invar) { // No invar-
      if (!mark_post) { // No post-
	if ( !mark_pre ) { // No pre-, default is preassert
	  preassert = contract;
	} else { // with pre- only
	  mark_pre[len_pre-1]='{';
	  mark_pre[len_pre]='\n';
	  preassert = mark_pre+len_pre-1;
	}
      } else { // with post-
	if (!mark_pre) { // with post- only, but maybe has preassert
	  preassert = contract;
	  mark_post[0] = '}';
	  mark_post[1] = '\0';	
	  mark_post[len_post-2] = '{';
	  mark_post[len_post-1] = '\n';
	  postassert = mark_post+len_post-2;
	} else { //with both pre- & post- marks
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
    } else { //with invar-mark
      if (!mark_post) { // No post- mark
	if ( !mark_pre ) { // with invar- only, but maybe has pre-
	  preassert = contract;
	  mark_invar[0] = '}';
	  mark_invar[1] = '\0';
	  mark_invar[len_invar-2] = '{';
	  mark_invar[len_invar-1] = '\n';
	  invariant = mark_invar+len_invar-2;
	} else { // with pre- & invar-, no postassert
	  mark_pre[len_pre-1]='{';
	  mark_pre[len_pre]='\n';
	  preassert = mark_pre+len_pre-1;
	  mark_invar[0] = '}';
	  mark_invar[1] = '\0';
	  mark_invar[len_invar-2] = '{';
	  mark_invar[len_invar-1] = '\n';
	  invariant = mark_invar+len_invar-2;
	}
      } else { // with invar- & post-
	if (!mark_pre) { // with post- & invar- only, but maybe has preassert
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
	} else { // with pre-, post- & invar-
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
    
    Setattr(n, "feature:preassert", preassert);
    Setattr(n, "feature:postassert", postassert);
    Setattr(n, "feature:invariant", invariant);
    Delete(contract);
    return SWIG_OK;
  }

  int AssertModify(Node *n, int flag) {
    String   *str_assert, *s, *tag, *tag_sync;
    List     *list_assert;
    ParmList *list_params;
 
    if (flag == 1) { // preassert
      str_assert = NewString(Getattr(n, "feature:preassert"));
      tag = NewString(" SWIG_preassert(");
    } else if (flag == 2){ //postassert
      str_assert = NewString(Getattr(n, "feature:postassert"));      
      tag = NewString(" SWIG_postassert(");
    } else if (flag == 3){
      str_assert = NewString(Getattr(n, "feature:invariant"));
      tag = NewString(" SWIG_invariant(");
    } else
      return SWIG_ERROR;

    // Modify format into { SWIG_xxxassert(...);\n ...}
    // Omit all unuseful characters and split by ;
    Replaceall(str_assert, "\n", "");
    Replaceall(str_assert, "{", "");
    Replaceall(str_assert, "}", "");
    Replaceall(str_assert, " ", "");
    list_assert = Split(str_assert, ';', -1);
    Delete(str_assert);

    // build up new assertion
    str_assert = NewString("{");
    for (s = Firstitem(list_assert); s; s = Nextitem(list_assert)) {
      if (Len(s)) {
	//Printf(stdout, "%s\n", s);
	if (Strstr(s, SWIG_BEFORE)) { //before sync assertion
	  tag_sync = NewString(" SWIG_sync(");
	  Append(tag_sync, Getattr(n, "name"));
	  Append(tag_sync, ", ");
	  Replaceall(s, SWIG_BEFORE, tag_sync);
	  Append(str_assert, s);
	  Append(str_assert, ";\n");
	  Delete(tag_sync);
	} else if (Strstr(s, SWIG_AFTER)) { //after sync assertion
	  tag_sync = NewString(" SWIG_sync(");
	  Replaceall(s, SWIG_AFTER, tag_sync);
	  Replaceall(s, ")", ", ");
	  Append(str_assert, s);
	  Append(str_assert, Getattr(n,"name"));
	  Append(str_assert, ");\n");
	  Delete(tag_sync);
	} else { // no sync assertion
	  Append(str_assert, tag);
	  Append(str_assert, s);
	  Append(str_assert, ");\n");
	}
      }
    }
    Append(str_assert, "}");

    // Set the params in preassert & postassert
    list_params = Getmeta(Getattr(n, "feature:contract"), "parms");
    if ((InClass) && (!InConstructor) && (!InDestructor)){
      // Insert function name as parm for class member functions
      String *type = NewString(Getattr(n,"type"));
      String *name = NewString("self");
      Parm *p = NewParm(type, name);
      set_nextSibling(p, list_params);
      list_params = p;
     }
    Setmeta(str_assert, "parms", list_params);

    if (flag == 1) {
      Replaceid(str_assert, Getattr(n,"name"), "result");
      Setattr(n, "feature:preassert", str_assert);
    } else if (flag == 2) {
      Replaceid(str_assert, Getattr(n,"name"), "result");
      Setattr(n, "feature:postassert", str_assert);
   } else {
      Setattr(n, "feature:invariant", str_assert);
    }

    Delete(list_assert);
    Delete(list_params);
    Delete(s);
    Delete(tag);
    return SWIG_OK;
  }

  int emit_contract(Node *n) {
    int   ret = SWIG_OK;
    if (!Getattr(n, "feature:contract"))
      return SWIG_ERROR;
    //Printf(stdout, "--------In emit_contract code:\nname is : %s\n",
    //	   Getattr(n,"name"));
    // Split contract into preassert & postassert
    if (!SliptContract(n))
      return SWIG_ERROR;
    
    // Modify pre- , post- * invar-
    ret = AssertModify(n, 1);
    ret = AssertModify(n, 2);
    ret = AssertModify(n, 3);
    /*
    Printf(stdout, "preassert after Setmeta :\n%s\n",
    	   Getattr(n, "feature:preassert"));
    Printf(stdout, "postassert after Setmeta :\n%s\n",
	   Getattr(n, "feature:postassert"));
    Printf(stdout, "invariant after Setmeta :\n%s\n",
	   Getattr(n, "feature:invariant"));
    */
    return ret;
  }

  /*
  virtual int emit_one(Node *n) {
    int   ret = SWIG_OK;
    char *tag = Char(nodeType(n));

    if (!n) return SWIG_OK;
    
    if (strcmp(tag,"include") == 0)
      ret = emit_children(n);
    else if (strcmp(tag, "top") == 0)
      ret = top(n);
    else if (Getattr(n, "feature:contract")) {
      ret = emit_contract(n);
    }
    return ret;
  }
  */
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
