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

   where each of the constructors can have some attributes.

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

    Base types have no parent.  They are as follows, with attributes:
    o integer: a signed integer
      - width: bit width of value
    o unsigned: an unsigned integer
      - width: bit width of value
    o character: a character value
      - width: bit width of value
    o float: a floating-point value
      - width: bit width of value
    o void: a placeholder
    o name: a type name, ostensibly one previously typedef'd
      - tag: the name of the type
    o enum: an enumeration
      - tag: the tag of the enum (optional)
      - contents: a list of strings of the form 'name=value', where
        value may be omitted if it is not specified (optional)
    o struct: a structure
      - tag: the tag of the struct (optional)
      - contents: a list of further type objects constituting this
        structure (optional)
    o union: a union (same format as struct)
    o class: a class (same format as struct)

   Constructor types

    Constructor types all have a 'parent' -- the type upon which they
    build.  Constructor types are as follows, with attributes (the
    parent attribute is implied):
    o array: an array of the parent type
      - tag: the size of the array, stored as a string (optional)
    o function: a function returning the parent type
      - contents: a list of further type objects constituting the
        function's parameter types
    o pointer: a pointer to the parent type
    o reference: a reference to the parent type
    o qualifier: a qualifier applied to the parent type
      - tag: the name of the qualifier (e.g. 'const' or 'volatile')
    
   Note: it is up to the parser to distinguish character types from
   integer types, most likely using some simple heuristics. */

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
   DOH *tag;
   DOH *contents;
   short width;

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

/* =========================================================================
 * SwigType_tag DOH type declaration
 * ========================================================================= */

static DOH * 
SwigType_tag_new(short type, DOH *tag, DOH *contents, int width);
static DOH *SwigType_tag_fromstring(DOH *string, DOH *parent);

static DOH *SwigType_tag_str(DOH *o); /* the part between the dots */
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

static DOH *SwigType_node_str(DOH *o);
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
   else if (SwigType_root) children = SwigType_root;
   else children = SwigType_root = NewHash();
		  
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

/* =========================================================================
 * SwigType_tag DOH type implementation
 * ========================================================================= */

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_tag_new( ... );
 * -------------------------------------------------------------------------
 * Private constructor for tags
 * ------------------------------------------------------------------------- */

static DOH *
SwigType_tag_new(short type, DOH *tag, DOH *contents, int width)
{
   SwigType_tag *t;

   t = (SwigType_tag *)DohObjMalloc(sizeof(SwigType_tag));
   t->objinfo = &SwigType_tag_type;
   t->hashkey = -1;
   t->type = type;
   t->tag = SwigType_make_string(tag); if (t->tag) Incref(t->tag);
   t->contents = contents; if (t->contents) Incref(t->contents);
   t->width = width;

   return t;
}

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_tag_fromstring( ... );
 * -------------------------------------------------------------------------
 * Private constructor for tags, from components of dave-strings
 * ------------------------------------------------------------------------- */

static DOH *SwigType_tag_fromstring(DOH *string, DOH *parent)
{
   char *str = Char(string);
   DOH *contents, *p;
   DOH *list, *tag;
   DOH *rv;
   int type;

   switch(str[0])
   {
   case '*':
      assert(parent);
      return SwigType_tag_new(SWIGTYPE_POINTER, NULL, NULL, 0);
   case '&':
      assert(parent);
      return SwigType_tag_new(SWIGTYPE_REFERENCE, NULL, NULL, 0);
   case '[':
      assert(parent);
      str[strlen(str)-1] = 0;
      return SwigType_tag_new(SWIGTYPE_ARRAY, str+1, NULL, 0);
   case '(':
      assert(parent);
      contents = StringType_split_parms(string);
      if (contents)
      {
	 list = NewList();
	 for (p = Firstitem(contents); p; p = Nextitem(contents))
	    Append(list, SwigType_fromstring(p));
	 Delete(contents);
      }
      else
	 list = NULL;

      rv = SwigType_tag_new(SWIGTYPE_FUNCTION, NULL, list, 0);
      if (list) Delete(list);
      return rv;
   case '{':
      assert(!parent);
      switch(str[1])
      {
      case 's': type = SWIGTYPE_STRUCT; break;
      case 'u': type = SWIGTYPE_UNION; break;
      case 'c': type = SWIGTYPE_CLASS; break;
      default: assert(0);
      }
      tag = StringType_get_tag(string);
      contents = StringType_split_struct(string);
      if (contents)
      {
	 list = NewList();
	 for (p = Firstitem(contents); p; p = Nextitem(contents))
	    Append(list, SwigType_fromstring(p));
	 Delete(contents);
      }
      else
	 list = NULL;
      rv = SwigType_tag_new(type, tag, list, 0);
      if (list) Delete(list);
      return rv;
   case '<':
      assert(!parent);
      tag = StringType_get_tag(string);
      contents = StringType_split_enum(string);
      rv = SwigType_tag_new(SWIGTYPE_ENUM, tag, contents, 0);
      Delete(contents);
      return rv;
   case '+':
      assert(parent);
      return SwigType_tag_new(SWIGTYPE_QUALIFIER, str+1, NULL, 0);
   case 'i':
      type = SWIGTYPE_INTEGER;
      goto getwidth;
   case 'u':
      type = SWIGTYPE_UNSIGNED;
      goto getwidth;
   case 'c':
      type = SWIGTYPE_CHARACTER;
      goto getwidth;
   case 'f':
      type = SWIGTYPE_FLOAT;
      goto getwidth;
   getwidth:
      if (str[1] != '-') goto name;
      return SwigType_tag_new(type, NULL, NULL, atoi(str+2));
   name:
   default:
      return SwigType_tag_new(SWIGTYPE_NAME, string, NULL, 0);
   }
   
}

/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_tag_str(DOH *o);
 * -------------------------------------------------------------------------
 * Output the part of string representation corresponding to this tag
 * ------------------------------------------------------------------------- */

static DOH *SwigType_tag_str(DOH *o)
{
   SwigType_tag *tag = TagData(o);
   DOH *s = NewString("");
   
   switch (tag->type)
   {
   case SWIGTYPE_INTEGER:
      Printf(s, "i-%d", tag->width);
      break;
   case SWIGTYPE_UNSIGNED:
      Printf(s, "u-%d", tag->width);
      break;
   case SWIGTYPE_CHARACTER:
      Printf(s, "c-%d", tag->width);
      break;
   case SWIGTYPE_FLOAT:
      Printf(s, "f-%d", tag->width);
      break;
   case SWIGTYPE_VOID:
      Printf(s, "void");
      break;
   case SWIGTYPE_NAME:
      Printf(s, "%s", tag->tag);
      break;
   case SWIGTYPE_ENUM:
      Printf(s, "<");
      if (tag->tag)
	 Printf(s, "/%s/", tag->tag);
      if (tag->contents)
      {
	 DOH *c;
	 int first = 1;

	 for (c = Firstitem(tag->contents); c; 
	      c = Nextitem(tag->contents))
	    if (first) Printf(s, "%s", c);
	    else Printf(s, ",%s", c);
      }
      else
	 Printf(s, "\\");
      Printf(s, ">");
      break;
   case SWIGTYPE_STRUCT:
      Printf(s, "{s");
      goto structlike;
   case SWIGTYPE_UNION:
      Printf(s, "{u");
      goto structlike;
   case SWIGTYPE_CLASS:
      Printf(s, "{c");
      goto structlike;
   structlike:
      if (tag->tag)
	 Printf(s, "/%s/", tag->tag);
      if (tag->contents)
      {
	 DOH *c;
	 int first = 1;

	 for (c = Firstitem(tag->contents); c; 
	      c = Nextitem(tag->contents))
	    if (first) Printf(s, "%s", c);
	    else Printf(s, ",%s", c);
      }
      else
	 Printf(s, "\\");
      Printf(s, "}");
      break;
   case SWIGTYPE_ARRAY:
      if (tag->tag)
	 Printf(s, "[%s]", tag->tag);
      else
	 Printf(s, "[]");
      break;
   case SWIGTYPE_FUNCTION:
      Printf(s, "(");
      {
	 DOH *c;
	 int first = 1;

	 for (c = Firstitem(tag->contents); c; 
	      c = Nextitem(tag->contents))
	    if (first)
	       Printf(s, "%s", c);
	    else
	       Printf(s, ",%s", c);
      }
      Printf(s, ")");
      break;
   case SWIGTYPE_POINTER:
      Printf(s, "*");
      break;
   case SWIGTYPE_REFERENCE:
      Printf(s, "&");
      break;
   case SWIGTYPE_QUALIFIER:
      Printf(s, "+%s", tag->tag);
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
   case SWIGTYPE_INTEGER:
      tag->hashkey = 
	 (tag->width >> 4) +
	 0 << 20;
      break;
   case SWIGTYPE_UNSIGNED:
      tag->hashkey = 
	 (tag->width >> 4) + 
	 1 << 20;
      break;
   case SWIGTYPE_CHARACTER:
      tag->hashkey = 
	 (tag->width >> 4) +
	 2 << 10;
      break;
   case SWIGTYPE_FLOAT:
      tag->hashkey = 
	 (tag->width >> 4) + 
	 3 << 20;
      break;
   case SWIGTYPE_VOID:
      tag->hashkey = 
	 4 << 10;
      break;
   case SWIGTYPE_NAME:
   case SWIGTYPE_ARRAY:
   case SWIGTYPE_QUALIFIER:
      tag->hashkey = 
	 SafeHashval(tag->tag);
      break;
   case SWIGTYPE_ENUM:
   case SWIGTYPE_STRUCT:
   case SWIGTYPE_UNION:
   case SWIGTYPE_CLASS:
      tag->hashkey = 
	 SafeHashval(tag->tag) +
	 SafeHashval(tag->contents);
      break;
   case SWIGTYPE_FUNCTION:
      tag->hashkey = 
	 SafeHashval(tag->contents) +
	 9 << 10;
      break;
   case SWIGTYPE_POINTER:
      tag->hashkey = 
	 10 << 10;
      break;
   case SWIGTYPE_REFERENCE:
      tag->hashkey =
	 11 << 10;
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
   case SWIGTYPE_INTEGER:
   case SWIGTYPE_UNSIGNED:
   case SWIGTYPE_CHARACTER:
   case SWIGTYPE_FLOAT:
      if (t1->width != t2->width) return TAGS_NEQ;
      else return TAGS_EQ;
      break;
   case SWIGTYPE_VOID:
   case SWIGTYPE_POINTER:
   case SWIGTYPE_REFERENCE:
      return TAGS_EQ;
      break;
   case SWIGTYPE_NAME:
   case SWIGTYPE_QUALIFIER:
      return Cmp(t1->tag, t2->tag);
      break;
   case SWIGTYPE_STRUCT:
   case SWIGTYPE_UNION:
   case SWIGTYPE_CLASS:
   case SWIGTYPE_ENUM:
      /* do the names differ? */
      if (t1->tag && t2->tag)
      {
	 if (Cmp(t1->tag, t2->tag) != 0)
	    return TAGS_NEQ;
	 else if (t1->contents && t2->contents)
	    return Cmp(t1->contents, t2->contents);
	 else if (t1->contents || t2->contents)
	    /* both named, only one has attributes... */
	    return TAGS_NEQ;
	 else
	    /* both named, neither has attributes */
	    return TAGS_EQ;
      }
      else if (t1->tag || t2->tag) 
	 /* one named, one not */
	 return TAGS_NEQ;
      else 
      {
	 /* neither named -- structural equivalence */
	 if (t1->contents && t2->contents)
	    return Cmp(t1->contents, t2->contents);
	 else
	    /* this should never happen .. */
	    return TAGS_NEQ;
      }
   case SWIGTYPE_ARRAY:
      if (t1->contents && t2->contents)
	 return Cmp(t1->contents, t2->contents);
      else if (t1->contents || t2->contents)
	 return TAGS_NEQ;
      else
	 return TAGS_EQ;
   case SWIGTYPE_FUNCTION:
      return Cmp(t1->contents, t2->contents);
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
 * Construct a type from the string representation
 * ------------------------------------------------------------------------- */

DOH *SwigType_fromstring(DOH *string)
{
   DOH *components, *component;
   DOH *rv = NULL;
   int i;

   assert(DohIsString(string));
   components = StringType_split(string);
   if (!components || Len(components) == 0)
      return NULL;
  
   /* construct the base type */

   for (i = Len(components)-1; i >= 0; i--)
   {
      component = Getitem(components, i);
      rv = SwigType_step(rv, SwigType_tag_fromstring(component, rv));
   }

   return rv;
}

/* -------------------------------------------------------------------------
 * DOH *
 * SwigType_newxxx( <varies> );
 * ------------------------------------------------------------------------- 
 * Public constructors for various sorts of types (types of sorts?)
 * ------------------------------------------------------------------------- */

DOH *SwigType_new(int type, DOH *tag, DOH *contents, DOH *parent, int width)
{
   return SwigType_step(parent, 
			SwigType_tag_new(type, tag, contents, width));
}

DOH *SwigType_integer(int width)
{
   return SwigType_step(NULL, 
			SwigType_tag_new(SWIGTYPE_INTEGER, NULL, NULL, width));
}

DOH *SwigType_unsigned(int width)
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_UNSIGNED, NULL, NULL, width));
}

DOH *SwigType_character(int width)
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_CHARACTER, NULL, NULL, width));
}

DOH *SwigType_float(int width)
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_FLOAT, NULL, NULL, width));
}

DOH *SwigType_void()
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_VOID, NULL, NULL, 0));
}

DOH *SwigType_name(DOH *tag)
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_NAME, tag, NULL, 0));
}

DOH *SwigType_enum(DOH *tag, DOH *contents)
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_ENUM, tag, contents, 0));
}

DOH *SwigType_struct(DOH *tag, DOH *contents)
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_STRUCT, tag, contents, 0));
}

DOH *SwigType_union(DOH *tag, DOH *contents)
{
   return SwigType_step(NULL,
			SwigType_tag_new(SWIGTYPE_UNION, tag, contents, 0));
}

DOH *SwigType_array(DOH *size, DOH *parent)
{
   return SwigType_step(parent,
			SwigType_tag_new(SWIGTYPE_ARRAY, size, NULL, 0));
}

DOH *SwigType_function(DOH *parameters, DOH *parent)
{
   return SwigType_step(parent,
			SwigType_tag_new(SWIGTYPE_FUNCTION, parameters, NULL, 0));
}

DOH *SwigType_pointer(DOH *parent)
{
   return SwigType_step(parent,
			SwigType_tag_new(SWIGTYPE_POINTER, NULL, NULL, 0));
}

DOH *SwigType_reference(DOH *parent)
{
   return SwigType_step(parent,
			SwigType_tag_new(SWIGTYPE_REFERENCE, NULL, NULL, 0));
}

DOH *SwigType_qualifier(DOH *tag, DOH *parent)
{
   return SwigType_step(parent,
			SwigType_tag_new(SWIGTYPE_QUALIFIER, tag, NULL, 0));
}


/* -------------------------------------------------------------------------
 * static DOH *
 * SwigType_getxxx(DOH *t);
 * ------------------------------------------------------------------------- 
 * Field accessors
 * ------------------------------------------------------------------------- */

int SwigType_get_type(DOH *t) { return NodeData(t)->tag->type; }
DOH *SwigType_get_tag(DOH *t) { return NodeData(t)->tag->tag; }
DOH *SwigType_get_contents(DOH *t) { return NodeData(t)->tag->contents; }
int SwigType_get_width(DOH *t) { return NodeData(t)->tag->width; }

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
      Printf(s, "%s.%s", n->tag, n->parent);
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
   else
      return NULL;
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
DOH *safe(DOH *in)
{
   if (in) return in;
   return "(NULL)";
}
char *types[] = {
   "INTEGER",
   "UNSIGNED",
   "CHARACTER",
   "FLOAT",
   "VOID",
   "NAME",
   "ENUM",
   "STRUCT",
   "UNION",
   "CLASS",
   "ARRAY",
   "FUNCTION",
   "POINTER",
   "REFERENCE",
   "QUALIFIER" };

int main(int argc, char **argv)
{
   int i, j;
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
   {
      Printf(stdout, "0x%08x\t%s\n", node[i],
	     node[i]);
      for (key = Firstitem(node[i]); key; key = Nextitem(node[i]))
      {
	 Printf(stdout, "0x%08x\t %s %s %s %d\n", key,
		types[SwigType_get_type(key)], 
		safe(SwigType_get_tag(key)),
		safe(SwigType_get_contents(key)),
		SwigType_get_width(key));
      }
   }
}
#endif
