/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * constraints.c
 *
 * Parse tree representation of C++20 constraint-expressions and
 * requires-expressions, plus a renderer that reproduces the source text.
 *
 * Three node types are produced:
 *
 *   constraint            - constraint-logical-or-expression node, with
 *                           op = "or" / "and" / "atom".  Atom nodes carry a
 *                           kind attribute distinguishing concept-ids,
 *                           parenthesised constraints, requires-expressions,
 *                           fold-expressions, and the catchall "expression"
 *                           form for constraint primaries SWIG does not model
 *                           structurally.
 *   requires-expression   - a 'requires(parms) { requirements }' primary,
 *                           with parms held as a ParmList and requirements
 *                           as a chain of requirement child nodes.
 *   requirement           - a single requirement inside a requires-expression
 *                           body, with kind = "simple" / "type" / "compound"
 *                           / "nested".
 *
 * Constraint subtrees are held on host nodes (cdecl, class, template, concept,
 * constructor) via the "constraint" attribute, mirroring how parameter lists
 * live on "parms".
 *
 * Constraint_str walks a constraint subtree and returns a String * holding
 * the rendered constraint text in C++20 syntax.  The renderer is the only
 * supported path for materialising constraint text: the structured tree is
 * the source of truth.
 *
 * Constraints also decide whether two declarations are the same declaration,
 * as two function templates alike in all else are different templates when
 * their constraints differ.  A declaration's constraint signature, built by
 * Constraint_signature_str, is the rendered text of every constraint that is
 * part of its signature, normalised and arranged so that two of them can be
 * compared.  It is never shown to a user.
 * ----------------------------------------------------------------------------- */

#include "swig.h"

/* -----------------------------------------------------------------------------
 * Constraint_new_atom()
 *
 * Create a new constraint atom node with op = "atom" and the supplied kind.
 * The caller is responsible for populating kind specific attributes ("type"
 * for concept-id, "value"/"valuetype" for expression, firstChild for parens
 * / requires-expression / fold).
 * ----------------------------------------------------------------------------- */

Node *Constraint_new_atom(const_String_or_char_ptr kind) {
  Node *n = NewHash();
  set_nodeType(n, "constraint");
  Setattr(n, "op", "atom");
  Setattr(n, "kind", kind);
  return n;
}

/* -----------------------------------------------------------------------------
 * Constraint_new_op()
 *
 * Create a new constraint operator node with op = "and" or "or".  The caller
 * appends two or more constraint operands as children.
 * ----------------------------------------------------------------------------- */

Node *Constraint_new_op(const_String_or_char_ptr op) {
  Node *n = NewHash();
  set_nodeType(n, "constraint");
  Setattr(n, "op", op);
  return n;
}

/* -----------------------------------------------------------------------------
 * Constraint_new_requires_expression()
 *
 * Create a new requires-expression node.  parms is set separately if the
 * requirement-parameter-list is non-empty; requirement children are appended
 * via appendChild.
 * ----------------------------------------------------------------------------- */

Node *Constraint_new_requires_expression(void) {
  Node *n = NewHash();
  set_nodeType(n, "requires-expression");
  return n;
}

/* -----------------------------------------------------------------------------
 * Constraint_new_requirement()
 *
 * Create a new requirement node with the given kind ("simple", "type",
 * "compound", or "nested").
 * ----------------------------------------------------------------------------- */

Node *Constraint_new_requirement(const_String_or_char_ptr kind) {
  Node *n = NewHash();
  set_nodeType(n, "requirement");
  Setattr(n, "kind", kind);
  return n;
}

/* -----------------------------------------------------------------------------
 * Constraint_combine()
 *
 * Combine two constraint operands under a logical operator op ("and" or "or"),
 * flattening any operand whose own op matches into the resulting child chain.
 * This produces an n-ary tree for sequences like 'A && B && C', so a renderer
 * emits operands in source order without having to walk a left leaning binary
 * tree.
 * ----------------------------------------------------------------------------- */

Node *Constraint_combine(const_String_or_char_ptr op, Node *lhs, Node *rhs) {
  Node *combined = Constraint_new_op(op);
  Node *operands[2];
  int i;

  operands[0] = lhs;
  operands[1] = rhs;
  for (i = 0; i < 2; i++) {
    Node *operand = operands[i];
    String *operand_op = Getattr(operand, "op");
    if (operand_op && Equal(operand_op, op)) {
      /* Splice the matching op operand's children directly into the combined chain.  The operand
       * wrapper is no longer reachable. */
      Node *c = firstChild(operand);
      Node *next;
      set_firstChild(operand, 0);
      while (c) {
        next = nextSibling(c);
        set_nextSibling(c, 0);
        set_previousSibling(c, 0);
        set_parentNode(c, 0);
        appendChild(combined, c);
        c = next;
      }
      Delete(operand);
    } else {
      appendChild(combined, operand);
    }
  }
  return combined;
}

/* Forward declaration: the renderer recurses across all three node types. */
static void render_node(String *out, Node *n);

static void render_constraint(String *out, Node *n) {
  String *op = Getattr(n, "op");
  if (!op) {
    return;
  }
  if (Equal(op, "and") || Equal(op, "or")) {
    const char *sep = Equal(op, "and") ? " && " : " || ";
    Node *c = firstChild(n);
    int first = 1;
    while (c) {
      if (!first)
        Append(out, sep);
      render_node(out, c);
      first = 0;
      c = nextSibling(c);
    }
    return;
  }
  /* op == "atom" */
  {
    String *kind = Getattr(n, "kind");
    if (!kind) {
      return;
    }
    if (Equal(kind, "concept-id")) {
      /* The "type" attribute is a SwigType encoded concept-id like 'AllNumeric<(T,v.Rest)>'; decode it
       * back to source form via SwigType_str. */
      SwigType *t = Getattr(n, "type");
      if (t) {
        String *s = SwigType_str(t, 0);
        Append(out, s);
        Delete(s);
      }
    } else if (Equal(kind, "parens")) {
      Append(out, "(");
      if (firstChild(n))
        render_node(out, firstChild(n));
      Append(out, ")");
    } else if (Equal(kind, "requires-expression")) {
      if (firstChild(n))
        render_node(out, firstChild(n));
    } else if (Equal(kind, "fold")) {
      String *fold_op = Getattr(n, "fold_op");
      String *fold_kind = Getattr(n, "fold_kind");
      Append(out, "(");
      if (fold_kind && Equal(fold_kind, "unary-right")) {
        if (firstChild(n))
          render_node(out, firstChild(n));
        Printf(out, " %s ...", fold_op ? Char(fold_op) : "&&");
      } else if (fold_kind && Equal(fold_kind, "unary-left")) {
        Printf(out, "... %s ", fold_op ? Char(fold_op) : "&&");
        if (firstChild(n))
          render_node(out, firstChild(n));
      } else {
        /* Binary or unspecified - render as 'pattern op ...' for the common unary-right case, which
         * is by far the most frequent in practice. */
        if (firstChild(n))
          render_node(out, firstChild(n));
        Printf(out, " %s ...", fold_op ? Char(fold_op) : "&&");
      }
      Append(out, ")");
    } else if (Equal(kind, "expression")) {
      String *value = Getattr(n, "value");
      if (value)
        Append(out, value);
    }
  }
}

static void render_requires_expression(String *out, Node *n) {
  ParmList *parms = Getattr(n, "parms");
  Node *c;
  Append(out, "requires");
  if (parms) {
    String *ps = ParmList_str(parms);
    Printf(out, " (%s)", ps);
    Delete(ps);
  }
  Append(out, " { ");
  c = firstChild(n);
  while (c) {
    render_node(out, c);
    Append(out, " ");
    c = nextSibling(c);
  }
  Append(out, "}");
}

static void render_requirement(String *out, Node *n) {
  String *kind = Getattr(n, "kind");
  if (!kind) {
    return;
  }
  if (Equal(kind, "simple")) {
    String *value = Getattr(n, "value");
    if (value)
      Append(out, value);
    Append(out, ";");
  } else if (Equal(kind, "type")) {
    String *type = Getattr(n, "type");
    Append(out, "typename ");
    if (type) {
      String *ts = SwigType_str(type, 0);
      Append(out, ts);
      Delete(ts);
    }
    Append(out, ";");
  } else if (Equal(kind, "compound")) {
    String *value = Getattr(n, "value");
    String *no_except = Getattr(n, "noexcept");
    Append(out, "{ ");
    if (value)
      Append(out, value);
    Append(out, " }");
    if (no_except)
      Append(out, " noexcept");
    if (firstChild(n)) {
      Append(out, " -> ");
      render_node(out, firstChild(n));
    }
    Append(out, ";");
  } else if (Equal(kind, "nested")) {
    Append(out, "requires ");
    if (firstChild(n)) {
      render_node(out, firstChild(n));
    } else {
      String *value = Getattr(n, "value");
      if (value)
        Append(out, value);
    }
    Append(out, ";");
  }
}

static void render_node(String *out, Node *n) {
  String *type;
  if (!n)
    return;
  type = nodeType(n);
  if (!type)
    return;
  if (Equal(type, "constraint")) {
    render_constraint(out, n);
  } else if (Equal(type, "requires-expression")) {
    render_requires_expression(out, n);
  } else if (Equal(type, "requirement")) {
    render_requirement(out, n);
  }
}

/* -----------------------------------------------------------------------------
 * Constraint_str()
 *
 * Render a constraint subtree (constraint, requires-expression, or requirement
 * node) as the C++20 source text it represents.
 * ----------------------------------------------------------------------------- */

String *Constraint_str(Node *n) {
  String *out = NewStringEmpty();
  render_node(out, n);
  return out;
}

/* Append constraint 'c' to the signature 'out' without the whitespace between its tokens and with the names of
 * 'templateparms' replaced by their positions, as C++ compares two declarations' constraints token by token after
 * renaming their template parameters ([temp.over.link]). */
static void append_signature_constraint(String *out, Node *c, ParmList *templateparms) {
  String *rendered = Constraint_str(c);
  String *normalised = Swig_squeeze_c_whitespace(rendered);
  ParmList_replace_names_positional(normalised, templateparms, 0);
  Append(out, normalised);
  Delete(normalised);
  Delete(rendered);
}

/* -----------------------------------------------------------------------------
 * Constraint_signature_str()
 *
 * Render every constraint that is part of the signature of declaration 'n' into a slot for
 * each place a constraint can be written: first the requires-clause on the declaration
 * itself, then the type-constraint on each template parameter, which is where a C++20
 * abbreviated 'Concept auto' parameter puts it.
 *
 * Each constraint is rendered without the whitespace between its tokens and with every template
 * parameter name replaced by its position, $1 for the first, so a declaration and a definition
 * spelling a constraint differently only in these ways compare equal, as they do in C++
 * ([temp.over.link]).  'requires (sizeof(T) > 4)' after 'template<class T>' and
 * 'requires (sizeof(U)>4)' after 'template<class U>' both render as '(sizeof($1)>4)'.
 *
 * Every slot is terminated by a semicolon whether or not a constraint went into it, so the
 * position of an entry says which slot it came from:
 *
 *   template<typename T> requires std::integral<T> T f(T);            std::integral<$1>;;
 *   template<std::integral T> T f(T);                                 ;std::integral;
 *   template<typename T, std::integral U> T f(T, U);                  ;;std::integral;
 *   template<std::integral T, typename U, typename V> T f(T, U, V);   ;std::integral;;;
 *
 * A semicolon therefore terminates a slot rather than separating one from the next, and ";;"
 * is two empty slots rather than a doubled separator.  A declaration with no constraint in
 * any slot renders as nothing but terminators, one for itself and one for each template
 * parameter, so ";" is a plain declaration, ";;" a template taking one parameter and ";;;;"
 * one taking three.
 *
 * A constrained and an unconstrained declaration never compare equal, and the same concept
 * on different parameters compares unequal too.
 * ----------------------------------------------------------------------------- */

String *Constraint_signature_str(Node *n) {
  String *out = NewStringEmpty();
  Node *constraint = Getattr(n, "constraint");
  ParmList *templateparms = Getattr(n, "templateparms");
  Parm *tp;
  if (constraint)
    append_signature_constraint(out, constraint, templateparms);
  Append(out, ";");
  for (tp = templateparms; tp; tp = nextSibling(tp)) {
    Node *tconstraint = Getattr(tp, "constraint");
    if (tconstraint)
      append_signature_constraint(out, tconstraint, templateparms);
    Append(out, ";");
  }
  return out;
}

/* -----------------------------------------------------------------------------
 * Constraint_signatures_equal()
 *
 * Whether two declarations carry identical constraints.  SWIG does not evaluate a constraint, so two
 * written differently, other than in whitespace or template parameter names, are taken to be different
 * even where they mean the same thing.
 * ----------------------------------------------------------------------------- */

int Constraint_signatures_equal(Node *a, Node *b) {
  String *ca = Constraint_signature_str(a);
  String *cb = Constraint_signature_str(b);
  int equal = Equal(ca, cb);
  Delete(ca);
  Delete(cb);
  return equal;
}

/* -----------------------------------------------------------------------------
 * Constraint_has_any()
 *
 * Whether declaration 'n' carries any constraint: a requires-clause, or a type-constraint on one of its
 * template parameters.
 * ----------------------------------------------------------------------------- */

int Constraint_has_any(Node *n) {
  Parm *tp;
  if (Getattr(n, "constraint"))
    return 1;
  for (tp = Getattr(n, "templateparms"); tp; tp = nextSibling(tp)) {
    if (Getattr(tp, "constraint"))
      return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Constraint_differently_constrained()
 *
 * Whether a constraint is what tells two declarations apart, which needs one of them to carry a
 * constraint as well as the signatures to differ.  Two unconstrained declarations can have different
 * signatures simply by having different numbers of template parameters, as ";" against ";;".
 * ----------------------------------------------------------------------------- */

int Constraint_differently_constrained(Node *a, Node *b) {
  return (Constraint_has_any(a) || Constraint_has_any(b)) && !Constraint_signatures_equal(a, b);
}

/* -----------------------------------------------------------------------------
 * Constraint_display_str()
 *
 * Render every constraint of declaration 'n', which Constraint_signature_str() puts in slots, as written and
 * joined by '&&' for a diagnostic, or as "no constraint" when it has none.
 * ----------------------------------------------------------------------------- */

String *Constraint_display_str(Node *n) {
  String *out = NewStringEmpty();
  Node *constraint = Getattr(n, "constraint");
  Parm *tp;
  if (constraint)
    render_node(out, constraint);
  for (tp = Getattr(n, "templateparms"); tp; tp = nextSibling(tp)) {
    Node *tconstraint = Getattr(tp, "constraint");
    if (tconstraint) {
      if (Len(out) > 0)
        Append(out, " && ");
      render_node(out, tconstraint);
    }
  }
  if (Len(out) == 0)
    Append(out, "no constraint");
  return out;
}

/* Append 's' to 'conjuncts' without the whitespace between its tokens, as a parenthesised primary keeps the text as written. */
static void add_conjunct(List *conjuncts, String *s) {
  String *squeezed = Swig_squeeze_c_whitespace(s);
  Append(conjuncts, squeezed);
  Delete(squeezed);
}

/* Append each operand of constraint 'n' that a top level '&&' joins to the others to 'conjuncts'. */
static void add_conjuncts(List *conjuncts, Node *n) {
  if (Equal(Getattr(n, "op"), "and")) {
    Node *c;
    for (c = firstChild(n); c; c = nextSibling(c))
      add_conjuncts(conjuncts, c);
  } else {
    String *s = NewStringEmpty();
    render_node(s, n);
    add_conjunct(conjuncts, s);
    Delete(s);
  }
}

static int compare_conjuncts(const DOH *a, const DOH *b) {
  return Cmp((DOH *)a, (DOH *)b);
}

/* -----------------------------------------------------------------------------
 * Constraint_match_str()
 *
 * Render requires-clause 'constraint' and the type-constraints on 'templateparms', either of
 * which may be 0, as the requires-clause that %rename, %ignore and %feature match them with.
 * Returns 0 when there is no constraint.
 *
 * A type-constraint is written as the concept-id it stands for, 'IsInt T' as 'IsInt<T>' and
 * 'IsInt... Ts' as '(IsInt<Ts> && ...)', and the operands of a top level '&&' are sorted and
 * lose the whitespace between their tokens, so each of these is 'IsInt<T>&&Small<T>':
 *
 *   template<typename T> requires IsInt<T> && Small<T> void f(T);
 *   template<typename T> requires Small<T> void f(T) requires IsInt<T>;
 *   template<IsInt T> requires Small<T> void f(T);
 *
 * The type-constraint on a parameter invented for an abbreviated 'Concept auto' parameter is
 * left out, as it is written in the declarator that a directive already names.
 * ----------------------------------------------------------------------------- */

String *Constraint_match_str(Node *constraint, ParmList *templateparms) {
  List *conjuncts = NewList();
  String *out = 0;
  Parm *tp;
  Iterator ci;
  if (constraint)
    add_conjuncts(conjuncts, constraint);
  for (tp = templateparms; tp; tp = nextSibling(tp)) {
    Node *tconstraint = Getattr(tp, "constraint");
    if (tconstraint && Equal(Getattr(tconstraint, "kind"), "concept-id") && !GetFlag(tp, "abbreviated_auto")) {
      SwigType *id = Copy(Getattr(tconstraint, "type"));
      String *s;
      if (SwigType_istemplate(id)) {
        String *first = NewStringf("<(%s,", Getattr(tp, "name"));
        Replace(id, "<(", first, DOH_REPLACE_FIRST);
        Delete(first);
      } else {
        Printf(id, "<(%s)>", Getattr(tp, "name"));
      }
      s = SwigType_str(id, 0);
      if (SwigType_isvariadic(Getattr(tp, "type"))) {
        String *fold = NewStringf("(%s && ...)", s);
        add_conjunct(conjuncts, fold);
        Delete(fold);
      } else {
        add_conjunct(conjuncts, s);
      }
      Delete(s);
      Delete(id);
    }
  }
  if (Len(conjuncts) > 0) {
    SortList(conjuncts, compare_conjuncts);
    out = NewStringEmpty();
    for (ci = First(conjuncts); ci.item; ci = Next(ci)) {
      if (Len(out) > 0)
        Append(out, "&&");
      Append(out, ci.item);
    }
  }
  Delete(conjuncts);
  return out;
}
