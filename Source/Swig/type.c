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
   of a Float.  Only ints can be signed or unsigned (i.e. their
   'is_signed' and 'is_unsigned' are relevant) (N.B.: the axiom of the
   excluded middle does not apply here: an integer, an unsigned
   integer, and a signed integer are distinct types). 'name' specifies
   the name of a Name type, as well as the optional tag for an Enum or
   Struct.  'attributes' specifies the indirect attributes of a type.
   For Enums, this is the optional list of defined names and their
   values.  For Structs and Unions, this is an optional list of the
   types and names of the members.  The even-indexed elements of these
   lists are the values and types, respectively, and the odd-indexed
   elements are the names.  Helper functions may appear to handle such
   information. 

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
   (SwigType_tag) is a completely internal DOH type, while the second
   is the publicly exported DOH type. */

typedef struct SwigType_tag
{
   DOHCOMMON;

   short type;
   DOH *name;
   DOH *attributes;
   short width;
   int is_const;
   int is_volatile;
   int is_signed;
   int is_unsigned;

   int hashkey;
} SwigType_tag;

typedef DOH *SwigType_children; /* a DOH Hash */

typedef struct SwigType_node
{
   DOHCOMMON;

   SwigType_tag *tag;
   struct SwigType_node *parent;
   SwigType_children children;

   struct SwigType_node *current_item;
   int hashkey;
} SwigType_node;

/* =========================================================================
 * static variables
 * ========================================================================= */

/* shorthand */
#define ROOT SwigType_root
static SwigType_children SwigType_root = NULL;

/* =========================================================================
 * utility function declarations
 * ========================================================================= */

/* Take one step down into the children, creating a new node if
   necessary. If parent is NULL, add to the root. */
static SwigType_node *
SwigType_step(SwigType_node *parent, SwigType_tag *tag);

/* Make sure that this is a real DOH string, not a (char *). */
static DOH *
SwigType_make_string(DOH *in);

/* the smallest n such that i < 2**n */
static int SwigType_bit_count(unsigned int i);

/* return a string of tag's flags, possibly including signs */
static DOH *
SwigType_tag_flags(SwigType_tag *tag, int do_signs);

/* =========================================================================
 * SwigType_tag DOH type declaration
 * ========================================================================= */

static DOH * 
SwigType_tag_new(short type,
		  DOH *name, DOH *attributes,
		  int width, int is_const, int is_volatile,
		  int is_signed, int is_unsigned);

static DOH *SwigType_tag_str(DOH *o); /* e.g. 'pointer to' */
static int SwigType_tag_hash(DOH *o);
static int SwigType_tag_cmp(DOH *o1, DOH *o2);
#define TagData(x) ((SwigType_tag *)(x))

static DohObjInfo SwigType_tag_type = 
{
   "TypeTag",			/* objname */
   sizeof(SwigType_tag),	/* objsize */
   0,				/* doh_del -- will never happen */
   0,				/* doh_copy */
   0,				/* doh_clear */
   0,				/* doh_scope */
   SwigType_tag_str,		/* doh_str */
   0,				/* doh_data */
   0,				/* doh_dump */
   0,				/* doh_load */
   0,				/* doh_len */
   SwigType_tag_hash,		/* doh_hash */
   SwigType_tag_cmp,		/* doh_cmp */
   0,				/* doh_mapping */
   0,				/* doh_sequence */
   0,				/* doh_file */
   0,				/* doh_string */ 
   0,				/* doh_callable */ 
   0,				/* doh_position */
};

/* =========================================================================
 * SwigType_node DOH type declaration
 * ========================================================================= */

static DOH *SwigType_node_new(DOH *tag, DOH *parent);

static DOH *SwigType_node_str(DOH *o); /* e.g. 'pointer to array (10)
					   of pointer to char'' */
static int SwigType_node_hash(DOH *o);
static int SwigType_node_cmp(DOH *o, DOH *o2);
static DOH *SwigType_node_getitem(DOH *o, int index);
static DOH *SwigType_node_firstitem(DOH *o);
static DOH *SwigType_node_nextitem(DOH *o);
static int SwigType_node_len(DOH *o);
#define NodeData(x) ((SwigType_node *)(x))

static DohSequenceMethods SwigType_node_assequence =
{
   SwigType_node_getitem,
   0,
   0,
   0,
   SwigType_node_firstitem,
   SwigType_node_nextitem
};

static DohObjInfo SwigType_node_type = 
{
   "Type",			/* objname */
   sizeof(SwigType_node),	/* objsize */
   0,				/* doh_del -- will never happen */
   0,				/* doh_copy */
   0,				/* doh_clear */
   0,				/* doh_scope */
   SwigType_node_str,		/* doh_str */
   0,				/* doh_data */
   0,				/* doh_dump */
   0,				/* doh_load */
   SwigType_node_len,		/* doh_len */
   SwigType_node_hash,		/* doh_hash */
   SwigType_node_cmp,		/* doh_cmp */
   0,				/* doh_mapping */
   &SwigType_node_assequence,	/* doh_sequence */
   0,				/* doh_file */
   0,				/* doh_string */ 
   0,				/* doh_callable */ 
   0,				/* doh_position */
};

/* =========================================================================
 * utility functions
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * static SwigType_node *
 * SwigType_step(SwigType_node *parent, SwigType_children children, 
 *                SwigType_tag *tag);
 * -------------------------------------------------------------------------
 * Take a step down the tree, creating a new node if necessary, and
 * return a pointer to the node we arrive at.
 * ------------------------------------------------------------------------- */

static SwigType_node *
SwigType_step(SwigType_node *parent, SwigType_tag *tag)
{
   SwigType_children children;
   DOH *subnode;

   if (parent) children = parent->children;
   else if (ROOT) children = ROOT;
   else children = ROOT = NewHash();
		  
   subnode = Getattr(children, tag);
   
   if (!subnode) {
      subnode = SwigType_node_new(tag, parent);
      Setattr(children, tag, subnode);
   }
   
   return NodeData(subnode);
}

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_make_string(DOH *in);
 * -------------------------------------------------------------------------
 * Make sure that this is a real DOH string, not a (char *). 
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_make_string(DOH *in)
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
 * static int SwigType_bit_count(unsigned int i);
 * -------------------------------------------------------------------------
/* The smallest n such that i < 2**n 
 * ------------------------------------------------------------------------- */

static int SwigType_bit_count(unsigned int i)
{
   int n = 0;
   while (i)
      n++, i >>= 1;
   return n;
}

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_tag_flags(SwigType_tag *tag, int do_signs);
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_tag_flags(SwigType_tag *tag, int do_signs)
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
 * SwigType_tag DOH type implementation
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_tag_new( ... );
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_tag_new(short type,
		  DOH *name, DOH *attributes,
		  int width, int is_const, int is_volatile,
		  int is_signed, int is_unsigned)
{
   SwigType_tag *t;

   t = (SwigType_tag *)DohObjMalloc(sizeof(SwigType_tag));
   t->objinfo = &SwigType_tag_type;
   t->hashkey = -1;
   t->type = type;
   t->name = SwigType_make_string(name); if (t->name) Incref(t->name);
   t->attributes = attributes; if (t->attributes) Incref(t->attributes);
   t->width = width;
   t->is_const = is_const;
   t->is_volatile = is_volatile;
   t->is_signed = is_signed;
   t->is_unsigned = is_unsigned;

   return t;
}

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_tag_str(DOH *o);
 * ------------------------------------------------------------------------- */

static DOH *SwigType_tag_str(DOH *o)
{
   SwigType_tag *tag = TagData(o);
   DOH *s = NewString("");
   Seek(s, 0, SEEK_END);
   
   switch (tag->type)
   {
   case SWIGTYPE_INT:
      Printf(s, "Int(%d, %s)", tag->width,
	     SwigType_tag_flags(tag, 1));
      break;
   case SWIGTYPE_FLOAT:
      Printf(s, "Float(%d, %s)", 
	     tag->width, SwigType_tag_flags(tag, 0));
      break;
   case SWIGTYPE_VOID:
      Printf(s, "Void");
      break;
   case SWIGTYPE_CHAR:
      Printf(s, "Char(%d, %s)", tag->width,
	     SwigType_tag_flags(tag, 0));
      break;
   case SWIGTYPE_NAME:
      Printf(s, "Name('%s', %s)", tag->name,
	     SwigType_tag_flags(tag, 0));
      break;
   case SWIGTYPE_ENUM:
      Printf(s, "Enum(");
      if (tag->name)
	 Printf(s, "'%s', ", tag->name);
      if (tag->attributes)
	 Printf(s, "%s, ", tag->attributes);
      Printf(s, "%s)", SwigType_tag_flags(tag, 0));
      break;
   case SWIGTYPE_STRUCT:
      Printf(s, "Struct(");
      if (tag->name)
	 Printf(s, "'%s', ", tag->name);
      if (tag->attributes)
	 Printf(s, "%s, ", tag->attributes);
      Printf(s, "%s)", SwigType_tag_flags(tag, 0));
      break;
   case SWIGTYPE_UNION:
      Printf(s, "Union(");
      if (tag->name)
	 Printf(s, "'%s', ", tag->name);
      if (tag->attributes)
	 Printf(s, "%s, ", tag->attributes);
      Printf(s, "%s)", SwigType_tag_flags(tag, 0));
      break;
   case SWIGTYPE_ARRAY:
      if (tag->attributes)
	 Printf(s, "Array (%s) of ", tag->attributes);
      else
	 Printf(s, "Array of ");
      break;
   case SWIGTYPE_FUNCTION:
      Printf(s, "Function (%s) returning ", tag->attributes);
      break;
   case SWIGTYPE_POINTER:
      Printf(s, "Pointer %s to ", SwigType_tag_flags(tag, 0));
      break;
   }

   return s;
}

/* -------------------------------------------------------------------------
 * static int
 * SwigType_tag_hash(DOH *o);
 * ------------------------------------------------------------------------- */

/* helpful macro */
#define SafeHashval(x) (x ? Hashval(x) : 0)

static int SwigType_tag_hash(DOH *o)
{
   SwigType_tag *tag = TagData(o);
   if (tag->hashkey != -1) return tag->hashkey;

   /* barring the use of any sub-object's Hashval, we assign a
      different integer to each of our types. */
   switch (tag->type)
   {
      /* base types are assigned certain numbers */
   case SWIGTYPE_INT:
      tag->hashkey = 
	 SwigType_bit_count(tag->width) +
	 (tag->is_const << 4) +
	 (tag->is_volatile << 5) +
	 (tag->is_signed << 6) +
	 (tag->is_unsigned << 7);
      break;
   case SWIGTYPE_FLOAT:
      tag->hashkey = 
	 SwigType_bit_count(tag->width) + 
	 (tag->is_const << 8) +
	 (tag->is_volatile << 9) +
	 1 << 10;
      break;
   case SWIGTYPE_VOID:
      tag->hashkey = 
	 SwigType_bit_count(tag->width) +
	 (tag->is_const << 4) +
	 (tag->is_volatile << 5) +
	 (tag->is_signed << 6) +
	 (tag->is_unsigned << 7) +
	 2 << 10;
      break;
   case SWIGTYPE_CHAR:
      tag->hashkey = 
	 SwigType_bit_count(tag->width) +
	 (tag->is_const << 4) +
	 (tag->is_volatile << 5) +
	 (tag->is_signed << 6) +
	 (tag->is_unsigned << 7) +
	 3 << 10;
      break;
   case SWIGTYPE_NAME:
      tag->hashkey = 
	 Hashval(tag->name);
      break;
   case SWIGTYPE_ENUM:
      tag->hashkey = 
	 SafeHashval(tag->name) +
	 SafeHashval(tag->attributes) +
	 5 << 10;
      break;
   case SWIGTYPE_STRUCT:
      tag->hashkey = 
	 SafeHashval(tag->name) +
	 SafeHashval(tag->attributes) +
	 6 << 10;
      break;
   case SWIGTYPE_UNION:
      tag->hashkey = 
	 SafeHashval(tag->name) +
	 SafeHashval(tag->attributes) +
	 7 << 10;
      break;
   case SWIGTYPE_ARRAY:
      tag->hashkey = 
	 SafeHashval(tag->attributes) +
	 8 << 10;
      break;
   case SWIGTYPE_FUNCTION:
      tag->hashkey = 
	 SafeHashval(tag->attributes) +
	 9 << 10;
      break;
   case SWIGTYPE_POINTER:
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

/* no longer a helpful macro :) */
#undef SafeHashval

/* -------------------------------------------------------------------------
 * static int
 * SwigType_tag_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static int SwigType_tag_cmp(DOH *o1, DOH *o2)
{
   SwigType_tag *t1, *t2;
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
   case SWIGTYPE_INT:
      if (t1->width != t2->width ||
	  t1->is_const != t2->is_const ||
	  t1->is_volatile != t2->is_volatile ||
	  t1->is_unsigned != t2->is_unsigned ||
	  t1->is_signed != t2->is_signed)
	 return TAGS_NEQ;
      break;
   case SWIGTYPE_FLOAT:
      if (t1->width != t2->width ||
	  t1->is_const != t2->is_const ||
	  t1->is_volatile != t2->is_volatile)
	 return TAGS_NEQ;
      break;
   case SWIGTYPE_VOID:
      break;			/* nothing to it.. */
   case SWIGTYPE_CHAR:
      if (t1->width != t2->width ||
	  t1->is_const != t2->is_const ||
	  t1->is_volatile != t2->is_volatile)
	 return TAGS_NEQ;
      break;
   case SWIGTYPE_NAME:
      return Cmp(t1->name, t2->name);
   case SWIGTYPE_STRUCT:
   case SWIGTYPE_UNION:
   case SWIGTYPE_ENUM:
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
   case SWIGTYPE_ARRAY:
      if (t1->attributes && t2->attributes)
	 return Cmp(t1->attributes, t2->attributes);
      else if (t1->attributes || t2->attributes)
	 return TAGS_NEQ;
      else
	 return TAGS_EQ;
   case SWIGTYPE_FUNCTION:
      return Cmp(t1->attributes, t2->attributes);
   case SWIGTYPE_POINTER:
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
 * SwigType_node DOH type implementation
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * DOH *
 * SwigType_fromstring( DOH *string );
 * ------------------------------------------------------------------------- 
 * Construct a type from Dave's string representation
 * ------------------------------------------------------------------------- */

/* these will eventually be in configure.in */
#define CHAR_WIDTH 8
#define SHORT_WIDTH 16
#define INT_WIDTH 32
#define LONG_WIDTH 32
#define LONG_LONG_WIDTH 64
#define FLOAT_WIDTH 32
#define DOUBLE_WIDTH 64
#define LONG_DOUBLE_WIDTH 128

static int startswith(char *s1, char *s2)
{
   return strncmp(s1, s2, strlen(s2));
}

DOH *SwigType_fromstring(DOH *string)
{
   DOH *components, *component;
   DOH *rv;
   int i;

   assert(DohIsString(string));
   components = SwigType_split(string);
   if (Len(components) < 1)
      return NULL;
  
   /* construct the base type */

   component = Getitem(components, Len(components)-1);

   if (Cmp(component, "char") == 0)
      rv = SwigType_newchar(CHAR_WIDTH, 0, 0);
   else if (Cmp(component, "unsigned char") == 0)
      rv = SwigType_newint(CHAR_WIDTH, 0, 0, 0, 1);
   else if (Cmp(component, "signed char") == 0)
      rv = SwigType_newint(CHAR_WIDTH, 0, 0, 1, 0);
   else if (Cmp(component, "short") == 0)
      rv = SwigType_newint(SHORT_WIDTH, 0, 0, 0, 0);
   else if (Cmp(component, "unsigned short") == 0)
      rv = SwigType_newint(SHORT_WIDTH, 0, 0, 0, 1);
   else if (Cmp(component, "signed short") == 0)
      rv = SwigType_newint(SHORT_WIDTH, 0, 0, 1, 0);
   else if (Cmp(component, "int") == 0)
      rv = SwigType_newint(INT_WIDTH, 0, 0, 0, 0);
   else if (Cmp(component, "unsigned int") == 0)
      rv = SwigType_newint(INT_WIDTH, 0, 0, 0, 1);
   else if (Cmp(component, "signed int") == 0)
      rv = SwigType_newint(INT_WIDTH, 0, 0, 1, 0);
   else if (Cmp(component, "long") == 0)
      rv = SwigType_newint(LONG_WIDTH, 0, 0, 0, 0);
   else if (Cmp(component, "unsigned long") == 0)
      rv = SwigType_newint(LONG_WIDTH, 0, 0, 0, 1);
   else if (Cmp(component, "signed long") == 0)
      rv = SwigType_newint(LONG_WIDTH, 0, 0, 1, 0);
   else if (Cmp(component, "long long") == 0)
      rv = SwigType_newint(LONG_WIDTH, 0, 0, 0, 0);
   else if (Cmp(component, "unsigned long long") == 0)
      rv = SwigType_newint(LONG_LONG_WIDTH, 0, 0, 0, 1);
   else if (Cmp(component, "signed long long") == 0)
      rv = SwigType_newint(LONG_LONG_WIDTH, 0, 0, 1, 0);
   else if (Cmp(component, "float") == 0)
      rv = SwigType_newfloat(FLOAT_WIDTH, 0, 0);
   else if (Cmp(component, "double") == 0)
      rv = SwigType_newfloat(DOUBLE_WIDTH, 0, 0);
   else if (Cmp(component, "long double") == 0)
      rv = SwigType_newfloat(LONG_DOUBLE_WIDTH, 0, 0);
   else if (Cmp(component, "void") == 0)
      rv = SwigType_newvoid();
   else if (startswith(Data(component), "enum ") == 0)
      rv = SwigType_newenum(Data(component) + 5, NULL, 0, 0);
   else if (Cmp(component, "enum") == 0)
      rv = SwigType_newint(INT_WIDTH, 0, 0, 0, 0);
   else if (startswith(Data(component), "struct ") == 0)
      rv = SwigType_newstruct(Data(component) + 7, NULL, 0, 0);
   else if (SwigType_isstruct(component))
   {
      DOH *struct_members = SwigType_split_struct(component);
      DOH *body = NewList();
      char name[100] = "";
      int j;

      for (j = 0; j < Len(struct_members); j++)
      {
	 Insert(body, j*2, 
		SwigType_fromstring(Getitem(struct_members, j)));
	 sprintf(name, "unk%d", j);
	 Insert(body, j*2+1, name);
      }

      rv = SwigType_newstruct(NULL, body, 0, 0);
      Delete(struct_members);
      Delete(body);
   }
   else
      rv = SwigType_newname(Data(component), 0, 0);

   for (i = Len(components)-2; i >= 0; i--)
   {
      component = Getitem(components, i);
      if (SwigType_ispointer(component))
	 rv = SwigType_newpointer(0, 0, rv);
      else if (SwigType_isreference(component))
	 /* Do nothing yet */;
      else if (SwigType_isarray(component))
      {
	 char *size = strdup(Data(component));
	 size[strlen(size) - 1] = 0;
	 rv = SwigType_newarray(NewString(size+1), rv);
	 free(size);
      }
      else if (SwigType_isfunction(component))
      {
	 DOH *parms = SwigType_split_parms(component);
	 DOH *args = NewList();
	 int j;
	 
	 for (j = 0; j < Len(parms); j++)
	    Insert(args, DOH_END, SwigType_fromstring(Getitem(parms, j)));

	 rv = SwigType_newfunction(args, rv);
	 Delete(parms);
	 Delete(args);
      }
      else if (SwigType_isqualifier(component))
      {
	 int t = SwigType_gettype(rv);
	 DOH *n = SwigType_getname(rv);
	 DOH *a = SwigType_getattributes(rv);
	 int w = SwigType_getwidth(rv);
	 int c = SwigType_getconst(rv);
	 int v = SwigType_getvolatile(rv);
	 int s = SwigType_getsigned(rv);
	 int u = SwigType_getunsigned(rv);
	 DOH *p;
	 DOH *orv = rv;

	 if (Len(rv) > 1)
	    p = Getitem(rv, 1);
	 else
	    p = NULL;

	 /* we must construct a new type object instead of modifying
	    the old one because we depend on immutability for the
	    storage efficiency */
	 if (Cmp(component, "+const"))
	 {
	    rv = SwigType_step(p, SwigType_tag_new(t,n,a,w,v,1,s,u));
	    Delete(orv);
	 }
	 else if (Cmp(component, "+volatile"))
	 {
	    rv = SwigType_step(p, SwigType_tag_new(t,n,a,w,1,c,s,u));
	    Delete(orv);
	 }
      }
   }

   return rv;
}

/* -------------------------------------------------------------------------
 * DOH *
 * SwigType_newxxx( <varies> );
 * ------------------------------------------------------------------------- 
 * Public constructors for various sorts of types (types of sorts?)
 * ------------------------------------------------------------------------- */

DOH *SwigType_newint(int width, int is_const, int is_volatile, 
		      int is_signed, int is_unsigned)
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_INT, 
					   NULL, NULL,
					   width,
					   is_const, is_volatile,
					   is_signed, is_unsigned));
}

DOH *SwigType_newfloat(int width, int is_const,
			int is_volatile)
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_FLOAT,
					   NULL, NULL,
					   width,
					   is_const, is_volatile,
					   0, 0));
}

DOH *SwigType_newvoid()
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_VOID,
					   NULL, NULL,
					   0,
					   0, 0,
					   0, 0));
}

DOH *SwigType_newchar(int width, int is_const, int is_volatile)
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_CHAR,
					   NULL, NULL,
					   width,
					   is_const, is_volatile,
					   0, 0));
}

DOH *SwigType_newname(DOH *name, int is_const, int is_volatile)
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_NAME,
					   name, NULL,
					   0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *SwigType_newenum(DOH *name, DOH *body, 
		       int is_const, int is_volatile)
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_NAME,
					   name, body,
					   0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *SwigType_newstruct(DOH *name, DOH *body, 
			 int is_const, int is_volatile)
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_STRUCT, 
					   name, body,
					   0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *SwigType_newunion(DOH *name, DOH *body, 
			int is_const, int is_volatile)
{
   return SwigType_step(NULL, 
			 SwigType_tag_new(SWIGTYPE_UNION, 
					   name, body,
					   0,
					   is_const, is_volatile,
					   0, 0));
}

DOH *SwigType_newarray(DOH *size, DOH *parent)
{
   return SwigType_step(parent, 
			 SwigType_tag_new(SWIGTYPE_ARRAY, 
					   0, size,
					   0,
					   0, 0,
					   0, 0));
}

DOH *SwigType_newfunction(DOH *parameters, DOH *parent)
{
   return SwigType_step(parent, 
			 SwigType_tag_new(SWIGTYPE_FUNCTION, 
					   0, parameters,
					   0,
					   0, 0,
					   0, 0));
}

DOH *SwigType_newpointer(int is_const, int is_volatile, DOH *parent)
{
   return SwigType_step(parent, 
			 SwigType_tag_new(SWIGTYPE_POINTER, 
					   0,
					   0, 0,
					   is_const, is_volatile,
					   0, 0));
}

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_getxxx(DOH *t);
 * ------------------------------------------------------------------------- 
 * Field accessors
 * ------------------------------------------------------------------------- */

int SwigType_gettype(DOH *t) { return NodeData(t)->tag->type; }
DOH *SwigType_getname(DOH *t) { return NodeData(t)->tag->name; }
DOH *SwigType_getattributes(DOH *t) { return NodeData(t)->tag->attributes; }
int SwigType_getwidth(DOH *t) { return NodeData(t)->tag->width; }
int SwigType_getconst(DOH *t) { return NodeData(t)->tag->is_const; }
int SwigType_getvolatile(DOH *t) { return NodeData(t)->tag->is_volatile; }
int SwigType_getsigned(DOH *t) { return NodeData(t)->tag->is_signed; }
int SwigType_getunsigned(DOH *t) { return NodeData(t)->tag->is_unsigned; }

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_node_new(DOH *tag, DOH *parent);
 * ------------------------------------------------------------------------- 
 * private, 'real' constructor
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_node_new(DOH *tag, DOH *parent)
{
   SwigType_node *n;

   n = (SwigType_node *)DohObjMalloc(sizeof(SwigType_node));
   n->objinfo = &SwigType_node_type;

   n->parent = parent;
   n->tag = tag; Incref(tag);
   n->children = NewHash();
   n->hashkey = -1;

   return n;
}

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_node_str(DOH *o);
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_node_str(DOH *o)
{
   SwigType_node *n = (SwigType_node *)o;
   DOH *s = NewString("");
   if (n->parent)
      Printf(s, "%s%s", n->tag, n->parent);
   else
      Printf(s, "%s", Str(n->tag));

   return s;
}

/* -------------------------------------------------------------------------
 * static int
 * SwigType_node_hash(DOH *o);
 * ------------------------------------------------------------------------- */

static int
SwigType_node_hash(DOH *o)
{
   SwigType_node *n = (SwigType_node *)o;   
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
 * SwigType_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static int 
SwigType_node_cmp(DOH *o1, DOH *o2)
{
   SwigType_node *n1 = (SwigType_node *)o1;
   SwigType_node *n2 = (SwigType_node *)o1;

   /* we call the comparison functions directly just to shave a
      harmless hair off the execution time */

   if (SwigType_tag_cmp(n1->tag, n2->tag))
      return TAGS_NEQ;
   
   else if (n1->parent && n2->parent)
      return SwigType_node_cmp(n1->parent, n2->parent);

   else if (n1->parent || n2->parent)
      return TAGS_NEQ;
   else
      return TAGS_EQ;
}

/* -------------------------------------------------------------------------
 * static int
 * SwigType_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_node_getitem(DOH *o, int index)
{
   SwigType_node *n = NodeData(o);
   while (n && index--)
      n = n->parent;

   return n;
}

/* -------------------------------------------------------------------------
 * static int
 * SwigType_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_node_firstitem(DOH *o)
{
   SwigType_node *n = NodeData(o);
   return n->current_item = n;
}

/* -------------------------------------------------------------------------
 * static int
 * SwigType_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_node_nextitem(DOH *o)
{
   SwigType_node *n = NodeData(o);
   if (n->parent)
      return n->current_item = n->current_item->parent;
}

/* -------------------------------------------------------------------------
 * static int
 * SwigType_node_cmp(DOH *o1, DOH *o2);
 * ------------------------------------------------------------------------- */

static int
SwigType_node_len(DOH *o)
{
   SwigType_node *n = NodeData(o);
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
   DOH *node[100];
   DOH *key;
   int num = argc-1;

   /* build some types */
   for (i = 0; i < argc - 1; i++)
      node[i] = SwigType_fromstring(NewString(argv[i+1]));

   /* print each type along with its address (to see the hashing) */
   Printf(stdout, "Address\t\tType\n");
   Printf(stdout, "-------\t\t----\n");
   for (i = 0; i < num; i++)
      Printf(stdout, "0x%08x\t%s\n", node[i],
	     node[i]);
}
#endif
