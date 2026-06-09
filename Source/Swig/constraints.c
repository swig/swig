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
 * node) as the C++20 source text it represents.  The returned String must be
 * freed by the caller.
 * ----------------------------------------------------------------------------- */

String *Constraint_str(Node *n) {
  String *out = NewStringEmpty();
  render_node(out, n);
  return out;
}
