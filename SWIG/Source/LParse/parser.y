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
static Hash     *class_hash = 0;

/* Pre-created attribute name objects.  Used to improve parsing performance */

static DOH      *ATTR_TAG = 0;
static DOH      *ATTR_CHILD = 0;
static DOH      *ATTR_PARENT = 0;
static DOH      *ATTR_NEXT = 0;
static DOH      *ATTR_PREV = 0;
static DOH      *ATTR_NAME = 0;
static DOH      *ATTR_VALUE = 0;
static DOH      *ATTR_TYPE = 0;
static DOH      *ATTR_PARMS = 0;
static DOH      *ATTR_PARM = 0;
static DOH      *ATTR_STORAGE = 0;
static DOH      *TAG_ENUMVALUE = 0;
static DOH      *TAG_FUNCTION = 0;
static DOH      *TAG_VARIABLE = 0;

static int       pure_virtual = 0;

 /* Set parent node of a collection of children */
 static void setparent(DOH *parent, DOH *child) {
   DOH *o;
   o = child;
   while (o) {
     Setattr(o,ATTR_PARENT,parent);
     o = Getattr(o,ATTR_NEXT);
   }
 }

 /* Create all back links so we get a doubly-linked lists */
 static void create_backlinks(DOH *top) {
   DOH *prev = 0;
   DOH *obj;

   if (!top) return;
   obj = top;
   while (obj) {
     if (prev) {
       Setattr(obj,ATTR_PREV,prev);
     }
     create_backlinks(Getattr(obj,ATTR_CHILD));
     prev = obj;
     obj = Getattr(obj,ATTR_NEXT);
   }
 }

/* LParse_parse() - Main entry point to the C parser */
 DOH *LParse_parse(DOH *str) {
   int yyparse();
   DOH *tp;

   if (!ATTR_NEXT) {
     ATTR_PARENT = NewString("parent");
     DohIntern(ATTR_PARENT);
     ATTR_NEXT = NewString("next");
     DohIntern(ATTR_NEXT);
     ATTR_PREV = NewString("prev");
     DohIntern(ATTR_PREV);
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
     ATTR_PARM = NewString("parm");
     DohIntern(ATTR_PARM);
     ATTR_STORAGE = NewString("storage");
     DohIntern(ATTR_STORAGE);
     TAG_ENUMVALUE = NewString("c:enumvalue");
     DohIntern(TAG_ENUMVALUE);
     TAG_FUNCTION = NewString("c:function");
     DohIntern(TAG_FUNCTION);
     TAG_VARIABLE = NewString("c:variable");
     DohIntern(TAG_VARIABLE);

   }
   LParse_push(str);
   top = 0;
   class_hash = NewHash();
   tp = NewHash();
   Setattr(tp, "tag", "swig:top");
   Setattr(tp, ATTR_NAME, Getfile(str));
   yyparse();
   Setattr(tp, ATTR_CHILD, top);
   setparent(tp,top);
   create_backlinks(tp);

   {
     DOH *key;
     key = Firstkey(class_hash);
     while (key) {
       DOH *node, *tag;
       node = Getattr(class_hash,key);
       tag = Gettag(node);
       if (Cmp(tag,"swig:addmethods") == 0) {
	 Printf(stderr,"%s:%d. Warning. Added methods for '%s' ignored.\n", Getfile(node),Getline(node),Getname(node));
       }
       key = Nextkey(class_hash);
     }
   }
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
  struct {
    DOH   *name;
    DOH   *array;
    DOH   *stars;
  } sdecl;
};

/* Literals */
%token <tok> ID TYPE_TYPEDEF
%token <tok> HBLOCK 
%token <tok> STRING
%token <tok> NUM_INT NUM_FLOAT CHARCONST NUM_UNSIGNED NUM_LONG NUM_ULONG

/* C Symbols */

%token <tok> LPAREN RPAREN LBRACE RBRACE COMMA SEMI PERIOD LBRACKET RBRACKET EQUAL COLON

/* C keywords */
%token <tok> CONST ENUM EXTERN SIZEOF STATIC STRUCT TYPEDEF UNION 

/* C++ keywords */
%token <tok> VIRTUAL CLASS FRIEND OPERATOR PRIVATE PROTECTED PUBLIC TEMPLATE THROW 

/* Objective C keywords */
%token <tok> OC_INTERFACE OC_END OC_PUBLIC OC_PRIVATE OC_PROTECTED OC_CLASS OC_IMPLEMENT OC_PROTOCOL

/* C Types */
%token <tok> TYPE_INT TYPE_UNSIGNED TYPE_SHORT TYPE_LONG TYPE_FLOAT TYPE_DOUBLE TYPE_CHAR TYPE_VOID TYPE_SIGNED TYPE_BOOL

/* SWIG directives */
%token <tok> ADDMETHODS APPLY CLEAR CONSTANT ECHO EXCEPT SCOPE
%token <tok> ILLEGAL FILEDIRECTIVE INLINE MACRO MODULE NAME PRAGMA INSERT
%token <tok> TYPEMAP TYPES

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

%type <tok>    idstring template_decl cpptype expr definetype def_args storage_spec pragma_arg ename tm_code
%type <node>   parm parms ptail stars
%type <node>   array array2
%type <node>   type strict_type opt_signed opt_unsigned
%type <decl>   declaration 
%type <pname>  pname
%type <node>   tm_args tm_parm tm_tail tm_list
%type <tmname> tm_name
%type <tok>    tm_method
%type <node>   statement swig_directive c_declaration constant_directive
%type <node>   file_include code_block except_directive pragma_directive typemap_directive scope_directive type_directive
%type <node>   variable_decl function_decl enum_decl typedef_decl stail edecl typedeflist
%type <nodelist>   enumlist interface
%type <node>   inherit base_list
%type <tok>    base_specifier access_specifier cpp_end ctor_end opt_id
%type <node>   cpp_decl cpp_class cpp_other
%type <sdecl>  starparm

%%

/* The productions of the grammar with their
   associated semantic actions. */

program        : interface {
                    top = $1.node;
               } 
               ;

interface      : interface statement { 
                   DOH *o, *o2 = 0;
		   if (!$1.node) {
		     $$.node = $2;
		     o = $2;
		     while (o) {
		       o2 = o;
		       o = Getattr(o,ATTR_NEXT);
		     }
		     $$.last = o2;
		   } else {
		     if ($2) {
		       o = $1.last;
		       if (o) {
			 Setattr(o,ATTR_NEXT,$2);
		       } else { 
			 Setattr($1.node,ATTR_NEXT,$2);
		       }
		       o = $2;
		       while (o) {
			 o2 = o;
			 o = Getattr(o,ATTR_NEXT);
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
               | SEMI { $$ = 0; }
               | error { $$ = 0; }
               ;

/* =============================================================================
 *                          -- SWIG DIRECTIVES --
 * ============================================================================= */
swig_directive : MODULE idstring {
                   $$ = new_node("swig:module",$1.filename,$1.line);
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
               | constant_directive {
		 $$ = $1;
               }
               | echo_directive { $$ = 0; }
               | file_include { $$ = $1; }
               | code_block { $$ = $1; }
               | except_directive { $$ = $1; }
               | pragma_directive { $$ = $1; }
               | typemap_directive { $$ = $1; }
               | scope_directive {$$ = $1; }
               | type_directive { $$ = $1; }
               ;

constant_directive:
                CONSTANT ID EQUAL definetype SEMI {
		  $$ = new_node("swig:constant",$2.filename, $2.line);
		  Setattr($$,ATTR_NAME,$2.text);
		  Setattr($$,ATTR_VALUE,$4.text);
		  switch($4.ivalue) {
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
		    Delitem($4.text,0);
		    Delitem($4.text,DOH_END);
		    break;
		  case LPARSE_T_STRING:
		    Setattr($$,ATTR_TYPE,"p.char");
		    break;
		  default:
		    break;
		  }
               }
               | CONSTANT LPAREN parm RPAREN ID def_args SEMI {
		 $$ = new_node("swig:constant", $5.filename, $5.line);
		 Setattr($$,ATTR_NAME,$5.text);
		 Setattr($$,ATTR_VALUE,$6.text);
		 Setattr($$,ATTR_TYPE,Gettype($3));
               }
               ;

scope_directive: SCOPE LBRACE interface RBRACE {
		 $$ = new_node("swig:scope",$1.filename,$1.line);
		 if ($3.node) {
		   Setattr($$,ATTR_CHILD,$3.node);
		   setparent($$,$3.node);
		 }
               }
               | SCOPE LPAREN idstring RPAREN LBRACE interface RBRACE {
                 $$ = new_node("swig:scope",$1.filename,$1.line);
                 if ($6.node) {
                   Setattr($$,ATTR_CHILD,$6.node);
		   Setattr($$,ATTR_NAME,$3.text);
                   setparent($$,$6.node);
                 }
               }
               ;

echo_directive:  ECHO HBLOCK { 
		 char line[32];
		 sprintf(line,"%d",Getline($2.text));
		 Replace($2.text,"$file",Getfile($2.text),DOH_REPLACE_ANY);
		 Replace($2.text,"$line",line, DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", $2.text); 
                 }
               | ECHO STRING { 
		 char line[32];
		 sprintf(line,"%d",Getline($2.text));
		 Replace($2.text,"$file",Getfile($2.text),DOH_REPLACE_ANY);
		 Replace($2.text,"$line",line, DOH_REPLACE_ANY);
                 Printf(stderr,"%s\n", $2.text);
                 }
               ;

/* -- File inclusion directives -- */

file_include   : FILEDIRECTIVE LPAREN STRING RPAREN STRING LBRACE {
		    $1.data = new_node("swig:file",$1.filename,$1.line);
                    Setattr($1.data,ATTR_NAME,$5.text);
		    Setattr($1.data,ATTR_TYPE,$3.text);
		    LParse_set_location($5.text,0);
               } interface RBRACE {
		    LParse_set_location($6.filename,$6.line + 1);
		    $$ = $1.data;
		    if ($8.node) {
		      Setattr($$,ATTR_CHILD,$8.node);
		      setparent($$,$8.node);
		    }
               }
              ;

/* -- Code inclusion directives -- */

code_block    : INSERT LPAREN idstring RPAREN STRING {
                  $$ = new_node("swig:insert", $1.filename, $1.line);
		  Setattr($$,"filename", $5.text);
		  Setattr($$,"section",$3.text);
               }
               | INSERT LPAREN idstring RPAREN HBLOCK {
		 $$ = new_node("swig:insert",$1.filename, $1.line);
		 Setattr($$,"section",$3.text);
		 Setattr($$,"code",$5.text);
               }
              | HBLOCK {
                 $$ = new_node("swig:insert",$1.filename, $1.line);
                 Setattr($$,"code",$1.text);
	      }
              | INLINE HBLOCK {
		 DOH *pp;
		 $$ = new_node("swig:insert",$2.filename,$2.line);
		 Setattr($$,"code", $2.text);
		 Seek($2.text,0,SEEK_SET);
		 pp = Preprocessor_parse($2.text);
		 Seek(pp,0,SEEK_SET);
		 LParse_push(pp);
	       }
               ;

idstring       : ID { $$ = $1; }
               | TYPE_TYPEDEF { $$ = $1; }
               | STRING {  $$ = $1; }
               ;

/* -- Exceptions -- */

except_directive:  EXCEPT LPAREN ID RPAREN LBRACE {
                  DOH  *t;
		  t = LParse_skip_balanced('{','}');
		  $$ = new_node("swig:exception",$1.filename,$1.line);
		  Setattr($$,"lang",$3.text);
		  Setattr($$,"code",t);
		  LParse_error($1.filename,$1.line,"Warning. Language specifier in %except is now ignored.\n");
                }

/* A Generic Exception (no language specified) */
               | EXCEPT LBRACE {
                   DOH *t;
		   t = LParse_skip_balanced('{','}');
		   $$ = new_node("swig:exception",$1.filename,$1.line);
		   Setattr($$,"code",t);
               }

/* Clear an exception */
               | EXCEPT LPAREN ID RPAREN SEMI {
		 $$ = new_node("swig:exception",$1.filename,$1.line);
		 Setattr($$,"lang",$3.text);
		 LParse_error($1.filename,$1.line,"Warning. Language specifier in %except is now ignored.\n");
	       }

/* Generic clear */
               | EXCEPT SEMI {
		 $$ = new_node("swig:exception",$1.filename,$1.line);
	       }
               ; 

pragma_directive :  PRAGMA idstring pragma_arg SEMI {
                  $$ = new_node("swig:pragma",$1.filename,$1.line);
		  Setattr($$,ATTR_NAME,$2.text);
		  Setattr($$,ATTR_VALUE,$3.text);
    	       }
               | PRAGMA LPAREN idstring RPAREN idstring pragma_arg SEMI {
		 $$ = new_node("swig:pragma",$1.filename,$1.line);
		 Setattr($$,ATTR_NAME,$5.text);
		 Setattr($$,"lang",$3.text);
		 Setattr($$,ATTR_VALUE,$6.text);
	       }
               ;

pragma_arg     : idstring {
                  $$.text = $1.text;
               }
               | EQUAL idstring {
                  $$.text = $2.text;
                  /* print warning message here */
               }
               | HBLOCK {
		 $$.text = $1.text;
               }
               | empty { 
                  $$.text = 0;
               }  
               ;

/* -- Typemap directives -- */


typemap_directive: TYPEMAP LPAREN ID COMMA tm_method RPAREN tm_list tm_code {
                      DOH *o, *prev = 0, *t, *l;
		      t = $8.text;
		      $$ = 0;
		      for (l = $7; l; l = Getnext(l)) {
			o = new_node("swig:typemap",$1.filename, $1.line);
			Setattr(o,"lang",$3.text);
			Setattr(o,"method",$5.text);
			Setattr(o,"code",t);
			Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
			Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
			Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
			if (!$$) $$ = o;
			if (prev) {
			  Setattr(prev,ATTR_NEXT,o);
			}
			prev = o;
		      }
                  }

/* Create a new typemap in current language */
               | TYPEMAP LPAREN tm_method RPAREN tm_list tm_code {
                   DOH *o, *t, *l, *prev = 0;
		   /*		   t = LParse_skip_balanced('{','}');*/
		   t = $6.text;
		   $$ = 0;
		   for (l = $5; l; l = Getnext(l)) {
		     o = new_node("swig:typemap",$1.filename, $1.line);
		     Setattr(o,"method",$3.text);
		     Setattr(o,"code",t);
		     Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
		     Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
		     Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
		     if (!$$) $$ = o;
		     if (prev) Setattr(prev,ATTR_NEXT,o);
		     prev = o;
		   }
	       }

/* Clear a typemap */

               | TYPEMAP LPAREN ID COMMA tm_method RPAREN tm_list SEMI {
		   DOH *o, *l, *prev = 0;
		   $$ = 0;
		   for (l = $7; l; l = Getnext(l)) {
		      o = new_node("swig:typemap",$1.filename, $1.line);
		      Setattr(o,"lang",$3.text);
		      Setattr(o,"method",$5.text);
		      Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
		      Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
		      if (!$$) $$ = o;
		      if (prev) Setattr(prev,ATTR_NEXT,o);
		      prev = o;
		    }
	       }

/* Clear a typemap in current language */

               | TYPEMAP LPAREN tm_method RPAREN tm_list SEMI {
                   DOH *o, *l, *prev = 0;
		   $$ = 0;
		   for (l = $5; l; l = Getnext(l)) {
		     o = new_node("swig:typemap",$1.filename, $1.line);
		     Setattr(o,"method",$3.text);
		     Setattr(o,ATTR_NAME,Getattr(l,ATTR_NAME));
		     Setattr(o,ATTR_TYPE,Getattr(l,ATTR_TYPE));
		     if (!$$) $$ = o;
		     if (prev) Setattr(prev,ATTR_NEXT,o);
		     prev = o;
		   }
	       }

/* Copy a typemap */

               | TYPEMAP LPAREN ID COMMA tm_method RPAREN tm_list EQUAL tm_parm SEMI {
		 DOH *o, *l, *prev = 0;
		 $$ = 0;
		 for (l = $7; l ; l = Getnext(l)) {
		   o = new_node("swig:typemap",$1.filename, $1.line);
		   Setattr(o,"method", $5.text);
		   Setattr(o,"lang", $3.text);
		   Setattr(o,ATTR_NAME, Getattr(l,ATTR_NAME));
		   Setattr(o,ATTR_TYPE, Getattr(l,ATTR_TYPE));
		   Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
		   Setattr(o,"srcname",Getattr($9,ATTR_NAME));
		   Setattr(o,"srctype",Getattr($9,ATTR_TYPE));
		   if (!$$) $$ = o;
		   if (prev) Setattr(prev,ATTR_NEXT,o);
		   prev = o;
		 }
	       }

/* Copy typemap in current language */

               | TYPEMAP LPAREN tm_method RPAREN tm_list EQUAL tm_parm SEMI {
		 DOH *o, *l, *prev = 0;
		 $$ = 0;
		 for (l = $5; l; l = Getnext(l)) {
		   o = new_node("swig:typemap",$1.filename, $1.line);
		   Setattr(o,"method", $3.text);
		   Setattr(o,ATTR_NAME, Getattr(l,ATTR_NAME));
		   Setattr(o,ATTR_TYPE, Getattr(l,ATTR_TYPE));
		   Setattr(o,ATTR_PARMS,Getattr(l,ATTR_PARMS));
		   Setattr(o,"srcname",Getattr($7,ATTR_NAME));
		   Setattr(o,"srctype",Getattr($7,ATTR_TYPE));
		   if (!$$) $$ = o;
		   if (prev) Setattr(prev,ATTR_NEXT,o);
		   prev = o;
		 }
	       }

/* Apply directive */

               | APPLY tm_parm LBRACE tm_list RBRACE {
		 $$ = new_node("swig:apply",$1.filename, $1.line);
		 Setattr($$,ATTR_NAME,Getattr($2,ATTR_NAME));
		 Setattr($$,ATTR_TYPE,Getattr($2,ATTR_TYPE));
		 Setattr($$,ATTR_PARMS,$4);
               }

/* Clear directive */

	       | CLEAR tm_list SEMI {
		 $$ = new_node("swig:clear",$1.filename, $1.line);
		 Setattr($$,ATTR_PARMS,$2);
	       }
               ;

tm_code        : STRING {
                 $$.text = $1.text;
               }
               | LBRACE {
                 $$.text = LParse_skip_balanced('{','}');
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
                 if ($2) {
		   Setattr($1,ATTR_NEXT,$2);
                   Setattr($2,ATTR_PREV,$1);
		 }
                 $$ = $1;
		}
               ;

tm_tail        : COMMA tm_parm tm_tail {
                 if ($3) {
                   Setattr($2,ATTR_NEXT,$3);
                   Setattr($3,ATTR_PREV,$2);
                 }
                 $$ = $2;
                }
               | empty { $$ = 0; }
               ;

tm_parm        : type tm_name {
                    $$ = new_node("tmparm",Getfile($2.name),Getline($2.name));
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
		  $$ = new_node("tmparm",Getfile($3.name),Getline($3.name));
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
		  $$ = new_node("tmparm",Getfile($3.name),Getline($3.name));
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
                | type LPAREN stars tm_name RPAREN LPAREN parms RPAREN {
		  $$ = new_node("tmparm", Getfile($4.name),Getline($4.name));
		  SwigType_add_function($1,$7);
		  SwigType_push($1,$3);
		  if ($4.array) {
		    SwigType_push($1,$4.array);
		  }
		  if ($4.name)
		    Setattr($$,ATTR_NAME,$4.name);
		  Setattr($$,ATTR_TYPE,$1);
		  if ($4.parms)
		    Setattr($$,ATTR_PARMS,$4.parms);
                }
                | type stars LPAREN stars tm_name RPAREN LPAREN parms RPAREN {
		  SwigType_push($1,$2);
		  $$ = new_node("tmparm", Getfile($5.name),Getline($5.name));
		  SwigType_add_function($1,$8);
		  SwigType_push($1,$4);
		  if ($5.array) {
		    SwigType_push($1,$5.array);
		  }
		  if ($5.name)
		    Setattr($$,ATTR_NAME,$5.name);
		  Setattr($$,ATTR_TYPE,$1);
		  if ($5.parms)
		    Setattr($$,ATTR_PARMS,$5.parms);
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

type_directive  : TYPES LPAREN parms RPAREN SEMI {
                   $$ = new_node("swig:types",$1.filename,$1.line);
		   Setattr($$,"parms",$3);
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
		      Setattr($$,ATTR_NEXT,$6);
		      o = $6;
		      while (o) {
			t = Copy($2);
			SwigType_push(t,Getattr(o,ATTR_TYPE));
			Setattr(o,ATTR_TYPE,t);
			if ($1.ivalue) {
			  Setattr(o,ATTR_STORAGE,$1.text);
			}
			o = Getattr(o,ATTR_NEXT);
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
		      Setattr($$,ATTR_NEXT,$8);
		      o = $8;
		      while (o) {
			t = Copy($2);
			SwigType_push(t,Getattr(o,ATTR_TYPE));
			Setattr(o,ATTR_TYPE,t);
			if ($1.ivalue) {
			  Setattr(o,ATTR_STORAGE,$1.text);
			}
			o = Getattr(o,ATTR_NEXT);
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
		  if (pure_virtual) {
		    SetInt($$,"abstract",1);
		    pure_virtual = 0;
		  }
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
              | storage_spec NOT ID LPAREN parms RPAREN cpp_end {
		$$ = new_node("c:destructor",$3.filename,$3.line);
		Setattr($$,ATTR_NAME,$3.text);
		if ($7.text) {
		  Setattr($$,"code",$7.text);
		}
		if (pure_virtual) {
		  SetInt($$,"abstract",1);
		  pure_virtual = 0;
		}
		if ($1.ivalue) {
		  Setattr($$,ATTR_STORAGE,$1.text);
		}
	      }
              | storage_spec NOT ID LPAREN parms RPAREN cpp_const SEMI {
		$$ = new_node("c:destructor",$3.filename,$3.line);
		Setattr($$,ATTR_NAME,$3.text);
		if ($1.ivalue) {
		  Setattr($$,ATTR_STORAGE,$1.text);
		}
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
		   Setattr($$,ATTR_NEXT, $5);
	       }
               | COMMA declaration LPAREN parms RPAREN stail {
		 DOH *t = NewString("");
		 SwigType_push(t,$2.decl);
		 $$ = new_node(TAG_FUNCTION, Getfile($2.id), Getline($2.id));
		 Setattr($$,ATTR_NAME,$2.id);
		 Setattr($$,ATTR_PARMS,$4);
		 Setattr($$,ATTR_TYPE, t);
		 if ($6)
		   Setattr($$,ATTR_NEXT,$6);
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
               | VIRTUAL {
                   $$.ivalue = 1;
                   $$.text = NewString("virtual");
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
                    $$ = new_node("c:enum", $2.filename,$2.line);
		    Setattr($$,ATTR_NAME,$3.text);
		    Setattr($$,ATTR_CHILD,$5.node);
		    setparent($$,$5.node);
		    /* Add typename */
                 }

/* A typdef'd enum.  Pretty common in C headers */

               | TYPEDEF ENUM ename LBRACE enumlist RBRACE ID SEMI { 
   		   $$ = new_node("c:enum",$2.filename,$2.line);
		   Setattr($$,ATTR_NAME,$3.text);
		   Setattr($$,ATTR_CHILD,$5.node);
		   setparent($$,$5.node);
		   /* Add typedef for enum */
		   {
		     DOH *o;
		     o = new_node("c:typedef",$7.filename,$7.line);
		     Setattr(o,ATTR_NAME,$7.text);
		     Setattr(o,ATTR_TYPE,$3.text);
		     Setattr($$,ATTR_NEXT,o);
		   }
	       }
               ;

/* Some stuff for handling enums */

ename          :  ID { $$ = $1; } 
               |  empty { $$.text = NewString(""); }
               ;

enumlist       :  enumlist COMMA edecl { 
                   Setattr($1.last,ATTR_NEXT,$3);
		   $1.last = $3;
		   $$ = $1;
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
                    DOH *t, *d, *o, *prev;
		    int i;
                    $$ = new_node("c:typedef", $1.filename,$1.line);
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
		      o = new_node("c:typedef",$1.filename,$1.line);
		      ty = Copy(t);
		      SwigType_push(ty,Getattr(d,"decl"));
		      SwigType_push(ty,Getattr(d,"array"));
		      Setattr(o,ATTR_TYPE,ty);
		      Setattr(o,ATTR_NAME,Getattr(d,ATTR_NAME));
		      Setattr(prev,ATTR_NEXT,o);
		      prev = o;
		    }
		    Delete($5);
               }

/* A rudimentary typedef involving function pointers */

               | TYPEDEF type LPAREN starparm RPAREN LPAREN parms RPAREN SEMI {
		 $$ = new_node("c:typedef", $1.filename,$1.line);
		 SwigType_add_function($2,$7);
		 if ($4.stars)
		   SwigType_push($2,$4.stars);
		 if ($4.array)
		   SwigType_push($2,$4.array);
		 Setattr($$,ATTR_NAME,$4.name);
		 Setattr($$,ATTR_TYPE,$2);
	       }

/* A typedef involving function pointers again */

               | TYPEDEF type stars LPAREN starparm RPAREN LPAREN parms RPAREN SEMI {
		 $$ = new_node("c:typedef", $1.filename,$1.line);
		 SwigType_push($2,$3);
		 SwigType_add_function($2,$8);
		 if ($5.stars)
		   SwigType_push($2,$5.stars);
		 if ($5.array)
		   SwigType_push($2,$5.array);
		 Setattr($$,ATTR_NAME,$5.name);
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

cpp_decl     : cpp_class { 
		String *name;
		DOH    *cls;
		$$ = $1; 
		/* Save a copy of the class */
		name = Getattr($$,"altname");
		if (!name) {
		  name = Getname($$);
		}
		cls = Getattr(class_hash,name);
		if (cls) {
		  /* We already saw this class.  If the previous class really was a class,
                     we'll generate an error.  If the class was an added method instead,
                     we'll add those methods to our class */
		  String *tag = Gettag(cls);
		  if (Cmp(tag,"c:class") == 0) {
		    /* Already saw this */
		    Printf(stderr,"%s:%d. Class '%s' previously defined.\n", Getfile($$),Getline($$),name);
		    $$ = 0;
		  } else {
		    /* Hmmm. Must have been an added method.  Attach to the end of my children */
		    Swig_node_append_child($$,cls);
		    Setattr(class_hash,name,$$);
		  }
		} else {
		  Setattr(class_hash,name,$$);
		}
             }
             | cpp_other { $$ = $1; }
             ;
  
cpp_class    :  storage_spec cpptype ID inherit LBRACE interface RBRACE opt_id SEMI {
                   $$ = new_node("c:class",$3.filename,$3.line);
		   Setattr($$,"classtype",$2.text);
		   Setattr($$,ATTR_NAME,$3.text);
		   Setattr($$,"bases", $4);
		   Setattr($$,"namespace",$3.text);
		   if ($6.node) {
		     Setattr($$,ATTR_CHILD,$6.node);
		     setparent($$,$6.node);
		   }
		   if ($8.text) {
		     Setattr($$,TAG_VARIABLE,$8.text);
		   }
	      }

              | storage_spec cpptype LBRACE interface RBRACE opt_id SEMI {
		  $$ = new_node("c:class",$3.filename,$3.line);
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
	       $$ = new_node("c:class",$3.filename,$3.line);
	       Setattr($$,"classtype",$2.text);
	       Setattr($$,ATTR_NAME,$3.text);
	       Setattr($$,"bases",$4);
	       Setattr($$,"namespace",$3.text);
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
		 o = new_node("c:typedef",$3.filename,$3.line);
		 Setattr(o,ATTR_NAME,$8.id);
		 t = Copy($3.text);
		 SwigType_push(t,$8.decl);
		 Setattr(o,ATTR_TYPE,t);
		 Setattr($$,ATTR_NEXT,o);
		 prev = o;
		 for (i = 0; i < Len($9); i++) {
		   d = Getitem($9,i);
		   o = new_node("c:typedef",$3.filename,$3.line);
		   t = Copy($3.text);
		   SwigType_push(t,Getattr(d,"decl"));
		   SwigType_push(t,Getattr(d,"array"));
		   Setattr(o,ATTR_TYPE,t);
		   Setattr(o,ATTR_NAME,Getattr(d,ATTR_NAME));
		   Setattr(prev,ATTR_NEXT,o);
		   prev = o;
		 }
		 Delete($9);
	       }
	     } 

/* An unnamed struct with a typedef */

             | TYPEDEF cpptype LBRACE interface RBRACE declaration typedeflist {
	       $$ = new_node("c:class",$3.filename,$3.line);
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
		   pure_virtual = 0;
               }
               | EQUAL definetype SEMI {
                   $$.text = 0;
		   pure_virtual = 1;
    	       }
/*               | cpp_const { 
                   $$.text = 0;
		   pure_virtual = 0;
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
                 DOH *o = new_node("c:classdecl",$4.filename,$4.line);
                 Setattr(o,ATTR_NAME,$3.text);
	     }   
             | PUBLIC COLON { 
                 $$ = new_node("c:access",$1.filename,$1.line);
                 Setattr($$,ATTR_NAME,"public");
	     }
             | PRIVATE COLON { 
                 $$ = new_node("c:access",$1.filename,$1.line);
                 Setattr($$,ATTR_NAME,"private");
             }
             | PROTECTED COLON {
                 $$ = new_node("c:access",$1.filename,$1.line);
                 Setattr($$,ATTR_NAME,"protected");
             }

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
	        $$ = new_node("swig:addmethods",$1.filename,$1.line);
 		if ($4.node) {
		  Setattr($$,ATTR_CHILD,$4.node);
		  setparent($$,$4.node);
		}
		if ($2.text) {
		  DOH *cls;
		  Setattr($$,ATTR_NAME,$2.text);
		  /* A named addmethods directive.   If not in a class. We have to save */
		  cls = Getattr(class_hash,$2.text);
		  if (cls) {
		    /* Hmmm. A class or addmethods directive was already found */
		    String *tag = Gettag(cls);
		    if (Cmp(tag,"swig:addmethods") == 0) {
		      /* We need to append our methods to previous methods */
		      Swig_node_append_child(cls,$4.node);
		      setparent(cls,$4.node);
		      $$ = 0;
		    } else {
		      /* No. This must be a class.  We'll add ourselves to it */
		      Swig_node_append_child(cls,$$);
		      $$ = 0;
		    }
		  } else {
		    /* Nothing previously defined. Save ourselves */
		    Setattr(class_hash,$2.text,$$);
		    $$ = 0;
		  }
		}
	     }
             ;

opt_id       : ID { $$ = $1; }
             | empty { $$.text = 0; }
             ;

/* =============================================================================
 *                  -- Generic (admittedly poor) C Parsing --
 * ============================================================================= */

/* -- Function parameter lists -- */

parms          : parm ptail {
                  if ($2) {
                    Setattr($1,ATTR_NEXT,$2);
                    Setattr($2,ATTR_PREV,$1);
                  }
		  $$ = $1;
               }
               | empty { $$ = 0; }
               ;

ptail          : COMMA parm ptail {
                 if ($3) {
		   Setattr($2,ATTR_NEXT,$3);
		   Setattr($3,ATTR_PREV,$2);
		 }
		 $$ = $2;
                }
               | empty { $$ = 0; }
               ;

parm           : type pname {
                   $$ = new_node("parm",Getfile($2.name),Getline($2.name));
		   Setattr($$,ATTR_NAME,$2.name);
		   SwigType_push($1,$2.array);
		   if ($2.value)
		     Setattr($$,ATTR_VALUE,$2.value);
		   Setattr($$,ATTR_TYPE,$1);
                }
                | type stars pname {
		  $$ = new_node("parm",Getfile($3.name),Getline($3.name));
		  Setattr($$,ATTR_NAME,$3.name);
		  SwigType_push($1,$2);
		  SwigType_push($1,$3.array);
		  if ($3.value) {
		    Setattr($$,ATTR_VALUE,$3.value);
		  }
		  Setattr($$,ATTR_TYPE,$1);
		}
                | type AND pname {
		  $$ = new_node("parm",Getfile($3.name),Getline($3.name));
		  SwigType_add_reference($1);
		  SwigType_push($1,$3.array);
		  Setattr($$,ATTR_NAME,$3.name);
		  if ($3.value) {
		    Setattr($$,ATTR_VALUE,$3.value);
		  }
		  Setattr($$,ATTR_TYPE,$1);
		}
                | type LPAREN stars pname RPAREN LPAREN parms RPAREN {
		  $$ = new_node("parm",$2.filename, $2.line);
		  SwigType_add_function($1,$7);
		  SwigType_push($1,$3);
		  if ($4.array)
		    SwigType_push($1,$4.array);
		  Setattr($$,ATTR_NAME,$4.name);
		  if ($4.value)
		    Setattr($$,ATTR_VALUE,$4.value);
		  Setattr($$,ATTR_TYPE,$1);
		}
                | type stars LPAREN stars pname RPAREN LPAREN parms RPAREN {
		  $$ = new_node("parm",$3.filename, $3.line);
		  SwigType_push($1,$2);
		  SwigType_add_function($1,$8);
		  SwigType_push($1,$4);
		  if ($5.array)
		    SwigType_push($1,$5.array);
		  Setattr($$,ATTR_NAME,$5.name);
		  if ($5.value)
		    Setattr($$,ATTR_VALUE,$5.value);
		  Setattr($$,ATTR_TYPE,$1);
		}
                | PERIOD PERIOD PERIOD {
		  $$ = new_node("parm",$1.filename,$1.line);
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
		 $$.text = NewStringf("&%s", $3.text);
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

/* Used for typenames with or without pointers */

starparm      : stars pname {
		 $$.name = $2.name;
		 $$.array = $2.array;
		 $$.stars = $1;
               }
              | pname {
                 $$.name = $1.name;          
		 $$.array = $1.array;
                 $$.stars = 0;
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
		 $$ = NewStringf("%s::%s",$1.text,$3.text);
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
                | ID {
		  $$.text = $1.text;
                  $$.ivalue = LPARSE_T_ERROR;
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
               | MINUS expr %prec UMINUS {
		 $$.text = NewString("");
		 Printf($$.text,"-%s", $2.text);
		 $$.ivalue = $2.ivalue;
	       }
               | NOT expr {
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











