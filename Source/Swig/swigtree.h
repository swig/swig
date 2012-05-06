/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * swigtree.h
 *
 * These functions are used to access and manipulate the SWIG parse tree.
 * The structure of this tree is modeled directly after XML-DOM.  The attribute 
 * and function names are meant to be similar.
 * ----------------------------------------------------------------------------- */

/* $Id: swig.h 9622 2006-12-19 03:49:17Z beazley $ */

/* Macros to traverse the DOM tree */

#define  nodeType(x)               Getattr(x,"nodeType")
#define  parentNode(x)             Getattr(x,"parentNode")
#define  previousSibling(x)        Getattr(x,"previousSibling")
#define  nextSibling(x)            Getattr(x,"nextSibling")
#define  firstChild(x)             Getattr(x,"firstChild")
#define  lastChild(x)              Getattr(x,"lastChild")

/* Macros to set up the DOM tree (mostly used by the parser) */

#define  set_nodeType(x,v)         Setattr(x,"nodeType",v)
#define  set_parentNode(x,v)       Setattr(x,"parentNode",v)
#define  set_previousSibling(x,v)  Setattr(x,"previousSibling",v)
#define  set_nextSibling(x,v)      Setattr(x,"nextSibling",v)
#define  set_firstChild(x,v)       Setattr(x,"firstChild",v)
#define  set_lastChild(x,v)        Setattr(x,"lastChild",v)

/* Utility functions */

extern int    checkAttribute(Node *obj, const String_or_char *name, const String_or_char *value);
extern void   appendChild(Node *node, Node *child);
extern void   prependChild(Node *node, Node *child);
extern void   removeNode(Node *node);
extern Node  *copyNode(Node *node);

/* Node restoration/restore functions */

extern void  Swig_require(const char *ns, Node *node, ...);
extern void  Swig_save(const char *ns, Node *node, ...);
extern void  Swig_restore(Node *node);

/* Debugging of parse trees */

extern void Swig_print_tags(File *obj, Node *root);
extern void Swig_print_tree(Node *obj);
extern void Swig_print_node(Node *obj);
