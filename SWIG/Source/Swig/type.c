/* ------------------------------------------------------------------------- 
 * type.c
 *
 *     Definition of a DOH type to represent a C type.  The interface
 *     to this DOH type is fairly simple, but its implementation is
 *     complex, as it uses a tree structure internally to cache
 *     already-represented types and avoid the need to allocate an
 *     entire DOH object every time a type object is created.
 *
 *     While this library is designed to handle C types, it should be
 *     sufficiently general to handle most system-level langages.
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
 * Implementation Overview
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
   const or volatile (that is, 'is_const' and 'is_volatile' are
   relevant).  'width' specifies the length in bits of an integral or
   character (e.g. wchar) type, and the length in bits of the mantissa
   of a Float.  'exp_width' specifies the width of the exponent in a
   float type.  Only ints can be signed or unsigned (i.e. their
   'is_signed' and 'is_unsigned' are relevant) (N.B.: the axiom of the
   excluded middle does not apply here: an integer, an unsigned
   integer, and a signed integer are distinct types). 'name' specifies
   the name of a Name type, as well as the optional tag for an Enum or
   Struct.  'attributes' specifies the indirect attributes of a type.
   For Enums, this is the optional list of defined names and their
   values.  For Structs and Unions, this is an optional list of the
   types and names of the members.

   Note: it is up to the parser to distinguish character types
   (i.e. those containing ASCII data) from 8-bit integer types, most
   likely using some simple heuristics.

   (*) If a Name's underlying type is known, then its child field
   points to that type.
   
   Constructors

   Constructors have a parent.  Further, Arrays may have their size
   expression in 'attributes', and Functions have the types and names
   of their arguments in 'attributes'.  A Pointer may be const or
   volatile (which characteristic more accurately applies to its
   child, although this is a matter of interpretation). */

/* (these constants are now in swig.h) */

/* Constants for results of comparisons: */

#define TAGS_EQ 0
#define TAGS_NEQ 1

/* =========================================================================
 * structure definitions
 * ========================================================================= */
/* These are both DOH types so that we can hash them.  The first
   (Swig_Type_tag) is a completely internal DOH type, while the second
   is the publicly exported DOH type. */

typedef struct Swig_Type_tag
{
   DOHCOMMON;

   short type;
   DOH *name;
   DOH *attributes;
   short width;
   short exp_width;
   int is_const;
   int is_volatile;
   int is_signed;
   int is_unsigned;

   int hashkey;
} Swig_Type_tag;

typedef DOH *Swig_Type_children; /* a DOH Hash */

typedef struct Swig_Type_node
{
   DOHCOMMON;

   Swig_Type_tag *tag;
   struct Swig_Type_node *parent;
   Swig_Type_children children;

   struct Swig_Type_node *current_item;
   int hashkey;
} Swig_Type_node;

/* =========================================================================
 * static variables
 * ========================================================================= */

/* shorthand */
#define ROOT Swig_Type_root
static Swig_Type_children Swig_Type_root = NULL;

/* =========================================================================
 * utility function declarations
 * ========================================================================= */

/* Take one step down into the children, creating a new node if
   necessary. If parent is NULL, add to the root. */
static Swig_Type_node *
Swig_Type_step(Swig_Type_node *parent, Swig_Type_tag *tag);

/* Make sure that this is a real DOH string, not a (char *). */
static DOH *
Swig_Type_make_string(DOH *in);

/* the smallest n such that i < 2**n */
static int Swig_Type_bit_count(unsigned int i);

/* return a string of tag's flags, possibly including signs */
static DOH *
Swig_Type_tag_flags(Swig_Type_tag *tag, int do_signs);

/* =========================================================================
 * Swig_Type_tag DOH type declaration
 * ========================================================================= */

static DOH * 
Swig_Type_tag_new(short type,
		  DOH *name, DOH *attributes,
		  int width, int exp_width,
		  int is_const, int is_volatile,
		  int is_signed, int is_unsigned);

static DOH *Swig_Type_tag_str(DOH *o); /* e.g. 'pointer to' */
static int Swig_Type_tag_hash(DOH *o);
static int Swig_Type_tag_cmp(DOH *o1, DOH *o2);
#define TagData(x) ((Swig_Type_tag *)(x))

static DohObjInfo Swig_Type_tag_Type = 
{
   "TypeTag",			/* objname */
   sizeof(Swig_Type_tag),	/* objsize */
   0,				/* doh_del -- will never happen */
   0,				/* doh_copy */
   0,				/* doh_clear */
   0,				/* doh_scope */
   Swig_Type_tag_str,		/* doh_str */
   0,				/* doh_data */
   0,				/* doh_dump */
   0,				/* doh_load */
   0,				/* doh_len */
   Swig_Type_tag_hash,		/* doh_hash */
   Swig_Type_tag_cmp,		/* doh_cmp */
   0,				/* doh_mapping */
   0,				/* doh_sequence */
   0,				/* doh_file */
   0,				/* doh_string */ 
   0,				/* doh_callable */ 
   0,				/* doh_position */
};

/* =========================================================================
 * Swig_Type_node DOH type declaration
 * ========================================================================= */

static DOH *Swig_Type_node_new(DOH *tag, DOH *parent);

static DOH *Swig_Type_node_str(DOH *o); /* e.g. 'pointer to array (10)
					   of pointer to char'' */
static int Swig_Type_node_hash(DOH *o);
static int Swig_Type_node_cmp(DOH *o, DOH *o2);
static DOH *Swig_Type_node_getitem(DOH *o, int index);
static DOH *Swig_Type_node_firstitem(DOH *o);
static DOH *Swig_Type_node_nextitem(DOH *o);
static int Swig_Type_node_len(DOH *o);
#define NodeData(x) ((Swig_Type_node *)(x))

static DohSequenceMethods Swig_Type_node_AsSequence =
{
   Swig_Type_node_getitem,
   0,
   0,
   0,
   Swig_Type_node_firstitem,
   Swig_Type_node_nextitem
};

static DohObjInfo Swig_Type_node_Type = 
{
   "Type",			/* objname */
   sizeof(Swig_Type_node),	/* objsize */
   0,				/* doh_del -- will never happen */
   0,				/* doh_copy */
   0,				/* doh_clear */
   0,				/* doh_scope */
   Swig_Type_node_str,		/* doh_str */
   0,				/* doh_data */
   0,				/* doh_dump */
   0,				/* doh_load */
   Swig_Type_node_len,		/* doh_len */
   Swig_Type_node_hash,		/* doh_hash */
   Swig_Type_node_cmp,		/* doh_cmp */
   0,				/* doh_mapping */
   &Swig_Type_node_AsSequence,	/* doh_sequence */
   0,				/* doh_file */
   0,				/* doh_string */ 
   0,				/* doh_callable */ 
   0,				/* doh_position */
};

/* =========================================================================
 * utility functions
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * static Swig_Type_node *
 * Swig_Type_step(Swig_Type_node *parent, Swig_Type_children children, 
 *                Swig_Type_tag *tag);
 * -------------------------------------------------------------------------
 * Take a step down the tree, creating a new node if necessary, and
 * return a pointer to the node we arrive at.
 * ------------------------------------------------------------------------- */

static Swig_Type_node *
Swig_Type_step(Swig_Type_node *parent, Swig_Type_tag *tag)
{
   Swig_Type_children children;
   DOH *subnode;

   if (parent) children = parent->children;
   else if (ROOT) children = ROOT;
   else children = ROOT = NewHash();
		  
   subnode = Getattr(children, tag);
   
   if (!subnode) {
      subnode = Swig_Type_node_new(tag, parent);
      Setattr(children, tag, subnode);
   }
   
   return NodeData(subnode);
}

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_make_string(DOH *in);
 * -------------------------------------------------------------------------
 * Make sure that this is a real DOH string, not a (char *). 
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_make_string(DOH *in)
{
   if (String_check(in) || SuperString_check(in))
      return in;
   
   /* assume (char *) */
   if (in)
      return NewString(in);
   else
      return NULL;
}

/* -------------------------------------------------------------------------
 * static int Swig_Type_bit_count(unsigned int i);
 * -------------------------------------------------------------------------
/* The smallest n such that i < 2**n 
 * ------------------------------------------------------------------------- */

static int Swig_Type_bit_count(unsigned int i)
{
   int n = 0;
   while (i)
      n++, i >>= 1;
   return n;
}

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_tag_flags(Swig_Type_tag *tag, int do_signs);
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_tag_flags(Swig_Type_tag *tag, int do_signs)
{
   char * fmt = "%s";
   DOH *s = NewString("[");
   Seek(s, 0, SEEK_END);

   if (tag->is_const) Printf(s, fmt, "const"), fmt = " %s";
   if (tag->is_volatile) Printf(s, fmt, "volatile"), fmt = " %s";
   if (do_signs && tag->is_signed) Printf(s, fmt, "signed"), fmt = " %s";
   if (do_signs && tag->is_unsigned) Printf(s, fmt, "unsigned"), fmt = " %s";

   Printf(s, "]");

   return s;
}

/* =========================================================================
 * Swig_Type_tag DOH type implementation
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_tag_new( ... );
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_tag_new(short type,
		  DOH *name, DOH *attributes,
		  int width, int exp_width,
		  int is_const, int is_volatile,
		  int is_signed, int is_unsigned)
{
   Swig_Type_tag *t;

   t = (Swig_Type_tag *)DohObjMalloc(sizeof(Swig_Type_tag));
   t->objinfo = &Swig_Type_tag_Type;
   t->hashkey = -1;
   t->type = type;
   t->name = Swig_Type_make_string(name); if (t->name) Incref(t->name);
   t->attributes = attributes; if (t->attributes) Incref(t->attributes);
   t->width = width;
   t->exp_width = exp_width;
   t->is_const = is_const;
   t->is_volatile = is_volatile;
   t->is_signed = is_signed;
   t->is_unsigned = is_unsigned;

   return t;
}

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_tag_str(DOH *o);
 * ------------------------------------------------------------------------- */

static DOH *Swig_Type_tag_str(DOH *o)
{
   Swig_Type_tag *tag = TagData(o);
   DOH *s = NewString("");
   Seek(s, 0, SEEK_END);
   
   switch (tag->type)
   {
   case Swig_Type_Int:
      Printf(s, "Int(%d, %s)", tag->width,
	     Swig_Type_tag_flags(tag, 1));
      break;
   case Swig_Type_Float:
      Printf(s, "Float(%d ** %d, %s)", 
	     tag->width, tag->exp_width,
	     Swig_Type_tag_flags(tag, 0));
      break;
   case Swig_Type_Void:
      Printf(s, "Void");
      break;
   case Swig_Type_Char:
      Printf(s, "Char(%d, %s)", tag->width,
	     Swig_Type_tag_flags(tag, 0));
      break;
   case Swig_Type_Name:
      Printf(s, "Name('%s', %s)", tag->name,
	     Swig_Type_tag_flags(tag, 0));
      break;
   case Swig_Type_Enum:
      Printf(s, "Enum(");
      if (tag->name)
	 Printf(s, "'%s', ", tag->name);
      if (tag->attributes)
	 Printf(s, "%s, ", tag->attributes);
      Printf(s, "%s)", Swig_Type_tag_flags(tag, 0));
      break;
   case Swig_Type_Struct:
      Printf(s, "Struct(");
      if (tag->name)
	 Printf(s, "'%s', ", tag->name);
      if (tag->attributes)
	 Printf(s, "%s, ", tag->attributes);
      Printf(s, "%s)", Swig_Type_tag_flags(tag, 0));
      break;
   case Swig_Type_Union:
      Printf(s, "Union(");
      if (tag->name)
	 Printf(s, "'%s', ", tag->name);
      if (tag->attributes)
	 Printf(s, "%s, ", tag->attributes);
      Printf(s, "%s)", Swig_Type_tag_flags(tag, 0));
      break;
   case Swig_Type_Array:
      if (tag->attributes)
	 Printf(s, "Array (%s)", tag->attributes);
      Printf(s, "Array of ");
      break;
   case Swig_Type_Function:
      Printf(s, "Function (%s) returning ", tag->attributes);
      break;
   case Swig_Type_Pointer:
      Printf(s, "Pointer %s to ", Swig_Type_tag_flags(tag, 0));
      break;
   }

   return s;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_tag_hash(DOH *o);
 * ------------------------------------------------------------------------- */

static int Swig_Type_tag_hash(DOH *o)
{
   Swig_Type_tag *tag = TagData(o);
   if (tag->hashkey != -1) return tag->hashkey;

   /* barring the use of any sub-object's Hashval, we assign a
      different integer to each of our types. */
   switch (tag->type)
   {
      /* base types are assigned certain numbers */
   case Swig_Type_Int:
      tag->hashkey = 
	 Swig_Type_bit_count(tag->width) +
	 (tag->is_const << 4) +
	 (tag->is_volatile << 5) +
	 (tag->is_signed << 6) +
	 (tag->is_unsigned << 7);
      break;
   case Swig_Type_Float:
      tag->hashkey = 
	 Swig_Type_bit_count(tag->width) + 
	 (Swig_Type_bit_count(tag->exp_width) << 4) + 
	 (tag->is_const << 8) +
	 (tag->is_volatile << 9) +
	 1 << 10;
      break;
   case Swig_Type_Void:
      tag->hashkey = 
	 Swig_Type_bit_count(tag->width) +
	 (tag->is_const << 4) +
	 (tag->is_volatile << 5) +
	 (tag->is_signed << 6) +
	 (tag->is_unsigned << 7) +
	 2 << 10;
      break;
   case Swig_Type_Char:
      tag->hashkey = 
	 Swig_Type_bit_count(tag->width) +
	 (tag->is_const << 4) +
	 (tag->is_volatile << 5) +
	 (tag->is_signed << 6) +
	 (tag->is_unsigned << 7) +
	 3 << 10;
      break;
   case Swig_Type_Name:
      tag->hashkey = 
	 Hashval(tag->name);
      break;
   case Swig_Type_Enum:
      tag->hashkey = 
	 (tag->name) ? Hashval(tag->name) : 0 +
	 (tag->attributes) ? Hashval(tag->attributes) : 0 +
	 5 << 10;
      break;
   case Swig_Type_Struct:
      tag->hashkey = 
	 (tag->name) ? Hashval(tag->name) : 0 +
	 (tag->attributes) ? Hashval(tag->attributes) : 0 +
	 6 << 10;
      break;
   case Swig_Type_Union:
      tag->hashkey = 
	 (tag->name) ? Hashval(tag->name) : 0 +
	 (tag->attributes) ? Hashval(tag->attributes) : 0 +
	 7 << 10;
      break;
   case Swig_Type_Array:
      tag->hashkey = 
	 (tag->attributes) ? Hashval(tag->attributes) : 0 +
	 8 << 10;
      break;
   case Swig_Type_Function:
      tag->hashkey = 
	 (tag->attributes) ? Hashval(tag->attributes) : 0 +
	 9 << 10;
      break;
   case Swig_Type_Pointer:
      tag->hashkey = 
	 (tag->is_const << 8) +
	 (tag->is_volatile << 9) +
	 10 << 10;
      break;

   default:
      tag->hashkey =
	 tag->type;
      break;
   }

   if (tag->hashkey == -1) tag->hashkey = 1;
   return tag->hashkey;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_tag_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static int Swig_Type_tag_cmp(DOH *o1, DOH *o2)
{
   Swig_Type_tag *t1, *t2;
   t1 = TagData(o1);
   t2 = TagData(o2);

   /* we define only equal or not equal, as that's all we need to hash
      types. */

   if (t1 == t2)
      return TAGS_EQ;

   if (t1->type != t2->type)
      return TAGS_NEQ;

   switch (t1->type)
   {
   case Swig_Type_Int:
      if (t1->width != t2->width ||
	  t1->is_const != t2->is_const ||
	  t1->is_volatile != t2->is_volatile ||
	  t1->is_unsigned != t2->is_unsigned ||
	  t1->is_signed != t2->is_signed)
	 return TAGS_NEQ;
      break;
   case Swig_Type_Float:
      if (t1->width != t2->width ||
	  t1->exp_width != t2->exp_width ||
	  t1->is_const != t2->is_const ||
	  t1->is_volatile != t2->is_volatile)
	 return TAGS_NEQ;
      break;
   case Swig_Type_Void:
      break;			/* nothing to it.. */
   case Swig_Type_Char:
      if (t1->width != t2->width ||
	  t1->is_const != t2->is_const ||
	  t1->is_volatile != t2->is_volatile)
	 return TAGS_NEQ;
      break;
   case Swig_Type_Name:
      return Cmp(t1->name, t2->name);
   case Swig_Type_Struct:
   case Swig_Type_Union:
   case Swig_Type_Enum:
      /* do the names differ? */
      if (t1->name && t2->name)
      {
	 if (Cmp(t1->name, t2->name))
	    return TAGS_NEQ;
	 else if (t1->attributes && t2->attributes)
	    return Cmp(t1->attributes, t2->attributes);
	 else if (t1->attributes || t2->attributes)
	    /* both named, only one has attributes... */
	    return TAGS_NEQ;
	 else
	    /* both named, neither has attributes */
	    return TAGS_EQ;
      }
      else if (t1->name || t2->name) 
	 /* one named, one not */
	 return TAGS_NEQ;
      else 
      {
	 /* neither named -- structural equivalence */
	 if (t1->attributes && t2->attributes)
	    return Cmp(t1->attributes, t2->attributes);
	 else
	    /* this should never happen .. */
	    return TAGS_NEQ;
      }
   case Swig_Type_Array:
      if (t1->attributes && t2->attributes)
	 return Cmp(t1->attributes, t2->attributes);
      else if (t1->attributes || t2->attributes)
	 return TAGS_NEQ;
      else
	 return TAGS_EQ;
   case Swig_Type_Function:
      return Cmp(t1->attributes, t2->attributes);
   case Swig_Type_Pointer:
      if (t1->is_volatile != t2->is_volatile ||
	  t1->is_const != t2->is_const)
	 return TAGS_NEQ;
      break;
   default:
      return TAGS_NEQ;
   }

   /* fall through -> equal */
   return TAGS_EQ;
}

/* =========================================================================
 * Swig_Type_node DOH type implementation
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_NewXXX( <varies> );
 * ------------------------------------------------------------------------- 
 * Public constructors for various sorts of types (types of sorts?)
 * ------------------------------------------------------------------------- */

DOH *Swig_Type_NewInt(int width, int is_const, int is_volatile, 
		      int is_signed, int is_unsigned)
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Int, 
					   NULL, NULL,
					   width, 0,
					   is_const, is_volatile,
					   is_signed, is_unsigned));
}

DOH *Swig_Type_NewFloat(int width, int exp_width, int is_const,
			int is_volatile)
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Float,
					   NULL, NULL,
					   width, exp_width,
					   is_const, is_volatile,
					   0, 0));
}

DOH *Swig_Type_NewVoid()
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Void,
					   NULL, NULL,
					   0, 0,
					   0, 0,
					   0, 0));
}

DOH *Swig_Type_NewChar(int width, int is_const, int is_volatile)
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Char,
					   NULL, NULL,
					   width, 0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *Swig_Type_NewName(DOH *name, int is_const, int is_volatile)
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Name,
					   name, NULL,
					   0, 0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *Swig_Type_NewEnum(DOH *name, DOH *body, 
		       int is_const, int is_volatile)
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Name,
					   name, body,
					   0, 0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *Swig_Type_NewStruct(DOH *name, DOH *body, 
			 int is_const, int is_volatile)
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Struct, 
					   name, body,
					   0, 0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *Swig_Type_NewUnion(DOH *name, DOH *body, 
			int is_const, int is_volatile)
{
   return Swig_Type_step(NULL, 
			 Swig_Type_tag_new(Swig_Type_Union, 
					   name, body,
					   0, 0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *Swig_Type_NewArray(DOH *size, DOH *parent)
{
   return Swig_Type_step(parent, 
			 Swig_Type_tag_new(Swig_Type_Array, 
					   0, size,
					   0, 0,
					   0, 0,
					   0, 0));
}

DOH *Swig_Type_NewFunction(DOH *parameters, DOH *parent)
{
   return Swig_Type_step(parent, 
			 Swig_Type_tag_new(Swig_Type_Function, 
					   0, parameters,
					   0, 0,
					   0, 0,
					   0, 0));
}

DOH *Swig_Type_NewPointer(int is_const, int is_volatile, DOH *parent)
{
   return Swig_Type_step(parent, 
			 Swig_Type_tag_new(Swig_Type_Pointer, 
					   0, 0,
					   0, 0,
					   is_const, is_volatile,
					   0, 0));
}

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_GetXXX(DOH *t);
 * ------------------------------------------------------------------------- 
 * Field accessors
 * ------------------------------------------------------------------------- */

int Swig_Type_GetType(DOH *t) { return NodeData(t)->tag->type; }
DOH *Swig_Type_GetName(DOH *t) { return NodeData(t)->tag->name; }
DOH *Swig_Type_GetAttributes(DOH *t) { return NodeData(t)->tag->attributes; }
int Swig_Type_GetWidth(DOH *t) { return NodeData(t)->tag->width; }
int Swig_Type_GetExpWidth(DOH *t) { return NodeData(t)->tag->exp_width; }
int Swig_Type_GetConst(DOH *t) { return NodeData(t)->tag->is_const; }
int Swig_Type_GetVolatile(DOH *t) { return NodeData(t)->tag->is_volatile; }
int Swig_Type_GetSigned(DOH *t) { return NodeData(t)->tag->is_signed; }
int Swig_Type_GetUnsigned(DOH *t) { return NodeData(t)->tag->is_unsigned; }

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_node_new(DOH *tag, DOH *parent);
 * ------------------------------------------------------------------------- 
 * private, 'real' constructor
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_node_new(DOH *tag, DOH *parent)
{
   Swig_Type_node *n;

   n = (Swig_Type_node *)DohObjMalloc(sizeof(Swig_Type_node));
   n->objinfo = &Swig_Type_node_Type;

   n->parent = parent;
   n->tag = tag; Incref(tag);
   n->children = NewHash();
   n->hashkey = -1;

   return n;
}

/* -------------------------------------------------------------------------
 * static DOH *
 * Swig_Type_node_str(DOH *o);
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_node_str(DOH *o)
{
   Swig_Type_node *n = (Swig_Type_node *)o;
   DOH *s = NewString("");
   if (n->parent)
      Printf(s, "%s%s", n->tag, n->parent);
   else
      Printf(s, "%s", Str(n->tag));

   return s;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_node_hash(DOH *o);
 * ------------------------------------------------------------------------- */

static int
Swig_Type_node_hash(DOH *o)
{
   Swig_Type_node *n = (Swig_Type_node *)o;   
   if (n->hashkey != -1) return n->hashkey;

   n->hashkey = Hashval(n->tag);
   if (n->parent)
   {
      int hvp = Hashval(n->parent);

      n->hashkey += (hvp << 12) + (hvp >> 12);
   }

   if (n->hashkey == -1) n->hashkey = 1;
   
   return n->hashkey;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static int 
Swig_Type_node_cmp(DOH *o1, DOH *o2)
{
   Swig_Type_node *n1 = (Swig_Type_node *)o1;
   Swig_Type_node *n2 = (Swig_Type_node *)o1;

   /* we call the comparison functions directly just to shave a
      harmless hair off the execution time */

   if (Swig_Type_tag_cmp(n1->tag, n2->tag))
      return TAGS_NEQ;
   
   else if (n1->parent && n2->parent)
      return Swig_Type_node_cmp(n1->parent, n2->parent);

   else if (n1->parent || n2->parent)
      return TAGS_NEQ;
   else
      return TAGS_EQ;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_node_getitem(DOH *o, int index)
{
   Swig_Type_node *n = NodeData(o);
   while (n && index--)
      n = n->parent;

   return n;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_node_firstitem(DOH *o)
{
   Swig_Type_node *n = NodeData(o);
   return n->current_item = n;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static DOH *
Swig_Type_node_nextitem(DOH *o)
{
   Swig_Type_node *n = NodeData(o);
   if (n->parent)
      return n->current_item = n->current_item->parent;
}

/* -------------------------------------------------------------------------
 * static int
 * Swig_Type_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static int
Swig_Type_node_len(DOH *o)
{
   Swig_Type_node *n = NodeData(o);
   int depth = 0;
 
   while (n)
      n = n->parent, depth++;

   return depth;
}

/* -------------------------------------------------------------------------
 * main() -- conditionally compiled test harness
 * ------------------------------------------------------------------------- */

#ifdef TYPE_TEST
#include <stdio.h>
int main(int argc, char **argv)
{
   int i;
   DOH *node[10];
   DOH *key;
   DOH *t;

   /* build some types */
   node[0] = Swig_Type_NewInt(8, 0, 0, 1, 0);
   node[1] = Swig_Type_NewPointer(0, 1, node[0]);
   node[2] = Swig_Type_NewPointer(1, 0, node[1]);
   node[3] = Swig_Type_NewArray(NULL, node[2]);

   node[4] = Swig_Type_NewInt(8, 0, 0, 1, 0);
   node[5] = Swig_Type_NewPointer(0, 1, node[4]);
   node[6] = Swig_Type_NewPointer(1, 1, node[5]);
   node[7] = Swig_Type_NewArray(NULL, node[5]);
   
   node[8] = Swig_Type_NewVoid();
   node[9] = Swig_Type_NewVoid();
   node[9] = Swig_Type_NewPointer(0, 1, node[9]);
   node[9] = Swig_Type_NewPointer(1, 1, node[9]);
   node[9] = Swig_Type_NewPointer(1, 0, node[9]);
   node[9] = Swig_Type_NewPointer(0, 0, node[9]);

   /* print each type along with its address (to see the hashing) */
   Printf(stdout, "Address\t\tHashvalue\tType\n");
   Printf(stdout, "-------\t\t---------\t----\n");
   for (i = 0; i < 10; i++)
      Printf(stdout, "0x%08x\t0x%08x\t%s\n", node[i],
	     Hashval(node[i]), node[i]);

   /* print the root of our tree (internal interest) */
   Printf(stdout, "\nROOT (0x%08x):\n", ROOT);
   for (key = Firstkey(ROOT); key; key = Nextkey(ROOT))
      Printf(stdout, "%s : %s\n", key, Getattr(ROOT, key));
   
   /* walk the tree for a type in two different ways */
   Printf(stdout, "\nWalk 1:\n");
   for (t = Firstitem(node[9]); t; t = Nextitem(node[9]))
   {
      switch(Swig_Type_GetType(t))
      {
      case Swig_Type_Pointer:
	 Printf(stdout, "Pointer\n");
	 break;
      case Swig_Type_Void:
	 Printf(stdout, "Void\n");
	 break;
      default:
	 Printf(stdout, "Other\n");
	 break;
      }
   }

   Printf(stdout, "\nWalk 2:\n");
   for (i = 0; i < Len(node[9]); i++)
   {
      t = Getitem(node[9], i);
      switch(Swig_Type_GetType(t))
      {
      case Swig_Type_Pointer:
	 Printf(stdout, "Pointer\n");
	 break;
      case Swig_Type_Void:
	 Printf(stdout, "Void\n");
	 break;
      default:
	 Printf(stdout, "Other\n");
	 break;
      }
   }
   return 0;
}
#endif
