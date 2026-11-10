/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * tree.c
 *
 * This file provides some general purpose functions for manipulating
 * parse trees.
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include <stdarg.h>
#include <assert.h>

static int debug_quiet = 0;

/* -----------------------------------------------------------------------------
 * Swig_print_quiet()
 *
 * Set quiet mode when printing a parse tree node
 * ----------------------------------------------------------------------------- */

int Swig_print_quiet(int quiet) {
  int previous_quiet = debug_quiet;
  debug_quiet = quiet;
  return previous_quiet;
}

/* -----------------------------------------------------------------------------
 * Swig_print_tags()
 *
 * Dump the tag structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

void Swig_print_tags(Node *n, String *prefix) {
  String *cprefix, *newprefix;
  Node *child;

  if (!prefix)
    cprefix = NewStringEmpty();
  else
    cprefix = prefix;

  while (n) {
    Swig_diagnostic(Getfile(n), Getline(n), "%s . %s\n", cprefix, nodeType(n));
    child = firstChild(n);
    if (child) {
      newprefix = NewStringf("%s . %s", cprefix, nodeType(n));
      Swig_print_tags(child, newprefix);
      Delete(newprefix);
    }
    n = nextSibling(n);
  }
  if (!prefix)
    Delete(cprefix);
}

static int indent_level = 0;

static void print_indent(int l) {
  int i;
  for (i = 0; i < indent_level; i++) {
    fputc(' ', stdout);
  }
  if (l) {
    fputc('|', stdout);
    fputc(' ', stdout);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_print_node(Node *n)
 * ----------------------------------------------------------------------------- */

void Swig_print_node(Node *n) {
  Iterator ki;
  Node *child;
  List *keys = Keys(n);

  print_indent(0);
  if (debug_quiet)
    Printf(stdout, "+++ %s ----------------------------------------\n", nodeType(n));
  else
    Printf(stdout, "+++ %s - %p ----------------------------------------\n", nodeType(n), n);

  SortList(keys, 0);
  ki = First(keys);
  while (ki.item) {
    String *k = ki.item;
    DOH *value = Getattr(n, k);
    if (Equal(k, "nodeType") || (*(Char(k)) == '$')) {
      /* Do nothing */
    } else if (debug_quiet &&
               (Equal(k, "firstChild") || Equal(k, "lastChild") || Equal(k, "parentNode") || Equal(k, "nextSibling") || Equal(k, "previousSibling") ||
                Equal(k, "symtab") || Equal(k, "csymtab") || Equal(k, "sym:symtab") || Equal(k, "sym:nextSibling") || Equal(k, "sym:previousSibling") ||
                Equal(k, "csym:nextSibling") || Equal(k, "csym:previousSibling"))) {
      /* Do nothing */
    } else if (Equal(k, "kwargs") || Equal(k, "parms") || Equal(k, "wrap:parms") || Equal(k, "pattern") || Equal(k, "templateparms") ||
               Equal(k, "templateparmsraw") || Equal(k, "template_parameters") || Equal(k, "throws")) {
      print_indent(2);
      /* Differentiate parameter lists by displaying within single quotes */
      Printf(stdout, "%-12s - \'%s\'\n", k, ParmList_str_defaultargs(value));
    } else if (Equal(k, "constraint")) {
      /* C++20 constraint subtree: render as the C++ source text it represents, like a parameter list. */
      String *cs = Constraint_str(value);
      print_indent(2);
      Printf(stdout, "%-12s - \'%s\'\n", k, cs);
      Delete(cs);
    } else {
      DOH *o;
      const char *trunc = "";
      print_indent(2);
      if (DohIsString(value)) {
        o = Str(value);
        if (Len(o) > 80) {
          trunc = "...";
        }
        Printf(stdout, "%-12s - \"%(escape)-0.80s%s\"\n", k, o, trunc);
        Delete(o);
        /*
              } else if (DohIsSequence(value)) {
                Printf(stdout, "%-12s - %s\n", k, value);
        */
      } else {
        Printf(stdout, "%-12s - %p\n", k, value);
      }
    }
    ki = Next(ki);
  }
  child = firstChild(n);
  if (child) {
    indent_level += 6;
    Printf(stdout, "\n");
    Swig_print_tree(child);
    indent_level -= 6;
  } else {
    print_indent(1);
    Printf(stdout, "\n");
  }
  Delete(keys);
}

/* -----------------------------------------------------------------------------
 * Swig_print_tree()
 *
 * Dump the tree structure of a parse tree to standard output
 * ----------------------------------------------------------------------------- */

void Swig_print_tree(Node *n) {
  while (n) {
    Swig_print_node(n);
    n = nextSibling(n);
  }
}

/* -----------------------------------------------------------------------------
 * appendChild()
 *
 * Appends a new child to a node
 * ----------------------------------------------------------------------------- */

void appendChild(Node *n, Node *child) {
  Node *lc;

  if (!child)
    return;

  lc = lastChild(n);
  if (!lc) {
    set_firstChild(n, child);
  } else {
    set_nextSibling(lc, child);
    set_previousSibling(child, lc);
  }
  while (child) {
    lc = child;
    set_parentNode(child, n);
    child = nextSibling(child);
  }
  set_lastChild(n, lc);
}

/* -----------------------------------------------------------------------------
 * prependChild()
 *
 * Prepends a new child to a node
 * ----------------------------------------------------------------------------- */

void prependChild(Node *n, Node *child) {
  Node *fc;

  if (!child)
    return;

  fc = firstChild(n);
  if (fc) {
    set_nextSibling(child, fc);
    set_previousSibling(fc, child);
  }
  set_firstChild(n, child);
  while (child) {
    set_parentNode(child, n);
    child = nextSibling(child);
  }
}

void appendSibling(Node *n, Node *child) {
  Node *parent;
  Node *lc = n;
  while (nextSibling(lc))
    lc = nextSibling(lc);
  set_nextSibling(lc, child);
  set_previousSibling(child, lc);
  parent = parentNode(n);
  if (parent) {
    while (child) {
      lc = child;
      set_parentNode(child, parent);
      child = nextSibling(child);
    }
    set_lastChild(parent, lc);
  }
}

/* -----------------------------------------------------------------------------
 * removeNode()
 *
 * Removes a node from the parse tree.  Detaches it from its parent's child list.
 * ----------------------------------------------------------------------------- */

void removeNode(Node *n) {
  Node *parent;
  Node *prev;
  Node *next;

  parent = parentNode(n);
  if (!parent)
    return;

  prev = previousSibling(n);
  next = nextSibling(n);
  if (prev) {
    set_nextSibling(prev, next);
  } else {
    if (parent) {
      set_firstChild(parent, next);
    }
  }
  if (next) {
    set_previousSibling(next, prev);
  } else {
    if (parent) {
      set_lastChild(parent, prev);
    }
  }

  /* Delete attributes */
  Delattr(n, "parentNode");
  Delattr(n, "nextSibling");
  Delattr(n, "previousSibling");
}

/* -----------------------------------------------------------------------------
 * copyNode()
 *
 * Copies a node, but only copies simple attributes (no lists, hashes).
 * ----------------------------------------------------------------------------- */

Node *copyNode(Node *n) {
  Iterator ki;
  Node *c = NewHash();
  for (ki = First(n); ki.key; ki = Next(ki)) {
    if (DohIsString(ki.item)) {
      Setattr(c, ki.key, Copy(ki.item));
    }
  }
  Setfile(c, Getfile(n));
  Setline(c, Getline(n));
  return c;
}

/* -----------------------------------------------------------------------------
 * checkAttribute()
 * ----------------------------------------------------------------------------- */

int checkAttribute(Node *n, const_String_or_char_ptr name, const_String_or_char_ptr value) {
  String *v = Getattr(n, name);
  return v ? Equal(v, value) : 0;
}

/* -----------------------------------------------------------------------------
 * Swig_require()
 * ns   - namespace for the view name for saving any attributes under
 * n    - node
 * ...  - list of attribute names of type char*
 *
 * An attribute is optional if it is prefixed by ?, eg "?value".  All
 * non-optional attributes are checked for on node n and if any do not exist
 * SWIG exits with a fatal error.
 *
 * If the attribute name is prefixed by * or ?, eg "*value" then a copy of the
 * attribute is saved. The saved attributes will be restored on a subsequent
 * call to Swig_restore(). All the saved attributes are saved in the view
 * namespace (prefixed by ns).
 *
 * This function can be called more than once with different namespaces.
 * ----------------------------------------------------------------------------- */

void Swig_require(const char *ns, Node *n, ...) {
  va_list ap;
  char *name;
  DOH *obj;

  va_start(ap, n);
  name = va_arg(ap, char *);
  while (name) {
    int newref = 0;
    int opt = 0;
    if (*name == '*') {
      newref = 1;
      name++;
    } else if (*name == '?') {
      newref = 1;
      opt = 1;
      name++;
    }
    obj = Getattr(n, name);
    if (!opt && !obj) {
      Swig_error(Getfile(n), Getline(n), "Internal error (Swig_require).  Missing attribute '%s' in node '%s'.\n", name, nodeType(n));
      Exit(EXIT_FAILURE);
    }
    if (!obj)
      obj = None;
    if (newref) {
      /* Save a copy of the attribute */
      Setattr(n, NewStringf("%s:%s", ns, name), obj);
    }
    name = va_arg(ap, char *);
  }
  va_end(ap);

  /* Save the view */
  {
    String *view = Getattr(n, "view");
    if (view) {
      if (Strcmp(view, ns) != 0) {
        Setattr(n, NewStringf("%s:view", ns), view);
        Setattr(n, "view", ns);
      }
    } else {
      Setattr(n, "view", ns);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_save()
 * Same as Swig_require(), but all attribute names are optional and all attributes
 * are saved, ie behaves as if all the attribute names were prefixed by ?.
 * ----------------------------------------------------------------------------- */

void Swig_save(const char *ns, Node *n, ...) {
  va_list ap;
  char *name;
  DOH *obj;

  va_start(ap, n);
  name = va_arg(ap, char *);
  while (name) {
    if (*name == '*') {
      name++;
    } else if (*name == '?') {
      name++;
    }
    obj = Getattr(n, name);
    if (!obj)
      obj = None;

    /* Save a copy of the attribute */
    if (Setattr(n, NewStringf("%s:%s", ns, name), obj)) {
      Printf(stderr, "Swig_save('%s','%s'): Warning, attribute '%s' was already saved.\n", ns, nodeType(n), name);
    }
    name = va_arg(ap, char *);
  }
  va_end(ap);

  /* Save the view */
  {
    String *view = Getattr(n, "view");
    if (view) {
      if (Strcmp(view, ns) != 0) {
        Setattr(n, NewStringf("%s:view", ns), view);
        Setattr(n, "view", ns);
      }
    } else {
      Setattr(n, "view", ns);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_restore()
 * Restores attributes saved by a previous call to Swig_require() or Swig_save().
 * ----------------------------------------------------------------------------- */

void Swig_restore(Node *n) {
  String *temp;
  int len;
  List *l;
  String *ns;
  Iterator ki;

  ns = Getattr(n, "view");
  assert(ns);

  l = NewList();

  temp = NewStringf("%s:", ns);
  len = Len(temp);

  for (ki = First(n); ki.key; ki = Next(ki)) {
    if (Strncmp(temp, ki.key, len) == 0) {
      Append(l, ki.key);
    }
  }
  for (ki = First(l); ki.item; ki = Next(ki)) {
    DOH *obj = Getattr(n, ki.item);
    Setattr(n, Char(ki.item) + len, obj);
    Delattr(n, ki.item);
  }
  Delete(l);
  Delete(temp);
}
