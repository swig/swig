/* ----------------------------------------------------------------------------- 
 * s-exp.cxx
 *
 *     A parse tree represented as Lisp s-expressions.
 * 
 * Author(s) : Matthias Koeppe (mkoeppe@mail.math.uni-magdeburg.de)
 *
 * Copyright (C) 2002.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

/* Derived from xml.cxx 1.1.2.2 */

static char cvsroot[] = "$Header$";
static const char *usage = "\
S-Exp Options (available with -sexp)\n\
     -typemaplang lang - Typemap language.\n\n";

#include "swigmod.h"

//static Node *view_top = 0;
static File *out = 0;
      
class Sexp : public Language {
public:
  int indent_level;
  Sexp() : indent_level( 0 ) {}
  virtual ~Sexp() {}
  virtual void main(int argc, char *argv[]) {
    SWIG_typemap_lang("sexp");
    for( int iX = 0; iX < argc; iX++ )
      {
	if( strcmp( argv[iX], "-typemaplang" ) == 0 )
	  {
	    Swig_mark_arg (iX);
	    iX++;
	    SWIG_typemap_lang(argv[iX]);
	    Swig_mark_arg (iX);
	    continue;
	  }
	if( strcmp( argv[iX], "-help" ) == 0 )
	  {
	    fputs( usage, stderr );
	  }
      }
  }

  DOHHash *print_cycle_hash;
  int print_cycle_count;
  int hanging_parens;

  /* Top of the parse tree */
  virtual int top(Node *n) 
  {
    if( out == 0 )
      {
	String *outfile = Getattr(n,"outfile");
	Replaceall(outfile,"_wrap.cxx", ".lisp");
	out = NewFile(outfile,"w");
	if (!out) 
	  {
	    Printf(stderr,"*** Can't open '%s'\n", outfile);
	    SWIG_exit(EXIT_FAILURE);
	  }
      }
    Language::top(n);
    Printf( out, ";;; Lisp parse tree produced by SWIG\n" );
    print_cycle_hash = DohNewHash();
    print_cycle_count = 0;
    hanging_parens = 0;
    Sexp_print_node(n);
    flush_parens();
    return SWIG_OK;
  }

  void print_indent(int l) 
  {
    int i;
    for (i = 0; i < indent_level; i++) 
      {
	Printf(out, " ");
      }
    if (l) 
      {
	Printf(out, " ");
      }
  }

  void open_paren(const String *oper)
  {
    flush_parens();
    Printf(out, "(");
    if (oper) Printf(out, "%s ", oper);
  }

  void close_paren()
  {
    hanging_parens++;
  }

  void flush_parens()
  {
    int i;
    if (hanging_parens) {
      for (i = 0; i<hanging_parens; i++)
	Printf(out, ")");
      Printf(out, "\n");
      hanging_parens = 0;
    }
  }

  bool internal_key_p(DOH *key)
  {
    return ((Cmp(key,"nodeType") == 0) 
	    || (Cmp(key,"firstChild") == 0) 
	    || (Cmp(key,"lastChild") == 0) 
	    || (Cmp(key,"parentNode") == 0) 
	    || (Cmp(key,"nextSibling") == 0) 
	    || (Cmp(key,"previousSibling") == 0)
	    || (Cmp(key,"csym:nextSibling") == 0)
	    || (Cmp(key,"csym:previousSibling") == 0)
	    || (Cmp(key,"typepass:visit") == 0)
	    || (Cmp(key,"allocate:visit") == 0)
	    || (*(Char(key)) == '$'));
  }

  bool boolean_key_p(DOH *key)
  {
    return ((Cmp(key,"allocate:default_constructor") == 0) 
	    || (Cmp(key,"allocate:default_destructor") == 0) 
	    || (Cmp(key,"allows_typedef") == 0) 
	    || (Cmp(key,"feature:immutable") == 0));
  }

  bool list_key_p(DOH *key)
  {
    return ((Cmp(key, "parms") == 0)
	    || (Cmp(key, "baselist") == 0));
  }

  bool plist_key_p(DOH *key)
    // true if KEY is the name of data that is a mapping from keys to
    // values, which should be printed as a plist.
  {
    return ((Cmp(key, "typescope") == 0));
  }

  bool maybe_plist_key_p(DOH *key)
  {
    return (Strncmp(key, "tmap:", 5) == 0);
  }
  
  bool print_circle(DOH *obj, bool list_p)
    // We have a complex object, which might be referenced several
    // times, or even recursively.  Use Lisp's reader notation for
    // circular structures (#n#, #n=).
    //
    // An object can be printed in list-mode or object-mode; LIST_P toggles.
    // return TRUE if OBJ still needs to be printed
  {
    // Following is a silly hack.  It works around the limitation of
    // DOH's hash tables that only work with string keys!
    char address[16];
    sprintf(address, "%x%c", obj, list_p ? 'L' : 'O');
    DOH *placeholder = Getattr(print_cycle_hash, address);
    if (placeholder) {
      Printv(out, placeholder, NIL);
      return false;
    }
    else {
      String *placeholder = NewStringf("#%d#", ++print_cycle_count);
      Setattr(print_cycle_hash, address, placeholder);
      Printf(out, "#%d=", print_cycle_count);
      return true;
    }
  }  

  void Sexp_print_value_of_key(DOH *value, DOH *key)
  {
    if ((Cmp(key, "parms") == 0) || (Cmp(key, "wrap:parms") == 0)
	|| (Cmp(key, "kwargs") == 0) || (Cmp(key, "pattern") == 0))
      Sexp_print_parms(value);
    else if (plist_key_p(key))
      Sexp_print_plist(value);
    else if (maybe_plist_key_p(key)) {
      if (DohIsMapping(value))
	Sexp_print_plist(value);
      else
	Sexp_print_doh(value);
    }
    else if (list_key_p(key))
      Sexp_print_list(value);
    else if (boolean_key_p(key))
      Sexp_print_boolean(value);
    else
      Sexp_print_doh(value);
  }
  
  void Sexp_print_boolean(DOH *obj)
  {
    flush_parens();
    /* See DOH/Doh/base.c, DohGetInt() */
    if (DohIsString(obj)) {
      if (atoi(Char(obj)) != 0)
	Printf(out, "t");
      else Printf(out, "nil");
    }
    else Printf(out, "nil");
  }
  
  void Sexp_print_list(DOH *obj)
  {
    if (print_circle(obj, true)) {
      open_paren(NIL);
      for (; obj; obj = nextSibling(obj)) {
	Sexp_print_doh(obj);
	flush_parens();
	Printf(out, " ");      
      }
      close_paren();
    }
  }

  void Sexp_print_parms(DOH *obj)
    // print it as a list of plists
  {
    if (print_circle(obj, true)) {
      open_paren(NIL);
      for (; obj; obj = nextSibling(obj)) {
	if (DohIsMapping(obj)) {
	  DOH *k;
	  open_paren(NIL);
	  for (k = Firstkey(obj); k; k = Nextkey(obj)) {
	    if (!internal_key_p(k)) {
	      DOH *value = Getattr(obj, k);
	      Sexp_print_as_keyword(k);
	      Sexp_print_value_of_key(value, k);
	      flush_parens(); Printf(out, " ");
	    }
	  }	
	  close_paren();
	}
	else Sexp_print_doh(obj);
	flush_parens();
	Printf(out, " ");      
      }
      close_paren();
    }
  }

  void Sexp_print_doh(DOH *obj)
  {
    flush_parens();
    if (DohIsString(obj)) {
      String *o = Str(obj);
      Replaceall( o, "\\", "\\\\" );
      Replaceall( o, "\"", "\\\"" );
      Printf(out,"\"%s\"", o);
      Delete(o);
    }
    else {
      if (print_circle(obj, false)) {
	// Dispatch type
	if (nodeType(obj)) {
	  Sexp_print_node(obj);
	}
	
	else if (DohIsMapping(obj)) {
	  DOH *k;
	  open_paren(NIL);
	  for (k = Firstkey(obj); k; k = Nextkey(obj)) {
	    if (!internal_key_p(k)) {
	      DOH *value = Getattr(obj, k);
	      flush_parens();
	      open_paren(NIL);
	      Sexp_print_doh(k);
	      Printf(out, " . ");
	      Sexp_print_value_of_key(value, k);
	      close_paren();
	    }
	  }
	  close_paren();
	}
	else {
	  // What is it?
	  Printf(out,"#<DOH %x>", obj);
	}
      }
    }
  }

  void Sexp_print_as_keyword(const DOH *k)
  {
    /* Print key, replacing ":" with "-" because : is CL's package prefix */
    String *key = NewString(k);
    Replaceall(key, ":", "-");
    Replaceall(key, "_", "-");
    Printf(out,":%s ", key);
    Delete(key);
  }

  void Sexp_print_plist_noparens(DOH *obj)
  {
    /* attributes map names to objects */
    String *k;
    bool first;
    //indent_level += 4;		
    for (k = Firstkey(obj), first = true; k; k = Nextkey(obj), first=false) {
      if (!internal_key_p(k)) {
	DOH *value = Getattr(obj, k);
	flush_parens();
	if (!first) {
	  Printf(out, " ");
	}
	Sexp_print_as_keyword(k);
	/* Print value */
	Sexp_print_value_of_key(value, k);
      }
    }
  }
  
  void Sexp_print_plist(DOH *obj)
  {
    flush_parens();
    if (print_circle(obj, true)) {
      open_paren(NIL);
      Sexp_print_plist_noparens(obj);
      close_paren();
    }
  }

  void Sexp_print_attributes(Node * obj)
  {
    Sexp_print_plist_noparens(obj);
  }
  
  void Sexp_print_node(Node *obj) 
  {
    Node   *cobj;
    open_paren(nodeType(obj));
    /* A node has an attribute list... */
    Sexp_print_attributes(obj);
    /* ... and child nodes. */
    cobj = firstChild(obj);
    if (cobj) {
      flush_parens();
      Printf(out, "\n");
      Sexp_print_as_keyword("children");
      open_paren(NIL);
      for (; cobj; cobj = nextSibling(cobj)) {
	Sexp_print_node(cobj);
      }
      close_paren();
    }
    close_paren();
  }


  virtual int functionWrapper(Node *n)
  {
    ParmList *l = Getattr(n,"parms");
    Wrapper *f = NewWrapper();
    emit_attach_parmmaps(l,f);
    Setattr(n,"wrap:parms",l);
    return SWIG_OK;
  }
  
};


extern "C"
{
  Language * swig_sexp( void )
  {
    return new Sexp();
  }
}
