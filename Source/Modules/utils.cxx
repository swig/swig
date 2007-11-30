/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * utils.cxx
 *
 * Various utility functions.
 * ----------------------------------------------------------------------------- */

char cvsroot_utils_cxx[] = "$Id$";

#include <swigmod.h>

int is_public(Node *n) {
  String *access = Getattr(n, "access");
  return !access || !Cmp(access, "public");
}

int is_private(Node *n) {
  String *access = Getattr(n, "access");
  return access && !Cmp(access, "private");
}

int is_protected(Node *n) {
  String *access = Getattr(n, "access");
  return access && !Cmp(access, "protected");
}

int is_member_director(Node *parentnode, Node *member) {
  int director_mode = Swig_director_mode();

  if (parentnode && checkAttribute(member, "storage", "virtual")) {
    int parent_nodirector = GetFlag(parentnode, "feature:nodirector");
    if (parent_nodirector)
      return 0;
    int parent_director = director_mode && GetFlag(parentnode, "feature:director");
    int cdecl_director = parent_director || GetFlag(member, "feature:director");
    int cdecl_nodirector = GetFlag(member, "feature:nodirector");
    return cdecl_director && !cdecl_nodirector && !GetFlag(member, "feature:extend");
  } else {
    return 0;
  }
}

int is_member_director(Node *member) {
  return is_member_director(Getattr(member, "parentNode"), member);
}

/* Clean overloaded list.  Removes templates, ignored, and errors */

void clean_overloaded(Node *n) {
  Node *nn = Getattr(n, "sym:overloaded");
  Node *first = 0;
  while (nn) {
    String *ntype = nodeType(nn);
    if ((GetFlag(nn, "feature:ignore")) ||
	(Getattr(nn, "error")) ||
	(Strcmp(ntype, "template") == 0) ||
	((Strcmp(ntype, "cdecl") == 0) && is_protected(nn) && !is_member_director(nn))) {
      /* Remove from overloaded list */
      Node *ps = Getattr(nn, "sym:previousSibling");
      Node *ns = Getattr(nn, "sym:nextSibling");
      if (ps) {
	Setattr(ps, "sym:nextSibling", ns);
      }
      if (ns) {
	Setattr(ns, "sym:previousSibling", ps);
      }
      Delattr(nn, "sym:previousSibling");
      Delattr(nn, "sym:nextSibling");
      Delattr(nn, "sym:overloaded");
      nn = ns;
      continue;
    } else {
      if (!first)
	first = nn;
      Setattr(nn, "sym:overloaded", first);
    }
    nn = Getattr(nn, "sym:nextSibling");
  }
  if (!first || (first && !Getattr(first, "sym:nextSibling"))) {
    if (Getattr(n, "sym:overloaded"))
      Delattr(n, "sym:overloaded");
  }
}
