%{
/* ----------------------------------------------------------------------------- 
 * parser.y
 *
 *     YACC grammar for Dave's lame parser.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#define yylex lparse_yylex
#define yyerror lparse_yyerror
#define yyparse lparse_yyparse
#define yylval  lparse_yylval
#define yychar  lparse_yychar
#define yynerrs lparse_yynerrs
 
extern int lparse_yylex();
extern void LParse_strict_type(int);

void   yyerror (char *s);       

#include "lparse.h"
#include "preprocessor.h"

#define CPLUS_PRIVATE 1
#define CPLUS_PUBLIC  2

static DOH      *top = 0;
static int       readonly = 0;
static DOH      *swig_rename = 0;
static LParseType *Active_typedef = 0;
static LParseType *Active_type = 0;
static DOH      *Active_extern = 0;
static DOH      *name_hash = 0;
static int       NewObject = 0;
static int       cplus_mode = CPLUS_PUBLIC;
static DOH      *nested = 0;
static int       Intype = 0;

/* LParse_parse() - Main entry point to the C parser */
 DOH *LParse_parse(DOH *str) {
   int yyparse();
   DOH *tp;
   LParse_push(str);
   top = NewHash();
   nested = NewList();
   Setattr(top, "tag", "IncludeFile");
   Setattr(top,"name", Getfile(str));
   name_hash = NewHash();
   tp = top;
   yyparse();
   return tp;
 }

 static void add_child(DOH *o) {
   DOH *child;
   assert(top);
   
   child = Getattr(top,"children");
   if (!child) {
     child = NewList();
     Setattr(top,"children", child);
   }
   Setattr(o,"parent", top);
   Append(child,o);
 }

 static void apply_modifier(DOH *o) {
   DOH *n;
   if (swig_rename) {
     Setattr(o,"rename",swig_rename);
   }
   n = Getattr(name_hash,Getattr(o,"name"));
   if (n) {
     Setattr(o,"rename",n);
   }
   if (NewObject) Setattr(o,"new",DohNone);
   NewObject = 0;
   swig_rename = 0;
 }

 static DOH *new_node(char *tag, DOH *file, int line) {
   DOH *o;
   o = NewHash();
   Setattr(o,"tag",tag);
   Setline(o,line);
   Setfile(o,file);
   add_child(o);
   return o;
 }

 static void dump_nested(DOH *name) {
   int i;
   for (i = 0; i < Len(nested); i++) {
     DOH *code;
     LParseType *t;
     DOH *o = Getitem(nested,i);
     code = Getattr(o,"code");
     Replace(code,"$classname",name,DOH_REPLACE_ANY);
     t = (LParseType *) Getattr(o,"type");
     sprintf(t->name,"%s_%s",Char(name),Char(Getattr(o,"name")));
     o = new_node("HeaderBlock",Getfile(code),Getline(code));
     Setattr(o,"text",code);
     o = new_node("MemberData",Getfile(code),Getline(code));
     Setattr(o,"name",Getattr(o,"name"));
     Setattr(o,"type",t);
     Seek(code,0,SEEK_SET);
     /*     Printf(stderr,"NESTED : %s\n", code); */
     LParse_push(code);
   }
   Clear(nested);
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
  LParseType *type;
  struct {
    DOH    *id;
    int     is_pointer;
    int     is_reference;
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
%token <tok> CLASS FRIEND OPERATOR PRIVATE PROTECTED PUBLIC TEMPLATE THROW VIRTUAL

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

%type <tok> idstring idtype cpptype template_decl stars array array2 expr definetype def_args extern_spec func_end tm_method pragma_arg ename
%type <tok> base_specifier access_specifier cpp_end ctor_end stylearg
%type <node> file_include_type parm parms ptail tm_tail tm_list tm_parm tm_args idlist inherit base_list stylelist styletail
%type <type> type realtype opt_signed opt_unsigned
%type <decl> declaration nested_decl
%type <pname> pname
%type <tmname> tm_name 

%%

/* The productions of the grammar with their
   associated semantic actions. */

interface      : interface statement { }
               | empty { }
               ;

statement      : swig_directive { Intype = 0; }
               | c_declaration { Intype = 0; }
               | LBRACE {
                    DOH *o = new_node("Scope",$1.filename,$1.line);
		    top = o;
               } interface RBRACE {
                    top = Getattr(top,"parent");
               }
               | SEMI { }
               | error { }
               ;

/* =============================================================================
 *                          -- SWIG DIRECTIVES --
 * ============================================================================= */
swig_directive : MODULE idstring {
                   if (!Getattr(top,"module")) {
		     Setattr(top,"module",$2.text);
		   }
               }
               | MACRO idtype COMMA STRING COMMA NUM_INT LBRACE {
		 LParse_macro_location($2.text,$1.filename,$1.line);
		 LParse_set_location($4.text, atoi(Char($6.text))-1);
               } interface RBRACE { 
		 LParse_macro_location(0,0,0);
		 LParse_set_location($7.filename,$7.line-1);
	       }

               | RENAME ID ID SEMI { Setattr(name_hash,$2.text,$3.text); }
               | CONSTANT ID definetype SEMI {
		  DOH *o = new_node("Constant",$2.filename, $2.line);
		  Setattr(o,"name",$2.text);
		  Setattr(o,"value",$3.text);
		  SetInt(o,"type",$3.ivalue);
		  apply_modifier(o);
               }
               | ECHO HBLOCK { Printf(stderr,"%s\n", $2.text); }
               | ECHO STRING { Printf(stderr,"%s\n", $2.text); }
               | file_include 
               | code_block 
               | doc_directive
               | typemap_directive
	       | except_directive
	       | pragma_directive
	       | modifier_directive
	       | native_directive
               | TYPE ID idlist SEMI {
		 DOH *l;
		 LParseType *t;
		 int i;
		 Insert($3,0,$2.text);
		 for (i = 0; i < Len($3); i++) {
		   l = Getitem($3,i);
		   t = NewLParseType(LPARSE_T_USER);
		   LParse_typedef_add(t,l);
		 }
	       }
               ;

/* -- File inclusion directives -- */

file_include   : file_include_type STRING LBRACE {
                    Setattr($1,"name",$2.text);
                    top = $1;
		    LParse_set_location($2.text,0);
               } interface RBRACE {
                    top = Getattr(top,"parent");
		    LParse_set_location($3.filename,$3.line + 1);
               }

file_include_type : INCLUDE { $$ = new_node("IncludeFile",$1.filename,$1.line); }
               | WEXTERN { $$ = new_node("ExternFile",$1.filename,$1.line); }
               | IMPORT { $$ = new_node("ImportFile", $1.filename,$1.line); }
               ;

/* -- Modifier directives -- */

modifier_directive : READONLY { readonly = 1; }
               | READWRITE { readonly = 0; }
               | NAME LPAREN idstring RPAREN { swig_rename = Copy($3.text); } statement {  swig_rename = 0; }
               | NEW { NewObject = 1; } statement { NewObject = 0; }
               ;

/* -- Code inclusion directives -- */

code_block    : HBLOCK {
		 DOH *o = new_node("HeaderBlock",$1.filename,$1.line);
		 Setattr(o,"text", $1.text);
               }
               | WRAPPER HBLOCK {
                 DOH *o = new_node("WrapperBlock",$2.filename,$2.line);
                 Setattr(o,"text",$2.text);
	       }
               | INIT HBLOCK {
                 DOH *o = new_node("InitBlock",$2.filename,$2.line);
                 Setattr(o,"text",$2.text);
               }
               | INLINE HBLOCK {
		 DOH *pp;
		 DOH *o = new_node("HeaderBlock",$2.filename,$2.line);
		 Setattr(o,"text", $2.text);
		 Seek($2.text,0,SEEK_SET);
		 pp = Preprocessor_parse($2.text);
		 Seek(pp,0,SEEK_SET);
		 LParse_push(pp);
	       }
               ;

/* -- Documentation directives -- */

doc_directive  : DOC_ENABLE { 
		 new_node("DocEnable",$1.filename,$1.line);
               }
               | DOC_DISABLE { 
                 new_node("DocDisable",$1.filename,$1.line);
	       }

/* %title directive */

               | TITLE STRING styletail {
		 DOH *o = new_node("Title",$1.filename,$1.line);
		 Setattr(o,"text",$2.text);
		 Setattr(o,"parms",$3);
	       } 

/* %section directive */

               | SECTION STRING styletail {
		 DOH *o = new_node("Section",$1.filename,$1.line);
		 Setattr(o,"text",$1.text);
		 Setattr(o,"parms",$3);
	       }

/* %subsection directive */
               | SUBSECTION STRING styletail {
		 DOH *o = new_node("SubSection",$1.filename,$1.line);
		 Setattr(o,"text",$1.text);
		 Setattr(o,"parms",$3);
	       }

/* %subsubsection directive */
               | SUBSUBSECTION STRING styletail {
		 DOH *o = new_node("SubSubSection",$1.filename,$1.line);
		 Setattr(o,"text",$1.text);
		 Setattr(o,"parms",$3);
	       }

/* %text directive */

               | TEXT HBLOCK {
		 DOH *o = new_node("Text",$1.filename,$1.line);
		 Setattr(o,"text",$2.text);
	       }

/* Disable code generation */
               | DOCONLY { }


/* %style directive.   This applies to all current styles */

               | STYLE stylelist {
		 DOH *o = new_node("Style",$1.filename,$1.line);
		 Setattr(o,"parms",$2);
	       }

/* %localstyle directive.   This applies only to the current style */

               | LOCALSTYLE stylelist {
		 DOH *o = new_node("LocalStyle",$1.filename,$1.line);
		 Setattr(o,"parms",$2);
	       }

/* Documentation style list */

stylelist      : ID stylearg styletail {
                    DOH *o;
		    o = NewHash();
		    Setattr(o,"name",$1.text);
		    Setattr(o,"value",$2.text);
		    Insert($3,0,o);
		    $$ = $3;
                 }
               ;

styletail      : styletail COMMA ID stylearg {
                    DOH *o;
                    $$ = $1;
		    o = NewHash();
		    Setattr(o,"name",$3.text);
		    Setattr(o,"value",$4.text);
                 }
               | empty {
                    $$ = NewList();
	       }
               ;

stylearg       : EQUAL NUM_INT {
                     $$ = $2;
                 }
               | EQUAL STRING {
                     $$ = $2;
	       }
               | empty { 
                     $$.text = 0;
                }
               ;

idstring       : ID { $$ = $1; }
               | TYPE_TYPEDEF { $$ = $1; }
               | STRING {  $$ = $1; }
               ;

/* -- Typemap directives -- */


typemap_directive: TYPEMAP LPAREN idtype COMMA tm_method RPAREN tm_list LBRACE {
                      DOH *o, *t, *l;
		      int i;
		      t = LParse_skip_balanced('{','}');
		      for (i = 0; i < Len($7); i++) {
			l = Getitem($7,i);
			o = new_node("Typemap",$1.filename, $1.line);
			Setattr(o,"lang",$3.text);
			Setattr(o,"method",$5.text);
			Setattr(o,"code",t);
			Setattr(o,"name",Getattr(l,"name"));
			Setattr(o,"type",Getattr(l,"type"));
			Setattr(o,"parms",Getattr(l,"parms"));
		      }
                    }

/* Create a new typemap in current language */
               | TYPEMAP LPAREN tm_method RPAREN tm_list LBRACE {
                   DOH *o, *t, *l;
		   int i;
		   t = LParse_skip_balanced('{','}');
		   for (i = 0; i < Len($5); i++) {
		     l = Getitem($5,i);
		     o = new_node("Typemap",$1.filename, $1.line);
		     Setattr(o,"method",$3.text);
		     Setattr(o,"code",t);
		     Setattr(o,"name",Getattr(l,"name"));
		     Setattr(o,"type",Getattr(l,"type"));
		     Setattr(o,"parms",Getattr(l,"parms"));
		   }
	       }

/* Clear a typemap */

               | TYPEMAP LPAREN idtype COMMA tm_method RPAREN tm_list SEMI {
		 DOH *o, *l;
		   int i;
		    for (i = 0; i < Len($7); i++) {
		      l = Getitem($7,i);
		      o = new_node("TypemapClear",$1.filename, $1.line);
		      Setattr(o,"lang",$3.text);
		      Setattr(o,"method",$5.text);
		      Setattr(o,"name",Getattr(l,"name"));
		      Setattr(o,"type",Getattr(l,"type"));
		    }
	       }

/* Clear a typemap in current language */

               | TYPEMAP LPAREN tm_method RPAREN tm_list SEMI {
                   DOH *o, *l;
		   int i;
		   for (i = 0; i < Len($5); i++) {
		     l = Getitem($5,i);
		     o = new_node("TypemapClear",$1.filename, $1.line);
		     Setattr(o,"method",$3.text);
		     Setattr(o,"name",Getattr(l,"name"));
		     Setattr(o,"type",Getattr(l,"type"));
		   }
	       }

/* Copy a typemap */

               | TYPEMAP LPAREN idtype COMMA tm_method RPAREN tm_list EQUAL tm_parm SEMI {
		 DOH *o, *l;
		 int i;
		 for (i = 0; i < Len($7); i++) {
		   l = Getitem($7,i);
		   o = new_node("TypemapCopy",$1.filename, $1.line);
		   Setattr(o,"method", $5.text);
		   Setattr(o,"lang", $3.text);
		   Setattr(o,"name", Getattr(l,"name"));
		   Setattr(o,"type", Getattr(l,"type"));
		   Setattr(o,"parms",Getattr(l,"parms"));
		   Setattr(o,"srcname",Getattr($9,"name"));
		   Setattr(o,"srctype",Getattr($9,"type"));
		 }
	       }

/* Copy typemap in current language */

               | TYPEMAP LPAREN tm_method RPAREN tm_list EQUAL tm_parm SEMI {
		 DOH *o, *l;
		 int i;
		 for (i = 0; i < Len($5); i++) {
		   l = Getitem($5,i);
		   o = new_node("TypemapCopy",$1.filename, $1.line);
		   Setattr(o,"method", $3.text);
		   Setattr(o,"name", Getattr(l,"name"));
		   Setattr(o,"type", Getattr(l,"type"));
		   Setattr(o,"parms",Getattr(l,"parms"));
		   Setattr(o,"srcname",Getattr($7,"name"));
		   Setattr(o,"srctype",Getattr($7,"type"));
		 }
	       }

/* Apply directive */

               | APPLY tm_parm LBRACE tm_list RBRACE {
		 DOH *o;
		 o = new_node("Apply",$1.filename, $1.line);
		 Setattr(o,"name",Getattr($2,"name"));
		 Setattr(o,"type",Getattr($2,"type"));
		 Setattr(o,"parms",$4);
               }

/* Clear directive */

	       | CLEAR tm_list SEMI {
		 DOH *o;
		 o = new_node("ClearApply",$1.filename, $1.line);
		 Setattr(o,"parms",$2);
	       }
               ;

tm_method      : idtype {
                 $$ = $1;
               } 
               | CONST {
                 $$.text = NewString("const");
               }
               ;


tm_list        : tm_parm tm_tail {
                 Append($2,$1);
		 $$ = $2;
		}
               ;

tm_tail        : COMMA tm_parm tm_tail {
                 Append($2,$3);
                 $$ = $3;
                }
               | empty { $$ = NewList(); }
               ;

tm_parm        : type tm_name {
                    $$ = NewHash();
		    if ($2.array) {
		      $1->is_pointer++;
		      $1->arraystr = Swig_copy_string(Char($2.array));
		    }
		    Setattr($$,"type",$1);
		    if ($2.name)
		      Setattr($$,"name",$2.name);
		    if ($2.parms)
		      Setattr($$,"parms",$2.parms);
                }
                | type stars tm_name {
		  $$ = NewHash();
		  $1->is_pointer += $2.ivalue;
		  if ($3.array) {
		    $1->is_pointer++;
		    $1->arraystr = Swig_copy_string(Char($3.array));
		  }
		  Setattr($$,"type",$1);
		  if ($3.name)
		    Setattr($$,"name",$3.name);
		  if ($3.parms)
		    Setattr($$,"parms",$3.parms);
		}
                | type AND tm_name {
		  $$ = NewHash();
		  $1->is_reference = 1;
		  $1->is_pointer++;
		  if ($3.array) {
		    $1->is_pointer++;
		    $1->arraystr = Swig_copy_string(Char($3.array));
		  }
		  Setattr($$,"type",$1);
		  if ($3.name)
		    Setattr($$,"name",$3.name);
		  if ($3.parms)
		    Setattr($$,"parms",$3.parms);
		}
		;

tm_name         : ID tm_args {
                $$.parms = $2;
		$$.name = $1.text;
		$$.array = 0;
               }
               | ID array tm_args { 
                $$.name = $1.text;
		$$.array = $2.text;
		$$.parms = $3;
	       }
               | array tm_args { 
		 $$.name = 0;
		 $$.array = $1.text;
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


/* -- Exceptions -- */

except_directive:  EXCEPT LPAREN idtype RPAREN LBRACE {
                  DOH *o, *t;
		  t = LParse_skip_balanced('{','}');
		  o = new_node("Exception",$1.filename,$1.line);
		  Setattr(o,"lang",$3.text);
		  Setattr(o,"code",t);
                }

/* A Generic Exception (no language specified */
               | EXCEPT LBRACE {
                   DOH *o, *t;
		   t = LParse_skip_balanced('{','}');
		   o = new_node("Exception",$1.filename,$1.line);
		   Setattr(o,"code",t);
               }

/* Clear an exception */
               | EXCEPT LPAREN idtype RPAREN SEMI {
		 DOH *o;
		 o = new_node("ExceptionClear",$1.filename,$1.line);
		 Setattr(o,"lang",$3.text);
	       }

/* Generic clear */
               | EXCEPT SEMI {
		 new_node("ExceptionClear",$1.filename,$1.line);
	       }
               ; 


pragma_directive :  PRAGMA ID pragma_arg SEMI {
                  DOH *o = new_node("Pragma",$1.filename,$1.line);
		  Setattr(o,"name",$2.text);
		  Setattr(o,"value",$3.text);
    	       }
               | PRAGMA LPAREN ID RPAREN ID pragma_arg SEMI {
		 DOH *o = new_node("Pragma",$1.filename,$1.line);
		 Setattr(o,"name",$5.text);
		 Setattr(o,"lang",$3.text);
		 Setattr(o,"value",$6.text);
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

native_directive : NATIVE LBRACE {
                  DOH *o = new_node("Native",$1.filename,$1.line);
		  top = o;
                  } interface RBRACE {
                  top = Getattr(top,"parent");
    	          }
                ;

/* =============================================================================
 *                       -- C Declarations -- 
 * ============================================================================= */

c_declaration   : variable_decl
                | function_decl
                | enum_decl
                | typedef_decl 
                | cpp_decl
                | STATIC { LParse_skip_decl(); }
                ;

/* A variable declaration */

variable_decl   : extern_spec type declaration array2 def_args {
                    DOH *o;
                    Active_type = (LParseType *) Copy($2);
                    Active_extern = $1.text;
		    $2->is_pointer += $3.is_pointer;
		    if ($4.text) {
		      $2->is_pointer++;
                      $2->arraystr = Swig_copy_string(Char($4.text));
		    }
		    $2->is_reference = $3.is_reference;
		    o = new_node("Variable", Getfile($3.id),Getline($3.id));
		    Setattr(o,"name",$3.id);
		    Setattr(o,"type",$2);
		    if ($1.ivalue) {
		      Setattr(o,"extern",$1.text);
		    }
		    if ($5.text)
		      Setattr(o,"value",$5.text);
		    if (readonly)
		      Setattr(o,"readonly",DohNone);

		    apply_modifier(o);
                  } stail { }

/* Global variable that smells like a function pointer */

                | extern_spec type LPAREN STAR { 
		  LParse_error($3.filename,$3.line,"Pointer to function not currently supported.\n");
		  LParse_skip_decl();
		}
                ;


/* A function declaration */

function_decl  : extern_spec type declaration LPAREN parms RPAREN cpp_const {
                    DOH *o;
                    Active_type = (LParseType *) Copy($2);
		    Active_extern = $1.text;
		    $2->is_pointer += $3.is_pointer;
		    $2->is_reference = $3.is_reference;
		    o = new_node("Function",Getfile($3.id),Getline($3.id));
		    Setattr(o,"name",$3.id);
		    Setattr(o,"type",$2);
		    Setattr(o,"parms",$5);
		    if ($1.ivalue) {
		      Setattr(o,"extern", $1.text);
		    }
		    apply_modifier(o);
                 } stail { } 
               
/* A function declaration with code after it */

                | extern_spec type declaration LPAREN parms RPAREN func_end {
		  DOH *o;
		  Active_type = (LParseType *) Copy($2);
		  Active_extern = $1.text;
		  $2->is_pointer += $3.is_pointer;
		  $2->is_reference = $3.is_reference;
		  o = new_node("Function",Getfile($3.id),Getline($3.id));
		  Setattr(o,"name",$3.id);
		  Setattr(o,"type",$2);
		  Setattr(o,"parms",$5);
		  if ($1.ivalue) {
		    Setattr(o,"extern", $1.text);
		  }
		  if ($7.text)
		    Setattr(o,"code",$7.text);
		  apply_modifier(o);
		};

/* A function declared without any return datatype */

                | extern_spec declaration LPAREN parms RPAREN cpp_const { 
		  DOH *o;
		  LParseType *t = NewLParseType(LPARSE_T_INT);
		  Active_type = (LParseType *) Copy(t);
		  Active_extern = $1.text;
		  t->is_pointer += $2.is_pointer;
		  t->is_reference = $2.is_reference;
		  o = new_node("Function", Getfile($2.id),Getline($2.id));
		  Setattr(o,"name",$2.id);
		  Setattr(o,"type",t);
		  Setattr(o,"parms",$4);
		  if ($1.ivalue) {
		    Setattr(o,"extern", $1.text);
		  }
		  apply_modifier(o);
                } stail { };

/* A function with an explicit inline directive. Not safe to use inside a %inline block */

                | INLINE type declaration LPAREN parms RPAREN func_end {
		  DOH *o;
		  $2->is_pointer += $3.is_pointer;
		  $2->is_reference = $3.is_reference;
		  o = new_node("Function",Getfile($3.id),Getline($3.id));
		  Setattr(o,"name",$3.id);
		  Setattr(o,"type",$2);
		  Setattr(o,"parms",$5);
		  Setattr(o,"inline",NewString(""));
		  if ($7.text) {
		    Setattr(o,"code",$7.text);
		  }
		  apply_modifier(o);
		}
                ;

/* Allow lists of variables and functions to be built up */

stail          : SEMI { }
               | COMMA declaration array2 def_args {
		 DOH *o;
		 LParseType *t = (LParseType *) Copy(Active_type);
		 t->is_pointer += $2.is_pointer;
		 if ($3.text) {
		     t->is_pointer++;
		     t->arraystr = Swig_copy_string(Char($3.text));
		 }
		 t->is_reference = $2.is_reference;
		 o = new_node("Variable", Getfile($2.id),Getline($2.id));
		 Setattr(o,"name",$2.id);
		 Setattr(o,"type",t);
		 if (Active_extern) {
		   Setattr(o,"extern",Active_extern);
		 }
		 if ($4.text)
		   Setattr(o,"value",$4.text);
		 apply_modifier(o);
		 if (readonly)
		   Setattr(o,"readonly",DohNone);
	       } stail { } 
               | COMMA declaration LPAREN parms RPAREN {
		 DOH *o;
		 LParseType *t = (LParseType *) Copy(Active_type);
		 t->is_pointer += $2.is_pointer;
		 t->is_reference = $2.is_reference;
		 o = new_node("Function", Getfile($2.id), Getline($2.id));
		 Setattr(o,"name",$2.id);
		 Setattr(o,"parms",$4);
		 Setattr(o,"type", t);
		 if (Active_extern) {
		   Setattr(o,"extern",Active_extern);
		 }
		 apply_modifier(o);
	       } stail { }
              ;

extern_spec    : EXTERN { 
                   $$.ivalue = 1; 
		   $$.text = NewString("");
                }
               | EXTERN STRING {
                   $$.ivalue = 1;
		   $$.text = $2.text;
	       }
               | empty {
                   $$.ivalue = 0;
		   $$.text = 0;
               }
               ;
                 
func_end       : cpp_const LBRACE { $$.text = LParse_skip_balanced('{','}'); }
               ;

cpp_const      : CONST {} 
               | THROW LPAREN { LParse_skip_balanced('(',')'); }
               | empty {}
               ;

/* Enumerations */

enum_decl      : extern_spec ENUM ename LBRACE {
                    DOH *o;
		    o = new_node("Enumeration",$2.filename,$2.line);
		    Setattr(o,"name",$2.text);
		    top = o;
                 } enumlist RBRACE SEMI {
 		    LParseType *t;
                    top = Getattr(top,"parent");
		    t = NewLParseType(LPARSE_T_ENUM);
		    LParse_typedef_add(t,$3.text);
		 }

/* A typdef'd enum.  Pretty common in C headers */

               | TYPEDEF ENUM ename LBRACE { 
   		   DOH *o;
		   o = new_node("Enumeration",$2.filename,$2.line);
		   Setattr(o,"name",$3.text);
		   top = o;
	       } enumlist RBRACE ID {
		   LParseType *t;
		   DOH *o2;
		   top = Getattr(top,"parent");
		   t = NewLParseType(LPARSE_T_ENUM);
		   Active_typedef = (LParseType *) Copy(t);
		   LParse_typedef_add(t,$3.text);
		   LParse_typedef_add(t,$8.text);
		   o2 = new_node("Typedef",$1.filename,$1.line);
		   Setattr(o2,"name",$8.text);
		   Setattr(o2,"type",Copy(t));
	       } typedeflist SEMI { }
               ;

/* Some stuff for handling enums */

ename          :  ID { $$ = $1; } 
               |  empty { $$.text = NewString(""); }
               ;

enumlist       :  enumlist COMMA edecl {}
               |  edecl {}
               ;

edecl          :  ID {
                   DOH *o = new_node("EnumValue",$1.filename,$1.line);
                   Setattr(o,"name",$1.text);
		   Setattr(o,"value",$1.text);
		 } 
                 | ID EQUAL expr {
		   DOH *o = new_node("EnumValue",$1.filename,$1.line);
		   Setattr(o,"name",$1.text);
		   Setattr(o,"value",$1.text);
                 }
                 | empty { }
                 ;
		   
typedef_decl   : TYPEDEF type declaration {
                   DOH *o;
                   Active_typedef = (LParseType *) Copy($2);
		   $2->is_pointer += $3.is_pointer;
		   LParse_typedef_add($2,$3.id);
		   o = new_node("Typedef", $1.filename, $1.line);
		   Setattr(o,"name", $3.id);
		   Setattr(o,"type", Copy($2));
                } typedeflist SEMI { };

/* A rudimentary typedef involving function pointers */

               | TYPEDEF type LPAREN STAR pname RPAREN LPAREN parms RPAREN SEMI {
		   DOH *o;
		   LParseType *rt;
		   rt = NewLParseType(LPARSE_T_FUNCTION);
		   rt->is_pointer = 1;
		   strcpy(rt->name,"<function ptr>");
                   LParse_typedef_add(rt,$5.name);
                   o = new_node("Typedef", $1.filename, $1.line);
		   Setattr(o,"name", $5.name);
		   Setattr(o,"type", Copy(rt));
		   Setattr(o,"rettype",$2);
		   Setattr(o,"parms", $8);
	       }

/* A typedef involving function pointers again */

               | TYPEDEF type stars LPAREN STAR pname RPAREN LPAREN parms RPAREN SEMI {
		   DOH *o;
		   LParseType *rt;
		   rt = NewLParseType(LPARSE_T_FUNCTION);
		   rt->is_pointer = 1;
		   strcpy(rt->name,"<function ptr>");
		   $2->is_pointer += $3.ivalue;
                   LParse_typedef_add(rt,$6.name);
                   o = new_node("Typedef", $1.filename, $1.line);
		   Setattr(o,"name", $6.name);
		   Setattr(o,"type", Copy(rt));
		   Setattr(o,"parms", $9);
		   Setattr(o,"rettype", $2);
		 }

/* A typedef involving arrays */

               | TYPEDEF type declaration array {
		   DOH *o;
		   Active_typedef = (LParseType *) Copy($2);
		   $2->is_pointer += $3.is_pointer;
		   $2->is_pointer++;
		   $2->arraystr = Swig_copy_string(Char($4.text));
		   LParse_typedef_add($2,$3.id);
		   o = new_node("Typedef", $1.filename, $1.line);
		   Setattr(o,"name", $3.id);
		   Setattr(o,"type", Copy($2));
	       } typedeflist SEMI { }
               ;

typedeflist   : COMMA declaration typedeflist {
                  if (Active_typedef) {
		    DOH *o;
		    LParseType *t;
		    t = (LParseType *) Copy(Active_typedef);
		    t->is_pointer += $2.is_pointer;
		    LParse_typedef_add(t,$2.id);
		    o = new_node("Typedef", Getfile($2.id), Getline($2.id));
		    Setattr(o,"name", $2.id);
		    Setattr(o,"type", t);
		  }
              }
              | COMMA declaration array {
                    DOH *o;
		    LParseType *t;
		    t = (LParseType *) Copy(Active_typedef);
		    t->is_pointer += $2.is_pointer + 1;
		    t->arraystr = Swig_copy_string(Char($3.text));
		    LParse_typedef_add(t,$2.id);
		    o = new_node("Typedef", Getfile($2.id), Getline($2.id));
		    Setattr(o,"name", $2.id);
		    Setattr(o,"type", t);
	      }
              | empty
              ;


/* =============================================================================
 *                        -- Feeble C++ (yuck) Parsing --
 * ============================================================================= */

cpp_decl     : cpp_class { }
             | cpp_other { }
             ;
  
cpp_class    :  extern_spec cpptype ID inherit LBRACE {
	       LParseType *t;
	       DOH *o = new_node("Class",$3.filename,$3.line);
	       Setattr(o,"name",$3.text);
	       Setattr(o,"bases",$4);
	       Setattr(o,"type",$2.text);
	       apply_modifier(o);
	       t = NewLParseType(LPARSE_T_USER);
	       strcpy(t->name,Char($3.text));
	       LParse_typedef_add(t,$3.text);
	       LParse_new_scope(0);
	       if (Cmp($2.text,"class") == 0) {
		 cplus_mode = CPLUS_PRIVATE;
	       } else {
		 cplus_mode = CPLUS_PUBLIC;
	       }
	       top = o;
              } cpp_members RBRACE {
                  dump_nested($3.text);
                  Setattr(top,"scope",LParse_collapse_scope($3.text));
		  top = Getattr(top,"parent");
		  cplus_mode = CPLUS_PUBLIC;
	      }

/* Class with a typedef */
		
             | TYPEDEF cpptype ID inherit LBRACE {
	       LParseType *t;
	       DOH *o = new_node("Class",$3.filename,$3.line);
	       Setattr(o,"name",$3.text);
	       Setattr(o,"bases",$4);
	       Setattr(o,"type",$2.text);
	       apply_modifier(o);
	       t = NewLParseType(LPARSE_T_USER);
	       strcpy(t->name,Char($3.text));
	       LParse_typedef_add(t,$3.text);
	       LParse_new_scope(0);
	       if (Cmp($2.text,"class") == 0) {
		 cplus_mode = CPLUS_PRIVATE;
	       } else {
		 cplus_mode = CPLUS_PUBLIC;
	       }
	       top = o;
	     } cpp_members RBRACE declaration {
	       DOH *o2;
	       Active_typedef = NewLParseType(LPARSE_T_USER);
	       sprintf(Active_typedef->name,"%s %s", Char($2.text),Char($3.text));
	       Active_typedef->is_pointer = 0;
	       Active_typedef->implicit_ptr = 0;
	       /* Create dump nested class code */
	       if ($9.is_pointer > 0) {
		 dump_nested($3.text);
	       } else {
		 dump_nested($9.id);
	       }
	       Setattr(top,"scope",LParse_collapse_scope($3.text));
	       o2 = top;
	       top = Getattr(top,"parent");
	       /* Create a typedef in global scope */
	       if ($9.is_pointer == 0) {
		 LParse_typedef_add((LParseType *) Copy(Active_typedef), $9.id);
		 Setattr(o2,"typedef",$9.id);
	       } else {
		 LParseType *t = (LParseType *) Copy(Active_typedef);
		 t->is_pointer += $9.is_pointer;
		 LParse_typedef_add(t,$9.id);
	       }
	       cplus_mode = CPLUS_PUBLIC;
	     } typedeflist { };

/* An unnamed struct with a typedef */

             | TYPEDEF cpptype LBRACE {
	       DOH *o = new_node("Class",$1.filename,$1.line);
	       Setattr(o,"type",$2.text);
	       LParse_new_scope(0);
	       if (Cmp($2.text,"class") == 0) {
		 cplus_mode = CPLUS_PRIVATE;
	       } else {
		 cplus_mode = CPLUS_PUBLIC;
	       }
	       top = o;
              } cpp_members RBRACE declaration {
		if ($7.is_pointer > 0) {
		  LParse_error($1.filename,$1.line,"typedef %s {} *%s not supported correctly. Will be ignored.\n", $2.text, $7.id);
		  Setattr(top,"error",DohNone);
		  top = Getattr(top,"parent");
		} else {
		  /* Create a datatype for correctly processing the typedef */
		  Active_typedef = NewLParseType(LPARSE_T_USER);
		  sprintf(Active_typedef->name,"%s",Char($7.id));
		  if ($7.is_pointer == 0) {
		    dump_nested($7.id);
		  }
		  Setattr(top,"name",$7.id);
		  apply_modifier(top);
		  Setattr(top,"typedef",$7.id);
		  Setattr(top,"scope",LParse_collapse_scope(0));
		  top = Getattr(top,"parent");
		  LParse_typedef_add((LParseType *) Copy(Active_typedef),$7.id);
		}
		cplus_mode = CPLUS_PUBLIC;
	      } typedeflist { }
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
                                 
base_specifier : idtype {  
		 LParse_error($1.filename,$1.line,"No access specifier given for base class %s (ignored).\n", $1.text);
		  $$.text = 0;
               }
               | VIRTUAL ID { 
		 LParse_error($2.filename,$2.line,"No access specifier given for base class %s (ignored).\n", $2.text);
                  $$.text = 0;
	       }
	       | VIRTUAL access_specifier ID {
		 if (Cmp($2.text,"public") == 0) {
		   $$ = $3;
		 } else {
		   LParse_error($3.filename,$3.line,"%s inheritance not supported (ignored).\n", $2.text); 
		   $$.text = 0;
		 }
               }
               | access_specifier ID {
		 if (Cmp($1.text,"public") == 0) {
		   $$ = $2;
		 } else {
		   LParse_error($2.filename,$2.line,"%s inheritance not supported (ignored).\n", $1.text); 
		   $$.text = 0;
		 }
	       }                          
               | access_specifier VIRTUAL ID {
                 if (Cmp($1.text,"public") == 0) {
		   $$ = $3;
		 } else {
		   $$.text = 0;
		   LParse_error($3.filename,$3.line,"%s inheritance not supported (ignored).\n", $1.text); 
		 }
               }
               ;                               

access_specifier :  PUBLIC { $$.text = NewString("public"); }
               | PRIVATE { $$.text = NewString("private"); }
               | PROTECTED { $$.text = NewString("protected"); }
               ;

cpp_members  : cpp_member cpp_members {}
             | ADDMETHODS LBRACE {
                 DOH *o = new_node("AddMethods",$1.filename,$1.line);
		 top = o;
	     } cpp_members RBRACE {
	         top = Getattr(top,"parent");
	     } cpp_members { }
	     | error {
	       LParse_error(0,0,"Syntax error in class definition.\n");
	       LParse_skip_decl();
	     } cpp_members { }
             | empty { }
             ;

cpp_member   :  type declaration LPAREN parms RPAREN cpp_end {
                 if (cplus_mode == CPLUS_PUBLIC) {
                    DOH *o = new_node("MemberFunction",$3.filename,$3.line);
		    Setattr(o,"name",$2.id);
		    $1->is_pointer += $2.is_pointer;
		    $1->is_reference = $2.is_reference;
		    Setattr(o,"type",$1);
		    Setattr(o,"parms",$4);
		    Setattr(o,"code",$6.text);
		    apply_modifier(o);
		  }
              }

             | VIRTUAL type declaration LPAREN parms RPAREN cpp_end {
                 if (cplus_mode == CPLUS_PUBLIC) {
                    DOH *o = new_node("MemberFunction",$4.filename,$4.line);
		    Setattr(o,"name",$3.id);
		    $2->is_pointer += $3.is_pointer;
		    $2->is_reference = $3.is_reference;
		    Setattr(o,"type",$2);
		    Setattr(o,"parms",$5);
		    Setattr(o,"code",$7.text);
		    apply_modifier(o);
		  }
              }

/* Possibly a constructor */
              | idtype LPAREN parms RPAREN ctor_end {
		if (cplus_mode == CPLUS_PUBLIC) {
		  DOH *o = new_node("Constructor", $2.filename, $2.line);
		  Setattr(o,"name",$1.text);
		  Setattr(o,"parms",$3);
		  Setattr(o,"code",$5.text);
		  apply_modifier(o);
		}
	      }

/* A destructor (hopefully) */

              | NOT idtype LPAREN parms RPAREN cpp_end {
		  if (cplus_mode == CPLUS_PUBLIC) {
		    DOH *o = new_node("Destructor",$2.filename,$2.line);
		    Setattr(o,"name",$1.text);
		    Setattr(o,"parms",$4);
		    Setattr(o,"code",$6.text);
		    apply_modifier(o);
		  }
	      }

              | VIRTUAL NOT idtype LPAREN parms RPAREN cpp_end {
		  if (cplus_mode == CPLUS_PUBLIC) {
		    DOH *o = new_node("Destructor",$3.filename,$3.line);
		    Setattr(o,"name",$2.text);
		    Setattr(o,"parms",$5);
		    Setattr(o,"code",$7.text);
		    apply_modifier(o);
		  }
	      }

/* Member data */

              | type declaration def_args {
		if (cplus_mode == CPLUS_PUBLIC) {
		  DOH *o = new_node("MemberData",Getfile($2.id),Getline($2.id));
		  Active_type = (LParseType *) Copy($1);
		  $1->is_pointer += $2.is_pointer;
		  $1->is_reference = $2.is_reference;
		  Setattr(o,"name",$2.id);
		  Setattr(o,"type",$1);
		  Setattr(o,"value",$3.text);
		  apply_modifier(o);
  	       }
              } cpp_tail { }

              | type declaration array def_args {
		if (cplus_mode == CPLUS_PUBLIC) {
		  DOH *o = new_node("MemberData",Getfile($2.id),Getline($2.id));
		  Active_type = (LParseType *) Copy($1);
		  $1->is_pointer += $2.is_pointer;
		  $1->is_reference = $2.is_reference;
		  if ($3.text) {
		    $1->arraystr = Swig_copy_string(Char($3.text));
		    $1->is_pointer++;
		  }
		  Setattr(o,"name",$2.id);
		  Setattr(o,"type",$1);
		  Setattr(o,"value",$3.text);
		  apply_modifier(o);
		}
	      }

/* Static Member data */

              | STATIC type declaration {
		if (cplus_mode == CPLUS_PUBLIC) {
		  DOH *o;
		  Active_type = (LParseType *) Copy($2);
		  $2->is_pointer += $3.is_pointer;
		  $2->is_reference = $3.is_reference;
		  o = new_node("StaticMemberData",$1.filename, $1.line);
		  Setattr(o,"name",$3.id);
		  Setattr(o,"type",$2);
		  apply_modifier(o);
		}
	      } cpp_tail { }

/* Static member function */

              | STATIC type declaration LPAREN parms RPAREN cpp_end {
  	        if (cplus_mode == CPLUS_PUBLIC) {
		  DOH *o = new_node("StaticMemberFunction",$1.filename,$1.line);
		  $2->is_pointer += $3.is_pointer;
		  $2->is_reference = $3.is_reference;
		  Setattr(o,"name",$3.id);
		  apply_modifier(o);
		  Setattr(o,"type",$2);
		  Setattr(o,"parms",$5);
		  Setattr(o,"code",$7.text);
		}
	      }

/* Turn on public: mode */

              | PUBLIC COLON { cplus_mode = CPLUS_PUBLIC; }

/* Turn on private: mode */

              | PRIVATE COLON { cplus_mode = CPLUS_PRIVATE; }

/* Turn on protected mode */

              | PROTECTED COLON { cplus_mode = CPLUS_PRIVATE; }

              | modifier_directive { } 

              | ENUM ename LBRACE {
                    DOH *o;
		    o = new_node("Enumeration",$2.filename,$2.line);
		    Setattr(o,"name",$2.text);
		    top = o;
              } enumlist RBRACE SEMI {
 		    LParseType *t;
                    top = Getattr(top,"parent");
		    t = NewLParseType(LPARSE_T_ENUM);
		    LParse_typedef_add(t,$3.text);
     	      }

/* A friend :   Illegal */
              | FRIEND {
		LParse_skip_decl();
	      }  

/* An operator: Illegal */
              | type type_extra OPERATOR {
		LParse_skip_decl();
	      }

/* A typedef inside a class */
              | typedef_decl { }

/* Pragma directive */

              | pragma_directive { }

/* ----------------------------------------------------------------------
   Nested structure.   If we encounter a nested structure, we're going to
   grab the text of its definition and feed it back into the scanner.  
   In the meantime, we need to grab variable declaration information and 
   generate the associated wrapper code later. 

   This really only works in a limited sense.   Since we use the 
   code attached to the nested class to generate both C/C++ code,
   it can't have any SWIG directives in it.  It also needs to be parsable
   by SWIG or this whole thing is going to puke.
   ---------------------------------------------------------------------- */

/* A struct sname { } id;  declaration */

              | cpptype ID LBRACE { 
		$3.text = LParse_skip_balanced('{','}');
	      } nested_decl SEMI { 
		if (cplus_mode == CPLUS_PUBLIC) {
		  LParseType *t = NewLParseType(LPARSE_T_USER);
		  strcpy(t->name,Char($2.text));
		  LParse_typedef_add(t,$2.text);
		  if ($5.id) {
		    if (Cmp($1.text,"class") == 0) {
		      LParse_error($2.filename,$2.line,"Nested classes not currently supported (ignored).\n");
		      /* Generate some code for a new class */
		    } else {
		      DOH *s;
		      DOH *n = NewHash();
		      s = NewString("");
		      Printf(s,"typedef %s %s $classname_%s;\n", $1.text,$3.text,$5.id);
		      Setattr(n,"code",s);
		      Setattr(n,"name",$5.id);
		      t = (LParseType *) Copy(t);
		      t->is_pointer = $5.is_pointer;
		      t->is_reference = $5.is_reference;
		      Setattr(n,"type",t);
		      Append(nested,n);
		    }
		  }
		}
	      }
/* An unnamed structure definition */
              | cpptype LBRACE { 
		$2.text = LParse_skip_balanced('{','}');		
              } declaration SEMI { 
		if (cplus_mode == CPLUS_PUBLIC) {
		  if ($4.id) {
		    if (Cmp($1.text,"class") == 0) {
		      LParse_error($2.filename,$2.line, "Nested classes not currently supported (ignored).\n");
		      /* Generate some code for a new class */
		    } else {
		      DOH *s;
		      LParseType *t;
		      DOH *n = NewHash();
		      s = NewString("");
		      Printf(s,"typedef %s %s $classname_%s;\n", $1.text,$2.text,$4.id);
		      Setattr(n,"code",s);
		      Setattr(n,"name",$4.id);
		      t = NewLParseType(LPARSE_T_USER);
		      t->is_pointer = $4.is_pointer;
		      t->is_reference = $4.is_reference;
		      Setattr(n,"type",t);
		      Append(nested,n);
		    }
		  }
		}
	      }
              ;

nested_decl   : declaration { $$ = $1;}
              | empty { $$.id = 0; }
              ;

cpp_tail      : SEMI { }
               | COMMA declaration def_args {
		 if (cplus_mode == CPLUS_PUBLIC) {
		   DOH *o = new_node("MemberData",$1.filename,$1.line);
		   LParseType *t = (LParseType *) Copy(Active_type);
		   t->is_pointer += $2.is_pointer;
		   t->is_reference = $2.is_reference;
		   Setattr(o,"name", $2.id);
		   Setattr(o,"type",t);
		   Setattr(o,"value",$3.text);
		   apply_modifier(o);
		 }
	       } cpp_tail { } 
               | COMMA declaration array def_args {
		 if (cplus_mode == CPLUS_PUBLIC) {
		   DOH *o = new_node("MemberData",$1.filename,$1.line);
		   LParseType *t = (LParseType *) Copy(Active_type);
		   t->is_pointer += $2.is_pointer;
		   t->is_reference = $2.is_reference;
		   if ($3.text) {
		     t->arraystr = Swig_copy_string(Char($3.text));
		     t->is_pointer++;
		   }
		   Setattr(o,"name",$2.id);
		   Setattr(o,"type",t);
		   Setattr(o,"value",$3.text);
		   apply_modifier(o);
		 }
	       } cpp_tail { } 
               ;

cpp_end        : cpp_const SEMI { 
                   $$.text = 0;
               } 
               | cpp_const LBRACE {  
                   $$.text = LParse_skip_balanced('{','}');
               }
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

             extern_spec cpptype idtype SEMI {
                 DOH *o = new_node("ClassDecl",$4.filename,$4.line);
                 Setattr(o,"name",$3.text);
	     }   

/* Any sort of out-of-class C++ declaration */
            
              | extern_spec type declaration DCOLON {
		LParse_skip_decl();
	      }
 
/* Template catch */
             | TEMPLATE {
		LParse_skip_decl();
	     }

/* %addmethods directive used outside of a class definition */

             | ADDMETHODS idtype LBRACE {
	       DOH *o = new_node("AddMethods",$3.filename, $3.line);
	       Setattr(o,"name",$2.text);
	       cplus_mode = CPLUS_PUBLIC;
	       top = o;
	     } cpp_members RBRACE {
	       top = Getattr(top,"parent");
	     }
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
		   Setattr($$,"name",$2.name);
		   if ($2.array) {
		     $1->is_pointer++;
		     $1->arraystr = Swig_copy_string(Char($2.array));
		   }
		   if ($2.value)
		     Setattr($$,"value",$2.value);
		   Setattr($$,"type",$1);
                }
                | type stars pname {
		  $$ = NewHash();
		  Setattr($$,"name",$3.name);
		  $1->is_pointer += $2.ivalue;
		  if ($3.array) {
		     $1->is_pointer++;
		     $1->arraystr = Swig_copy_string(Char($3.array));
		  }
		  if ($3.value) {
		    Setattr($$,"value",$3.value);
		  }
		  Setattr($$,"type",$1);
		}
                | type AND pname {
		  $$ = NewHash();
		  $1->is_reference = 1;
		  $1->is_pointer++;
		  Setattr($$,"name",$3.name);
		  if ($3.array) {
		     $1->is_pointer++;
		     $1->arraystr = Swig_copy_string(Char($3.array));
		  }
		  if ($3.value) {
		    Setattr($$,"value",$3.value);
		  }
		  Setattr($$,"type",$1);
		}
                | type LPAREN stars pname RPAREN LPAREN parms RPAREN {
		  $$ = NewHash();
		  $1->type = LPARSE_T_FUNCTION;
		  $1->is_pointer += $3.ivalue;
		  strcpy($1->name,"<function ptr>");
		  Setattr($$,"name",$4.name);
		  if ($4.value)
		    Setattr($$,"value",$4.value);
		  Setattr($$,"type",$1);
		}
                | PERIOD PERIOD PERIOD {
		  LParseType *t;
		  $$ = NewHash();
		  Setattr($$,"name","...");
		  t = NewLParseType(LPARSE_T_VARARGS);
		  Setattr($$,"type",t);
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
		 $$.array = $2.text;
               }
               | array {
		 $$.name = NewString("");
		 $$.value = 0;
		 $$.array = $1.text;
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
               | empty {
                 $$.text = 0; 
                 $$.ivalue = 0;
	       }
               ;

/* Declaration must be an identifier, possibly preceded by a * for pointer types  */

declaration    : ID { $$.id = $1.text;
                      $$.is_pointer = 0;
		      $$.is_reference = 0;
                }
               | stars ID {
                      $$.id = $2.text;
		      $$.is_pointer = $1.ivalue;
		      $$.is_reference = 0;
	       }
               | AND ID {
		      $$.id = $2.text;
		      $$.is_pointer = 1;
		      $$.is_reference = 1;
	       }
               ;

stars :          STAR empty { $$.ivalue = 1; }
               | STAR stars { $$.ivalue = $2.ivalue + 1;}
               ;

array :        LBRACKET RBRACKET array2 {
                 $$.ivalue = $3.ivalue + 1;
		 $$.text = NewString("[]");
		 Append($$.text,$3.text);
              }
              | LBRACKET expr RBRACKET array2 {
		$$.ivalue = $4.ivalue + 1;
		$$.text = NewString("");
		Printf($$.text,"[%s]",$2.text);
              }
	      ;
array2 :      array {
                 $$ = $1;
              }
              | empty { $$.ivalue = 0;
                        $$.text = 0;
              }
	      ;

type           : realtype { Intype++; }
               ;

realtype       : TYPE_INT {  $$ = NewLParseType(LPARSE_T_INT);  }
               | TYPE_SHORT opt_int { $$ = NewLParseType(LPARSE_T_SHORT); }
               | TYPE_LONG opt_int {  $$ = NewLParseType(LPARSE_T_LONG); }
               | TYPE_CHAR { $$ = NewLParseType(LPARSE_T_CHAR); }
               | TYPE_BOOL {  $$ = NewLParseType(LPARSE_T_BOOL); }
               | TYPE_FLOAT { $$ = NewLParseType(LPARSE_T_FLOAT); }
               | TYPE_DOUBLE { $$ = NewLParseType(LPARSE_T_DOUBLE); }
               | TYPE_VOID {  $$ = NewLParseType(LPARSE_T_VOID); }
               | TYPE_SIGNED opt_signed { 
                 if ($2) $$ = $2;
		 else {
		   $$ = NewLParseType(LPARSE_T_INT);
		   strcpy($$->name,"signed");
		 }
	       }
               | TYPE_UNSIGNED opt_unsigned {
                   if ($2) $$ = $2;
		   else {
		     $$ = NewLParseType(LPARSE_T_UINT);
		     strcpy($$->name,"unsigned");
		   }
	       }
               | TYPE_TYPEDEF {
                   $$ = NewLParseType(LPARSE_T_USER);
                   strcpy($$->name,Char($1.text));
		   LParse_typedef_resolve($$,0);
	       }
               | TYPE_TYPEDEF template_decl {
		 $$ = NewLParseType(LPARSE_T_USER);
		 if ($2.text) 
		   sprintf($$->name,"%s%s",Char($1.text),Char($2.text));
		 else
		   strcpy($$->name,Char($1.text));
	       }
               | CONST type {
		  $$ = $2;
                  $$->qualifier = Swig_copy_string("const");
     	       }
               | cpptype idtype {
                  $$ = NewLParseType(LPARSE_T_USER);
		  sprintf($$->name,"%s %s",Char($1.text), Char($2.text));
	       }
               | TYPE_TYPEDEF DCOLON idtype {
                  $$ = NewLParseType(LPARSE_T_USER);
                  sprintf($$->name,"%s::%s",Char($1.text),Char($3.text));
                  LParse_typedef_resolve($$,0);
               }
/* This declaration causes a shift-reduce conflict.  Unresolved for now */
               | DCOLON TYPE_TYPEDEF {
                  $$ = NewLParseType(LPARSE_T_USER);
                  sprintf($$->name,"%s", Char($2.text));
		  LParse_typedef_resolve($$,1);
               }
               | ENUM idtype {
		 $$ = NewLParseType(LPARSE_T_ENUM);
		 sprintf($$->name,"enum %s", Char($2.text));
		 /*		 LParse_typedef_resolve($$,1);*/
		 /* $$->typedef_resolve(1); */
               }
               ;

/* Optional signed types */
opt_signed     : empty { $$ = 0; }
               | TYPE_INT { 
                   $$ = NewLParseType(LPARSE_T_INT);
                   strcpy($$->name,"signed int");
	       }
               | TYPE_SHORT opt_int {
                   $$ = NewLParseType(LPARSE_T_SHORT);
		   strcpy($$->name,"signed short");
	       }
               | TYPE_LONG opt_int {
                   $$ = NewLParseType(LPARSE_T_LONG);
		   strcpy($$->name,"signed long");
	       }
               | TYPE_CHAR {
                   $$ = NewLParseType(LPARSE_T_SCHAR);
	       }
               ;

/* Optional unsigned types */

opt_unsigned   : empty { $$ = 0;}
               | TYPE_INT {
                   $$ = NewLParseType(LPARSE_T_UINT);
		   strcpy($$->name,"unsigned int");
	       }
               | TYPE_SHORT opt_int {
                   $$ = NewLParseType(LPARSE_T_USHORT);
		   strcpy($$->name,"unsigned short");
	       }
               | TYPE_LONG opt_int {
		 $$ = NewLParseType(LPARSE_T_ULONG);
		 strcpy($$->name, "unsigned long");
	       }
               | TYPE_CHAR {
                   $$ = NewLParseType(LPARSE_T_UCHAR);
	       }
               ;

opt_int        : TYPE_INT { }
               | empty { }
               ;

cpptype        : CLASS { $$ = $1; }
               | STRUCT { $$ = $1; }
               | UNION { $$ = $1; }  
               ;

template_decl  : LESSTHAN {
                  $$ = $1;
                  $$.text = LParse_skip_balanced('<','>');
               } 
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

idtype         : ID { $$ = $1; }
               | TYPE_TYPEDEF { $$ = $1; }
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
  if (Intype == 0) {
    LParse_error(0,0,"Syntax error. Perhaps you need to specify a typename.\n");
  } else {
    LParse_error(0,0,"Syntax error.\n", e);
  }
}











