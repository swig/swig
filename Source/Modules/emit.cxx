/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * emit.cxx
 *
 * Useful functions for emitting various pieces of code.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include "cparse.h"

/* -----------------------------------------------------------------------------
 * emit_return_variable()
 *
 * Emits a variable declaration for a function return value.
 * The variable name is always called result.
 * n => Node of the method being wrapped
 * rt => the return type
 * f => the wrapper to generate code into
 * ----------------------------------------------------------------------------- */

void emit_return_variable(Node *n, SwigType *rt, Wrapper *f) {

  if (!GetFlag(n, "tmap:out:optimal")) {
    if (rt && (SwigType_type(rt) != T_VOID)) {
      SwigType *vt = cplus_value_type(rt);
      SwigType *tt = vt ? vt : rt;
      SwigType *lt = SwigType_ltype(tt);
      String *lstr = SwigType_str(lt, Swig_cresult_name());
      if (SwigType_ispointer(lt)) {
        Wrapper_add_localv(f, Swig_cresult_name(), lstr, "= 0", NULL);
      } else {
        Wrapper_add_local(f, Swig_cresult_name(), lstr);
      }
      if (vt) {
        Delete(vt);
      }
      Delete(lt);
      Delete(lstr);
    }
  }
}

/* -----------------------------------------------------------------------------
 * emit_parameter_variables()
 *
 * Emits a list of variable declarations for function parameters.
 * The variable names are always called arg1, arg2, etc...
 * l => the parameter list
 * f => the wrapper to generate code into
 * ----------------------------------------------------------------------------- */

void emit_parameter_variables(ParmList *l, Wrapper *f) {

  Parm *p;
  String *tm;

  /* Emit function arguments */
  Swig_cargs(f, l);

  /* Attach typemaps to parameters */
  Swig_typemap_attach_parms("default", l, f);
  Swig_typemap_attach_parms("arginit", l, f);

  /* Apply the arginit and default */
  p = l;
  while (p) {
    tm = Getattr(p, "tmap:arginit");
    if (tm) {
      Printv(f->code, tm, "\n", NIL);
      p = Getattr(p, "tmap:arginit:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Apply the default typemap */
  p = l;
  while (p) {
    tm = Getattr(p, "tmap:default");
    if (tm) {
      Printv(f->code, tm, "\n", NIL);
      p = Getattr(p, "tmap:default:next");
    } else {
      p = nextSibling(p);
    }
  }
}

/* -----------------------------------------------------------------------------
 * emit_attach_parmmaps()
 *
 * Attach the standard parameter related typemaps.
 * ----------------------------------------------------------------------------- */

void emit_attach_parmmaps(ParmList *l, Wrapper *f) {
  Swig_typemap_attach_parms("in", l, f);
  Swig_typemap_attach_parms("typecheck", l, 0);
  Swig_typemap_attach_parms("argout", l, f);
  Swig_typemap_attach_parms("check", l, f);
  Swig_typemap_attach_parms("freearg", l, f);

  {
    /* Handle in typemaps with numinputs=0. */
    Parm *p = l;
    while (p) {
      String *tm = Getattr(p, "tmap:in");
      if (tm) {
        if (checkAttribute(p, "tmap:in:numinputs", "0")) {
          Printv(f->code, tm, "\n", NIL);
        }
        p = Getattr(p, "tmap:in:next");
      } else {
        p = nextSibling(p);
      }
    }
  }

  /* Perform a sanity check on "in" and "freearg" typemaps.  These
     must exactly match to avoid chaos.  If a mismatch occurs, we
     nuke the freearg typemap */
  {
    Parm *p = l;
    Parm *npin, *npfreearg;
    while (p) {
      npin = Getattr(p, "tmap:in:next");

      if (Getattr(p, "tmap:freearg")) {
        npfreearg = Getattr(p, "tmap:freearg:next");
        if (npin != npfreearg) {
          while (p != npin) {
            Delattr(p, "tmap:freearg");
            Delattr(p, "tmap:freearg:next");
            p = nextSibling(p);
          }
        }
      }
      p = npin;
    }
  }

  /* Check for variable length arguments with no input typemap.
     If no input is defined, we set this to ignore and print a
     message.
   */
  {
    Parm *p = l;
    Parm *lp = 0;
    while (p) {
      if (!checkAttribute(p, "tmap:in:numinputs", "0")) {
        lp = p;
        p = Getattr(p, "tmap:in:next");
        continue;
      }
      if (SwigType_isvarargs(Getattr(p, "type"))) {
        Swig_warning(WARN_LANG_VARARGS, input_file, line_number, "Variable length arguments discarded.\n");
        Setattr(p, "tmap:in", "");
      }
      lp = 0;
      p = nextSibling(p);
    }

    /* Check if last input argument is variable length argument */
    if (lp) {
      p = lp;
      while (p) {
        if (SwigType_isvarargs(Getattr(p, "type"))) {
          // Mark the head of the ParmList that it has varargs
          Setattr(l, "emit:varargs", lp);
          // Printf(stdout, "setting emit:varargs %s ... %s +++ %s\n", Getattr(l, "emit:varargs"), Getattr(l, "type"), Getattr(p, "type"));
          break;
        }
        p = nextSibling(p);
      }
    }
  }

  /*
   * An equivalent type can be used in the typecheck typemap for SWIG to detect the overloading of equivalent
   * target language types. This is primarily for the smartptr feature, where a pointer and a smart pointer
   * are seen as equivalent types in the target language.
   */
  {
    Parm *p = l;
    while (p) {
      String *tm = Getattr(p, "tmap:typecheck");
      if (tm) {
        String *equivalent = Getattr(p, "tmap:typecheck:equivalent");
        if (equivalent) {
          String *precedence = Getattr(p, "tmap:typecheck:precedence");
          if (precedence && Strcmp(precedence, "0") != 0)
            Swig_error(Getfile(tm),
                       Getline(tm),
                       "The 'typecheck' typemap for %s contains an 'equivalent' attribute for a 'precedence' that is not set to SWIG_TYPECHECK_POINTER or 0.\n",
                       SwigType_str(Getattr(p, "type"), 0));
          SwigType *cpt = Swig_cparse_type(equivalent);
          if (cpt) {
            Setattr(p, "equivtype", cpt);
            Delete(cpt);
          } else {
            Swig_error(Getfile(tm),
                       Getline(tm),
                       "Invalid type (%s) in 'equivalent' attribute in 'typecheck' typemap for type %s.\n",
                       equivalent,
                       SwigType_str(Getattr(p, "type"), 0));
          }
        }
        p = Getattr(p, "tmap:typecheck:next");
      } else {
        p = nextSibling(p);
      }
    }
  }
}

/* -----------------------------------------------------------------------------
 * emit_num_arguments()
 *
 * Calculate the total number of arguments.   This function is safe for use
 * with multi-argument typemaps which may change the number of arguments in
 * strange ways.
 * ----------------------------------------------------------------------------- */

int emit_num_arguments(ParmList *parms) {
  Parm *p = parms;
  int nargs = 0;

  while (p) {
    if (Getattr(p, "tmap:in")) {
      nargs += GetInt(p, "tmap:in:numinputs");
      p = Getattr(p, "tmap:in:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* DB 04/02/2003: Not sure this is necessary with tmap:in:numinputs */
  /*
     if (parms && (p = Getattr(parms,"emit:varargs"))) {
     if (!nextSibling(p)) {
     nargs--;
     }
     }
   */
  return nargs;
}

/* -----------------------------------------------------------------------------
 * emit_output_summary()
 *
 * Works out which values a wrapped function returns to the target language.
 *
 * The first is the function's own return value, unless the 'out' typemap declares
 * numoutputs=0 to suppress it. Each matched 'argout' typemap then does one of three
 * things, according to its attributes:
 *
 *   numoutputs=1   - appends one value to those returned so far. This is the default
 *                    and what the typemaps.i OUTPUT family does.
 *   numoutputs=0   - returns nothing. Used by a typemap that writes back through the
 *                    parameter, or that only turns an error code into an exception.
 *   overwrite=1    - returns one value, discarding everything returned before it,
 *                    including the function return value. Used by a typemap that
 *                    assigns $result rather than appending to it. A 'container'
 *                    attribute on it names the container it assigns, which the argout
 *                    typemaps after it then append into.
 *
 * The parameter list to analyse is passed in so that a caller working on a copy of
 * the parameters, such as one that has attached its own typemaps to the copy, gets
 * back parameters from that same copy.
 *
 * Sets the following attributes on n:
 *
 *   wrap:returnsurvives  - set when the function return value is one of the values
 *                          returned to the target language
 *   wrap:outputparms     - List of the parameters contributing a returned value, in
 *                          the order the values are returned
 *   wrap:outputcontainer - the container the argout typemaps append into, from their
 *                          'container' attribute, or "unknown" when they disagree
 * ----------------------------------------------------------------------------- */

void emit_output_summary(Node *n, ParmList *parms) {
  Parm *p;
  List *outputs = NewList();
  String *container = 0;
  String *clashing_container = 0;
  int returnsurvives;

  /* A void function has no return value to return and an 'out' typemap declaring
     numoutputs=0 says not to return the one there is. */
  returnsurvives = !Equal(Getattr(n, "type"), "void");
  if (returnsurvives && Getattr(n, "tmap:out:numoutputs"))
    returnsurvives = GetInt(n, "tmap:out:numoutputs") > 0;

  for (p = parms; p; p = nextSibling(p)) {
    int numoutputs;
    if (!Getattr(p, "tmap:argout:match_type"))
      continue;

    numoutputs = Getattr(p, "tmap:argout:numoutputs") ? GetInt(p, "tmap:argout:numoutputs") : 1;

    String *tm_container = Getattr(p, "tmap:argout:container");

    if (GetFlag(p, "tmap:argout:overwrite")) {
      /* Everything returned so far is thrown away by this typemap. */
      Clear(outputs);
      returnsurvives = 0;
      Delete(container);
      container = numoutputs > 0 ? Copy(tm_container) : 0;
      Delete(clashing_container);
      clashing_container = 0;
    } else if (numoutputs > 0) {
      const char *want = tm_container ? Char(tm_container) : "list";
      if (!container) {
        container = NewString(want);
      } else if (!Equal(container, want) && !clashing_container) {
        clashing_container = NewString(want);
      }
    }

    if (numoutputs > 0)
      Append(outputs, p);
  }

  if (returnsurvives)
    SetFlag(n, "wrap:returnsurvives");
  else
    Delattr(n, "wrap:returnsurvives");

  Setattr(n, "wrap:outputparms", outputs);
  Delete(outputs);

  if (clashing_container) {
    Swig_warning(WARN_TYPEMAP_ARGOUT_CONTAINER_MISMATCH,
                 Getfile(n),
                 Getline(n),
                 "The argout typemaps for '%s' append into different containers, '%s' and '%s', so the type of the values returned cannot be worked out "
                 "and a catch-all type is used for the return type instead. "
                 "Check the container attribute in each argout typemap used by this function, noting that it defaults to 'list'.\n",
                 SwigType_namestr(Getattr(n, "name")),
                 container,
                 clashing_container);
    Setattr(n, "wrap:outputcontainer", "unknown");
  } else if (container) {
    Setattr(n, "wrap:outputcontainer", container);
  } else {
    Delattr(n, "wrap:outputcontainer");
  }
  Delete(container);
  Delete(clashing_container);
}

/* -----------------------------------------------------------------------------
 * emit_isvoid_special_variables()
 *
 * Substitutes the $isvoid and $isvoidresult special variables in the wrapper code.
 *
 * $isvoid says whether the C++ return type is void. $isvoidresult says whether the
 * wrapper has a return value for the 'argout' typemaps to append to, which a void
 * return does not and neither does a return value that an 'out' typemap has
 * suppressed with numoutputs=0.
 *
 * Pass n as 0 where there is no 'out' typemap to consult, such as a director
 * method, and $isvoidresult is then the same as $isvoid.
 * ----------------------------------------------------------------------------- */

void emit_isvoid_special_variables(Node *n, String *code, bool isvoid) {
  bool isvoidresult = isvoid || (n && checkAttribute(n, "tmap:out:numoutputs", "0"));
  Replaceall(code, "$isvoidresult", isvoidresult ? "1" : "0");
  Replaceall(code, "$isvoid", isvoid ? "1" : "0");
}

/* -----------------------------------------------------------------------------
 * emit_num_required()
 *
 * Computes the number of required arguments.  This function is safe for
 * use with multi-argument typemaps and knows how to skip over everything
 * properly. Note that parameters with default values are counted unless
 * the compact default args option is on.
 * ----------------------------------------------------------------------------- */

int emit_num_required(ParmList *parms) {
  Parm *p = parms;
  int nargs = 0;
  Parm *first_default_arg = 0;
  int compactdefargs = ParmList_is_compactdefargs(p);

  while (p) {
    if (Getattr(p, "tmap:in") && checkAttribute(p, "tmap:in:numinputs", "0")) {
      p = Getattr(p, "tmap:in:next");
    } else {
      if (Getattr(p, "tmap:default"))
        break;
      if (Getattr(p, "value")) {
        if (!first_default_arg)
          first_default_arg = p;
        if (compactdefargs)
          break;
      }
      nargs += GetInt(p, "tmap:in:numinputs");
      if (Getattr(p, "tmap:in")) {
        p = Getattr(p, "tmap:in:next");
      } else {
        p = nextSibling(p);
      }
    }
  }

  /* Print error message for non-default arguments following default arguments */
  /* The error message is printed more than once with most language modules, this ought to be fixed */
  if (first_default_arg) {
    p = first_default_arg;
    while (p) {
      if (Getattr(p, "tmap:in") && checkAttribute(p, "tmap:in:numinputs", "0")) {
        p = Getattr(p, "tmap:in:next");
      } else {
        if (!Getattr(p, "value") && (!Getattr(p, "tmap:default"))) {
          Swig_error(Getfile(p), Getline(p), "Non-optional argument '%s' follows an optional argument.\n", Getattr(p, "name"));
        }
        if (Getattr(p, "tmap:in")) {
          p = Getattr(p, "tmap:in:next");
        } else {
          p = nextSibling(p);
        }
      }
    }
  }

  /* DB 04/02/2003: Not sure this is necessary with tmap:in:numinputs */
  /*
     if (parms && (p = Getattr(parms,"emit:varargs"))) {
     if (!nextSibling(p)) {
     nargs--;
     }
     }
   */
  return nargs;
}

/* -----------------------------------------------------------------------------
 * emit_isvarargs()
 *
 * Checks if a ParmList is a parameter list containing varargs.
 * This function requires emit_attach_parmmaps to have been called beforehand.
 * ----------------------------------------------------------------------------- */

int emit_isvarargs(ParmList *p) {
  if (!p)
    return 0;
  if (Getattr(p, "emit:varargs"))
    return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * emit_isvarargs_function()
 *
 * Checks for varargs in a function/constructor (can be overloaded)
 * ----------------------------------------------------------------------------- */

bool emit_isvarargs_function(Node *n) {
  bool has_varargs = false;
  Node *over = Getattr(n, "sym:overloaded");
  if (over) {
    for (Node *sibling = over; sibling; sibling = Getattr(sibling, "sym:nextSibling")) {
      if (ParmList_has_varargs(Getattr(sibling, "parms"))) {
        has_varargs = true;
        break;
      }
    }
  } else {
    has_varargs = ParmList_has_varargs(Getattr(n, "parms")) ? true : false;
  }
  return has_varargs;
}

/* -----------------------------------------------------------------------------
 * void emit_mark_vararg_parms()
 *
 * Marks the vararg parameters which are to be ignored.
 * Vararg parameters are marked as ignored if there is no 'in' varargs (...)
 * typemap.
 * ----------------------------------------------------------------------------- */

void emit_mark_varargs(ParmList *l) {
  Parm *p = l;
  while (p) {
    if (SwigType_isvarargs(Getattr(p, "type")))
      if (!Getattr(p, "tmap:in"))
        Setattr(p, "varargs:ignore", "1");
    p = nextSibling(p);
  }
}

#if 0
/* replace_contract_args.  This function replaces argument names in contract
   specifications.   Used in conjunction with the %contract directive. */

static void replace_contract_args(Parm *cp, Parm *rp, String *s) {
  while (cp && rp) {
    String *n = Getattr(cp, "name");
    if (n) {
      Replace(s, n, Getattr(rp, "lname"), DOH_REPLACE_ID);
    }
    cp = nextSibling(cp);
    rp = nextSibling(rp);
  }
}
#endif

/* -----------------------------------------------------------------------------
 * int emit_action_code()
 *
 * Emits action code for a wrapper. Adds in exception handling code (%exception).
 * eaction -> the action code to emit
 * wrappercode -> the emitted code (output)
 * ----------------------------------------------------------------------------- */
int emit_action_code(Node *n, String *wrappercode, String *eaction) {
  assert(Getattr(n, "wrap:name"));

  /* Look for except feature (%exception) */
  String *tm = GetFlagAttr(n, "feature:except");
  if (tm)
    tm = Copy(tm);
  if ((tm) && Len(tm) && (Strcmp(tm, "1") != 0)) {
    if (Strchr(tm, '$')) {
      Swig_replace_special_variables(n, parentNode(n), tm);
      Replaceall(tm, "$action", eaction);
    }
    Printv(wrappercode, tm, "\n", NIL);
    Delete(tm);
    return 1;
  } else {
    Printv(wrappercode, eaction, "\n", NIL);
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * int emit_action()
 *
 * Emits the call to the wrapped function.
 * Adds in exception specification exception handling and %exception code.
 * ----------------------------------------------------------------------------- */
String *emit_action(Node *n) {
  String *actioncode = NewStringEmpty();
  String *tm;
  String *action;
  String *wrap;
  ParmList *catchlist = Getattr(n, "catchlist");

  /* Look for fragments */
  {
    String *fragment = Getattr(n, "feature:fragment");
    if (fragment) {
      char *c, *tok;
      String *t = Copy(fragment);
      c = Char(t);
      tok = strtok(c, ",");
      while (tok) {
        String *fname = NewString(tok);
        Setfile(fname, Getfile(n));
        Setline(fname, Getline(n));
        Swig_fragment_emit(fname);
        Delete(fname);
        tok = strtok(NULL, ",");
      }
      Delete(t);
    }
  }

  /* Emit wrapper code (if any) */
  wrap = Getattr(n, "wrap:code");
  if (wrap && Swig_filebyname("header") != Getattr(n, "wrap:code:done")) {
    File *f_code = Swig_filebyname("header");
    if (f_code) {
      Printv(f_code, wrap, NIL);
    }
    Setattr(n, "wrap:code:done", f_code);
  }

  action = Getattr(n, "feature:action");
  if (!action)
    action = Getattr(n, "wrap:action");
  assert(action != 0);

  /* Emit contract code (if any) */
  if (Swig_contract_mode_get()) {
    /* Preassertion */
    tm = Getattr(n, "contract:preassert");
    if (Len(tm)) {
      Printv(actioncode, tm, "\n", NIL);
    }
  }
  /* Exception handling code */

  /* saves action -> eaction for postcatching exception */
  String *eaction = NewString("");

  /* If we are in C++ mode and there is an exception specification. We're going to
     enclose the block in a try block */
  if (catchlist) {
    Printf(eaction, "try {\n");
  }

  String *preaction = Getattr(n, "wrap:preaction");
  if (preaction)
    Printv(eaction, preaction, NIL);

  Printv(eaction, action, NIL);

  String *postaction = Getattr(n, "wrap:postaction");
  if (postaction)
    Printv(eaction, postaction, NIL);

  if (catchlist) {
    int unknown_catch = 0;
    int has_varargs = 0;
    Printf(eaction, "}");
    for (Parm *ep = catchlist; ep; ep = nextSibling(ep)) {
      String *em = Swig_typemap_lookup("throws", ep, "_e", 0);
      if (em) {
        SwigType *et = Getattr(ep, "type");
        SwigType *etr = SwigType_typedef_resolve_all(et);
        if (SwigType_isreference(etr) || SwigType_ispointer(etr) || SwigType_isarray(etr)) {
          Printf(eaction, " catch(%s) {", SwigType_str(et, "_e"));
        } else if (SwigType_isvarargs(etr)) {
          Printf(eaction, " catch(...) {");
          has_varargs = 1;
        } else {
          Printf(eaction, " catch(%s) {", SwigType_str(et, "&_e"));
        }
        Printv(eaction, em, "\n", NIL);
        Printf(eaction, "}");
      } else {
        Swig_warning(WARN_TYPEMAP_THROW, Getfile(n), Getline(n), "No 'throws' typemap defined for exception type '%s'\n", SwigType_str(Getattr(ep, "type"), 0));
        unknown_catch = 1;
      }
    }
    if (unknown_catch && !has_varargs) {
      Printf(eaction, " catch(...) {\nthrow;\n}");
    }
  }

  /* emit the except feature code */
  emit_action_code(n, actioncode, eaction);

  Delete(eaction);

  /* Emit contract code (if any) */
  if (Swig_contract_mode_get()) {
    /* Postassertion */
    tm = Getattr(n, "contract:postassert");
    if (Len(tm)) {
      Printv(actioncode, tm, "\n", NIL);
    }
  }

  return actioncode;
}
