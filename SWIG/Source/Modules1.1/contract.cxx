/* ----------------------------------------------------------------------------- 
 * contract.cxx
 *
 *     Experimental support for contracts
 * 
 * Author(s) : Aquinas Hobor (aahobor@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_contract_cxx[] = "$Header$";

#include "swigmod.h"

class Contracts : public Dispatcher {

public:
  virtual int top(Node *n) {
    emit_children(n);
    return SWIG_OK;
  }

  virtual int importDirective(Node *n) { return emit_children(n); }
  virtual int includeDirective(Node *n) { return emit_children(n); }  // ?
  virtual int externDeclaration(Node *n) { return emit_children(n); }

  String * strParms(ParmList *l) {
    int comma = 0;
    int i = 0;
    Parm *p = l;
    SwigType *pt;
    String * returns = NewString("");
    while(p) {
      String *pname;
      pt = Getattr(p,"type");
      if ((SwigType_type(pt) != T_VOID)) {
	if (comma) Printf(returns,",");
	pname = Swig_cparm_name(p,i);
	Printf(returns,"%s",SwigType_rcaststr(pt,pname));
	comma = 1;
	i++;
      }
      p = nextSibling(p);
    }
    return returns;
  }

  virtual int cDeclaration(Node *n) {
    String *name = Getattr(n,"name");
    String *k = Getattr(n,"feature:contract");

    if(k)
    {
      /* make the names */
      ParmList *l = Getmeta(k,"parms");
      String *params = ParmList_str(l);
      String *transformed = strParms(l);
      if(DohStrcmp(params,"")==0) {
	DohDelete(params);
	params = DohNewString("void");
      }
      String *contractName = DohNewStringf("__SWIG_precontract_%s",name);

      /* make the contract */
      String *contract = DohNewStringf("int %s(%s,int rt[2])\n{\n",contractName,params);
      SwigScanner * ss = NewSwigScanner();
      SwigScanner_clear(ss);
      SwigScanner_push(ss,Copy(k));
      SwigScanner_token(ss);  // Get rid of the '{' at the begining

      /* loop over the clauses */
      int clauseNum = 1;
      int token = -1;
      while(1) {
	String *clause = DohNewString(""); /*BUG -- should free*/
	while((token=SwigScanner_token(ss))) {
	  if ((token==SWIG_TOKEN_SEMI)||(token==SWIG_TOKEN_RBRACE))
	    break;
	  //	  if (token != SWIG_TOKEN_ENDLINE)
	    Printf(clause,"%s",SwigScanner_text(ss));
	}
	if (DohStrcmp(clause,"\n") != 0) {
	  Printf(contract,"if (!(%s",clause);
	  Printf(contract,")) {\nrt[0]=__LINE__;\nrt[1]=%i;\nreturn 1;\n}\n",clauseNum);
	}
	if(token==SWIG_TOKEN_RBRACE) break;
	clauseNum++;
      }

      /* finish it off and attach it to the main tree */
      Printf(contract,"return 0;\n}\n");
      Setattr(n,"wrap:code",contract); /*BUG -- WHAT IF SOMETHING IS ALREADY THERE*/
      
      /*  Generate the calling code */
      String * calling = DohNewString("{\nint cfail[2];\nchar message[255];\n");
      Printf(calling,"if (%s(%s,cfail)) {\n",contractName,transformed);
      Printf(calling,"sprintf(message,\"Contract %s failed on clause %%i (line %%i)!\",cfail[1],cfail[0]);\n",contractName);
      Printf(calling,"PyErr_SetString(PyExc_Exception,message);return NULL;\n}\n");
      Printf(calling,"}\n");
      /*      Setattr(n,"feature:preassert",calling); */
    }
    /*There are two attributes "feature:preassert" and "feature:postassert".*/

    
    return SWIG_OK;
  }

};

void Swig_contracts(Node *n) {
  Printf(stdout,"Applying contracts (experimental v0.09)\n");

  Contracts *a = new Contracts;
  a->top(n);
  delete a;

}
