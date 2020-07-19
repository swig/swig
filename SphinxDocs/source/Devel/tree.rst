SWIG Parse Tree Handling
========================

Introduction
------------

This document describes the functions related to the handling of parse
trees in SWIG. The structure of SWIG parse trees has been influenced
heavily by ideas from XML-DOM trees. In fact, the functions in the API
and attribute names are nearly identical. The header file
``Source/swig/swigtree.h`` contains the functions and macros described
in this document. This API is considered to be stable.

Parse tree navigation
---------------------

The following macros are used to navigate the parse tree.

**``nodeType(n)``**

   Returns the type of a node as a String object. The type is stored in
   the "nodeType" attribute of ``n``.

**``parentNode(n)``**

   Returns the parent of a node. This is found in the "parentNode"
   attribute of ``n``.

**``previousSibling(n)``**

   Returns the previous sibling of a node (if any). This is found in the
   "previousSibling" attribute of ``n``.

**``nextSibling(n)``**

   Returns the next sibling of a node (if any). This is found in the
   "nextSibling" attribute of ``n``.

**``firstChild(n)``**

   Returns the first child of a node (if any). This is found in the
   "firstChild" attribute of ``n``.

**``lastChild(n)``**

   Returns the last child of a node (if any). This is found in the
   "lastChild" attribute of ``n``.

Parse Tree Construction
-----------------------

The following macros are used to construct parse trees.

**``set_nodeType(n, val)``**

   Sets the nodeType attribute of n. val is a string containing the
   type.

**``set_parentNode(n, parent)``**

   Sets the parent of node n.

**``set_previousSibling(n, prev)``**

   Sets the previous sibling of node n.

**``set_nextSibling(n, next)``**

   Sets the next sibling of node n.

**``set_firstChild(n, chd)``**

   Sets the first child of node n.

**``set_lastChild(n, chd)``**

   Sets the last child of node n.

Tree Management Functions
-------------------------

The following functions are used to help with the management and
construction of parse trees.

**``void appendChild(Node *node, Node *child)``**

   Adds a new child to ``node``. This function takes care of adjusting
   the "firstChild" and "lastChild" attributes of ``node`` to
   appropriate values. After calling this function, the "lastChild"
   attribute will point to ``child``.

**``void prependChild(Node *node, Node *child)``**

   Prepends a new child to ``node``. The new child is added so that it
   becomes the first child of ``node``.

**``void removeNode(Node *node)``**

   Removes a node from the parse tree. The removal process detaches a
   node from its parent by removing it from the parent's child list.
   Upon return, ``node`` will have no parent and no siblings. This
   function does NOT delete ``node`` or modify children of ``node``. If
   desired, ``node`` could be reattached to a different part of the
   parse tree.

**``Node *copyNode(Node *node)``**

   Copies a node, but only copies those attributes that are simple
   strings. Thus, the new node will not contain any references to other
   nodes, lists, hashes, or other complex data structures. This function
   may be useful if you want to copy the data contents of a node in the
   process of creating a new parse tree node.

Attribute Checking
------------------

The following utility is provided since this is an extremely common
operation.

**``int checkAttribute(Node *n, const String_or_char *name, const String_or_char *value)``**

   This function checks to see whether node ``n`` has a given attribute
   name and that the attribute has a given value. Returns 0 or 1.

Node Transformation
-------------------

In the course of processing, SWIG often applies a transform to a node.
This transformation process made modify many of the attributes--even
changing the type of a node. The following functions are used to help
manage this transformation process. In addition to provide sanity
checks, they save the old contents of the node so that they can be
restored later.

**``void Swig_save(const char *namespace, Node *n, ...)``**

   This function takes a node and a list of attribute names and saves
   their contents in a specified namespace. For example, the call

   ::

      Swig_save("temp",n,"type","parms","name",NIL)

   takes the attributes "type","parms", and "name" and saves their
   contents under the attribute names
   "temp:type","temp:parms","temp:name". In addition, this function sets
   an attribute "view" to hold the name of the current namespace. In
   this example, the "view" attribute would be set to "temp". The
   attribute names specified are all optional. If one or more of the
   attributes don't exist, this function merely records that those
   attributes did not exist in the original node.

**``void Swig_require(const char *namespace, Node *n, ...)``**

   This function is similar to ``Swig_save()`` except that adds
   additional attribute checking. There are different interpretations of
   the attribute names. A name of "attr" merely requests that the
   function check for the presence of an attribute. If the attribute is
   missing, SWIG will exit with a failed assertion. An attribute name of
   "?attr" specifies that the attribute "attr" is optional and that its
   old value must be saved (if any). An attribute name of "*attr"
   specifies that the attribute is required and that its value must be
   saved. The saving of attributes is performed in the same manner as
   with ``Swig_save()``. Here is an example:

   ::

      Swig_require("temp",n,"type","*name","?parms",NIL);

**``void Swig_restore(Node *n)``**

   This function restores a node to the state it was in prior to the
   last ``Swig_save()`` or ``Swig_require()`` call. This is used to undo
   node transformations.

Debugging Functions
-------------------

The following functions can be used to help debug any SWIG DOH object.

**``void Swig_print(DOH *object, int count = -1)``**

   Prints to stdout a string representation of any DOH type. The number
   of nested Hash types to expand is set by count (default is 1 if
   count<0). See Swig_set_max_hash_expand() to change default.

   ::

**``void Swig_print_with_location(DOH *object, int count = -1)``**

   Prints to stdout a string representation of any DOH type, within []
   brackets for Hash and List types, prefixed by line and file
   information. The number of nested Hash types to expand is set by
   count (default is 1 if count<0). See Swig_set_max_hash_expand() to
   change default.

   ::

The following functions can be used to help debug SWIG parse trees.

**``void Swig_print_tags(Node *node, String_or_char *prefix)``**

   Prints the tag-structure of the parse tree to standard output.
   ``node`` is the top-level parse tree node. ``prefix`` is a string
   prefix that's added to the start of each line. Normally, you would
   specify the empty string or NIL for ``prefix``. This function is
   called by the ``-debug-tags`` option to SWIG.

   ::

      % swig -debug-tags -python example.i
       . top (:1)
       . top . include (/Users/beazley/Projects/share/swig/1.3.31/swig.swg:0)
       . top . include . include (/Users/beazley/Projects/share/swig/1.3.31/swigwarnings.swg:0)
       . top . include . include . include (/Users/beazley/Projects/share/swig/1.3.31/swigwarn.swg:0)
      ...
      ...
       . top . include (example.i:0)
       . top . include . module (example.i:2)
       . top . include . insert (example.i:7)
       . top . include . cdecl (example.i:5)
       . top . include . cdecl (example.i:6)

   Since many language modules include hundreds of typemaps and other
   information, the output of this can be significantly more complicated
   than you might expect.

**``void Swig_print_node(Node *node)``**

   Prints the contents of a parse tree node, including all children, to
   standard output. The output includes all attributes and other
   details.

**``void Swig_print_tree(Node *node)``**

   Prints the same output as ``Swig_print_node()`` except that it also
   processes all of the siblings of ``node``. This can be used to dump
   the entire parse tree to standard output. The command line options
   ``-debug-module`` and ``-debug-top`` use this function to display the
   parse tree for a SWIG input file.
