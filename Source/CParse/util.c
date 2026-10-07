/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * util.c
 *
 * Parsing utilities.
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include "cparse.h"
#include <ctype.h>

/* -----------------------------------------------------------------------------
 * Swig_cparse_trim_whitespace()
 *
 * Removes any leading and trailing whitespace from the string 's', in place.
 * ----------------------------------------------------------------------------- */

void Swig_cparse_trim_whitespace(String *s) {
  const char *c;
  int leading = 0;

  Chop(s);
  c = Char(s);
  while (isspace((unsigned char)c[leading]))
    leading++;
  if (leading > 0)
    Delslice(s, 0, leading);
}

/* -----------------------------------------------------------------------------
 * Swig_cparse_trim_parenthesis()
 *
 * The expression 's' with the parentheses that enclose the whole of it removed,
 * so '(gp)' gives 'gp' and '((x))' gives 'x'.  Returns a new string, or 0 when
 * the expression is not parenthesised as a whole.  Neither '(a)+(b)' nor the
 * cast '(int)x' is, the first parenthesis of each being closed before the end
 * of the expression.
 * ----------------------------------------------------------------------------- */

String *Swig_cparse_trim_parenthesis(String *s) {
  String *trimmed = 0;
  const char *text = Char(s);

  while (*text == '(') {
    int depth = 0;
    const char *p;
    String *inner;
    for (p = text; *p; p++) {
      if (*p == '(') {
        depth++;
      } else if (*p == ')') {
        if (--depth == 0)
          break;
      }
    }
    if (!*p || p[1] != '\0')
      break;
    /* 'text' points into 'trimmed' after the first pass, so copy it out before deleting 'trimmed'. */
    inner = NewStringWithSize(text + 1, (int)(p - text) - 1);
    Delete(trimmed);
    trimmed = inner;
    Swig_cparse_trim_whitespace(trimmed);
    text = Char(trimmed);
  }
  return trimmed;
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
 * Swig_cparse_smartptr()
 *
 * Parse the type in smartptr feature and convert into a SwigType.
 * Error out if the parsing fails as this is like a parser syntax error.
 * ----------------------------------------------------------------------------- */

SwigType *Swig_cparse_smartptr(Node *n) {
  SwigType *smart = 0;
  String *smartptr = Getattr(n, "feature:smartptr");
  if (smartptr) {
    SwigType *cpt = Swig_cparse_type(smartptr);
    if (cpt) {
      smart = SwigType_typedef_resolve_all(cpt);
      Delete(cpt);
    } else {
      Swig_error(Getfile(n), Getline(n), "Invalid type (%s) in 'smartptr' feature for class %s.\n", smartptr, SwigType_namestr(Getattr(n, "name")));
    }
  }
  return smart;
}

/* -----------------------------------------------------------------------------
 * Swig_cparse_new_node()
 *
 * Create an empty parse node, setting file and line number information
 * ----------------------------------------------------------------------------- */

Node *Swig_cparse_new_node(const_String_or_char_ptr tag) {
  Node *n = NewHash();
  set_nodeType(n, tag);
  Setfile(n, cparse_file);
  Setline(n, cparse_line);
  return n;
}
