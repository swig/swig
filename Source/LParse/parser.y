%{
/* ----------------------------------------------------------------------------- 
 * parser.y
 *
 *     YACC grammar for Dave's lame C parser.  Based loosely on the SWIG1.1 parser
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

/* These defines are to move the bison generated functions into their own namespace */
#define yylex   lparse_yylex
#define yyerror lparse_yyerror
#define yyparse lparse_yyparse
#define yylval  lparse_yylval
#define yychar  lparse_yychar
#define yynerrs lparse_yynerrs

static char cvsroot[] = "$Header$";
 
extern int  lparse_yylex();
extern void LParse_strict_type(int);

void   yyerror (char *s);       

#include "lparse.h"
#include "preprocessor.h"

static DOH      *top = 0;

/* Pre-created attribute name objects.  Used to improve parsing performance */

static DOH      *ATTR_TAG = 0;
static DOH      *ATTR_CHILD = 0;
static DOH      *ATTR_PARENT = 0;
static DOH      *ATTR_SIBLING = 0;
static DOH      *ATTR_NAME = 0;
static DOH      *ATTR_VALUE = 0;
static DOH      *ATTR_TYPE = 0;
static DOH      *ATTR_PARMS = 0;
static DOH      *ATTR_STORAGE = 0;
static DOH      *TAG_ENUMVALUE = 0;
static DOH      *TAG_FUNCTION = 0;
static DOH      *TAG_VARIABLE = 0;

 /* Set parent node of a collection of children */
 static void setparent(DOH *parent, DOH *child) {
   DOH *o;
   o = child;
   while (o) {
     Setattr(o,ATTR_PARENT,parent);
     o = Getattr(o,ATTR_SIBLING);
   }
 }

/* LParse_parse() - Main entry point to the C parser */
 DOH *LParse_parse(DOH *str) {
   int yyparse();
   DOH *tp;

   if (!ATTR_SIBLING) {
     ATTR_PARENT = NewString("parent");
     DohIntern(ATTR_PARENT);
     ATTR_SIBLING = NewString("sibling");
     DohIntern(ATTR_SIBLING);
     ATTR_CHILD = NewString("child");
     DohIntern(ATTR_CHILD);
     ATTR_TAG = NewString("tag");
     DohIntern(ATTR_TAG);
     ATTR_NAME = NewString("name");
     DohIntern(ATTR_NAME);
     ATTR_VALUE = NewString("value");
     DohIntern(ATTR_VALUE);
     ATTR_TYPE = NewString("type");
     DohIntern(ATTR_TYPE);
     ATTR_PARMS = NewString("parms");
     DohIntern(ATTR_PARMS);
     ATTR_STORAGE = NewString("storage");
     DohIntern(ATTR_STORAGE);
     TAG_ENUMVALUE = NewString("enumvalue");
     DohIntern(TAG_ENUMVALUE);
     TAG_FUNCTION = NewString("function");
     DohIntern(TAG_FUNCTION);
     TAG_VARIABLE = NewString("variable");
     DohIntern(TAG_VARIABLE);

   }
   LParse_push(str);
   top = 0;
   tp = NewHash();
   Setattr(tp, "tag", "includefile");
   Setattr(tp, ATTR_NAME, Getfile(str));
   yyparse();
   Setattr(tp, ATTR_CHILD, top);
   setparent(tp,top);
   return tp;
 }

 static DOH *new_node(char *tag, DOH *file, int line) {
   DOH *o;
   o = NewHash();
   Setattr(o,ATTR_TAG,tag);
   Setline(o,line);
   Setfile(o,file);
   return o;
 }

 /* Take a parameter list and produce a type object */
 static DOH *parmstotype(DOH *parms) {
   int i, l;
   DOH *p, *r;
   r = NewString("(");
   l = Len(parms);
   for (i = 0; i < l; i++) {
     p = Getitem(parms,i);
     Append(r,Getattr(p,ATTR_TYPE));
     if (i < (l-1))
       Append(r,",");
   }
   Append(r,")");
   return r;
 }

#ifdef NEED_ALLOC
void *alloca(unsigned n) {
  return((void *) malloc(n));
}
#else
/* This redefinition is apparently needed on a number of machines */
#undef  alloca
#define alloca  malloc
#endif

/* Promote the type of arithmetic expressions */
static int promote(int t1, int t2) {

  if ((t1 == LPARSE_T_ERROR) || (t2 == LPARSE_T_ERROR)) return LPARSE_T_ERROR;
  if ((t1 == LPARSE_T_DOUBLE) || (t2 == LPARSE_T_DOUBLE)) return LPARSE_T_DOUBLE;
  if ((t1 == LPARSE_T_FLOAT) || (t2 == LPARSE_T_FLOAT)) return LPARSE_T_FLOAT;
  if ((t1 == LPARSE_T_ULONG) || (t2 == LPARSE_T_ULONG)) return LPARSE_T_ULONG;
  if ((t1 == LPARSE_T_LONG) || (t2 == LPARSE_T_LONG)) return LPARSE_T_LONG;
  if ((t1 == LPARSE_T_UINT) || (t2 == LPARSE_T_UINT)) return LPARSE_T_UINT;
  if ((t1 == LPARSE_T_INT) || (t2 == LPARSE_T_INT)) return LPARSE_T_INT;
  if ((t1 == LPARSE_T_USHORT) || (t2 == LPARSE_T_USHORT)) return LPARSE_T_SHORT;
  if ((t1 == LPARSE_T_SHORT) || (t2 == LPARSE_T_SHORT)) return LPARSE_T_SHORT;
  if ((t1 == LPARSE_T_UCHAR) || (t2 == LPARSE_T_UCHAR)) return LPARSE_T_UCHAR;
  if ((t1 == LPARSE_T_CHAR) || (t2 == LPARSE_T_CHAR)) return LPARSE_T_INT;
  if (t1 != t2) {
    LParse_error(0,0,"Type mismatch in constant expression.\n");
  }
  return t1;
}
%}

%union {
  struct {
    DOH     *filename;
    int      line;
    DOH     *text;
    int      ivalue;
    void    *data;
  } tok;
  DOH      *node;
  struct {
    DOH    *node;
    DOH    *last;
  } nodelist;
  struct {
    DOH    *id;
    DOH    *decl;
  } decl;
  struct {
    DOH    *name;
    DOH    *value;
    DOH    *array;
  } pname;
  struct {
    DOH   *name;
    DOH   *array;
    DOH   *parms;
  } tmname;
};

/* Literals */
%token <tok> ID TYPE_TYPEDEF
%token <tok> HBLOCK 
%token <tok> STRING
%token <tok> NUM_INT NUM_FLOAT CHARCONST NUM_UNSIGNED NUM_LONG NUM_ULONG

/* C Symbols */

%token <tok> LPAREN RPAREN LBRACE RBRACE COMMA SEMI PERIOD LBRACKET RBRACKET EQUAL COLON POUND 

/* C keywords */
%token <tok> CONST DEFINED ENUM EXTERN SIZEOF STATIC STRUCT TYPEDEF UNION 

/* C++ keywords */
%token <tok> CLASS FRIEND OPERATOR PRIVATE PROTECTED PUBLIC TEMPLATE THROW 

/* Objective C keywords */
%token <tok> OC_INTERFACE OC_END OC_PUBLIC OC_PRIVATE OC_PROTECTED OC_CLASS OC_IMPLEMENT OC_PROTOCOL

/* C Types */
%token <tok> TYPE_INT TYPE_UNSIGNED TYPE_SHORT TYPE_LONG TYPE_FLOAT TYPE_DOUBLE TYPE_CHAR TYPE_VOID TYPE_SIGNED TYPE_BOOL

/* SWIG directives */
%token <tok> ADDMETHODS ALPHA_MODE APPLY CHECKOUT CLEAR CONSTANT DOCONLY DOC_DISABLE DOC_ENABLE ECHO EXCEPT
%token <tok> ILLEGAL IMPORT INCLUDE INIT INLINE LOCALSTYLE MACRO MODULE NAME NATIVE NEW PRAGMA
%token <tok> RAW_MODE READONLY READWRITE RENAME SECTION STYLE SUBSECTION SUBSUBSECTION TEXT TITLE
%token <tok> TYPE TYPEMAP USERDIRECTIVE WEXTERN WRAPPER

/* Operators */
%left <tok> LOR
%left <tok> LAND
%left <tok> EQUALTO NOTEQUAL GREATERTHAN LESSTHAN LTEQUAL GTEQUAL 
%left <tok> OR
%left <tok> XOR
%left <tok> AND
%left <tok> LSHIFT RSHIFT 
%left <tok> PLUS MINUS 
%left <tok> STAR SLASH
%left <tok> UMINUS NOT LNOT
%left <tok> DCOLON

%type <tok>    idstring template_decl cpptype expr definetype def_args storage_spec pragma_arg ename
%type <node>   file_include_type parm parms ptail idlist stylelist styletail stars
%type <node>   array array2
%type <node>   type strict_type opt_signed opt_unsigned
%type <decl>   declaration 
%type <pname>  pname
%type <node>   tm_args tm_parm tm_tail tm_list
%type <tmname> tm_name
%type <tok>    tm_method
%type <node>   statement swig_directive c_declaration
%type <node>   file_include code_block doc_directive except_directive pragma_directive modifier_directive native_directive typemap_directive
%type <node>   variable_decl function_decl enum_decl typedef_decl stail edecl typedeflist
%type <nodelist>   enumlist interface
%type <node>   inherit base_list
%type <tok>    base_specifier access_specifier cpp_end ctor_end opt_id
%type <node>   cpp_decl cpp_class cpp_other

%%

/* The productions of the grammar with their
   associated semantic actions. */

program        : interface {
                    top = $1.node;
               } 
               ;

interface      : interface statement { 
                   DOH *o, *o2;
		   if (!$1.node) {
		     $$.node = $2;
		     o = $2;
		     while (o) {
		       o2 = o;
		       o = Getattr(o,ATTR_SIBLING);
		     }
		     $$.last = o2;
		   } else {
		     if ($2) {
		       o = $1.last;
		       if (o) {
			 Setattr(o,ATTR_SIBLING,$2);
		       } else { 
			 Setattr($1.node,ATTR_SIBLING,$2);
		       }
		       o = $2;
		       while (o) {
			 o2 = o;
			 o = Getattr(o,ATTR_SIBLING);
		       }
		       $1.last = o2;
		     }
		     $$ = $1;
		   }
                }
               | empty { $$.node = 0; $$.last = 0; }
               ;

statement      : swig_directive { $$ = $1; }
               | c_declaration { $$ = $1; }
               | LBRACE interface RBRACE {
		 $$ = new_node("scope",$1.filename,$1.line);
		 if ($2.node) {
		   Setattr($$,ATTR_CHILD,$2.node);
		   setparent($$,$2.node);
		 }
               }
               | SEMI { $$ = 0; }
               | error { $$ = 0; }
               ;

/* =============================================================================
 *                          -- SWIG DIRECTIVES --
 * ============================================================================= */
swig_directive : MODULE idstring {
                   $$ = new_node("moduledirective",$1.filename,$1.line);
		   Setattr($$,ATTR_NAME,$2.text);
               }
               | MACRO ID COMMA STRING COMMA NUM_INT LBRACE {
		 LParse_macro_location($2.text,$1.filename,$1.line);
		 LParse_set_location($4.text, atoi(Char($6.text))-1);
               } interface RBRACE { 
		 LParse_macro_location(0,0,0);
		 LParse_set_location($7.filename,$7.line-1);
                 $$ = $9.node;
	       }
               | RENAME ID ID SEMI { 
		 $$  = new_node("renamedirective",$2.filename,$2.line);
		 Setattr($$,"oldname",$2.text);
		 Setattr($$,"newname",$3.text);
	       }
               | CONSTANT ID definetype SEMI {
		  $$ = new_node("constant",$2.filename, $2.line);
		  Setattr($$,ATTR_NAME,$2.text);
		  Setattr($$,ATTR_VALUE,$3.text);
		  switch($3.ivalue) {
		  case LPARSE_T_DOUBLE:
		    Setattr($$,ATTR_TYPE,"double");
		    break;
		  case LPARSE_T_FLOAT:
		    Setattr($$,ATTR_TYPE,"float");
		    break;
		  case LPARSE_T_ULONG:
		    Setattr($$,ATTR_TYPE,"unsigned long");
		    break;
		  case LPARSE_T_LONG:
		    Setattr($$,ATTR_TYPE,"long");
		    break;
		  case LPARSE_T_UINT:
		    Setattr($$,ATTR_TYPE,"unsigned int");
		    break;
		  case LPARSE_T_INT:
		    Setattr($$,ATTR_TYPE,"int");
		    break;
		  case LPARSE_T_USHORT:
		    Setattr($$,ATTR_TYPE,"unsigned short");
		    break;
		  case LPARSE_T_SHORT:
		    Setattr($$,ATTR_TYPE,"short");
		    break;
		  case LPARSE_T_UCHAR:
		    Setattr($$,ATTR_TYPE,"unsigned char");
		    break;
		  case LPARSE_T_CHAR:
		    Setattr($$,ATTR_TYPE,"char");
		    break;
		  case LPARSE_T_STRING:
		    Setattr($$,ATTR_TYPE,"*.char");
		    break;
		  default:
		    break;
		  }
               }
               | echo_directive { $$ = 0; }
               | file_include { $$ = $1; }
               | code_block { $$ = $1; }
               | doc_directive { $$ = $1; }
               | except_directive { $$ = $1; }
               | pragma_directive { $$ = $1; }
               | modifier_directive { $$ = $1; }
               | native_directive { $$ = $1; }
               | typemap_directive { $$ = $1; }
               | TYPE ID idlist SEMI { $$ = 0; }
               ;

echo_directive:  ECHO HBLOCK { Printf(stderr,"%s\n", $2.text); }
               | ECHO STRING { Printf(stderr,"%s\n", $2.text); }
               ;

/* -- File inclusion directives -- */

file_include   : file_include_type STRING LBRACE {
                    Setattr($1,ATTR_NAME,$2.text);
		    $$ = $1;
		    LParse_set_location($2.text,0);
               } interface RBRACE {
		    LParse_set_location($3.filename,$3.line + 1);
		    if ($5.node) {
		      Setattr($$,ATTR_CHILD,$5.node);
		      setparent($$,$5.node);
		    }
               }

file_include_type : INCLUDE { $$ = new_node("includefile",$1.filename,$1.line); }
               | WEXTERN { $$ = new_node("externfile",$1.filename,$1.line); }
               | IMPORT { $$ = new_node("importfile", $1.filename,$1.line); }
               ;

/* -- Modifier directives -- */

modifier_directive : READONLY { $$ = new_node("readonlydirective",$1.filename, $1.line); }
               | READWRITE    { $$ = new_node("readwritedirective",$1.filename,$1.line); }
               | NAME LPAREN idstring RPAREN { 
		 $$ = new_node("namedirective",$3.filename,$3.line);
		 Setattr($$,ATTR_NAME,$3.text);
	       }
               | NEW { 
		 $$ = new_node("newdirective",$1.filename,$1.line);
	       }
               ;

/* -- Code inclusion directives -- */

code_block    : HBLOCK {
		 $$ = new_node("headerblock",$1.filename,$1.line);
		 Setattr($$,"text", $1.text);
               }
               | WRAPPER HBLOCK {
                 $$ = new_node("wrapperblock",$2.filename,$2.line);
                 Setattr($$,"text",$2.text);
	       }
               | INIT HBLOCK {
                 $$ = new_node("initblock",$2.filename,$2.line);
                 Setattr($$,"text",$2.text);
               }
               | INLINE HBLOCK {
		 DOH *pp;
		 $$ = new_node("headerblock",$2.filename,$2.line);
		 Setattr($$,"text", $2.text);
		 Seek($2.text,0,SEEK_SET);
		 pp = Preprocessor_parse($2.text);
		 Seek(pp,0,SEEK_SET);
		 LParse_push(pp);
	       }
               ;

/* -- Documentation directives -- */

doc_directive  : DOC_ENABLE { $$ = 0; }
               | DOC_DISABLE { $$ = 0; }

/* %title directive */

               | TITLE STRING styletail { $$ = 0; }

/* %section directive */

               | SECTION STRING styletail { $$ = 0; }

/* %subsection directive */
               | SUBSECTION STRING styletail { $$ = 0; }

/* %subsubsection directive */
               | SUBSUBSECTION STRING styletail { $$ = 0; }

/* %text directive */

               | TEXT HBLOCK { $$ = 0; }

/* Disable code generation */
               | DOCONLY { $$ = 0; }

/* %style directive.   This applies to all current styles */

               | STYLE stylelist { $$ = 0; }

/* %localstyle directive.   This applies only to the current style */

               | LOCALSTYLE stylelist { $$ = 0; }

/* Documentation style list */

stylelist      : ID stylearg styletail { $$ = 0; }
               ;

styletail      : styletail COMMA ID stylearg { $$ = 0; }
               | empty { $$ = 0; }
               ;

stylearg       : EQUAL NUM_INT { }
               | EQUAL STRING { }
               | empty { }
               ;

idstring       : ID { $$ = $1; }
               | TYPE_TYPEDEF { $$ = $1; }
               | STRING {  $$ = $1; }
               ;

/* -- Exceptions -- */

except_directive:  EXCEPT LPAREN ID RPAREN LBRACE {
                  DOH  *t;
		  t = LParse_skip_balanced('{','}');
		  $$ = new_node("exceptiondirective",$1.filename,$1.line);
		  Setattr($$,"lang",$3.text);
		  Setattr($$,"code",t);
                }

/* A Generic Exception (no language specified */
               | EXCEPT LBRACE {
                   DOH *t;
		   t = LParse_skip_balanced('{','}');
		   $$ = new_node("exceptiondirective",$1.filename,$1.line);
		   Setattr($$,"code",t);
               }

/* Clear an exception */
               | EXCEPT LPAREN ID RPAREN SEMI {
		 $$ = new_node("exceptiondirective",$1.filename,$1.line);
		 Setattr($$,"lang",$3.text);
	       }

/* Generic clear */
               | EXCEPT SEMI {
		 $$ = new_node("exceptiondirective",$1.filename,$1.line);
	       }
               ; 

pragma_directive :  PRAGMA ID pragma_arg {
                  $$ = new_node("pragmadirective",$1.filename,$1.line);
		  Setattr($$,ATTR_NAME,$2.text);
		  Setattr($$,ATTR_VALUE,$3.text);
    	       }
               | PRAGMA LPAREN ID RPAREN ID pragma_arg {
		 $$ = new_node("pragmadirective",$1.filename,$1.line);
		 Setattr($$,ATTR_NAME,$5.text);
		 Setattr($$,"lang",$3.text);
		 Setattr($$,ATTR_VALUE,$6.text);
	       }
               ;

pragma_arg     : EQUAL definetype {
                  $$.text = $2.text;
               }
               | empty { 
                  $$.text = 0;
               }  
               ;


/* A native wrapper function */

native_directive : NATIVE LBRACE interface RBRACE {
                      $$ = new_node("nativedirective",$1.filename,$1.line);
		      if ($3.node) {
			Setattr($$,ATTR_CHILD,$3.node);
			setparent($$,$3.node);
		      }
                }
                ;


/* -- Typemap directives -- */


typemap_directive: TYPEMAP LPAREN ID COMMA tm_method RPAREN tm_list LBRACE {
                      DOH *o, *prev = 0, *t, *l;
		      int i;
		      t = LParse_skip_balanced('{','}');
		      $$ = 0;
		      for (i = 0; i < Len($7); i++) {
			l = Getitem($7,i);
			o = new_node("typemap",$1.filename, $1.line);
			Setattr(o,"lang",$3.text);
			Setattr(o,"method",$5.text);
			Setattr(o,"code",t);
			Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
			Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
			Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
			if (!$$) $$ = o;
			if (prev) {
			  Setattr(prev,ATTR_SIBLING,o);
			}
			prev = o;
		      }
                  }

/* Create a new typemap in current language */
               | TYPEMAP LPAREN tm_method RPAREN tm_list LBRACE {
                   DOH *o, *t, *l, *prev = 0;
		   int i;
		   t = LParse_skip_balanced('{','}');
		   $$ = 0;
		   for (i = 0; i < Len($5); i++) {
		     l = Getitem($5,i);
		     o = new_node("typemap",$1.filename, $1.line);
		     Setattr(o,"method",$3.text);
		     Setattr(o,"code",t);
		     Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
		     Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
		     Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
		     if (!$$) $$ = o;
		     if (prev) Setattr(prev,ATTR_SIBLING,o);
		     prev = o;
		   }
	       }

/* Clear a typemap */

               | TYPEMAP LPAREN ID COMMA tm_method RPAREN tm_list SEMI {
		   DOH *o, *l, *prev = 0;
		   int i;
		   $$ = 0;
		   for (i = 0; i < Len($7); i++) {
		      l = Getitem($7,i);
		      o = new_node("typemap",$1.filename, $1.line);
		      Setattr(o,"lang",$3.text);
		      Setattr(o,"method",$5.text);
		      Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
		      Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
		      if (!$$) $$ = o;
		      if (prev) Setattr(prev,ATTR_SIBLING,o);
		      prev = o;
		    }
	       }

/* Clear a typemap in current language */

               | TYPEMAP LPAREN tm_method RPAREN tm_list SEMI {
                   DOH *o, *l, *prev = 0;
		   int i;
		   $$ = 0;
		   for (i = 0; i < Len($5); i++) {
		     l = Getitem($5,i);
		     o = new_node("typemap",$1.filename, $1.line);
		     Setattr(o,"method",$3.text);
		     Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
		     Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
		     if (!$$) $$ = o;
		     if (prev) Setattr(prev,ATTR_SIBLING,o);
		     prev = o;
		   }
	       }

/* Copy a typemap */

               | TYPEMAP LPAREN ID COMMA tm_method RPAREN tm_list EQUAL tm_parm SEMI {
		 DOH *o, *l, *prev = 0;
		 int i;
		 $$ = 0;
		 for (i = 0; i < Len($7); i++) {
		   l = Getitem($7,i);
		   o = new_node("typemapcopy",$1.filename, $1.line);
		   Setattr(o,"method", $5.text);
		   Setattr(o,"lang", $3.text);
		   Setattr(o,ATTR_NAME, Getattr(l,ATTR_NAME));
		   Setattr(o,ATTR_TYPE, Getattr(l,ATTR_TYPE));
		   Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
		   Setattr(o,"srcname",Getattr($9,ATTR_NAME));
		   Setattr(o,"srctype",Getattr($9,ATTR_TYPE));
		   if (!$$) $$ = o;
		   if (prev) Setattr(prev,ATTR_SIBLING,o);
		   prev = o;
		 }
	       }

/* Copy typemap in current language */

               | TYPEMAP LPAREN tm_method RPAREN tm_list EQUAL tm_parm SEMI {
		 DOH *o, *l, *prev = 0;
		 int i;
		 $$ = 0;
		 for (i = 0; i < Len($5); i++) {
		   l = Getitem($5,i);
		   o = new_node("typemapcopy",$1.filename, $1.line);
		   Setattr(o,"method", $3.text);
		   Setattr(o,ATTR_NAME, Getattr(l,ATTR_NAME));
		   Setattr(o,ATTR_TYPE, Getattr(l,ATTR_TYPE));
		   Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
		   Setattr(o,"srcname",Getattr($7,ATTR_NAME));
		   Setattr(o,"srctype",Getattr($7,ATTR_TYPE));
		   if (!$$) $$ = o;
		   if (prev) Setattr(prev,ATTR_SIBLING,o);
		   prev = o;
		 }
	       }

/* Apply directive */

               | APPLY tm_parm LBRACE tm_list RBRACE {
		 $$ = new_node("applydirective",$1.filename, $1.line);
		 Setattr($$,ATTR_NAME,Getattr($2,ATTR_NAME));
		 Setattr($$,ATTR_TYPE,Getattr($2,ATTR_TYPE));
		 Setattr($$,ATTR_PARMS,$4);
               }

/* Clear directive */

	       | CLEAR tm_list SEMI {
		 $$ = new_node("cleardirective",$1.filename, $1.line);
		 Setattr($$,ATTR_PARMS,$2);
	       }
               ;

tm_method      : ID {
                 $$ = $1;
               } 
               | CONST {
                 $$.text = NewString("const");
               }
               ;


tm_list        : tm_parm tm_tail {
                 Insert($2,0,$1);
		 $$ = $2;
		}
               ;

tm_tail        : COMMA tm_parm tm_tail {
                 Insert($3,0,$2);
                 $$ = $3;
                }
               | empty { $$ = NewList(); }
               ;

tm_parm        : type tm_name {
                    $$ = NewHash();
		    if ($2.array) {
		      SwigType_push($1,$2.array);
		    }
		    Setattr($$,ATTR_TYPE,$1);
		    if ($2.name)
		      Setattr($$,ATTR_NAME,$2.name);
		    if ($2.parms)
		      Setattr($$,ATTR_PARMS,$2.parms);
                }
                | type stars tm_name {
		  $$ = NewHash();
		  SwigType_push($1,$2);
		  if ($3.array) {
		    SwigType_push($1,$3.array);
		  }
		  Setattr($$,ATTR_TYPE,$1);
		  if ($3.name)
		    Setattr($$,ATTR_NAME,$3.name);
		  if ($3.parms)
		    Setattr($$,ATTR_PARMS,$3.parms);
		}
                | type AND tm_name {
		  $$ = NewHash();
		  SwigType_add_reference($1);
		  if ($3.array) {
		    SwigType_push($1,$3.array);
		  }
		  Setattr($$,ATTR_TYPE,$1);
		  if ($3.name)
		    Setattr($$,ATTR_NAME,$3.name);
		  if ($3.parms)
		    Setattr($$,ATTR_PARMS,$3.parms);
		}
		;

tm_name         : ID tm_args {
                $$.parms = $2;
		$$.name = $1.text;
		$$.array = 0;
               }
               | ID array tm_args { 
                $$.name = $1.text;
		$$.array = $2;
		$$.parms = $3;
	       }
               | array tm_args { 
		 $$.name = 0;
		 $$.array = $1;
		 $$.parms = $2;
	       }
               | tm_args {
		 $$.name = 0;
		 $$.array = 0;
		 $$.parms = $1;
	       }
                ;

tm_args         : LPAREN parms RPAREN {
                    $$ = $2;
                }
                | empty {
                    $$ = 0;
                }
                ;




/* =============================================================================
 *                       -- C Declarations -- 
 * ============================================================================= */

c_declaration   : variable_decl { $$ = $1; }
                | function_decl { $$ = $1; }
                | enum_decl { $$ = $1; }
                | typedef_decl { $$ = $1; }
                | cpp_decl { $$ = $1; }
                ;

/* A variable declaration */

variable_decl   : storage_spec type declaration array2 def_args stail {
                    DOH *o, *t;
		    $$ = new_node(TAG_VARIABLE,Getfile($3.id),Getline($3.id));
		    t = Copy($2);
                    SwigType_push(t,$3.decl);
		    SwigType_push(t,$4);
		    Setattr($$,ATTR_NAME,$3.id);
		    Setattr($$,ATTR_TYPE,t);
                    if ($1.ivalue) {
		      Setattr($$,ATTR_STORAGE,$1.text);
		    }
		    if ($5.text) {
		      Setattr($$,ATTR_VALUE,$5.text);
		    }
		    if ($6) {
		      Setattr($$,ATTR_SIBLING,$6);
		      o = $6;
		      while (o) {
			t = Copy($2);
			SwigType_push(t,Getattr(o,ATTR_TYPE));
			Setattr(o,ATTR_TYPE,t);
			if ($1.ivalue) {
			  Setattr(o,ATTR_STORAGE,$1.text);
			}
			o = Getattr(o,ATTR_SIBLING);
		      }
		    }
                  }

/* Global variable that smells like a function pointer */

                | storage_spec strict_type LPAREN STAR { 
		  LParse_error($3.filename,$3.line,"Pointer to function not currently supported.\n");
		  LParse_skip_decl();
		  $$ = 0;
		}
                ;


/* A function declaration */

function_decl  : storage_spec type declaration LPAREN parms RPAREN cpp_const stail {
                    DOH *o, *t;
		    t = Copy($2);
		    SwigType_push(t,$3.decl);
		    $$ = new_node(TAG_FUNCTION,Getfile($3.id),Getline($3.id));
		    Setattr($$,ATTR_NAME,$3.id);
		    Setattr($$,ATTR_TYPE,t);
		    Setattr($$,ATTR_PARMS,$5);
		    if ($1.ivalue) {
		      Setattr($$,ATTR_STORAGE, $1.text);
		    }
		    if ($8) {
		      Setattr($$,ATTR_SIBLING,$8);
		      o = $8;
		      while (o) {
			t = Copy($2);
			SwigType_push(t,Getattr(o,ATTR_TYPE));
			Setattr(o,ATTR_TYPE,t);
			if ($1.ivalue) {
			  Setattr(o,ATTR_STORAGE,$1.text);
			}
			o = Getattr(o,ATTR_SIBLING);
		      }
		    }
                 } 
               
/* A function declaration with code after it */

                | storage_spec type declaration LPAREN parms RPAREN cpp_end {
		  SwigType_push($2,$3.decl);
		  $$ = new_node(TAG_FUNCTION,Getfile($3.id),Getline($3.id));
		  Setattr($$,ATTR_NAME,$3.id);
		  Setattr($$,ATTR_TYPE,$2);
		  Setattr($$,ATTR_PARMS,$5);
		  if ($1.ivalue) {
		    Setattr($$,ATTR_STORAGE, $1.text);
		  }
		  if ($7.text)
		    Setattr($$,"code",$7.text);
		}

/* Possibly a constructor */
              | storage_spec ID LPAREN parms RPAREN ctor_end {
		  DOH *t = NewString("int");
		  $$ = new_node(TAG_FUNCTION,$2.filename,$2.line);
		  Setattr($$,ATTR_NAME,$2.text);
		  Setattr($$,ATTR_TYPE,t);
		  Setattr($$,ATTR_PARMS,$4);
		  if ($1.ivalue) {
		    Setattr($$,ATTR_STORAGE,$1.text);
		  }
		  if ($6.text) {
		    Setattr($$,"code",$6.text);
		  }
	      }

/* A C++ destructor */
              | NOT ID LPAREN parms RPAREN cpp_end {
		$$ = new_node("destructor",$2.filename,$2.line);
		Setattr($$,ATTR_NAME,$2.text);
		if ($6.text) {
		  Setattr($$,"code",$6.text);
		}
	      }
              | NOT ID LPAREN parms RPAREN cpp_const SEMI {
		$$ = new_node("destructor",$2.filename,$2.line);
		Setattr($$,ATTR_NAME,$2.text);
	      }

              ;

/* Allow lists of variables and functions to be built up */

stail          : SEMI { $$ = 0; }
               | COMMA declaration array2 def_args stail {
		 DOH *t = NewString("");
		 SwigType_push(t,$2.decl);
		 SwigType_push(t,$3);
		 $$ = new_node(TAG_VARIABLE, Getfile($2.id),Getline($2.id));
		 Setattr($$,ATTR_NAME,$2.id);
		 Setattr($$,ATTR_TYPE,t);
		 if ($4.text)
		   Setattr($$,ATTR_VALUE,$4.text);
		 if ($5)
		   Setattr($$,ATTR_SIBLING, $5);
	       }
               | COMMA declaration LPAREN parms RPAREN stail {
		 DOH *t = NewString("");
		 SwigType_push(t,$2.decl);
		 $$ = new_node(TAG_FUNCTION, Getfile($2.id), Getline($2.id));
		 Setattr($$,ATTR_NAME,$2.id);
		 Setattr($$,ATTR_PARMS,$4);
		 Setattr($$,ATTR_TYPE, t);
		 if ($6)
		   Setattr($$,ATTR_SIBLING,$6);
	       }
              ;

storage_spec    : EXTERN { 
                   $$.ivalue = 1; 
		   $$.text = NewString("extern");
                }
               | EXTERN STRING {
                   $$.ivalue = 1;
		   $$.text = NewStringf("extern \"%s\"", $2.text);
	       }
               | STATIC {
		 $$.ivalue = 1;
		 $$.text = NewString("static");
	       }
               | empty {
                   $$.ivalue = 0;
		   $$.text = 0;
               }
               ;
                 

cpp_const      : CONST {} 
               | THROW LPAREN { LParse_skip_balanced('(',')'); }
               | empty {}
               ;

/* Enumerations */

enum_decl      : storage_spec ENUM ename LBRACE enumlist RBRACE SEMI {
                    $$ = new_node("enum", $2.filename,$2.line);
		    Setattr($$,ATTR_NAME,$2.text);
		    Setattr($$,ATTR_CHILD,$5.node);
		    setparent($$,$5.node);
		    /* Add typename */
                 }

/* A typdef'd enum.  Pretty common in C headers */

               | TYPEDEF ENUM ename LBRACE enumlist RBRACE ID SEMI { 
   		   $$ = new_node("enum",$2.filename,$2.line);
		   Setattr($$,ATTR_NAME,$3.text);
		   Setattr($$,ATTR_CHILD,$5.node);
		   setparent($$,$5.node);
		   /* Add typedef for enum */
		   {
		     DOH *o;
		     o = new_node("typedef",$7.filename,$7.line);
		     Setattr(o,ATTR_NAME,$7.text);
		     Setattr(o,ATTR_TYPE,$3.text);
		     Setattr($$,ATTR_SIBLING,o);
		   }
	       }
               ;

/* Some stuff for handling enums */

ename          :  ID { $$ = $1; } 
               |  empty { $$.text = NewString(""); }
               ;

enumlist       :  enumlist COMMA edecl { 
                   Setattr($1.last,ATTR_SIBLING,$3);
		   $1.last = $3;
		   $$ = $1;
		   /*
		   DOH *o;
                   if ($3) {
		     o = Getattr($1,LASTATTR_SIBLING);
		     if (o) {
		       Setattr(o,ATTR_SIBLING,$3);
		     } else {
		       Setattr($1,ATTR_SIBLING,$3);
		     }
		     Setattr($1,LASTSIBLING,$3);;
		   }
		   $$ = $1;
		   */
               }
               |  edecl {
                  $$.node = $1;
                  $$.last = $1;
               }
               ;

edecl          :  ID {
                   $$ = new_node(TAG_ENUMVALUE,$1.filename,$1.line);
                   Setattr($$,ATTR_NAME,$1.text);
		 } 
                 | ID EQUAL expr {
		   $$ = new_node(TAG_ENUMVALUE,$1.filename,$1.line);
		   Setattr($$,ATTR_NAME,$1.text);
		   Setattr($$,ATTR_VALUE,$1.text);
                 }
                 | empty { $$ = 0; }
                 ;
		   
typedef_decl   : TYPEDEF type declaration array2 typedeflist SEMI {
                    DOH *t, *d, *o, *ty, *prev;
		    int i;
                    $$ = new_node("typedef", $1.filename,$1.line);
		    t = Copy($2);
		    SwigType_push($2,$3.decl);
		    if ($4) SwigType_push($2,$4);
		    Setattr($$,ATTR_NAME,$3.id);
		    Setattr($$,ATTR_TYPE,$2);
		    /* Go create more typedefs */
		    prev = $$;
		    for (i = 0; i < Len($5); i++) {
		      DOH *ty;
		      d = Getitem($5,i);
		      o = new_node("typedef",$1.filename,$1.line);
		      ty = Copy(t);
		      SwigType_push(ty,Getattr(d,"decl"));
		      SwigType_push(ty,Getattr(d,"array"));
		      Setattr(o,ATTR_TYPE,ty);
		      Setattr(o,ATTR_NAME,Getattr(d,ATTR_NAME));
		      Setattr(prev,ATTR_SIBLING,o);
		      prev = o;
		    }
		    Delete($5);
               }

/* A rudimentary typedef involving function pointers */

               | TYPEDEF type LPAREN stars pname RPAREN LPAREN parms RPAREN SEMI {
		 $$ = new_node("typedef", $1.filename,$1.line);
		 SwigType_push($2,parmstotype($8));
		 SwigType_push($2,$4);
		 if ($5.array)
		   SwigType_push($2,$5.array);
		 Setattr($$,ATTR_NAME,$5.name);
		 Setattr($$,ATTR_TYPE,$2);
	       }

/* A typedef involving function pointers again */

               | TYPEDEF type stars LPAREN stars pname RPAREN LPAREN parms RPAREN SEMI {
		 $$ = new_node("typedef", $1.filename,$1.line);
		 SwigType_push($2,$3);
		 SwigType_push($2,parmstotype($9));
		 SwigType_push($2,$5);
		 if ($6.array)
		   SwigType_push($2,$6.array);
		 Setattr($$,ATTR_NAME,$6.name);
		 Setattr($$,ATTR_TYPE,$2);
		 }
               ;

typedeflist   : COMMA declaration typedeflist {
                 DOH *o = NewHash();
		 Setattr(o,ATTR_NAME,$2.id);
		 Setattr(o,"decl",$2.decl);
		 Insert($3,0,o);
		 $$ = $3;
              }
              | COMMA declaration array typedeflist {
                 DOH *o;
                 $$ = $4;
		 o = NewHash();
		 Setattr(o,ATTR_NAME,$2.id);
		 Setattr(o,"decl",$2.decl);
		 if ($3)
		   Setattr(o,"array",$3);
		 Append($$,o);
	      }
              | empty {
                 $$ = NewList();
              }
              ;



/* =============================================================================
 *                        -- Feeble C++ (yuck) Parsing --
 * ============================================================================= */

cpp_decl     : cpp_class { $$ = $1; }
             | cpp_other { $$ = $1; }
             ;
  
cpp_class    :  storage_spec cpptype ID inherit LBRACE interface RBRACE opt_id SEMI {
                   $$ = new_node("class",$3.filename,$3.line);
		   Setattr($$,"classtype",$2.text);
		   Setattr($$,ATTR_NAME,$3.text);
		   Setattr($$,"bases", $4);
		   if ($6.node) {
		     Setattr($$,ATTR_CHILD,$6.node);
		     setparent($$,$6.node);
		   }
		   if ($8.text) {
		     Setattr($$,TAG_VARIABLE,$8.text);
		   }
	      }

              | storage_spec cpptype LBRACE interface RBRACE opt_id SEMI {
		  $$ = new_node("class",$3.filename,$3.line);
		  Setattr($$,"classtype",$2.text);
		  if ($4.node) {
		    Setattr($$,ATTR_CHILD,$4.node);
		    setparent($$,$4.node);
		  }
		  if ($6.text)
		    Setattr($$,TAG_VARIABLE,$6.text);
              }

/* Class with a typedef */
		
             | TYPEDEF cpptype ID inherit LBRACE interface RBRACE declaration typedeflist {
	       $$ = new_node("class",$3.filename,$3.line);
	       Setattr($$,"classtype",$2.text);
	       Setattr($$,ATTR_NAME,$3.text);
	       Setattr($$,"bases",$4);
	       if ($6.node) {
		 Setattr($$,ATTR_CHILD,$6.node);
		 setparent($$,$6.node);
	       }
	       if (Len($8.decl) == 0)
		 Setattr($$,"altname",$8.id);
	       
	       {
		 /* Go add a bunch of typedef declarations */
		 DOH *o, *t, *prev, *d;
		 int i;
		 o = new_node("typedef",$3.filename,$3.line);
		 Setattr(o,ATTR_NAME,$8.id);
		 t = Copy($3.text);
		 SwigType_push(t,$8.decl);
		 Setattr(o,ATTR_TYPE,t);
		 Setattr($$,ATTR_SIBLING,o);
		 prev = o;
		 for (i = 0; i < Len($9); i++) {
		   d = Getitem($9,i);
		   o = new_node("typedef",$3.filename,$3.line);
		   t = Copy($3.text);
		   SwigType_push(t,Getattr(d,"decl"));
		   SwigType_push(t,Getattr(d,"array"));
		   Setattr(o,ATTR_TYPE,t);
		   Setattr(o,ATTR_NAME,Getattr(d,ATTR_NAME));
		   Setattr(prev,ATTR_SIBLING,o);
		   prev = o;
		 }
		 Delete($9);
	       }
	     } 

/* An unnamed struct with a typedef */

             | TYPEDEF cpptype LBRACE interface RBRACE declaration typedeflist {
	       $$ = new_node("class",$3.filename,$3.line);
	       Setattr($$,"classtype",$2.text);
	       if ($4.node) {
		 Setattr($$,ATTR_CHILD,$4.node);
		 setparent($$,$4.node);
	       }
	       if (Len($6.decl) == 0)
		 Setattr($$,"altname",$6.id);
	       }
             ;

inherit        : COLON base_list {
                   $$ = $2;
             }
             | empty {
                 $$ = 0;
             }
             ;

base_list      : base_specifier { 
		  $$ = NewList();
		  Append($$,$1.text);
                }
               | base_list COMMA base_specifier { 
                   $$ = $1;
		   if ($3.text)
		     Append($$,$3.text);
               }
               ;
                                 
base_specifier : ID {  
		 LParse_error($1.filename,$1.line,"No access specifier given for base class %s (ignored).\n", $1.text);
		  $$.text = 0;
               }
               | access_specifier ID {
		 if (Cmp($1.text,"public") == 0) {
		   $$ = $2;
		 } else {
		   LParse_error($2.filename,$2.line,"%s inheritance not supported (ignored).\n", $1.text); 
		   $$.text = 0;
		 }
	       }                          
               ;                               

access_specifier :  PUBLIC { $$.text = NewString("public"); }
               |    PRIVATE { $$.text = NewString("private"); }
               |    PROTECTED { $$.text = NewString("protected"); }
               ;

cpp_end        : cpp_const LBRACE {  
                   $$.text = LParse_skip_balanced('{','}');
               }
               | EQUAL definetype SEMI {
                   $$.text = 0;
    	       }
/*               | cpp_const { 
                   $$.text = 0;
   	       }
*/
               ;

type_extra    : stars {}
              | AND {}
              | empty {}
              ; 

/* Constructor initializer */

ctor_end       : cpp_const ctor_initializer SEMI { $$.text = 0; }
               | cpp_const ctor_initializer LBRACE { $$.text = LParse_skip_balanced('{','}'); }
               ;

ctor_initializer : COLON mem_initializer_list {}
               | empty {}
               ;

mem_initializer_list : mem_initializer { }
               | mem_initializer_list COMMA mem_initializer { }
               ;

mem_initializer : ID LPAREN { LParse_skip_balanced('(',')'); }
                ;


cpp_other    :/* A dummy class name */
             storage_spec cpptype ID SEMI {
                 DOH *o = new_node("ClassDecl",$4.filename,$4.line);
                 Setattr(o,ATTR_NAME,$3.text);
	     }   

             | PUBLIC COLON { $$ = new_node("public",$1.filename,$1.line); }
             | PRIVATE COLON { $$ = new_node("private",$1.filename,$1.line); }
             | PROTECTED COLON { $$ = new_node("protected",$1.filename,$1.line); }

             | FRIEND {
	       LParse_skip_decl();
             }

             | storage_spec type type_extra OPERATOR {
	       LParse_skip_decl();
             }
	       
/* Any sort of out-of-class C++ declaration */
            
              | storage_spec type declaration DCOLON {
		LParse_skip_decl();
	      }
 
/* Template catch */
             | TEMPLATE {
		LParse_skip_decl();
	     }

/* %addmethods directive */

             | ADDMETHODS opt_id LBRACE interface RBRACE { 
	        $$ = new_node("addmethods",$1.filename,$1.line);
		if ($1.text)
		  Setattr($$,ATTR_NAME,$1.text);
		if ($4.node) {
		  Setattr($$,ATTR_CHILD,$4.node);
		  setparent($$,$4.node);
		}
             }

opt_id       : ID { $$ = $1; }
             | empty { $$.text = 0; }
             ;

/* =============================================================================
 *                  -- Generic (admittedly poor) C Parsing --
 * ============================================================================= */

/* -- Function parameter lists -- */

parms          : parm ptail {
                 Insert($2,0,$1);
                 $$ = $2;
		}
               | empty { $$ = NewList(); }
               ;

ptail          : COMMA parm ptail {
                 Insert($3,0,$2);
                 $$ = $3;
                }
               | empty { $$ = NewList(); }
               ;

parm           : type pname {
                   $$ = NewHash();
		   Setattr($$,ATTR_NAME,$2.name);
		   SwigType_push($1,$2.array);
		   if ($2.value)
		     Setattr($$,ATTR_VALUE,$2.value);
		   Setattr($$,ATTR_TYPE,$1);
                }
                | type stars pname {
		  $$ = NewHash();
		  Setattr($$,ATTR_NAME,$3.name);
		  SwigType_push($1,$2);
		  SwigType_push($1,$3.array);
		  if ($3.value) {
		    Setattr($$,ATTR_VALUE,$3.value);
		  }
		  Setattr($$,ATTR_TYPE,$1);
		}
                | type AND pname {
		  $$ = NewHash();
		  SwigType_add_reference($1);
		  SwigType_push($1,$3.array);
		  Setattr($$,ATTR_NAME,$3.name);
		  if ($3.value) {
		    Setattr($$,ATTR_VALUE,$3.value);
		  }
		  Setattr($$,ATTR_TYPE,$1);
		}
                | type LPAREN stars pname RPAREN LPAREN parms RPAREN {
		  $$ = NewHash();
		  SwigType_push($1,parmstotype($7));
		  SwigType_push($1,$3);
		  if ($4.array)
		    SwigType_push($1,$4.array);
		  Setattr($$,ATTR_NAME,$4.name);
		  if ($4.value)
		    Setattr($$,ATTR_VALUE,$4.value);
		  Setattr($$,ATTR_TYPE,$1);
		}
                | type stars LPAREN stars pname RPAREN LPAREN parms RPAREN {
		  $$ = NewHash();
		  SwigType_push($1,$2);
		  SwigType_push($1,parmstotype($8));
		  SwigType_push($1,$4);
		  if ($5.array)
		    SwigType_push($1,$5.array);
		  Setattr($$,ATTR_NAME,$5.name);
		  if ($5.value)
		    Setattr($$,ATTR_VALUE,$5.value);
		  Setattr($$,ATTR_TYPE,$1);
		}
                | PERIOD PERIOD PERIOD {
		  $$ = NewHash();
		  Setattr($$,ATTR_NAME,"...");
		  Setattr($$,ATTR_TYPE,"?");
		}
		;

pname          : ID def_args {
                 $$.name = $1.text;
		 $$.value = $2.text;
		 $$.array = 0;
               }
               | ID array {
                 $$.name = $1.text;
                 $$.value = 0;
		 $$.array = $2;
               }
               | array {
		 $$.name = NewString("");
		 $$.value = 0;
		 $$.array = $1;
               }
               | empty {
		 $$.name = NewString("");
		 $$.value = 0;
		 $$.array = 0;
	       }
               ;

def_args       : EQUAL definetype { $$ = $2; }
               | EQUAL AND ID {
		 $$.text = NewString("");
		 Printf($$.text,"&%s",$3.text);
		 $$.ivalue = LPARSE_T_USER;
	       }
               | EQUAL LBRACE {
		 LParse_skip_balanced('{','}');
		 $$.text = 0;
		 $$.ivalue = 0;
	       }
               | COLON NUM_INT {
		 $$.text = 0;
		 $$.ivalue = 0;
               }
               | empty {
                 $$.text = 0; 
                 $$.ivalue = 0;
	       }
               ;

/* Declaration must be an identifier, possibly preceded by a * for pointer types  */

declaration    : ID {
		 $$.id = $1.text;
		 $$.decl = NewString("");
                }
               | stars ID {
                 $$.id = $2.text;
                 $$.decl = $1;
	       }
               | AND ID {
                 $$.id = $2.text;
                 $$.decl = NewString("");
                 SwigType_add_reference($$.decl);
	       }
               | AND stars ID {
                 $$.id = $3.text;
                 $$.decl = $2;
                 SwigType_add_reference($$.decl);
               }
               ;

stars :          STAR empty { 
                    $$ = NewString("");
		    SwigType_add_pointer($$);
               }
               | STAR stars { 
                    $$ = $2;
		    SwigType_add_pointer($$);
               }
               ;

array :        LBRACKET RBRACKET array2 {
                 $$ = $3;
                 SwigType_add_array($$,"");
              }
              | LBRACKET expr RBRACKET array2 {
		$$ = $4;
		SwigType_add_array($$,$2.text);
              }
	      ;
array2 :      array {
                 $$ = $1;
              }
              | empty { $$ = NewString(""); }
	      ;


type           : TYPE_INT {  $$ = NewString("int"); }
               | TYPE_SHORT opt_int { $$ = NewString("short"); }
               | TYPE_LONG opt_int {  $$ = NewString("long"); }
               | TYPE_CHAR { $$ = NewString("char"); }
               | TYPE_BOOL {  $$ = NewString("bool"); }
               | TYPE_FLOAT { $$ = NewString("float"); }
               | TYPE_DOUBLE { $$ = NewString("double"); }
               | TYPE_VOID {  $$ = NewString("void"); }
               | TYPE_SIGNED opt_signed { 
                 if ($2) $$ = $2;
		 else {
		   $$ = NewString("signed");
		 }
	       }
               | TYPE_UNSIGNED opt_unsigned {
                   if ($2) $$ = $2;
		   else {
		     $$ = NewString("unsigned");
		   }
	       }
               | ID template_decl {
		 if ($2.text)
		   $$ = NewStringf("%s%s",$1.text,$2.text);
		 else
		   $$ = NewString($1.text);
	       }
               | CONST type {
		 SwigType_add_qualifier($2,"const");
		 $$ = $2;
     	       }
               | cpptype ID {
		 $$ = NewStringf("%s %s", $1.text, $2.text);
	       }
               | ID DCOLON ID {
		 $$ = NewStringf("%s::%s",$1.text,$2.text);
               }
/* This declaration causes a shift-reduce conflict.  Unresolved for now */
               | DCOLON ID {
		 $$ = Copy($2.text);
               }
               | ENUM ID {
		 $$ = NewStringf("enum %s", $2.text);
               }
               ;


strict_type    : TYPE_INT {  $$ = NewString("int"); }
               | TYPE_SHORT opt_int { $$ = NewString("short"); }
               | TYPE_LONG opt_int {  $$ = NewString("long"); }
               | TYPE_CHAR { $$ = NewString("char"); }
               | TYPE_BOOL {  $$ = NewString("bool"); }
               | TYPE_FLOAT { $$ = NewString("float"); }
               | TYPE_DOUBLE { $$ = NewString("double"); }
               | TYPE_VOID {  $$ = NewString("void"); }
               | TYPE_SIGNED opt_signed { 
                 if ($2) $$ = $2;
		 else {
		   $$ = NewString("signed");
		 }
	       }
               | TYPE_UNSIGNED opt_unsigned {
                   if ($2) $$ = $2;
		   else {
		     $$ = NewString("unsigned");
		   }
	       }
               | TYPE_TYPEDEF template_decl {
		 if ($2.text) {
		   $$ = NewStringf("%s%s",$1.text,$2.text);
		 } else {
		   $$ = NewString($1.text);
		 }
	       }
               | CONST type {
		  $$ = $2;
		  SwigType_add_qualifier($$,"const");
     	       }
               | cpptype ID {
		 $$ = NewStringf("%s %s", $1.text, $2.text);
	       }
               | ENUM ID {
		 $$ = NewStringf("enum %s", $2.text);
               }
               ;

template_decl  : LESSTHAN { 
		   $$.text = LParse_skip_balanced('<','>');
               }
               | empty { $$.text = 0; }
               ;

/* Optional signed types */
opt_signed     : empty { $$ = 0; }
               | TYPE_INT { 
                   $$ = NewString("signed int");
	       }
               | TYPE_SHORT opt_int {
                   $$ = NewString("signed short");
	       }
               | TYPE_LONG opt_int {
                   $$ = NewString("signed long");
	       }
               | TYPE_CHAR {
                   $$ = NewString("signed char");
	       }
               ;

/* Optional unsigned types */

opt_unsigned   : empty { $$ = 0;}
               | TYPE_INT {
                   $$ = NewString("unsigned int");
	       }
               | TYPE_SHORT opt_int {
		   $$ = NewString("unsigned short");
	       }
               | TYPE_LONG opt_int {
                   $$ = NewString("unsigned long");
	       }
               | TYPE_CHAR {
                   $$ = NewString("unsigned char");
	       }
               ;

opt_int        : TYPE_INT { }
               | empty { }
               ;

cpptype        : CLASS { $$ = $1; }
               | STRUCT { $$ = $1; }
               | UNION { $$ = $1; }  
               ;

/* -----------------------------------------------------------------------------
 *                              -- Expressions --
 * ----------------------------------------------------------------------------- */

definetype     :  expr {
                    $$ = $1;
                } 
                | STRING {
                    $$.text = $1.text;
                    $$.ivalue = LPARSE_T_STRING;
		}
                ;
  
expr           :  NUM_INT { 
                  $$.text = $1.text;
                  $$.ivalue = LPARSE_T_INT;
                 }
               |  NUM_FLOAT {
                  $$.text = $1.text;
                  $$.ivalue = LPARSE_T_DOUBLE;
               }
               |  NUM_UNSIGNED {
                  $$.text = $1.text;
		  $$.ivalue = LPARSE_T_UINT;
	       }
               |  NUM_LONG {
                  $$.text = $1.text;
		  $$.ivalue = LPARSE_T_LONG;
	       } 
               |  NUM_ULONG {
                  $$.text = $1.text;
		  $$.ivalue = LPARSE_T_ULONG;
	       }
               | CHARCONST {
		 $$.text = NewString("");
		 Printf($$.text,"\'%s\'", $1.text);
		 $$.ivalue = LPARSE_T_CHAR;
                }
               |  SIZEOF LPAREN {
		  $$.text = NewString("sizeof(");
		  Append($$.text,LParse_skip_balanced('(',')'));
		  $$.ivalue = LPARSE_T_INT;
	       }
/*               |  LPAREN strict_type RPAREN expr %prec UMINUS {
		  $$.id = new char[strlen($4.id)+strlen($2->name)+3];
		  sprintf($$.id,"(%s)%s",$2->name,$4.id);
		  $$.type = $2->type;
	       } 
               | ID {
		 $$.id = lookup_symvalue($1);
		 if ($$.id == (char *) 0)
		   $$.id = $1;
		 else {
		   $$.id = new char[strlen($$.id)+3];
		   sprintf($$.id,"(%s)",lookup_symvalue($1));
		 }
		 temp_typeptr = lookup_symtype($1);
		 if (temp_typeptr) $$.type = temp_typeptr->type;
		 else $$.type = LPARSE_T_INT;
               }
               | ID DCOLON ID {
                  $$.id = new char[strlen($1)+strlen($3)+3];
		  sprintf($$.id,"%s::%s",$1,$3);
                  $$.type = LPARSE_T_INT;
		  delete $1;
		  delete $3;
               }
*/
               | expr PLUS expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s+%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
	       }
               | expr MINUS expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s-%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
	       }
               | expr STAR expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s*%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
	       }
               | expr SLASH expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s/%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
	       }
               | expr AND expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s&%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
		 if (($1.ivalue == LPARSE_T_DOUBLE) || ($3.ivalue == LPARSE_T_DOUBLE)) {
		   LParse_error($2.filename,$2.line,"Type error in constant expression (expecting integers).\n");
		 }
	       }
               | expr OR expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s|%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
		 if (($1.ivalue == LPARSE_T_DOUBLE) || ($3.ivalue == LPARSE_T_DOUBLE)) {
		   LParse_error($2.filename,$2.line,"Type error in constant expression (expecting integers).\n");
		 }
		 $$.ivalue = LPARSE_T_INT;
	       }
               | expr XOR expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s^%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
		 if (($1.ivalue == LPARSE_T_DOUBLE) || ($3.ivalue == LPARSE_T_DOUBLE)) {
		   LParse_error($2.filename,$2.line,"Type error in constant expression (expecting integers).\n");
		 }
		 $$.ivalue = LPARSE_T_INT;
	       }
               | expr LSHIFT expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s<<%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
		 if (($1.ivalue == LPARSE_T_DOUBLE) || ($3.ivalue == LPARSE_T_DOUBLE)) {
		   LParse_error($2.filename,$2.line,"Type error in constant expression (expecting integers).\n");
		 }
		 $$.ivalue = LPARSE_T_INT;
	       }
               | expr RSHIFT expr {
		 $$.text = NewString("");
		 Printf($$.text,"%s>>%s", $1.text,$3.text);
		 $$.ivalue = promote($1.ivalue,$3.ivalue);
		 if (($1.ivalue == LPARSE_T_DOUBLE) || ($3.ivalue == LPARSE_T_DOUBLE)) {
		   LParse_error($2.filename,$2.line,"Type error in constant expression (expecting integers).\n");
		 }
		 $$.ivalue = LPARSE_T_INT;
	       }
               |  MINUS expr %prec UMINUS {
		 $$.text = NewString("");
		 Printf($$.text,"-%s", $2.text);
		 $$.ivalue = $2.ivalue;
	       }
               |  NOT expr {
		 $$.text = NewString("");
		 Printf($$.text,"~%s", $2.text);
		 if ($2.ivalue == LPARSE_T_DOUBLE) {
		   LParse_error($2.filename,$2.line,"Type error in constant expression (expecting integers).\n");
		 }
		 $$.ivalue = $2.ivalue;
	       }
               |  LPAREN expr RPAREN {
		 $$.text = NewString("");
		 Printf($$.text,"(%s)", $2.text);
		 $$.ivalue = $2.ivalue;
	       }
               ;

idlist         : idlist COMMA ID {
                   Append($$,$3.text);
               }
               | empty {
                    $$ = NewList();
               }
               ;

empty          :   ;

%%
void lparse_error_recover() {
  int c;
  c = yylex();
  while ((c > 0) && (c != SEMI)) 
    c = yylex();
}

/* Called by the parser (yyparse) when an error is found.*/
void yyerror (char *e) {
  LParse_error(0,0,"Syntax error.\n", e);
}











