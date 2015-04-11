/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * util.c
 *
 * Parsing utilities.
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include "cparse.h"
#include <ctype.h>

 /* Splits the arguments of a macro */
List *SWIG_split_args(String *s) {
  List *args = 0;
  char *c, *start;
  int level = 0;
  int angle_level = 0;
  int leading = 1;

  args = NewList();
  c = strchr(Char(s), '(');
  assert(c);
  c++;

  start = c;
  while (*c) {
    if (*c == '\"') {
      c++;
      while (*c) {
  if (*c == '\\') {
    c++;
  } else {
    if (*c == '\"')
      break;
  }
  c++;
      }
    }
    if ((level == 0) && angle_level == 0 && ((*c == ',') || (*c == ')'))) {
      Append(args, NewStringWithSize(start, c - start));
      start = c + 1;
      leading = 1;
      if (*c == ')')
  break;
      c++;
      continue;
    }
    if (*c == '(')
      level++;
    if (*c == ')')
      level--;
    if (*c == '<')
      angle_level++;
    if (*c == '>')
      angle_level--;
    if (isspace((int) *c) && leading)
      start++;
    if (!isspace((int) *c))
      leading = 0;
    c++;
  }
  return args;
}

 /* -----------------------------------------------------------------------------
 * Swig_cparse_replace_substitute()
 *
 * Replaces string $substitute() with the result of replacing all
 * instances of the second argument in the first argument with the thrid argument.
 * ----------------------------------------------------------------------------- */
 void Swig_cparse_replace_substitute(String *s) {
  List *parameterList = 0;
  char *start = 0;

  while ((start = strstr(Char(s), "$substitute("))) {
    /* Gather the parameters */
    char *end = 0, *c;
    int level = 0;
    String *dollar_substitute;
    int syntax_error = 1;
    c = start;
    while (*c) {
      if (*c == '(')
        level++;
      if (*c == ')') {
        level--;
        if (level == 0) {
          end = c + 1;
          break;
        }
      }
      c++;
    }

    if (end) {
      dollar_substitute = NewStringWithSize(start, (end - start));
      syntax_error = 0;
    } else {
      dollar_substitute = NewStringWithSize(start, (c - start));
    }

    if (!syntax_error) {
      parameterList = SWIG_split_args(dollar_substitute);
    }

    if (!syntax_error && Len(parameterList) == 3) {
      String *content = NewString(Getitem(parameterList, 0));
      String *pat = Getitem(parameterList, 1);
      String *rep = Getitem(parameterList, 2);

      Replace(content, pat, rep, DOH_REPLACE_ANY);
      Replace(s, dollar_substitute, content, DOH_REPLACE_ANY);

      Delete(content);
    }
    else {
      Swig_error(Getfile(s), Getline(s), "Bad $substitute() macro.\n");
      break;
    }

    Delete(dollar_substitute);
    Delete(parameterList);
  }
 }

/* -----------------------------------------------------------------------------
 * Swig_cparse_replace_descriptor()
 *
 * Replaces type descriptor string $descriptor() with the SWIG type descriptor
 * string.
 * ----------------------------------------------------------------------------- */

void Swig_cparse_replace_descriptor(String *s) {
  char tmp[512];
  String *arg = 0;
  SwigType *t;
  char *c = 0;

  while ((c = strstr(Char(s), "$descriptor("))) {
    char *d = tmp;
    int level = 0;
    while (*c) {
      if (*c == '(')
	level++;
      if (*c == ')') {
	level--;
	if (level == 0) {
	  break;
	}
      }
      *d = *c;
      d++;
      c++;
    }
    *d = 0;
    arg = NewString(tmp + 12);
    t = Swig_cparse_type(arg);
    Delete(arg);
    arg = 0;

    if (t) {
      String *mangle;
      String *descriptor;

      mangle = SwigType_manglestr(t);
      descriptor = NewStringf("SWIGTYPE%s", mangle);
      SwigType_remember(t);
      *d = ')';
      d++;
      *d = 0;
      Replace(s, tmp, descriptor, DOH_REPLACE_ANY);
      Delete(mangle);
      Delete(descriptor);
      Delete(t);
    } else {
      Swig_error(Getfile(s), Getline(s), "Bad $descriptor() macro.\n");
      break;
    }
  }
}

/* -----------------------------------------------------------------------------
 * cparse_normalize_void()
 *
 * This function is used to replace arguments of the form (void) with empty
 * arguments in C++
 * ----------------------------------------------------------------------------- */

void cparse_normalize_void(Node *n) {
  String *decl = Getattr(n, "decl");
  Parm *parms = Getattr(n, "parms");

  if (SwigType_isfunction(decl)) {
    if ((ParmList_len(parms) == 1) && (SwigType_type(Getattr(parms, "type")) == T_VOID)) {
      Replaceall(decl, "f(void).", "f().");
      Delattr(n, "parms");
    }
  }
}

/* -----------------------------------------------------------------------------
 * new_node()
 *
 * Create an empty parse node, setting file and line number information
 * ----------------------------------------------------------------------------- */

Node *new_node(const_String_or_char_ptr tag) {
  Node *n = NewHash();
  set_nodeType(n,tag);
  Setfile(n,cparse_file);
  Setline(n,cparse_line);
  return n;
}
