/* ------------------------------------------------------------------------- 
 * type.c
 *
 *     Definition of a DOH type to represent a C type.  The interface
 *     to this DOH type is fairly simple, but its implementation is
 *     complex, as it uses a tree structure internally to cache
 *     already-represented types and avoid the need to allocate an
 *     entire DOH object every time a type object is created.
 * 
 * Author(s) : Dustin Mitchell (djmitche@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ------------------------------------------------------------------------- */

#include "doh.h"
#include "swig.h"

static char cvstag[] = "$Header$";

/* =========================================================================
 * implementation overview
 * ========================================================================= */

/* Public appearance

   To the public, types appear as a chain of constructors, e.g.

   t = Pointer(Pointer(Array(Pointer(Char()))))

   where each of the constructors can have some attributes (const /
   volatile, array size, etc.)

   The 'parent' of a type is the argument to the outermost constructor
   used in the creation of that type.  Thus the parent of t is

   tp = Pointer(Array(Pointer(Char())))


   Internal representation

   In order to save space, we store all of our types in a large tree.
   Because types are constructed from the innermost constructor out
   (e.g. 'Char()' would be the first call in the example above), we
   put the base types (e.g. Char, Int, UInt) at the base of this tree,
   and build from there.  Thus we would find 't', above, by beginning
   at the root of the tree and following the path Char, Pointer,
   Array, Pointer, Pointer.  If we were to construct a type

   t2 = Array(Pointer(Char()))

   we would first walk from our root via the path Char, Pointer,
   Array, and then return a pointer to that node.  To construct

   t3 = Pointer(Pointer(Char()))

   we would walk from our root via the path Char, Pointer, Pointer,
   where we create the final node.

   Fortunately, when we refer to the 'parent' of a type, it is also
   that type's parent in our tree.  Similarly, the 'children' of a
   given type are not visible to the user, but are all the types
   defined by application of further constructors to the given
   type. */


/* =========================================================================
 * constants for internal use
 * ========================================================================= */

/* Base types

   Base types have no parent (with one exception; see *), and can be
   const or volatile.  Width specifies the length in bits of an
   integral type, and the length in bits of the mantissa of a Float.
   Exp_width specifies the width of the exponent in a float type.
   Name specifies the name of a Name type, as well as the optional tag
   for an Enum or Struct.  Attributes specifies the indirect
   attributes of a type.  For Enums, this is the optional list of
   defined names and their values.  For Structs, this is an optional
   list of the types and names of the members.

   (*) If a Name's underlying type is known, then its child field
   points to that type. */
   
#define Swig_Type_Int 1
#define Swig_Type_UInt 2
#define Swig_Type_Float 3
#define Swig_Type_Void 4
#define Swig_Type_Char 5
#define Swig_Type_Name 6
#define Swig_Type_Enum 7
#define Swig_Type_Struct 8

/* Constructors

   Constructors have a parent.  Further, Arrays may have their size
   expression in 'attributes', and Functions have the types and names
   of their arguments in 'attributes'.  A Pointer may be const or
   volatile (which characteristic more accurately applies to its
   child, although this is a matter of interpretation). */

#define Swig_Type_Array 11
#define Swig_Type_Function 12
#define Swig_Type_Pointer 13

/* Subtypes 

   A Struct may either be a Struct or a Union -- since SWIG handles
   them similarly, this is considered a subtype. */

#define Swig_Subtype_Struct 81
#define Swig_Subtype_Union 82

/* =========================================================================
 * structure definitions
 * ========================================================================= */

typedef struct Swig_Type_tag
{
   short type, subtype;
   DOH *name, *attributes;
} Swig_Type_tag;

typedef DOH *Swig_Type_children;

typedef struct Swig_Type_node
{
   Swig_Type_tag type;
   struct Swig_Type_node *parent;
   Swig_Type_hash children;
} Swig_Type_node;

/* =========================================================================
 * static variables
 * ========================================================================= */

/* shorthand */
#define ROOT Swig_Type_root
static Swig_Type_children Swig_Type_root;

/* =========================================================================
 * utility function prototypes
 * ========================================================================= */

/* Take one step down into the children, creating a new node if
   necessary. */
static Swig_Type_node *
Swig_Type_step(Swig_Type_hash children, Swig_Type_tag *tag);

/* Functions to support hashing on Swig_Type_tag objects */

/* =========================================================================
 * utility functions
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * static Swig_Type_node *
 * Swig_Type_step(Swig_Type_hash children, Swig_Type_tag *tag);
 * -------------------------------------------------------------------------
 * Take a step down the tree, creating a new node if necessary, and
 * return a pointer to the node we arrive at.
 * -------------------------------------------------------------------------
