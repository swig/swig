
/*  A Bison parser, made from parser.yxx
 by  GNU Bison version 1.27
  */

#define YYBISON 1  /* Identify Bison output.  */

#define	ID	257
#define	HBLOCK	258
#define	WRAPPER	259
#define	POUND	260
#define	STRING	261
#define	INCLUDE	262
#define	IMPORT	263
#define	WEXTERN	264
#define	SWIGMACRO	265
#define	NUM_INT	266
#define	NUM_FLOAT	267
#define	CHARCONST	268
#define	NUM_UNSIGNED	269
#define	NUM_LONG	270
#define	NUM_ULONG	271
#define	TYPEDEF	272
#define	TYPE_INT	273
#define	TYPE_UNSIGNED	274
#define	TYPE_SHORT	275
#define	TYPE_LONG	276
#define	TYPE_FLOAT	277
#define	TYPE_DOUBLE	278
#define	TYPE_CHAR	279
#define	TYPE_VOID	280
#define	TYPE_SIGNED	281
#define	TYPE_BOOL	282
#define	TYPE_TYPEDEF	283
#define	LPAREN	284
#define	RPAREN	285
#define	COMMA	286
#define	SEMI	287
#define	EXTERN	288
#define	INIT	289
#define	LBRACE	290
#define	RBRACE	291
#define	DEFINE	292
#define	PERIOD	293
#define	CONST	294
#define	STRUCT	295
#define	UNION	296
#define	EQUAL	297
#define	SIZEOF	298
#define	MODULE	299
#define	LBRACKET	300
#define	RBRACKET	301
#define	ILLEGAL	302
#define	CONSTANT	303
#define	READONLY	304
#define	READWRITE	305
#define	NAME	306
#define	RENAME	307
#define	ADDMETHODS	308
#define	PRAGMA	309
#define	CVALUE	310
#define	COUT	311
#define	ENUM	312
#define	ENDDEF	313
#define	MACRO	314
#define	CLASS	315
#define	PRIVATE	316
#define	PUBLIC	317
#define	PROTECTED	318
#define	COLON	319
#define	STATIC	320
#define	VIRTUAL	321
#define	FRIEND	322
#define	OPERATOR	323
#define	THROW	324
#define	TEMPLATE	325
#define	NATIVE	326
#define	INLINE	327
#define	RAW_MODE	328
#define	ALPHA_MODE	329
#define	TEXT	330
#define	DOC_DISABLE	331
#define	DOC_ENABLE	332
#define	STYLE	333
#define	LOCALSTYLE	334
#define	TYPEMAP	335
#define	EXCEPT	336
#define	ECHO	337
#define	NEW	338
#define	APPLY	339
#define	CLEAR	340
#define	DOCONLY	341
#define	TITLE	342
#define	SECTION	343
#define	SUBSECTION	344
#define	SUBSUBSECTION	345
#define	LESSTHAN	346
#define	GREATERTHAN	347
#define	USERDIRECTIVE	348
#define	OC_INTERFACE	349
#define	OC_END	350
#define	OC_PUBLIC	351
#define	OC_PRIVATE	352
#define	OC_PROTECTED	353
#define	OC_CLASS	354
#define	OC_IMPLEMENT	355
#define	OC_PROTOCOL	356
#define	OR	357
#define	XOR	358
#define	AND	359
#define	LSHIFT	360
#define	RSHIFT	361
#define	PLUS	362
#define	MINUS	363
#define	STAR	364
#define	SLASH	365
#define	UMINUS	366
#define	NOT	367
#define	LNOT	368
#define	DCOLON	369

#line 1 "parser.yxx"

/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/
/***********************************************************************
 * $Header$
 *
 * parser.y
 *
 * YACC parser for parsing function declarations.
 *
 * *** DISCLAIMER ***
 *
 * This is the most ugly, incredibly henious, and completely unintelligible
 * file in SWIG.  While it started out simple, it has grown into a
 * monster that is almost unmaintainable.   A complete parser rewrite is
 * currently in progress that should make this file about 1/4 the size
 * that it is now.   Needless to say, don't modify this file or even look
 * at it for that matter!
 ***********************************************************************/

#define yylex yylex

static char cvsroot[] = "$Header$";

extern "C" int yylex();
void   yyerror (char *s);       
    
extern int  line_number;
extern int  start_line;
extern void skip_brace(void);
extern void skip_define(void);
extern void skip_decl(void);
extern int  skip_cond(int);
extern void skip_to_end(void);
extern void skip_template(void);
extern void scanner_check_typedef(void);
extern void scanner_ignore_typedef(void);
extern void scanner_clear_start(void);
extern void start_inline(char *, int);
extern void format_string(char *);
extern void swig_pragma(char *, char *);

#include "internal.h"

#ifdef NEED_ALLOC
void *alloca(unsigned n) {
  return((void *) malloc(n));
}
#else
// This redefinition is apparently needed on a number of machines,
// particularly HPUX
#undef  alloca
#define alloca  malloc
#endif

// Initialization flags.   These indicate whether or not certain
// features have been initialized.  These were added to allow
// interface files without the block (required in previous
// versions).

static int     module_init = 0;    /* Indicates whether the %module name was given */
static int     title_init = 0;     /* Indicates whether %title directive has been given */
static int     doc_init = 0;    

static int     lang_init = 0;      /* Indicates if the language has been initialized */

static int            i;
       int            Error = 0;
static char           temp_name[128];
static DataType      *temp_typeptr, temp_type;
static char           yy_rename[256];
static int            Rename_true = 0;
static DataType      *Active_type = 0;         // Used to support variable lists
static int            Active_extern = 0;       // Whether or not list is external
static int            Active_static = 0;
static DataType       *Active_typedef = 0;     // Used for typedef lists
static int            InArray = 0;             // Used when an array declaration is found 
static int            in_then = 0;
static int            in_else = 0;       
static int            allow = 1;               // Used during conditional compilation
static int            doc_scope = 0;           // Documentation scoping
static String         ArrayString;             // Array type attached to parameter names
static String         ArrayBackup;             // Array backup string
static char           *DefArg = 0;             // Default argument hack
static char           *ConstChar = 0;          // Used to store raw character constants
static ParmList       *tm_parm = 0;            // Parameter list used to hold typemap parameters
static Hash            name_hash;              // Hash table containing renamings
       char           *objc_construct = "new"; // Objective-C constructor
       char           *objc_destruct = "free"; // Objective-C destructor

/* Some macros for building constants */

#define E_BINARY(TARGET, SRC1, SRC2, OP)  \
        TARGET = new char[strlen(SRC1) + strlen(SRC2) +strlen(OP)+1];\
	sprintf(TARGET,"%s%s%s",SRC1,OP,SRC2);

/* C++ modes */

#define  CPLUS_PUBLIC    1
#define  CPLUS_PRIVATE   2
#define  CPLUS_PROTECTED 3

int     cplus_mode;

// Declarations of some functions for handling C++ 

extern void cplus_open_class(char *name, char *rname, char *ctype);
extern void cplus_member_func(char *, char *, DataType *, ParmList *, int);
extern void cplus_constructor(char *, char *, ParmList *);
extern void cplus_destructor(char *, char *);
extern void cplus_variable(char *, char *, DataType *);
extern void cplus_static_func(char *, char *, DataType *, ParmList *);
extern void cplus_declare_const(char *, char *, DataType *, char *);
extern void cplus_class_close(char *);
extern void cplus_inherit(int, char **);
extern void cplus_cleanup(void);
extern void cplus_static_var(char *, char *, DataType *);
extern void cplus_register_type(char *);
extern void cplus_register_scope(Hash *);
extern void cplus_inherit_scope(int, char **);
extern void cplus_add_pragma(char *, char *, char *);
extern DocEntry *cplus_set_class(char *);
extern void cplus_unset_class();
extern void cplus_abort();
  
// ----------------------------------------------------------------------
// static init_language()
//
// Initialize the target language.
// Does nothing if this function has already been called.
// ----------------------------------------------------------------------

static void init_language() {
  if (!lang_init) {
    lang->initialize();
    
    // Initialize the documentation system

    if (!doctitle) {
      doctitle = new DocTitle(title,0);
    }
    if (!doc_init)
      doctitle->usage = title;

    doc_stack[0] = doctitle;
    doc_stack_top = 0;
    
    int oldignore = IgnoreDoc;
    IgnoreDoc = 1;
    IgnoreDoc = oldignore;
  }
  lang_init = 1;
  title_init = 1;
}

// ----------------------------------------------------------------------
// int promote(int t1, int t2)
//
// Promote types (for constant expressions)
// ----------------------------------------------------------------------

int promote(int t1, int t2) {

  if ((t1 == T_ERROR) || (t2 == T_ERROR)) return T_ERROR;
  if ((t1 == T_DOUBLE) || (t2 == T_DOUBLE)) return T_DOUBLE;
  if ((t1 == T_FLOAT) || (t2 == T_FLOAT)) return T_FLOAT;
  if ((t1 == T_ULONG) || (t2 == T_ULONG)) return T_ULONG;
  if ((t1 == T_LONG) || (t2 == T_LONG)) return T_LONG;
  if ((t1 == T_UINT) || (t2 == T_UINT)) return T_UINT;
  if ((t1 == T_INT) || (t2 == T_INT)) return T_INT;
  if ((t1 == T_USHORT) || (t2 == T_USHORT)) return T_SHORT;
  if ((t1 == T_SHORT) || (t2 == T_SHORT)) return T_SHORT;
  if ((t1 == T_UCHAR) || (t2 == T_UCHAR)) return T_UCHAR;
  if (t1 != t2) {
    fprintf(stderr,"%s : Line %d. Type mismatch in constant expression\n",
	    input_file, line_number);
    FatalError();
  }
  return t1;
}

/* Generate the scripting name of an object.  Takes %name directive into 
   account among other things */

static char *make_name(char *name) {
  // Check to see if the name is in the hash
  char *nn = (char *) name_hash.lookup(name);
  if (nn) return nn;        // Yep, return it.

  if (Rename_true) {
    Rename_true = 0;
    return yy_rename;
  } else {
    // Now check to see if the name contains a $
    if (strchr(name,'$')) {
      static String temp;
      temp = "";
      temp << name;
      temp.replace("$","_S_");
      return temp;
    } else {
      return name;
    }
  }
}

/* Return the parent of a documentation entry.   If wrapping externally, this is 0 */

static DocEntry *doc_parent() {
  if (!WrapExtern) 
    return doc_stack[doc_stack_top];
  else
    return 0;
}

// ----------------------------------------------------------------------
// create_function(int ext, char *name, DataType *t, ParmList *l)
//
// Creates a function and manages documentation creation.  Really
// only used internally to the parser.
// ----------------------------------------------------------------------

void create_function(int ext, char *name, DataType *t, ParmList *l) {
  if (Active_static) return;     // Static declaration. Ignore

  init_language();
  if (WrapExtern) return;        // External wrapper file. Ignore

  char *iname = make_name(name);

  // Check if symbol already exists

  if (add_symbol(iname, t, (char *) 0)) {
    fprintf(stderr,"%s : Line %d. Function %s multiply defined (2nd definition ignored).\n",
	    input_file, line_number, iname);
  } else {
    Stat_func++;
    if (Verbose) {
      fprintf(stderr,"Wrapping function : ");
      emit_extern_func(name, t, l, 0, stderr);
    }

    // If extern, make an extern declaration in the SWIG wrapper file

    if (ext) 
      emit_extern_func(name, t, l, ext, f_header);
    else if (ForceExtern) {
      emit_extern_func(name, t, l, 1, f_header);
    }

    // If this function has been declared inline, produce a function

    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
    lang->create_function(name, iname, t, l);
    l->check_defined();
    t->check_defined();
  }
  scanner_clear_start();
}

// -------------------------------------------------------------------
// create_variable(int ext, char *name, DataType *t)
//
// Create a link to a global variable.
// -------------------------------------------------------------------

void create_variable(int ext, char *name, DataType *t) {

  if (WrapExtern) return;        // External wrapper file. Ignore
  int oldstatus = Status;

  if (Active_static) return;  // If static ignore
				   
  init_language();

  char *iname = make_name(name);
  if (add_symbol(iname, t, (char *) 0)) {
    fprintf(stderr,"%s : Line %d. Variable %s multiply defined (2nd definition ignored).\n",
	    input_file, line_number, iname);
  } else {
    Stat_var++;
    if (Verbose) {
      fprintf(stderr,"Wrapping variable : ");
      emit_extern_var(name, t, 0, stderr);
    }

    // If externed, output an external declaration

    if (ext) 
      emit_extern_var(name, t, ext, f_header);
    else if (ForceExtern) {
      emit_extern_var(name, t, 1, f_header);
    }

    // If variable datatype is read-only, we'll force it to be readonly
    if (t->status & STAT_READONLY) Status = Status | STAT_READONLY;

    // Now dump it out
    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
    lang->link_variable(name, iname, t);
    t->check_defined();
    Status = oldstatus;
  }
  scanner_clear_start();
}

// ------------------------------------------------------------------
// create_constant(char *name, DataType *type, char *value)
//
// Creates a new constant.
// -------------------------------------------------------------------

void create_constant(char *name, DataType *type, char *value) {

  if (Active_static) return;
  if (WrapExtern) return;        // External wrapper file. Ignore
  init_language();

  if (Rename_true) {
    fprintf(stderr,"%s : Line %d. %%name directive ignored with #define\n",
	    input_file, line_number);
    Rename_true = 0;
  }

  if ((type->type == T_CHAR) && (!type->is_pointer))
    type->is_pointer++;
  
  if (!value) value = copy_string(name);
  sprintf(temp_name,"const:%s", name);
  if (add_symbol(temp_name, type, value)) {
    fprintf(stderr,"%s : Line %d. Constant %s multiply defined. (2nd definition ignored)\n",
	    input_file, line_number, name);
  } else {
    // Update symbols value if already defined.
    update_symbol(name, type, value);

    if (!WrapExtern) {    // Only wrap the constant if not in %extern mode
      Stat_const++;
      if (Verbose) 
	fprintf(stderr,"Creating constant %s = %s\n", name, value);

      doc_entry = new DocDecl(name,doc_stack[doc_stack_top]);	   
      lang->declare_const(name, name, type, value);
      type->check_defined();
    }
  }
  scanner_clear_start();
}


/* Print out array brackets */
void print_array() {
  int i;
  for (i = 0; i < InArray; i++)
    fprintf(stderr,"[]");
}

// Structures for handling code fragments built for nested classes

struct Nested {
  String   code;         // Associated code fragment
  int      line;         // line number where it starts
  char     *name;        // Name associated with this nested class
  DataType *type;        // Datatype associated with the name
  Nested   *next;        // Next code fragment in list
};

// Some internal variables for saving nested class information

static Nested      *nested_list = 0;

// Add a function to the nested list

static void add_nested(Nested *n) {
  Nested *n1;
  if (!nested_list) nested_list = n;
  else {
    n1 = nested_list;
    while (n1->next) n1 = n1->next;
    n1->next = n;
  }
}

// Dump all of the nested class declarations to the inline processor
// However.  We need to do a few name replacements and other munging
// first.  This function must be called before closing a class!

static void dump_nested(char *parent) {
  Nested *n,*n1;
  n = nested_list;
  int oldstatus = Status;

  Status = STAT_READONLY;
  while (n) {
    // Token replace the name of the parent class
    n->code.replace("$classname",parent);

    // Fix up the name of the datatype (for building typedefs and other stuff)
    sprintf(n->type->name,"%s_%s",parent,n->name);
    
    // Add the appropriate declaration to the C++ processor
    doc_entry = new DocDecl(n->name,doc_stack[doc_stack_top]);
    cplus_variable(n->name,(char *) 0, n->type);

    // Dump the code to the scanner
    if (Verbose)
      fprintf(stderr,"Splitting from %s : (line %d) \n%s\n", parent,n->line, n->code.get());

    fprintf(f_header,"\n%s\n", n->code.get());
    start_inline(n->code.get(),n->line);

    n1 = n->next;
    delete n;
    n = n1;
  }
  nested_list = 0;
  Status = oldstatus;
}    


#line 440 "parser.yxx"
typedef union {         
  char        *id;
  struct Declaration {
    char *id;
    int   is_pointer;
    int   is_reference;
  } decl;
  struct InitList {
    char **names;
    int    count;
  } ilist;
  struct DocList {
    char **names;
    char **values;
    int  count;
  } dlist;
  struct Define {
    char *id;
    int   type;
  } dtype;
  struct {
    char *filename;
    int   line;
    int   flag; 
  } loc;
  DataType     *type;
  Parm         *p;
  TMParm       *tmparm;
  ParmList     *pl;
  int           ivalue;
} YYSTYPE;
#include <stdio.h>

#ifndef __cplusplus
#ifndef __STDC__
#define const
#endif
#endif



#define	YYFINAL		895
#define	YYFLAG		-32768
#define	YYNTBASE	116

#define YYTRANSLATE(x) ((unsigned)(x) <= 369 ? yytranslate[x] : 251)

static const char yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     3,     4,     5,     6,
     7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
    17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
    27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
    37,    38,    39,    40,    41,    42,    43,    44,    45,    46,
    47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
    57,    58,    59,    60,    61,    62,    63,    64,    65,    66,
    67,    68,    69,    70,    71,    72,    73,    74,    75,    76,
    77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
    87,    88,    89,    90,    91,    92,    93,    94,    95,    96,
    97,    98,    99,   100,   101,   102,   103,   104,   105,   106,
   107,   108,   109,   110,   111,   112,   113,   114,   115
};

#if YYDEBUG != 0
static const short yyprhs[] = {     0,
     0,     1,     4,     7,     9,    10,    17,    18,    25,    26,
    33,    34,    45,    47,    48,    56,    61,    62,    70,    75,
    76,    86,    94,    95,   104,   112,   120,   121,   131,   133,
   135,   140,   145,   146,   150,   151,   157,   165,   177,   181,
   185,   189,   193,   195,   197,   199,   202,   204,   206,   209,
   212,   215,   218,   221,   223,   227,   231,   236,   237,   246,
   247,   248,   259,   268,   275,   284,   291,   302,   311,   317,
   321,   327,   330,   336,   339,   341,   343,   345,   347,   353,
   355,   358,   361,   363,   365,   367,   368,   374,   385,   397,
   398,   405,   409,   413,   415,   423,   427,   434,   436,   437,
   444,   445,   454,   456,   458,   461,   464,   467,   469,   473,
   475,   477,   480,   483,   487,   491,   500,   504,   507,   510,
   512,   514,   517,   521,   524,   527,   529,   531,   533,   536,
   538,   540,   543,   546,   549,   552,   556,   561,   563,   565,
   567,   570,   573,   575,   577,   579,   581,   583,   586,   589,
   592,   595,   598,   601,   605,   608,   611,   613,   616,   619,
   621,   623,   625,   627,   629,   632,   635,   638,   641,   644,
   646,   648,   651,   654,   656,   658,   660,   663,   666,   668,
   670,   672,   673,   676,   678,   680,   684,   686,   688,   690,
   694,   696,   698,   699,   704,   706,   708,   710,   712,   714,
   716,   718,   720,   725,   730,   732,   736,   740,   744,   748,
   752,   756,   760,   764,   768,   772,   775,   778,   782,   784,
   786,   787,   796,   797,   798,   810,   811,   812,   822,   827,
   837,   844,   850,   852,   853,   860,   863,   866,   868,   871,
   872,   873,   881,   882,   886,   888,   895,   903,   909,   916,
   923,   924,   930,   935,   936,   942,   950,   953,   956,   959,
   964,   965,   969,   970,   978,   980,   982,   984,   988,   990,
   992,   996,  1003,  1004,  1011,  1012,  1018,  1022,  1026,  1030,
  1034,  1036,  1038,  1040,  1042,  1044,  1046,  1048,  1050,  1051,
  1057,  1058,  1065,  1068,  1071,  1074,  1079,  1082,  1086,  1088,
  1090,  1094,  1100,  1108,  1110,  1113,  1115,  1117,  1121,  1123,
  1126,  1130,  1133,  1137,  1139,  1141,  1143,  1145,  1147,  1149,
  1151,  1156,  1158,  1162,  1166,  1169,  1171,  1173,  1177,  1182,
  1186,  1188,  1192,  1193,  1203,  1204,  1214,  1216,  1218,  1223,
  1227,  1230,  1232,  1234,  1237,  1238,  1242,  1243,  1247,  1248,
  1252,  1253,  1257,  1259,  1263,  1266,  1270,  1271,  1278,  1282,
  1287,  1289,  1292,  1293,  1299,  1300,  1307,  1308,  1312,  1314,
  1320,  1326,  1328,  1330,  1334,  1339,  1341,  1345,  1347,  1352,
  1354,  1356,  1359,  1363,  1368,  1370,  1373,  1376,  1378,  1380,
  1382,  1385,  1389,  1391,  1394,  1398,  1402,  1411,  1414,  1415,
  1420,  1421,  1425,  1427,  1431,  1433,  1439,  1442,  1445,  1448,
  1451
};

static const short yyrhs[] = {    -1,
   117,   118,     0,   118,   119,     0,   250,     0,     0,     8,
     7,    36,   120,   118,    37,     0,     0,    10,     7,    36,
   121,   118,    37,     0,     0,     9,     7,    36,   122,   118,
    37,     0,     0,    11,     3,    32,     7,    32,    12,    36,
   123,   118,    37,     0,     6,     0,     0,   143,   157,   153,
   156,   150,   124,   140,     0,   143,   158,    30,   110,     0,
     0,    66,   157,   153,   156,   150,   125,   140,     0,    66,
   158,    30,   110,     0,     0,   143,   157,   153,    30,   145,
    31,   207,   126,   140,     0,   143,   157,   153,    30,   145,
    31,   144,     0,     0,   143,   153,    30,   145,    31,   207,
   127,   140,     0,    66,   157,   153,    30,   145,    31,   144,
     0,    73,   157,   153,    30,   145,    31,   144,     0,     0,
    66,   157,   153,    30,   145,    31,   207,   128,   140,     0,
    50,     0,    51,     0,    52,    30,     3,    31,     0,    53,
     3,     3,    33,     0,     0,    84,   129,   119,     0,     0,
    52,    30,    31,   130,   171,     0,    72,    30,     3,    31,
   143,     3,    33,     0,    72,    30,     3,    31,   143,   157,
   153,    30,   145,    31,    33,     0,    88,     7,   238,     0,
    89,     7,   238,     0,    90,     7,   238,     0,    91,     7,
   238,     0,    75,     0,    74,     0,   134,     0,    76,     4,
     0,   135,     0,     4,     0,     5,     4,     0,    35,     4,
     0,    73,     4,     0,    83,     4,     0,    83,     7,     0,
    87,     0,    35,     3,   164,     0,    45,     3,   164,     0,
    49,     3,   162,    33,     0,     0,   143,    58,   165,    36,
   131,   166,    37,    33,     0,     0,     0,    18,    58,   165,
    36,   132,   166,    37,     3,   133,   138,     0,    81,    30,
     3,    32,   240,    31,   241,    36,     0,    81,    30,   240,
    31,   241,    36,     0,    81,    30,     3,    32,   240,    31,
   241,    33,     0,    81,    30,   240,    31,   241,    33,     0,
    81,    30,     3,    32,   240,    31,   241,    43,   243,    33,
     0,    81,    30,   240,    31,   241,    43,   243,    33,     0,
    85,   243,    36,   241,    37,     0,    86,   241,    33,     0,
    82,    30,     3,    31,    36,     0,    82,    36,     0,    82,
    30,     3,    31,    33,     0,    82,    33,     0,    33,     0,
   171,     0,   213,     0,     1,     0,    34,     7,    36,   118,
    37,     0,   139,     0,    79,   237,     0,    80,   237,     0,
   248,     0,    77,     0,    78,     0,     0,    18,   157,   153,
   136,   138,     0,    18,   157,    30,   110,   149,    31,    30,
   145,    31,    33,     0,    18,   157,   154,    30,   110,   149,
    31,    30,   145,    31,    33,     0,     0,    18,   157,   153,
   155,   137,   138,     0,    32,   153,   138,     0,    32,   153,
   155,     0,   250,     0,    55,    30,     3,    32,     3,   239,
    31,     0,    55,     3,   239,     0,    55,    30,     3,    31,
     3,   239,     0,    33,     0,     0,    32,   153,   156,   150,
   141,   140,     0,     0,    32,   153,    30,   145,    31,   207,
   142,   140,     0,    34,     0,   250,     0,    34,     7,     0,
   207,    36,     0,   147,   146,     0,   250,     0,    32,   147,
   146,     0,   250,     0,   148,     0,   152,   148,     0,   157,
   149,     0,   157,   154,   149,     0,   157,   105,   149,     0,
   157,    30,   154,   149,    31,    30,   145,    31,     0,    39,
    39,    39,     0,     3,   150,     0,     3,   155,     0,   155,
     0,   250,     0,    43,   162,     0,    43,   105,     3,     0,
    43,    36,     0,    65,    12,     0,   250,     0,    56,     0,
    57,     0,   152,   151,     0,   151,     0,     3,     0,   154,
     3,     0,   105,     3,     0,   110,   250,     0,   110,   154,
     0,    46,    47,   156,     0,    46,   170,    47,   156,     0,
   155,     0,   250,     0,    19,     0,    21,   161,     0,    22,
   161,     0,    25,     0,    28,     0,    23,     0,    24,     0,
    26,     0,    27,   159,     0,    20,   160,     0,    29,   217,
     0,     3,   217,     0,    40,   157,     0,   206,     3,     0,
     3,   115,     3,     0,   115,     3,     0,    58,     3,     0,
    19,     0,    21,   161,     0,    22,   161,     0,    25,     0,
    28,     0,    23,     0,    24,     0,    26,     0,    27,   159,
     0,    20,   160,     0,    29,   217,     0,    40,   157,     0,
   206,     3,     0,   250,     0,    19,     0,    21,   161,     0,
    22,   161,     0,    25,     0,   250,     0,    19,     0,    21,
   161,     0,    22,   161,     0,    25,     0,    19,     0,   250,
     0,     0,   163,   170,     0,     7,     0,    14,     0,   164,
    32,     3,     0,   250,     0,     3,     0,   250,     0,   166,
    32,   167,     0,   167,     0,     3,     0,     0,     3,    43,
   168,   169,     0,   250,     0,   170,     0,    14,     0,    12,
     0,    13,     0,    15,     0,    16,     0,    17,     0,    44,
    30,   157,    31,     0,    30,   158,    31,   170,     0,     3,
     0,     3,   115,     3,     0,   170,   108,   170,     0,   170,
   109,   170,     0,   170,   110,   170,     0,   170,   111,   170,
     0,   170,   105,   170,     0,   170,   103,   170,     0,   170,
   104,   170,     0,   170,   106,   170,     0,   170,   107,   170,
     0,   109,   170,     0,   113,   170,     0,    30,   170,    31,
     0,   172,     0,   178,     0,     0,   143,   206,     3,   202,
    36,   173,   181,    37,     0,     0,     0,    18,   206,     3,
   202,    36,   174,   181,    37,   153,   175,   138,     0,     0,
     0,    18,   206,    36,   176,   181,    37,   153,   177,   138,
     0,   143,   206,     3,    33,     0,   143,   157,   153,   115,
     3,    30,   145,    31,    33,     0,   143,   157,   153,   115,
     3,    33,     0,   143,   157,   153,   115,    69,     0,    71,
     0,     0,    54,     3,    36,   179,   180,    37,     0,   185,
   181,     0,   231,   227,     0,   250,     0,   185,   181,     0,
     0,     0,    54,    36,   182,   181,    37,   183,   181,     0,
     0,     1,   184,   181,     0,   250,     0,   157,   153,    30,
   145,    31,   198,     0,    67,   157,   153,    30,   145,    31,
   199,     0,     3,    30,   145,    31,   208,     0,   113,     3,
    30,   145,    31,   198,     0,    67,   113,     3,    30,    31,
   198,     0,     0,   157,   153,   150,   186,   195,     0,   157,
   153,   155,   150,     0,     0,    66,   157,   153,   187,   195,
     0,    66,   157,   153,    30,   145,    31,   198,     0,    63,
    65,     0,    62,    65,     0,    64,    65,     0,    52,    30,
     3,    31,     0,     0,    84,   188,   185,     0,     0,    58,
   165,    36,   189,   200,    37,    33,     0,    50,     0,    51,
     0,    68,     0,   157,   194,    69,     0,   135,     0,   190,
     0,    55,     3,   239,     0,    55,    30,     3,    31,     3,
   239,     0,     0,   206,     3,    36,   191,   193,    33,     0,
     0,   206,    36,   192,   153,    33,     0,   206,     3,    33,
     0,   157,   154,    30,     0,   158,    30,   110,     0,     3,
    30,   110,     0,   134,     0,    33,     0,   153,     0,   250,
     0,   154,     0,   105,     0,   250,     0,    33,     0,     0,
    32,   153,   150,   196,   195,     0,     0,    32,   153,   155,
   150,   197,   195,     0,   207,    33,     0,   207,    36,     0,
   207,    33,     0,   207,    43,   162,    33,     0,   207,    36,
     0,   200,    32,   201,     0,   201,     0,     3,     0,     3,
    43,   169,     0,    52,    30,     3,    31,     3,     0,    52,
    30,     3,    31,     3,    43,   169,     0,   250,     0,    65,
   203,     0,   250,     0,   204,     0,   203,    32,   204,     0,
     3,     0,    67,     3,     0,    67,   205,     3,     0,   205,
     3,     0,   205,    67,     3,     0,    63,     0,    62,     0,
    64,     0,    61,     0,    41,     0,    42,     0,    40,     0,
    70,    30,   145,    31,     0,   250,     0,   207,   209,    33,
     0,   207,   209,    36,     0,    65,   210,     0,   250,     0,
   211,     0,   210,    32,   211,     0,     3,    30,   212,    31,
     0,     3,    30,    31,     0,   170,     0,   212,    32,   170,
     0,     0,    95,     3,   216,   214,    36,   218,    37,   227,
    96,     0,     0,    95,     3,    30,     3,    31,   217,   215,
   227,    96,     0,   101,     0,   102,     0,   100,     3,   164,
    33,     0,    65,     3,   217,     0,   217,   250,     0,    92,
     0,   250,     0,   223,   218,     0,     0,    97,   219,   218,
     0,     0,    98,   220,   218,     0,     0,    99,   221,   218,
     0,     0,     1,   222,   218,     0,   250,     0,   224,   226,
    33,     0,   157,   153,     0,   157,   153,   155,     0,     0,
    52,    30,     3,    31,   225,   224,     0,    32,   153,   226,
     0,    32,   153,   155,   226,     0,   250,     0,   231,   227,
     0,     0,    54,    36,   228,   227,    37,     0,     0,    52,
    30,     3,    31,   229,   227,     0,     0,     1,   230,   227,
     0,   250,     0,   109,   233,     3,   235,   232,     0,   108,
   233,     3,   235,   232,     0,    33,     0,    36,     0,    30,
   157,    31,     0,    30,   157,   154,    31,     0,   250,     0,
    30,   147,    31,     0,   250,     0,   235,   236,   234,     3,
     0,   250,     0,    65,     0,     3,    65,     0,     3,   239,
   238,     0,   238,    32,     3,   239,     0,   250,     0,    43,
    12,     0,    43,     7,     0,   250,     0,     3,     0,    40,
     0,   243,   242,     0,    32,   243,   242,     0,   250,     0,
   157,   244,     0,   157,   154,   244,     0,   157,   105,   244,
     0,   157,    30,   154,   244,    31,    30,   145,    31,     0,
     3,   247,     0,     0,     3,   155,   245,   247,     0,     0,
   155,   246,   247,     0,   247,     0,    30,   145,    31,     0,
   250,     0,    94,    30,   145,    31,   249,     0,    94,   249,
     0,     3,    33,     0,     7,    33,     0,    36,    37,     0,
     0
};

#endif

#if YYDEBUG != 0
static const short yyrline[] = { 0,
   529,   538,   548,   552,   556,   561,   568,   575,   583,   591,
   597,   602,   609,   618,   643,   647,   655,   661,   667,   676,
   686,   690,   701,   708,   712,   727,   748,   755,   761,   767,
   772,   778,   787,   789,   795,   799,   805,   817,   838,   886,
   916,   952,   989,   997,  1005,  1009,  1018,  1022,  1033,  1043,
  1052,  1062,  1068,  1075,  1081,  1101,  1115,  1132,  1132,  1145,
  1145,  1153,  1163,  1176,  1195,  1207,  1225,  1240,  1261,  1272,
  1289,  1296,  1303,  1308,  1314,  1315,  1316,  1317,  1335,  1339,
  1343,  1359,  1372,  1378,  1390,  1407,  1417,  1421,  1441,  1463,
  1477,  1490,  1500,  1511,  1514,  1522,  1526,  1534,  1535,  1561,
  1562,  1572,  1575,  1576,  1577,  1589,  1598,  1604,  1607,  1612,
  1615,  1620,  1635,  1661,  1680,  1692,  1703,  1713,  1722,  1727,
  1733,  1740,  1741,  1747,  1751,  1753,  1756,  1757,  1760,  1763,
  1770,  1774,  1779,  1789,  1790,  1794,  1798,  1805,  1808,  1816,
  1819,  1822,  1825,  1828,  1831,  1834,  1837,  1840,  1844,  1848,
  1859,  1874,  1879,  1884,  1893,  1899,  1909,  1912,  1915,  1918,
  1921,  1924,  1927,  1930,  1933,  1937,  1941,  1945,  1950,  1959,
  1962,  1968,  1974,  1980,  1990,  1993,  1999,  2005,  2011,  2019,
  2020,  2023,  2023,  2029,  2036,  2048,  2054,  2064,  2065,  2071,
  2072,  2076,  2081,  2081,  2088,  2091,  2103,  2114,  2118,  2122,
  2126,  2130,  2134,  2139,  2144,  2156,  2163,  2169,  2175,  2182,
  2189,  2200,  2212,  2224,  2236,  2248,  2255,  2265,  2276,  2277,
  2280,  2314,  2351,  2385,  2448,  2452,  2475,  2511,  2514,  2527,
  2548,  2568,  2576,  2584,  2594,  2602,  2603,  2604,  2607,  2608,
  2610,  2612,  2613,  2623,  2624,  2627,  2651,  2674,  2695,  2715,
  2735,  2786,  2788,  2819,  2838,  2842,  2862,  2873,  2884,  2895,
  2903,  2905,  2910,  2910,  2928,  2933,  2939,  2947,  2955,  2959,
  2964,  2967,  2990,  2991,  3016,  3017,  3041,  3048,  3053,  3058,
  3063,  3064,  3067,  3068,  3071,  3072,  3073,  3076,  3077,  3101,
  3102,  3127,  3130,  3133,  3136,  3137,  3138,  3141,  3142,  3145,
  3160,  3176,  3191,  3205,  3208,  3211,  3217,  3230,  3239,  3244,
  3249,  3258,  3267,  3278,  3279,  3280,  3284,  3285,  3286,  3289,
  3290,  3291,  3296,  3299,  3302,  3303,  3306,  3307,  3310,  3311,
  3314,  3315,  3323,  3339,  3356,  3367,  3372,  3373,  3374,  3389,
  3390,  3394,  3400,  3405,  3406,  3408,  3409,  3411,  3412,  3414,
  3415,  3428,  3429,  3432,  3439,  3461,  3483,  3486,  3488,  3508,
  3530,  3533,  3534,  3536,  3539,  3542,  3543,  3556,  3557,  3560,
  3580,  3601,  3602,  3605,  3608,  3612,  3620,  3624,  3632,  3638,
  3643,  3644,  3655,  3665,  3672,  3679,  3682,  3685,  3695,  3698,
  3703,  3709,  3713,  3716,  3729,  3743,  3756,  3771,  3775,  3778,
  3784,  3787,  3794,  3800,  3803,  3810,  3811,  3814,  3815,  3816,
  3848
};
#endif


#if YYDEBUG != 0 || defined (YYERROR_VERBOSE)

static const char * const yytname[] = {   "$","error","$undefined.","ID","HBLOCK",
"WRAPPER","POUND","STRING","INCLUDE","IMPORT","WEXTERN","SWIGMACRO","NUM_INT",
"NUM_FLOAT","CHARCONST","NUM_UNSIGNED","NUM_LONG","NUM_ULONG","TYPEDEF","TYPE_INT",
"TYPE_UNSIGNED","TYPE_SHORT","TYPE_LONG","TYPE_FLOAT","TYPE_DOUBLE","TYPE_CHAR",
"TYPE_VOID","TYPE_SIGNED","TYPE_BOOL","TYPE_TYPEDEF","LPAREN","RPAREN","COMMA",
"SEMI","EXTERN","INIT","LBRACE","RBRACE","DEFINE","PERIOD","CONST","STRUCT",
"UNION","EQUAL","SIZEOF","MODULE","LBRACKET","RBRACKET","ILLEGAL","CONSTANT",
"READONLY","READWRITE","NAME","RENAME","ADDMETHODS","PRAGMA","CVALUE","COUT",
"ENUM","ENDDEF","MACRO","CLASS","PRIVATE","PUBLIC","PROTECTED","COLON","STATIC",
"VIRTUAL","FRIEND","OPERATOR","THROW","TEMPLATE","NATIVE","INLINE","RAW_MODE",
"ALPHA_MODE","TEXT","DOC_DISABLE","DOC_ENABLE","STYLE","LOCALSTYLE","TYPEMAP",
"EXCEPT","ECHO","NEW","APPLY","CLEAR","DOCONLY","TITLE","SECTION","SUBSECTION",
"SUBSUBSECTION","LESSTHAN","GREATERTHAN","USERDIRECTIVE","OC_INTERFACE","OC_END",
"OC_PUBLIC","OC_PRIVATE","OC_PROTECTED","OC_CLASS","OC_IMPLEMENT","OC_PROTOCOL",
"OR","XOR","AND","LSHIFT","RSHIFT","PLUS","MINUS","STAR","SLASH","UMINUS","NOT",
"LNOT","DCOLON","program","@1","command","statement","@2","@3","@4","@5","@6",
"@7","@8","@9","@10","@11","@12","@13","@14","@15","doc_enable","typedef_decl",
"@16","@17","typedeflist","pragma","stail","@18","@19","extern","func_end","parms",
"ptail","parm","parm_type","pname","def_args","parm_specifier","parm_specifier_list",
"declaration","stars","array","array2","type","strict_type","opt_signed","opt_unsigned",
"opt_int","definetype","@20","initlist","ename","enumlist","edecl","@21","etype",
"expr","cpp","cpp_class","@22","@23","@24","@25","@26","cpp_other","@27","added_members",
"cpp_members","@28","@29","@30","cpp_member","@31","@32","@33","@34","cpp_pragma",
"@35","@36","nested_decl","type_extra","cpp_tail","@37","@38","cpp_end","cpp_vend",
"cpp_enumlist","cpp_edecl","inherit","base_list","base_specifier","access_specifier",
"cpptype","cpp_const","ctor_end","ctor_initializer","mem_initializer_list","mem_initializer",
"expr_list","objective_c","@39","@40","objc_inherit","objc_protolist","objc_data",
"@41","@42","@43","@44","objc_vars","objc_var","@45","objc_vartail","objc_methods",
"@46","@47","@48","objc_method","objc_end","objc_ret_type","objc_arg_type","objc_args",
"objc_separator","stylelist","styletail","stylearg","tm_method","tm_list","tm_tail",
"typemap_parm","typemap_name","@49","@50","typemap_args","user_directive","uservalue",
"empty", NULL
};
#endif

static const short yyr1[] = {     0,
   117,   116,   118,   118,   120,   119,   121,   119,   122,   119,
   123,   119,   119,   124,   119,   119,   125,   119,   119,   126,
   119,   119,   127,   119,   119,   119,   128,   119,   119,   119,
   119,   119,   129,   119,   130,   119,   119,   119,   119,   119,
   119,   119,   119,   119,   119,   119,   119,   119,   119,   119,
   119,   119,   119,   119,   119,   119,   119,   131,   119,   132,
   133,   119,   119,   119,   119,   119,   119,   119,   119,   119,
   119,   119,   119,   119,   119,   119,   119,   119,   119,   119,
   119,   119,   119,   134,   134,   136,   135,   135,   135,   137,
   135,   138,   138,   138,   139,   139,   139,   140,   141,   140,
   142,   140,   143,   143,   143,   144,   145,   145,   146,   146,
   147,   147,   148,   148,   148,   148,   148,   149,   149,   149,
   149,   150,   150,   150,   150,   150,   151,   151,   152,   152,
   153,   153,   153,   154,   154,   155,   155,   156,   156,   157,
   157,   157,   157,   157,   157,   157,   157,   157,   157,   157,
   157,   157,   157,   157,   157,   157,   158,   158,   158,   158,
   158,   158,   158,   158,   158,   158,   158,   158,   158,   159,
   159,   159,   159,   159,   160,   160,   160,   160,   160,   161,
   161,   163,   162,   162,   162,   164,   164,   165,   165,   166,
   166,   167,   168,   167,   167,   169,   169,   170,   170,   170,
   170,   170,   170,   170,   170,   170,   170,   170,   170,   170,
   170,   170,   170,   170,   170,   170,   170,   170,   171,   171,
   173,   172,   174,   175,   172,   176,   177,   172,   178,   178,
   178,   178,   178,   179,   178,   180,   180,   180,   181,   182,
   183,   181,   184,   181,   181,   185,   185,   185,   185,   185,
   186,   185,   185,   187,   185,   185,   185,   185,   185,   185,
   188,   185,   189,   185,   185,   185,   185,   185,   185,   185,
   190,   190,   191,   190,   192,   190,   190,   190,   190,   190,
   190,   190,   193,   193,   194,   194,   194,   195,   196,   195,
   197,   195,   198,   198,   199,   199,   199,   200,   200,   201,
   201,   201,   201,   201,   202,   202,   203,   203,   204,   204,
   204,   204,   204,   205,   205,   205,   206,   206,   206,   207,
   207,   207,   208,   208,   209,   209,   210,   210,   211,   211,
   212,   212,   214,   213,   215,   213,   213,   213,   213,   216,
   216,   217,   217,   218,   219,   218,   220,   218,   221,   218,
   222,   218,   218,   223,   224,   224,   225,   224,   226,   226,
   226,   227,   228,   227,   229,   227,   230,   227,   227,   231,
   231,   232,   232,   233,   233,   233,   234,   234,   235,   235,
   236,   236,   237,   238,   238,   239,   239,   239,   240,   240,
   241,   242,   242,   243,   243,   243,   243,   244,   245,   244,
   246,   244,   244,   247,   247,   248,   248,   249,   249,   249,
   250
};

static const short yyr2[] = {     0,
     0,     2,     2,     1,     0,     6,     0,     6,     0,     6,
     0,    10,     1,     0,     7,     4,     0,     7,     4,     0,
     9,     7,     0,     8,     7,     7,     0,     9,     1,     1,
     4,     4,     0,     3,     0,     5,     7,    11,     3,     3,
     3,     3,     1,     1,     1,     2,     1,     1,     2,     2,
     2,     2,     2,     1,     3,     3,     4,     0,     8,     0,
     0,    10,     8,     6,     8,     6,    10,     8,     5,     3,
     5,     2,     5,     2,     1,     1,     1,     1,     5,     1,
     2,     2,     1,     1,     1,     0,     5,    10,    11,     0,
     6,     3,     3,     1,     7,     3,     6,     1,     0,     6,
     0,     8,     1,     1,     2,     2,     2,     1,     3,     1,
     1,     2,     2,     3,     3,     8,     3,     2,     2,     1,
     1,     2,     3,     2,     2,     1,     1,     1,     2,     1,
     1,     2,     2,     2,     2,     3,     4,     1,     1,     1,
     2,     2,     1,     1,     1,     1,     1,     2,     2,     2,
     2,     2,     2,     3,     2,     2,     1,     2,     2,     1,
     1,     1,     1,     1,     2,     2,     2,     2,     2,     1,
     1,     2,     2,     1,     1,     1,     2,     2,     1,     1,
     1,     0,     2,     1,     1,     3,     1,     1,     1,     3,
     1,     1,     0,     4,     1,     1,     1,     1,     1,     1,
     1,     1,     4,     4,     1,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3,     2,     2,     3,     1,     1,
     0,     8,     0,     0,    11,     0,     0,     9,     4,     9,
     6,     5,     1,     0,     6,     2,     2,     1,     2,     0,
     0,     7,     0,     3,     1,     6,     7,     5,     6,     6,
     0,     5,     4,     0,     5,     7,     2,     2,     2,     4,
     0,     3,     0,     7,     1,     1,     1,     3,     1,     1,
     3,     6,     0,     6,     0,     5,     3,     3,     3,     3,
     1,     1,     1,     1,     1,     1,     1,     1,     0,     5,
     0,     6,     2,     2,     2,     4,     2,     3,     1,     1,
     3,     5,     7,     1,     2,     1,     1,     3,     1,     2,
     3,     2,     3,     1,     1,     1,     1,     1,     1,     1,
     4,     1,     3,     3,     2,     1,     1,     3,     4,     3,
     1,     3,     0,     9,     0,     9,     1,     1,     4,     3,
     2,     1,     1,     2,     0,     3,     0,     3,     0,     3,
     0,     3,     1,     3,     2,     3,     0,     6,     3,     4,
     1,     2,     0,     5,     0,     6,     0,     3,     1,     5,
     5,     1,     1,     3,     4,     1,     3,     1,     4,     1,
     1,     2,     3,     4,     1,     2,     2,     1,     1,     1,
     2,     3,     1,     2,     3,     3,     8,     2,     0,     4,
     0,     3,     1,     3,     1,     5,     2,     2,     2,     2,
     0
};

static const short yydefact[] = {     1,
   411,     0,     4,    78,    48,     0,    13,     0,     0,     0,
     0,     0,    75,   103,     0,     0,     0,    29,    30,     0,
     0,     0,     0,     0,   233,     0,     0,    44,    43,     0,
    84,    85,     0,     0,     0,     0,     0,    33,     0,     0,
    54,     0,     0,     0,     0,     0,     0,     0,   337,   338,
     3,    45,    47,    80,     0,    76,   219,   220,    77,    83,
   104,    49,     0,     0,     0,     0,   411,   140,   411,   411,
   411,   145,   146,   143,   147,   411,   144,   411,     0,   318,
   319,   411,   317,     0,     0,     0,   105,   411,    50,   411,
   182,     0,     0,     0,   411,     0,   140,   411,   411,   411,
   145,   146,   143,   147,   411,   144,   411,     0,     0,     0,
     0,     0,     0,    51,     0,     0,    46,   411,    81,    82,
     0,     0,    74,    72,    52,    53,     0,   411,     0,     0,
   411,   411,   411,   411,   411,     0,     0,   411,     0,   407,
   411,   411,   411,   411,     0,   411,     0,     0,     0,     0,
     0,     5,     9,     7,     0,   342,     0,   151,   343,   176,
   411,   411,   179,   149,   175,   180,   141,   181,   142,   171,
   411,   411,   174,   148,   170,   150,   152,   156,     0,   189,
   155,   131,     0,    86,     0,   153,   226,   411,    55,   187,
    56,   184,   185,     0,     0,     0,    35,     0,   234,     0,
    96,   388,     0,   149,   141,   142,   148,   150,   152,   156,
   411,     0,   153,     0,     0,   153,   411,   389,   390,     0,
     0,    34,   411,   411,     0,   411,   411,   401,   394,   403,
   405,     0,    70,     0,   391,   393,    39,   385,    40,    41,
    42,   408,   409,     0,   127,   128,     0,   411,   111,   130,
     0,   411,   108,   410,     0,     0,   333,   411,     0,     0,
   133,   135,   134,   411,   132,   411,     0,   153,   411,   411,
   411,     0,   154,   177,   178,   172,   173,    60,   411,   411,
    90,     0,     0,     0,   306,     0,     0,     0,    57,   205,
   198,   199,   200,   201,   202,     0,     0,     0,     0,   183,
    31,   411,    32,   411,   387,   386,     0,     0,   411,   138,
   411,   139,    19,   411,   411,   383,     0,     0,     0,   411,
   399,   398,     0,   411,   411,     0,   396,   395,   411,     0,
   411,     0,     0,     0,     0,   107,   110,   112,   129,   411,
     0,   411,   113,   411,   120,   121,     0,   411,     0,   341,
   339,    58,     0,   411,     0,   411,    16,   229,     0,     0,
     0,     0,     0,   411,     0,     0,    87,    94,   411,   411,
   309,   315,   314,   316,     0,   305,   307,     0,   223,   243,
   411,     0,   282,   265,   266,     0,     0,     0,   411,     0,
     0,     0,     0,     0,   267,   261,     0,   281,   269,   411,
     0,     0,     0,   270,     0,   245,    79,   186,     0,   157,
   411,   411,   411,   162,   163,   160,   164,   411,   161,   411,
     0,     0,     0,     0,     0,   216,   217,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,   103,     0,    36,
   411,   411,     0,     0,     0,   238,   411,   411,     0,   182,
     0,    17,   126,     0,     0,   389,     0,     0,    73,    71,
   411,   404,     0,   136,   411,   402,    69,   392,   411,   117,
   406,   411,   118,   119,   411,   115,   114,   411,   340,     0,
   411,   411,     0,     0,   232,    14,   221,     6,    10,     8,
     0,   192,     0,   191,   195,     0,   411,    91,     0,   310,
     0,     0,   312,     0,     0,     0,   411,     0,   240,   411,
     0,     0,   258,   257,   259,     0,     0,     0,     0,     0,
   286,   411,   285,     0,   287,     0,     0,   239,   153,   275,
   206,   166,   158,   159,   165,   167,   168,     0,   218,   169,
     0,   212,   213,   211,   214,   215,   207,   208,   209,   210,
     0,   105,     0,     0,     0,     0,   376,     0,   235,   236,
   367,     0,     0,   237,     0,   369,    97,     0,   411,   124,
     0,   122,   125,     0,   411,     0,   411,     0,    66,    64,
     0,   400,     0,   137,   384,   109,     0,   335,   351,     0,
   345,   347,   349,     0,     0,     0,   411,   353,     0,   320,
     0,    23,   322,   411,   411,   231,     0,     0,    11,   193,
   411,     0,   411,    92,    93,     0,   311,   308,   313,     0,
   244,   280,     0,     0,     0,   271,     0,   263,   254,     0,
     0,   262,   411,   411,   251,   411,   278,   268,   279,   227,
   277,   273,     0,   204,   203,   411,     0,   153,     0,   411,
   411,     0,     0,   363,   362,    95,    25,    27,   123,     0,
    98,    18,    37,     0,    26,     0,     0,     0,   411,     0,
     0,     0,     0,     0,     0,     0,   355,     0,   344,     0,
     0,   361,     0,   411,     0,    22,    20,     0,    15,     0,
   411,     0,   190,    61,     0,   411,     0,   411,   260,     0,
     0,   411,   411,     0,     0,   411,     0,     0,     0,   253,
   411,   411,     0,   374,     0,     0,   380,     0,   368,     0,
     0,   106,     0,   411,   411,    65,    63,     0,    68,     0,
   411,     0,   352,     0,   346,   348,   350,   356,     0,   411,
   354,    59,     0,    24,     0,     0,   222,     0,   197,   194,
   196,   411,     0,     0,   224,   411,   248,   241,   411,   300,
     0,     0,   299,   304,     0,     0,   288,   255,   411,     0,
   411,   411,   252,   228,   283,     0,   284,   276,   375,     0,
   372,   373,   381,   371,   411,   370,   365,     0,    28,   411,
   411,     0,     0,   397,     0,   336,   357,   334,   411,   359,
   321,    21,   230,    12,    62,    88,     0,   411,     0,     0,
   326,     0,   272,     0,     0,   411,     0,   411,   411,   250,
     0,   411,   249,   246,   274,   382,     0,     0,   378,     0,
   364,     0,    99,     0,    67,   116,     0,   360,    89,   225,
     0,   325,   327,   323,   324,   242,   301,     0,   298,   264,
   256,   289,   411,   293,   294,   247,     0,     0,   379,   366,
   411,     0,    38,   358,     0,     0,     0,     0,   291,   295,
   297,   182,   377,   101,   100,   330,   331,     0,   328,   302,
   290,     0,     0,     0,   329,     0,     0,   292,   296,   102,
   332,   303,     0,     0,     0
};

static const short yydefgoto[] = {   893,
     1,     2,    51,   269,   271,   270,   691,   607,   574,   745,
   685,   723,   127,   302,   481,   364,   752,   398,   399,   280,
   369,   367,    54,   662,   862,   884,    55,   657,   323,   336,
   248,   249,   343,   452,   250,   251,   147,   148,   345,   311,
   252,   401,   174,   164,   167,   194,   195,   189,   179,   493,
   494,   692,   750,   751,    56,    57,   608,   505,   808,   286,
   711,    58,   304,   443,   402,   625,   812,   506,   403,   709,
   704,   519,   702,   404,   712,   643,   776,   524,   768,   868,
   882,   820,   856,   762,   763,   284,   376,   377,   378,   116,
   821,   757,   810,   842,   843,   878,    59,   349,   671,   257,
   158,   595,   674,   675,   676,   672,   596,   597,   837,   681,
   564,   721,   830,   652,   565,   784,   556,   828,   716,   785,
   119,   237,   201,   220,   130,   235,   131,   229,   461,   329,
   230,    60,   140,   253
};

static const short yypact[] = {-32768,
-32768,  1038,-32768,-32768,-32768,   118,-32768,   140,   202,   227,
   286,  2228,-32768,   289,   345,   347,   355,-32768,-32768,    99,
   372,   393,    32,  2255,-32768,   335,  2114,-32768,-32768,   424,
-32768,-32768,   448,   448,   415,   442,   226,-32768,  2298,  2298,
-32768,   450,   456,   458,   476,   364,   520,   525,-32768,-32768,
-32768,-32768,-32768,-32768,  2087,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,   423,   493,   498,   505,   -44,-32768,   465,   519,
   519,-32768,-32768,-32768,-32768,   497,-32768,   451,  2298,-32768,
-32768,   537,-32768,   551,    44,    40,   524,-32768,-32768,-32768,
    50,    42,   552,   526,   513,   558,   535,   465,   519,   519,
   542,   543,   545,   548,   497,   549,   451,  2298,   577,    64,
   563,   591,   594,-32768,    64,   596,-32768,   513,-32768,-32768,
   173,   597,-32768,-32768,-32768,-32768,  1656,   122,   565,   572,
   574,-32768,-32768,-32768,-32768,   576,   592,  2044,   589,-32768,
   158,-32768,     4,   537,   625,   521,   599,   627,    64,   602,
   630,-32768,-32768,-32768,   635,-32768,   631,-32768,-32768,-32768,
   519,   519,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
   519,   519,-32768,-32768,-32768,-32768,-32768,   612,   617,-32768,
-32768,-32768,   550,   613,   143,   -10,-32768,-32768,   626,-32768,
   626,-32768,-32768,   628,   669,   633,-32768,   629,-32768,    46,
-32768,-32768,   358,   636,   639,   646,   648,   649,   650,-32768,
   194,   555,   653,   656,   658,-32768,-32768,   657,-32768,   661,
   663,-32768,   265,  1945,   495,   236,   236,-32768,-32768,-32768,
-32768,  2298,-32768,  2298,-32768,-32768,   664,-32768,   664,   664,
   664,-32768,-32768,   659,-32768,-32768,   671,   668,-32768,-32768,
  2044,   189,-32768,-32768,   692,   700,-32768,-32768,   402,   672,
-32768,-32768,-32768,  2044,-32768,     6,   595,   452,-32768,-32768,
-32768,   675,-32768,-32768,-32768,-32768,-32768,-32768,    69,   677,
-32768,   604,   253,   676,-32768,   881,  1141,   701,-32768,   600,
-32768,-32768,-32768,-32768,-32768,   989,   687,   669,   669,   768,
-32768,   275,-32768,  1809,-32768,-32768,   715,   718,  2044,-32768,
   240,-32768,-32768,   688,  2044,   664,   198,  2298,   403,  2044,
-32768,-32768,   704,   236,   613,  1915,-32768,-32768,   706,   705,
   574,   738,   709,   401,  2044,-32768,-32768,-32768,-32768,   341,
   521,    69,-32768,    69,-32768,-32768,   712,   451,   713,-32768,
-32768,-32768,   714,  2044,    88,   240,-32768,-32768,   717,  1244,
  1347,  1450,   742,   747,   725,    64,-32768,-32768,   677,    69,
-32768,-32768,-32768,-32768,   212,   727,-32768,    51,-32768,-32768,
    80,  2298,-32768,-32768,-32768,   730,   721,   164,   537,   696,
   697,   699,  2298,  2158,-32768,-32768,   763,-32768,-32768,   102,
   737,   739,   881,-32768,    43,-32768,-32768,-32768,   771,-32768,
   465,   519,   519,-32768,-32768,-32768,-32768,   497,-32768,   451,
  2298,   744,   621,   774,  2298,-32768,-32768,   669,   669,   669,
   669,   669,   669,   669,   669,   669,   295,   772,  2298,-32768,
   750,   750,   746,   881,   154,-32768,   513,   513,   755,    23,
   769,-32768,-32768,  2325,   756,-32768,   757,   362,-32768,-32768,
   706,-32768,   758,-32768,   613,-32768,-32768,-32768,   513,-32768,
-32768,   668,-32768,-32768,    69,-32768,-32768,   451,-32768,  1759,
   747,   150,   760,   428,-32768,-32768,-32768,-32768,-32768,-32768,
   759,   749,   377,-32768,-32768,   764,   268,-32768,   762,-32768,
   793,   253,-32768,   794,   881,   881,  1988,   796,-32768,   513,
   797,   766,-32768,-32768,-32768,    64,   800,    64,  1879,   775,
   625,   308,   172,   735,-32768,   710,    64,-32768,   494,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,   669,-32768,-32768,
   778,   781,   506,   480,   512,   512,   342,   342,-32768,-32768,
   255,-32768,    64,   813,  2298,   816,-32768,   819,-32768,-32768,
-32768,   795,   788,-32768,    28,-32768,-32768,   799,   150,-32768,
   823,-32768,-32768,   459,   126,    64,   150,  2298,-32768,-32768,
  2298,-32768,   798,-32768,-32768,-32768,   801,-32768,-32768,   803,
-32768,-32768,-32768,    64,   790,  1759,   802,-32768,   389,-32768,
   806,-32768,-32768,   150,  2044,-32768,   459,   881,-32768,-32768,
   747,   828,  2044,-32768,-32768,   807,-32768,-32768,-32768,   804,
-32768,-32768,   808,   809,   881,-32768,   812,-32768,   814,   817,
   818,-32768,  2044,  2044,-32768,   240,-32768,-32768,-32768,-32768,
-32768,-32768,    64,-32768,-32768,   773,   731,   216,    -7,-32768,
-32768,    28,   846,-32768,-32768,-32768,-32768,   815,-32768,    64,
-32768,-32768,-32768,   820,-32768,   815,   387,   821,  2044,   825,
    55,  1759,   850,  1759,  1759,  1759,   613,    55,-32768,    64,
   824,-32768,   826,  2044,   459,-32768,   815,   830,-32768,   831,
-32768,   624,-32768,-32768,   832,  2044,    64,   150,-32768,   844,
   859,    41,  2044,   470,   834,  2044,   838,   852,   470,-32768,
   677,    64,   861,-32768,   864,   163,-32768,   163,-32768,   865,
   154,-32768,   459,   276,  2044,-32768,-32768,  2298,-32768,   866,
  2044,   829,-32768,   867,-32768,-32768,-32768,-32768,   841,   294,
-32768,-32768,   880,-32768,   459,   879,-32768,  1553,-32768,-32768,
   768,   677,   882,   886,-32768,   848,-32768,-32768,   513,   876,
   890,   390,-32768,-32768,   893,    64,-32768,-32768,   150,   895,
   150,   150,-32768,-32768,-32768,   894,-32768,-32768,-32768,   863,
-32768,-32768,-32768,-32768,   900,-32768,-32768,   901,-32768,  2044,
   240,   909,   908,-32768,   915,-32768,-32768,-32768,   802,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,   918,   677,   949,   434,
-32768,   881,-32768,   624,   950,    41,   921,   150,   341,-32768,
   500,   150,-32768,-32768,-32768,-32768,  2044,   952,-32768,    28,
-32768,   925,-32768,   924,-32768,-32768,  2185,-32768,-32768,-32768,
   930,   929,-32768,-32768,-32768,-32768,-32768,   931,-32768,-32768,
-32768,-32768,   240,-32768,-32768,-32768,   433,   932,-32768,-32768,
   150,   459,-32768,-32768,   554,   949,   961,   470,-32768,-32768,
-32768,    50,-32768,-32768,-32768,-32768,   768,   483,-32768,   923,
-32768,   470,   934,   459,-32768,   669,   624,-32768,-32768,-32768,
   768,-32768,   968,   969,-32768
};

static const short yypgoto[] = {-32768,
-32768,  -185,   843,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,    17,    21,-32768,
-32768,  -359,-32768,  -565,-32768,-32768,    62,  -340,   139,   499,
  -330,   722,  -254,  -318,   723,-32768,   340,   -68,    61,  -262,
   138,    -4,   -97,   -86,    82,  -443,-32768,   -59,  -130,   491,
   365,-32768,  -786,   117,   678,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,  -394,-32768,-32768,-32768,  -283,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,  -682,-32768,
-32768,  -511,-32768,-32768,   161,  -257,-32768,   477,   603,    -6,
  -469,-32768,-32768,-32768,   115,-32768,-32768,-32768,-32768,-32768,
   -46,  -341,-32768,-32768,-32768,-32768,-32768,   147,-32768,  -557,
  -473,-32768,-32768,-32768,   681,   269,   544,-32768,   337,-32768,
   955,   -94,  -103,   673,  -216,   660,   -37,  -113,-32768,-32768,
  -190,-32768,   665,    -1
};


#define	YYLAST		2440


static const short yytable[] = {     3,
    61,   129,   287,   356,   472,    86,   572,   207,   528,   498,
   359,   204,   602,   260,   217,   330,   185,   112,    52,   111,
   444,   473,    53,   714,   365,  -411,   773,   847,   561,   192,
   191,   176,   322,  -131,    95,   354,   193,   486,   239,   240,
   241,   689,   186,   760,   196,   529,   182,   156,   151,   560,
   150,   225,   305,   503,   283,   561,   192,   306,   570,   227,
   208,    96,   464,   193,  -411,   159,   182,   165,   168,   168,
   157,   340,   197,   183,   175,   187,   159,   262,   530,   562,
   180,   563,   259,   360,   361,   362,   190,   476,   190,   477,
   484,   655,   761,   202,   258,   156,   165,   168,   168,   658,
   892,   458,   146,   175,   182,   159,   562,   666,   563,   507,
   620,   621,   327,   328,   225,   499,   202,   504,   157,   744,
   355,    62,   316,  -411,   223,    61,   231,   571,    92,   236,
   238,   238,   238,   238,   687,   441,   442,   614,   466,   159,
   190,   159,   180,    52,   263,   265,    63,    53,   145,    85,
  -411,   224,   169,   146,   561,   324,   485,   789,   663,   168,
   168,   110,   441,   442,   115,   780,   510,   225,   145,   168,
   168,   156,   282,   146,   265,   218,   128,   128,   719,   802,
   205,   206,   800,   344,   285,   881,     3,   255,   228,   600,
  -411,   340,   149,   511,   157,   781,   331,   732,   782,   888,
   456,   637,   584,   635,   739,   562,   521,   563,    64,   312,
   463,   146,   219,   690,   500,   238,   177,   156,   341,   601,
   587,   231,   256,   309,   231,   231,   226,   783,   756,   125,
   700,   146,   126,    65,   225,   632,   665,   219,   223,   225,
   157,   838,   274,   275,   281,   209,   337,   788,   358,   156,
   346,  -411,   276,   277,   679,   371,   350,   646,   512,   823,
   824,   441,   442,   686,   312,   320,   285,     3,     3,     3,
   582,   310,   475,   372,   373,   374,   247,   346,   368,   405,
   283,   225,   450,   321,   406,    61,   228,   228,    66,   424,
   187,   422,   437,   342,   320,    87,   875,   405,   146,   366,
    61,   479,   446,    52,   451,   790,   851,    53,   438,   453,
   225,   300,    61,   225,   372,   373,   374,   710,   890,   375,
   535,   225,   231,   312,   532,   680,   310,   231,    22,   236,
   733,   523,   735,   736,   737,    80,    81,   634,   453,   225,
   346,   326,   346,   567,   568,    25,   159,    88,    89,    90,
   450,   774,   857,   225,   453,    83,   860,    91,    61,    61,
    61,   667,   495,   439,   113,   585,   136,   368,   346,   128,
   137,   128,   451,   536,    93,   454,    52,    52,    52,   159,
    53,    53,    53,   450,   228,   310,   225,   180,   307,   308,
   359,   874,   805,   138,   579,    94,   405,   580,   525,   139,
   474,   406,   353,   136,   581,   451,   626,   137,   611,   165,
   168,   168,   423,   612,   426,   427,   175,   846,   159,   726,
   611,   816,   727,   400,   184,   683,   817,   117,   883,   728,
   551,   588,   554,   288,   351,   459,   139,   405,   460,   557,
   557,   400,   406,   566,   121,   202,   202,   449,   840,   211,
   118,   435,   436,   455,   215,   128,   132,   605,   152,   231,
   606,   791,   133,   312,   134,   870,   844,   202,   871,   845,
   337,   122,   833,   346,   123,   872,   159,   124,   598,   495,
   603,  -169,   135,   160,   358,   161,   162,  -411,   266,   163,
   660,   661,   483,   533,   534,   368,   858,   290,   405,   405,
   852,   766,   767,   406,   406,   748,   291,   292,   202,   293,
   294,   295,   405,   885,   886,   170,   283,   171,   172,    85,
   453,   173,   141,  -169,   296,   310,   641,   142,   153,   642,
   516,   518,   854,   154,   869,   855,   155,   166,   297,   178,
   400,   325,   156,   668,   542,   543,   544,   545,   546,   547,
   548,   549,   550,   181,   198,   200,   290,   615,   537,   188,
   203,   199,   541,   566,  -157,   291,   292,   603,   293,   294,
   295,  -162,  -163,   159,  -160,   603,   553,  -164,  -161,   210,
   715,   400,   636,   296,   876,   431,   432,   433,   434,   435,
   436,   576,   212,   213,   598,   682,   214,   297,   216,   221,
   232,   405,   603,   298,   233,   234,   406,   299,   242,   495,
   430,   431,   432,   433,   434,   435,   436,   594,   405,   433,
   434,   435,   436,   406,   243,   254,   290,   261,   264,   265,
   146,   267,   268,   273,   453,   291,   292,   749,   293,   294,
   295,   272,   400,   400,   285,   623,   285,  -188,   717,   717,
   566,   539,   278,   296,   644,   813,   400,   288,   225,   279,
   289,   303,   298,   301,   313,  -166,   299,   297,  -158,   566,
   598,   290,   598,   598,   598,  -159,   566,  -165,  -167,  -168,
   291,   292,  -169,   293,   294,   295,   314,   315,   317,     3,
   793,   318,   649,   319,   347,   332,   603,   333,   296,   335,
   764,   334,   348,   408,   357,   497,   363,   352,   366,   368,
   777,   379,   297,   370,   409,   128,   425,   447,   128,   566,
   448,   438,   312,   428,   429,   430,   431,   432,   433,   434,
   435,   436,   298,   594,   462,   320,   299,   738,   682,   522,
   469,   467,   478,   688,   482,   400,    61,   470,   480,   492,
   368,   695,   487,   491,   811,   496,   509,   202,   502,   508,
   513,   514,   400,   515,    52,   520,   526,   603,    53,   603,
   603,   707,   708,   531,   538,   527,   540,   298,   552,   555,
   573,   299,   559,   829,   310,   569,   577,   578,   583,   453,
   604,   610,   616,   613,   609,   617,   619,   682,   624,   627,
   799,   628,   630,   638,   633,   405,   368,   730,   645,   594,
   406,   594,   594,   594,   764,   648,   603,   453,   650,   639,
   603,   651,   743,   654,   653,   659,   678,   669,   566,   656,
   694,   670,   673,   680,   754,   684,   696,   283,   698,   699,
   697,   765,   701,   703,   770,   355,   705,   706,   720,   725,
   722,   453,   734,   729,   731,   629,   741,   631,   742,   603,
   746,   759,   753,   792,   769,   128,   640,   747,   771,   795,
   428,   429,   430,   431,   432,   433,   434,   435,   436,   853,
   758,   380,   772,   381,   429,   430,   431,   432,   433,   434,
   435,   436,   647,   778,   779,   787,   794,   797,   382,    97,
    98,    99,   100,   101,   102,   103,   104,   105,   106,   107,
   801,   803,   809,   383,   806,   664,   807,  -411,   814,   815,
   108,    80,    81,   818,   796,   822,   825,   826,   832,   827,
   384,   385,   386,   677,   387,   388,   798,   831,   389,   834,
   835,    83,   390,   391,   392,   836,   393,   394,   395,   400,
   839,   841,   848,   850,   859,   861,   863,    31,    32,   865,
   866,   867,   873,   880,   396,   887,   889,   894,   895,   222,
   586,   599,   338,   339,   594,   693,   849,   501,   618,   440,
   879,   877,   713,   864,   445,   558,   786,   718,   120,   457,
   468,   290,     0,   397,     0,    84,     0,     0,   471,   724,
   291,   292,   891,   293,   294,   295,     0,   410,   411,   412,
   413,   414,   415,   416,   417,   418,   419,   420,   296,   740,
     0,     0,     0,     0,     0,     0,     0,     0,   421,    80,
    81,     0,   297,     0,     0,     0,   755,    -2,     4,     0,
  -411,     5,     6,     7,     0,     8,     9,    10,    11,    83,
     0,   775,     0,     0,     0,    12,  -411,  -411,  -411,  -411,
  -411,  -411,  -411,  -411,  -411,  -411,  -411,     0,     0,     0,
    13,    14,    15,     0,     0,     0,     0,  -411,  -411,  -411,
     0,     0,    16,     0,     0,     0,    17,    18,    19,    20,
    21,    22,    23,     0,     0,  -411,     0,   298,  -411,     0,
     0,   299,     0,    24,     0,   819,     0,     0,    25,    26,
    27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
    37,    38,    39,    40,    41,    42,    43,    44,    45,     0,
     0,    46,    47,     0,     0,     0,     0,    48,    49,    50,
     0,     4,  -411,  -411,     5,     6,     7,  -411,     8,     9,
    10,    11,  -411,     0,     0,     0,     0,     0,    12,  -411,
  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,
     0,     0,     0,    13,    14,    15,     0,   407,     0,     0,
  -411,  -411,  -411,     0,     0,    16,     0,     0,     0,    17,
    18,    19,    20,    21,    22,    23,     0,     0,  -411,     0,
     0,  -411,     0,     0,     0,     0,    24,     0,     0,     0,
     0,    25,    26,    27,    28,    29,    30,    31,    32,    33,
    34,    35,    36,    37,    38,    39,    40,    41,    42,    43,
    44,    45,     0,     0,    46,    47,     0,     0,     0,     0,
    48,    49,    50,     0,     4,  -411,  -411,     5,     6,     7,
  -411,     8,     9,    10,    11,  -411,     0,     0,     0,     0,
     0,    12,  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,
  -411,  -411,  -411,     0,     0,     0,    13,    14,    15,     0,
   488,     0,     0,  -411,  -411,  -411,     0,     0,    16,     0,
     0,     0,    17,    18,    19,    20,    21,    22,    23,     0,
     0,  -411,     0,     0,  -411,     0,     0,     0,     0,    24,
     0,     0,     0,     0,    25,    26,    27,    28,    29,    30,
    31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
    41,    42,    43,    44,    45,     0,     0,    46,    47,     0,
     0,     0,     0,    48,    49,    50,     0,     4,  -411,  -411,
     5,     6,     7,  -411,     8,     9,    10,    11,  -411,     0,
     0,     0,     0,     0,    12,  -411,  -411,  -411,  -411,  -411,
  -411,  -411,  -411,  -411,  -411,  -411,     0,     0,     0,    13,
    14,    15,     0,   489,     0,     0,  -411,  -411,  -411,     0,
     0,    16,     0,     0,     0,    17,    18,    19,    20,    21,
    22,    23,     0,     0,  -411,     0,     0,  -411,     0,     0,
     0,     0,    24,     0,     0,     0,     0,    25,    26,    27,
    28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
    38,    39,    40,    41,    42,    43,    44,    45,     0,     0,
    46,    47,     0,     0,     0,     0,    48,    49,    50,     0,
     4,  -411,  -411,     5,     6,     7,  -411,     8,     9,    10,
    11,  -411,     0,     0,     0,     0,     0,    12,  -411,  -411,
  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,     0,
     0,     0,    13,    14,    15,     0,   490,     0,     0,  -411,
  -411,  -411,     0,     0,    16,     0,     0,     0,    17,    18,
    19,    20,    21,    22,    23,     0,     0,  -411,     0,     0,
  -411,     0,     0,     0,     0,    24,     0,     0,     0,     0,
    25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
    35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
    45,     0,     0,    46,    47,     0,     0,     0,     0,    48,
    49,    50,     0,     4,  -411,  -411,     5,     6,     7,  -411,
     8,     9,    10,    11,  -411,     0,     0,     0,     0,     0,
    12,  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,  -411,
  -411,  -411,     0,     0,     0,    13,    14,    15,     0,   804,
     0,     0,  -411,  -411,  -411,     0,     0,    16,     0,     0,
     0,    17,    18,    19,    20,    21,    22,    23,     0,     0,
  -411,     0,     0,  -411,     0,     0,     0,     0,    24,     0,
     0,     0,     0,    25,    26,    27,    28,    29,    30,    31,
    32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
    42,    43,    44,    45,     0,     0,    46,    47,     0,     0,
     0,     0,    48,    49,    50,     0,     4,  -411,  -411,     5,
     6,     7,  -411,     8,     9,    10,    11,  -411,     0,     0,
     0,     0,     0,    12,  -411,  -411,  -411,  -411,  -411,  -411,
  -411,  -411,  -411,  -411,  -411,     0,     0,     0,    13,    14,
    15,     0,     0,     0,     0,  -411,  -411,  -411,     0,     0,
    16,     0,     0,     0,    17,    18,    19,    20,    21,    22,
    23,     0,     0,  -411,     0,     0,  -411,     0,     0,     0,
     0,    24,     0,     0,     0,     0,    25,    26,    27,    28,
    29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
    39,    40,    41,    42,    43,    44,    45,     0,     0,    46,
    47,     0,     0,     0,     0,    48,    49,    50,     0,   589,
  -411,    67,     0,     0,     0,  -411,     0,     0,     0,     0,
  -411,     0,     0,     0,     0,     0,     0,    68,    69,    70,
    71,    72,    73,    74,    75,    76,    77,    78,     0,     0,
     0,     0,     0,     0,     0,  -411,     0,     0,    79,    80,
    81,     0,     0,     0,     0,     0,     0,     0,     0,     0,
   590,   381,     0,     0,     0,     0,   109,     0,     0,    83,
     0,     0,     0,     0,     0,     0,   382,    97,    98,    99,
   100,   101,   102,   103,   104,   105,   106,   107,     0,     0,
     0,   383,     0,     0,     0,     0,     0,     0,   108,    80,
    81,     0,     0,     0,     0,   591,   592,   593,   384,   385,
   386,     0,     0,   388,     0,     0,   389,     0,     0,    83,
   390,   391,   392,    84,   393,   394,   395,     0,     0,     0,
     0,   381,     0,     0,     0,    31,    32,     0,     0,     0,
     0,     0,   396,     0,     0,     0,   382,    97,    98,    99,
   100,   101,   102,   103,   104,   105,   106,   107,     0,     0,
     0,   383,     0,     0,     0,     0,   441,   442,   108,    80,
    81,   397,     0,    84,     0,     0,     0,     0,   384,   385,
   386,     0,     0,   388,     0,     0,   389,     0,     0,    83,
   390,   391,   392,     0,   393,   394,   395,    67,     0,     0,
     0,     0,     0,     0,     0,    31,    32,     0,     0,     0,
     0,   465,   396,    68,    69,    70,    71,    72,    73,    74,
    75,    76,    77,    78,     0,     0,     0,     0,     0,     0,
     0,     0,     0,   244,    79,    80,    81,     0,     0,     0,
    67,   397,     0,    84,     0,     0,     0,     0,     0,     0,
   245,   246,   109,     0,     0,    83,    68,    69,    70,    71,
    72,    73,    74,    75,    76,    77,    78,   428,   429,   430,
   431,   432,   433,   434,   435,   436,   244,    79,    80,    81,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,   245,   246,   109,    67,     0,    83,     0,
     0,     0,     0,     0,   146,     0,     0,     0,     0,    84,
     0,     0,    68,    69,    70,    71,    72,    73,    74,    75,
    76,    77,    78,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   244,    79,    80,    81,     0,     0,     0,   143,
     0,     0,     0,     0,     0,     0,     0,   622,     0,   245,
   246,   109,    84,     0,    83,    97,    98,    99,   100,   101,
   102,   103,   104,   105,   106,   107,    67,   114,     0,     0,
     0,     0,     0,     0,     0,     0,   108,    80,    81,     0,
     0,     0,    68,    69,    70,    71,    72,    73,    74,    75,
    76,    77,    78,     0,   144,     0,     0,    83,     0,     0,
     0,     0,     0,    79,    80,    81,     0,     0,    84,     0,
    67,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,   109,     0,     0,    83,     0,    68,    69,    70,    71,
    72,    73,    74,    75,    76,    77,    78,    67,     0,     0,
     0,   145,     0,     0,     0,     0,   146,    79,    80,    81,
     0,    84,     0,    68,    69,    70,    71,    72,    73,    74,
    75,    76,    77,    78,     0,   109,     0,     0,    83,     0,
     0,     0,     0,     0,    79,    80,    81,     0,    84,     0,
    67,     0,     0,     0,     0,     0,   590,     0,     0,     0,
     0,     0,   109,     0,     0,    83,    68,    69,    70,    71,
    72,    73,    74,    75,    76,    77,    78,    67,     0,     0,
     0,     0,     0,     0,     0,     0,     0,    79,    80,    81,
   517,     0,    84,    97,    98,    99,   100,   101,   102,   103,
   104,   105,   106,   107,     0,    82,     0,     0,    83,     0,
     0,     0,     0,     0,   108,    80,    81,     0,     0,    84,
    67,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   109,     0,     0,    83,    68,    69,    70,    71,
    72,    73,    74,    75,    76,    77,    78,   575,     0,     0,
     0,     0,     0,     0,     0,     0,     0,    79,    80,    81,
     0,     0,    84,    68,    69,    70,    71,    72,    73,    74,
    75,    76,    77,    78,     0,   109,     0,     0,    83,     0,
     0,     0,     0,     0,    79,    80,    81,     0,     0,    84,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   109,     0,     0,    83,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,    84,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,    84
};

static const short yycheck[] = {     1,
     2,    39,   188,   266,   335,    12,   450,   105,   403,   369,
   268,    98,   482,   144,   118,   232,    85,    24,     2,    24,
   304,   340,     2,    31,   279,    36,   709,   814,     1,     7,
    90,    78,   223,    30,     3,    30,    14,   356,   133,   134,
   135,   607,     3,     3,     3,     3,     3,    92,    55,   444,
    55,    46,     7,     3,    65,     1,     7,    12,    36,   128,
   107,    30,   325,    14,    37,    67,     3,    69,    70,    71,
   115,     3,    31,    30,    76,    36,    78,   146,    36,    52,
    82,    54,   142,   269,   270,   271,    88,   342,    90,   344,
     3,   565,    52,    95,   141,    92,    98,    99,   100,   569,
   887,   318,   110,   105,     3,   107,    52,   577,    54,    30,
   505,   506,   226,   227,    46,   370,   118,    67,   115,   685,
   115,     4,   217,    96,     3,   127,   128,   105,    30,   131,
   132,   133,   134,   135,   604,   108,   109,   497,   329,   141,
   142,   143,   144,   127,   146,     3,     7,   127,   105,    12,
    96,    30,    71,   110,     1,   224,    69,   723,    33,   161,
   162,    24,   108,   109,    27,     3,     3,    46,   105,   171,
   172,    92,    30,   110,     3,     3,    39,    40,   652,   745,
    99,   100,   740,   252,   186,   868,   188,    30,   128,    40,
    37,     3,    55,    30,   115,    33,   234,   671,    36,   882,
     3,    30,   465,   522,   678,    52,   105,    54,     7,   211,
   324,   110,    40,   608,     3,   217,    79,    92,    30,    70,
   475,   223,    65,    30,   226,   227,   105,    65,   698,     4,
   625,   110,     7,     7,    46,   519,   577,    40,     3,    46,
   115,   799,   161,   162,   184,   108,   248,   721,    33,    92,
   252,    36,   171,   172,   596,     3,   258,     3,   389,   771,
   772,   108,   109,   604,   266,    30,   268,   269,   270,   271,
   461,   211,   341,    62,    63,    64,   138,   279,   280,   286,
    65,    46,    43,   223,   286,   287,   226,   227,     3,   296,
    36,   296,    18,   105,    30,     7,   862,   304,   110,    32,
   302,   348,   304,   287,    65,    30,   818,   287,    34,   311,
    46,   195,   314,    46,    62,    63,    64,   636,   884,    67,
   418,    46,   324,   325,   411,    32,   266,   329,    54,   331,
   672,   400,   674,   675,   676,    41,    42,    30,   340,    46,
   342,   225,   344,   447,   448,    71,   348,     3,     4,     3,
    43,   711,   822,    46,   356,    61,   830,     3,   360,   361,
   362,   578,   364,   302,    30,   469,     3,   369,   370,   232,
     7,   234,    65,   420,     3,   314,   360,   361,   362,   381,
   360,   361,   362,    43,   324,   325,    46,   389,    31,    32,
   648,   861,   752,    30,    33,     3,   403,    36,   400,    36,
   340,   403,   264,     3,    43,    65,   510,     7,    32,   411,
   412,   413,   296,    37,   298,   299,   418,   812,   420,    33,
    32,    32,    36,   286,    85,    37,    37,     4,   872,    43,
   437,   478,   439,    32,    33,    33,    36,   444,    36,   441,
   442,   304,   444,   445,    30,   447,   448,   309,   808,   110,
     3,   110,   111,   315,   115,   318,     7,    30,    36,   461,
    33,   724,     7,   465,     7,    33,    33,   469,    36,    36,
   472,    30,   791,   475,    33,    43,   478,    36,   480,   481,
   482,    30,     7,    19,    33,    21,    22,    36,   149,    25,
    32,    33,   354,   412,   413,   497,   827,     3,   505,   506,
   819,    32,    33,   505,   506,   691,    12,    13,   510,    15,
    16,    17,   519,    31,    32,    19,    65,    21,    22,   382,
   522,    25,     3,    30,    30,   465,    33,     3,    36,    36,
   393,   394,    33,    36,   853,    36,    32,    19,    44,     3,
   403,    47,    92,   581,   428,   429,   430,   431,   432,   433,
   434,   435,   436,     3,     3,    43,     3,   497,   421,    36,
     3,    36,   425,   565,    30,    12,    13,   569,    15,    16,
    17,    30,    30,   575,    30,   577,   439,    30,    30,     3,
   649,   444,   522,    30,    31,   106,   107,   108,   109,   110,
   111,   454,    30,     3,   596,   597,     3,    44,     3,     3,
    36,   608,   604,   109,    33,    32,   608,   113,    33,   611,
   105,   106,   107,   108,   109,   110,   111,   480,   625,   108,
   109,   110,   111,   625,    33,    37,     3,     3,    30,     3,
   110,    30,     3,     3,   636,    12,    13,    14,    15,    16,
    17,     7,   505,   506,   646,   507,   648,    36,   650,   651,
   652,    31,    36,    30,   538,   759,   519,    32,    46,   110,
    33,    33,   109,    31,   110,    30,   113,    44,    30,   671,
   672,     3,   674,   675,   676,    30,   678,    30,    30,    30,
    12,    13,    30,    15,    16,    17,    31,    30,    32,   691,
   728,    31,   555,    31,     3,    32,   698,    39,    30,    32,
   702,    31,     3,     3,   110,   366,    32,    36,    32,   711,
   712,    36,    44,   110,   115,   578,    30,     3,   581,   721,
     3,    34,   724,   103,   104,   105,   106,   107,   108,   109,
   110,   111,   109,   596,    31,    30,   113,   677,   740,   400,
     3,    37,    31,   605,    31,   608,   748,    39,    36,     3,
   752,   613,    36,    12,   756,    31,    36,   759,    32,    30,
    65,    65,   625,    65,   748,     3,    30,   769,   748,   771,
   772,   633,   634,     3,    31,    37,     3,   109,     7,    30,
    12,   113,    37,   785,   724,    31,    31,    31,    31,   791,
    31,    43,    31,    30,    36,     3,     3,   799,     3,     3,
   740,    36,     3,    69,    30,   812,   808,   669,    31,   672,
   812,   674,   675,   676,   816,     3,   818,   819,     3,   110,
   822,     3,   684,    36,    30,     3,    37,    30,   830,    31,
     3,    31,    30,    32,   696,    30,    30,    65,    31,    31,
    37,   703,    31,    30,   706,   115,    30,    30,     3,    30,
    36,   853,     3,    33,    30,   516,    33,   518,    33,   861,
    31,     3,    31,   725,    31,   728,   527,    37,    31,   731,
   103,   104,   105,   106,   107,   108,   109,   110,   111,   819,
    37,     1,    31,     3,   104,   105,   106,   107,   108,   109,
   110,   111,   553,    33,    31,    31,    31,    31,    18,    19,
    20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
    31,    33,    65,    33,    33,   576,    31,    37,    43,    30,
    40,    41,    42,    31,    96,    31,    33,    65,   790,    30,
    50,    51,    52,   594,    54,    55,    96,    37,    58,    31,
    33,    61,    62,    63,    64,    31,    66,    67,    68,   812,
    33,     3,     3,    33,     3,    31,    33,    77,    78,    30,
    32,    31,    31,     3,    84,    43,    33,     0,     0,   127,
   472,   481,   251,   251,   837,   611,   816,   375,   502,   302,
   866,   865,   643,   837,   304,   442,   718,   651,    34,   317,
   331,     3,    -1,   113,    -1,   115,    -1,    -1,   334,   660,
    12,    13,   886,    15,    16,    17,    -1,    19,    20,    21,
    22,    23,    24,    25,    26,    27,    28,    29,    30,   680,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    40,    41,
    42,    -1,    44,    -1,    -1,    -1,   697,     0,     1,    -1,
     3,     4,     5,     6,    -1,     8,     9,    10,    11,    61,
    -1,   712,    -1,    -1,    -1,    18,    19,    20,    21,    22,
    23,    24,    25,    26,    27,    28,    29,    -1,    -1,    -1,
    33,    34,    35,    -1,    -1,    -1,    -1,    40,    41,    42,
    -1,    -1,    45,    -1,    -1,    -1,    49,    50,    51,    52,
    53,    54,    55,    -1,    -1,    58,    -1,   109,    61,    -1,
    -1,   113,    -1,    66,    -1,   766,    -1,    -1,    71,    72,
    73,    74,    75,    76,    77,    78,    79,    80,    81,    82,
    83,    84,    85,    86,    87,    88,    89,    90,    91,    -1,
    -1,    94,    95,    -1,    -1,    -1,    -1,   100,   101,   102,
    -1,     1,   105,     3,     4,     5,     6,   110,     8,     9,
    10,    11,   115,    -1,    -1,    -1,    -1,    -1,    18,    19,
    20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
    -1,    -1,    -1,    33,    34,    35,    -1,    37,    -1,    -1,
    40,    41,    42,    -1,    -1,    45,    -1,    -1,    -1,    49,
    50,    51,    52,    53,    54,    55,    -1,    -1,    58,    -1,
    -1,    61,    -1,    -1,    -1,    -1,    66,    -1,    -1,    -1,
    -1,    71,    72,    73,    74,    75,    76,    77,    78,    79,
    80,    81,    82,    83,    84,    85,    86,    87,    88,    89,
    90,    91,    -1,    -1,    94,    95,    -1,    -1,    -1,    -1,
   100,   101,   102,    -1,     1,   105,     3,     4,     5,     6,
   110,     8,     9,    10,    11,   115,    -1,    -1,    -1,    -1,
    -1,    18,    19,    20,    21,    22,    23,    24,    25,    26,
    27,    28,    29,    -1,    -1,    -1,    33,    34,    35,    -1,
    37,    -1,    -1,    40,    41,    42,    -1,    -1,    45,    -1,
    -1,    -1,    49,    50,    51,    52,    53,    54,    55,    -1,
    -1,    58,    -1,    -1,    61,    -1,    -1,    -1,    -1,    66,
    -1,    -1,    -1,    -1,    71,    72,    73,    74,    75,    76,
    77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
    87,    88,    89,    90,    91,    -1,    -1,    94,    95,    -1,
    -1,    -1,    -1,   100,   101,   102,    -1,     1,   105,     3,
     4,     5,     6,   110,     8,     9,    10,    11,   115,    -1,
    -1,    -1,    -1,    -1,    18,    19,    20,    21,    22,    23,
    24,    25,    26,    27,    28,    29,    -1,    -1,    -1,    33,
    34,    35,    -1,    37,    -1,    -1,    40,    41,    42,    -1,
    -1,    45,    -1,    -1,    -1,    49,    50,    51,    52,    53,
    54,    55,    -1,    -1,    58,    -1,    -1,    61,    -1,    -1,
    -1,    -1,    66,    -1,    -1,    -1,    -1,    71,    72,    73,
    74,    75,    76,    77,    78,    79,    80,    81,    82,    83,
    84,    85,    86,    87,    88,    89,    90,    91,    -1,    -1,
    94,    95,    -1,    -1,    -1,    -1,   100,   101,   102,    -1,
     1,   105,     3,     4,     5,     6,   110,     8,     9,    10,
    11,   115,    -1,    -1,    -1,    -1,    -1,    18,    19,    20,
    21,    22,    23,    24,    25,    26,    27,    28,    29,    -1,
    -1,    -1,    33,    34,    35,    -1,    37,    -1,    -1,    40,
    41,    42,    -1,    -1,    45,    -1,    -1,    -1,    49,    50,
    51,    52,    53,    54,    55,    -1,    -1,    58,    -1,    -1,
    61,    -1,    -1,    -1,    -1,    66,    -1,    -1,    -1,    -1,
    71,    72,    73,    74,    75,    76,    77,    78,    79,    80,
    81,    82,    83,    84,    85,    86,    87,    88,    89,    90,
    91,    -1,    -1,    94,    95,    -1,    -1,    -1,    -1,   100,
   101,   102,    -1,     1,   105,     3,     4,     5,     6,   110,
     8,     9,    10,    11,   115,    -1,    -1,    -1,    -1,    -1,
    18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
    28,    29,    -1,    -1,    -1,    33,    34,    35,    -1,    37,
    -1,    -1,    40,    41,    42,    -1,    -1,    45,    -1,    -1,
    -1,    49,    50,    51,    52,    53,    54,    55,    -1,    -1,
    58,    -1,    -1,    61,    -1,    -1,    -1,    -1,    66,    -1,
    -1,    -1,    -1,    71,    72,    73,    74,    75,    76,    77,
    78,    79,    80,    81,    82,    83,    84,    85,    86,    87,
    88,    89,    90,    91,    -1,    -1,    94,    95,    -1,    -1,
    -1,    -1,   100,   101,   102,    -1,     1,   105,     3,     4,
     5,     6,   110,     8,     9,    10,    11,   115,    -1,    -1,
    -1,    -1,    -1,    18,    19,    20,    21,    22,    23,    24,
    25,    26,    27,    28,    29,    -1,    -1,    -1,    33,    34,
    35,    -1,    -1,    -1,    -1,    40,    41,    42,    -1,    -1,
    45,    -1,    -1,    -1,    49,    50,    51,    52,    53,    54,
    55,    -1,    -1,    58,    -1,    -1,    61,    -1,    -1,    -1,
    -1,    66,    -1,    -1,    -1,    -1,    71,    72,    73,    74,
    75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
    85,    86,    87,    88,    89,    90,    91,    -1,    -1,    94,
    95,    -1,    -1,    -1,    -1,   100,   101,   102,    -1,     1,
   105,     3,    -1,    -1,    -1,   110,    -1,    -1,    -1,    -1,
   115,    -1,    -1,    -1,    -1,    -1,    -1,    19,    20,    21,
    22,    23,    24,    25,    26,    27,    28,    29,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    37,    -1,    -1,    40,    41,
    42,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    52,     3,    -1,    -1,    -1,    -1,    58,    -1,    -1,    61,
    -1,    -1,    -1,    -1,    -1,    -1,    18,    19,    20,    21,
    22,    23,    24,    25,    26,    27,    28,    29,    -1,    -1,
    -1,    33,    -1,    -1,    -1,    -1,    -1,    -1,    40,    41,
    42,    -1,    -1,    -1,    -1,    97,    98,    99,    50,    51,
    52,    -1,    -1,    55,    -1,    -1,    58,    -1,    -1,    61,
    62,    63,    64,   115,    66,    67,    68,    -1,    -1,    -1,
    -1,     3,    -1,    -1,    -1,    77,    78,    -1,    -1,    -1,
    -1,    -1,    84,    -1,    -1,    -1,    18,    19,    20,    21,
    22,    23,    24,    25,    26,    27,    28,    29,    -1,    -1,
    -1,    33,    -1,    -1,    -1,    -1,   108,   109,    40,    41,
    42,   113,    -1,   115,    -1,    -1,    -1,    -1,    50,    51,
    52,    -1,    -1,    55,    -1,    -1,    58,    -1,    -1,    61,
    62,    63,    64,    -1,    66,    67,    68,     3,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    77,    78,    -1,    -1,    -1,
    -1,    47,    84,    19,    20,    21,    22,    23,    24,    25,
    26,    27,    28,    29,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    39,    40,    41,    42,    -1,    -1,    -1,
     3,   113,    -1,   115,    -1,    -1,    -1,    -1,    -1,    -1,
    56,    57,    58,    -1,    -1,    61,    19,    20,    21,    22,
    23,    24,    25,    26,    27,    28,    29,   103,   104,   105,
   106,   107,   108,   109,   110,   111,    39,    40,    41,    42,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    56,    57,    58,     3,    -1,    61,    -1,
    -1,    -1,    -1,    -1,   110,    -1,    -1,    -1,    -1,   115,
    -1,    -1,    19,    20,    21,    22,    23,    24,    25,    26,
    27,    28,    29,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    39,    40,    41,    42,    -1,    -1,    -1,     3,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,   110,    -1,    56,
    57,    58,   115,    -1,    61,    19,    20,    21,    22,    23,
    24,    25,    26,    27,    28,    29,     3,     4,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    40,    41,    42,    -1,
    -1,    -1,    19,    20,    21,    22,    23,    24,    25,    26,
    27,    28,    29,    -1,    58,    -1,    -1,    61,    -1,    -1,
    -1,    -1,    -1,    40,    41,    42,    -1,    -1,   115,    -1,
     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    58,    -1,    -1,    61,    -1,    19,    20,    21,    22,
    23,    24,    25,    26,    27,    28,    29,     3,    -1,    -1,
    -1,   105,    -1,    -1,    -1,    -1,   110,    40,    41,    42,
    -1,   115,    -1,    19,    20,    21,    22,    23,    24,    25,
    26,    27,    28,    29,    -1,    58,    -1,    -1,    61,    -1,
    -1,    -1,    -1,    -1,    40,    41,    42,    -1,   115,    -1,
     3,    -1,    -1,    -1,    -1,    -1,    52,    -1,    -1,    -1,
    -1,    -1,    58,    -1,    -1,    61,    19,    20,    21,    22,
    23,    24,    25,    26,    27,    28,    29,     3,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    40,    41,    42,
   113,    -1,   115,    19,    20,    21,    22,    23,    24,    25,
    26,    27,    28,    29,    -1,    58,    -1,    -1,    61,    -1,
    -1,    -1,    -1,    -1,    40,    41,    42,    -1,    -1,   115,
     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    58,    -1,    -1,    61,    19,    20,    21,    22,
    23,    24,    25,    26,    27,    28,    29,     3,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    40,    41,    42,
    -1,    -1,   115,    19,    20,    21,    22,    23,    24,    25,
    26,    27,    28,    29,    -1,    58,    -1,    -1,    61,    -1,
    -1,    -1,    -1,    -1,    40,    41,    42,    -1,    -1,   115,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    58,    -1,    -1,    61,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,   115,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115
};
/* -*-C-*-  Note some compilers choke on comments on `#line' lines.  */
#line 3 "/usr/lib/bison.simple"
/* This file comes from bison-1.27.  */

/* Skeleton output parser for bison,
   Copyright (C) 1984, 1989, 1990 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* This is the parser code that is written into each bison parser
  when the %semantic_parser declaration is not specified in the grammar.
  It was written by Richard Stallman by simplifying the hairy parser
  used when %semantic_parser is specified.  */

#ifndef YYSTACK_USE_ALLOCA
#ifdef alloca
#define YYSTACK_USE_ALLOCA
#else /* alloca not defined */
#ifdef __GNUC__
#define YYSTACK_USE_ALLOCA
#define alloca __builtin_alloca
#else /* not GNU C.  */
#if (!defined (__STDC__) && defined (sparc)) || defined (__sparc__) || defined (__sparc) || defined (__sgi) || (defined (__sun) && defined (__i386))
#define YYSTACK_USE_ALLOCA
#include <alloca.h>
#else /* not sparc */
/* We think this test detects Watcom and Microsoft C.  */
/* This used to test MSDOS, but that is a bad idea
   since that symbol is in the user namespace.  */
#if (defined (_MSDOS) || defined (_MSDOS_)) && !defined (__TURBOC__)
#if 0 /* No need for malloc.h, which pollutes the namespace;
	 instead, just don't use alloca.  */
#include <malloc.h>
#endif
#else /* not MSDOS, or __TURBOC__ */
#if defined(_AIX)
/* I don't know what this was needed for, but it pollutes the namespace.
   So I turned it off.   rms, 2 May 1997.  */
/* #include <malloc.h>  */
 #pragma alloca
#define YYSTACK_USE_ALLOCA
#else /* not MSDOS, or __TURBOC__, or _AIX */
#if 0
#ifdef __hpux /* haible@ilog.fr says this works for HPUX 9.05 and up,
		 and on HPUX 10.  Eventually we can turn this on.  */
#define YYSTACK_USE_ALLOCA
#define alloca __builtin_alloca
#endif /* __hpux */
#endif
#endif /* not _AIX */
#endif /* not MSDOS, or __TURBOC__ */
#endif /* not sparc */
#endif /* not GNU C */
#endif /* alloca not defined */
#endif /* YYSTACK_USE_ALLOCA not defined */

#ifdef YYSTACK_USE_ALLOCA
#define YYSTACK_ALLOC alloca
#else
#define YYSTACK_ALLOC malloc
#endif

/* Note: there must be only one dollar sign in this file.
   It is replaced by the list of actions, each action
   as one case of the switch.  */

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0
#define YYACCEPT	goto yyacceptlab
#define YYABORT 	goto yyabortlab
#define YYERROR		goto yyerrlab1
/* Like YYERROR except do call yyerror.
   This remains here temporarily to ease the
   transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */
#define YYFAIL		goto yyerrlab
#define YYRECOVERING()  (!!yyerrstatus)
#define YYBACKUP(token, value) \
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    { yychar = (token), yylval = (value);			\
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { yyerror ("syntax error: cannot back up"); YYERROR; }	\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

#ifndef YYPURE
#define YYLEX		yylex()
#endif

#ifdef YYPURE
#ifdef YYLSP_NEEDED
#ifdef YYLEX_PARAM
#define YYLEX		yylex(&yylval, &yylloc, YYLEX_PARAM)
#else
#define YYLEX		yylex(&yylval, &yylloc)
#endif
#else /* not YYLSP_NEEDED */
#ifdef YYLEX_PARAM
#define YYLEX		yylex(&yylval, YYLEX_PARAM)
#else
#define YYLEX		yylex(&yylval)
#endif
#endif /* not YYLSP_NEEDED */
#endif

/* If nonreentrant, generate the variables here */

#ifndef YYPURE

int	yychar;			/*  the lookahead symbol		*/
YYSTYPE	yylval;			/*  the semantic value of the		*/
				/*  lookahead symbol			*/

#ifdef YYLSP_NEEDED
YYLTYPE yylloc;			/*  location data for the lookahead	*/
				/*  symbol				*/
#endif

int yynerrs;			/*  number of parse errors so far       */
#endif  /* not YYPURE */

#if YYDEBUG != 0
int yydebug;			/*  nonzero means print parse trace	*/
/* Since this is uninitialized, it does not stop multiple parsers
   from coexisting.  */
#endif

/*  YYINITDEPTH indicates the initial size of the parser's stacks	*/

#ifndef	YYINITDEPTH
#define YYINITDEPTH 200
#endif

/*  YYMAXDEPTH is the maximum size the stacks can grow to
    (effective only if the built-in stack extension method is used).  */

#if YYMAXDEPTH == 0
#undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 10000
#endif

/* Define __yy_memcpy.  Note that the size argument
   should be passed with type unsigned int, because that is what the non-GCC
   definitions require.  With GCC, __builtin_memcpy takes an arg
   of type size_t, but it can handle unsigned int.  */

#if __GNUC__ > 1		/* GNU C and GNU C++ define this.  */
#define __yy_memcpy(TO,FROM,COUNT)	__builtin_memcpy(TO,FROM,COUNT)
#else				/* not GNU C or C++ */
#ifndef __cplusplus

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_memcpy (to, from, count)
     char *to;
     char *from;
     unsigned int count;
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#else /* __cplusplus */

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_memcpy (char *to, char *from, unsigned int count)
{
  register char *t = to;
  register char *f = from;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#endif
#endif

#line 216 "/usr/lib/bison.simple"

/* The user can define YYPARSE_PARAM as the name of an argument to be passed
   into yyparse.  The argument should have type void *.
   It should actually point to an object.
   Grammar actions can access the variable by casting it
   to the proper pointer type.  */

#ifdef YYPARSE_PARAM
#ifdef __cplusplus
#define YYPARSE_PARAM_ARG void *YYPARSE_PARAM
#define YYPARSE_PARAM_DECL
#else /* not __cplusplus */
#define YYPARSE_PARAM_ARG YYPARSE_PARAM
#define YYPARSE_PARAM_DECL void *YYPARSE_PARAM;
#endif /* not __cplusplus */
#else /* not YYPARSE_PARAM */
#define YYPARSE_PARAM_ARG
#define YYPARSE_PARAM_DECL
#endif /* not YYPARSE_PARAM */

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
#ifdef YYPARSE_PARAM
int yyparse (void *);
#else
int yyparse (void);
#endif
#endif

int
yyparse(YYPARSE_PARAM_ARG)
     YYPARSE_PARAM_DECL
{
  register int yystate;
  register int yyn;
  register short *yyssp;
  register YYSTYPE *yyvsp;
  int yyerrstatus;	/*  number of tokens to shift before error messages enabled */
  int yychar1 = 0;		/*  lookahead token as an internal (translated) token number */

  short	yyssa[YYINITDEPTH];	/*  the state stack			*/
  YYSTYPE yyvsa[YYINITDEPTH];	/*  the semantic value stack		*/

  short *yyss = yyssa;		/*  refer to the stacks thru separate pointers */
  YYSTYPE *yyvs = yyvsa;	/*  to allow yyoverflow to reallocate them elsewhere */

#ifdef YYLSP_NEEDED
  YYLTYPE yylsa[YYINITDEPTH];	/*  the location stack			*/
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)
#else
#define YYPOPSTACK   (yyvsp--, yyssp--)
#endif

  int yystacksize = YYINITDEPTH;
  int yyfree_stacks = 0;

#ifdef YYPURE
  int yychar;
  YYSTYPE yylval;
  int yynerrs;
#ifdef YYLSP_NEEDED
  YYLTYPE yylloc;
#endif
#endif

  YYSTYPE yyval;		/*  the variable used to return		*/
				/*  semantic values from the action	*/
				/*  routines				*/

  int yylen;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Starting parse\n");
#endif

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss - 1;
  yyvsp = yyvs;
#ifdef YYLSP_NEEDED
  yylsp = yyls;
#endif

/* Push a new state, which is found in  yystate  .  */
/* In all cases, when you get here, the value and location stacks
   have just been pushed. so pushing a state here evens the stacks.  */
yynewstate:

  *++yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Give user a chance to reallocate the stack */
      /* Use copies of these so that the &'s don't force the real ones into memory. */
      YYSTYPE *yyvs1 = yyvs;
      short *yyss1 = yyss;
#ifdef YYLSP_NEEDED
      YYLTYPE *yyls1 = yyls;
#endif

      /* Get the current used size of the three stacks, in elements.  */
      int size = yyssp - yyss + 1;

#ifdef yyoverflow
      /* Each stack pointer address is followed by the size of
	 the data in use in that stack, in bytes.  */
#ifdef YYLSP_NEEDED
      /* This used to be a conditional around just the two extra args,
	 but that might be undefined if yyoverflow is a macro.  */
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yyls1, size * sizeof (*yylsp),
		 &yystacksize);
#else
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yystacksize);
#endif

      yyss = yyss1; yyvs = yyvs1;
#ifdef YYLSP_NEEDED
      yyls = yyls1;
#endif
#else /* no yyoverflow */
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	{
	  yyerror("parser stack overflow");
	  if (yyfree_stacks)
	    {
	      free (yyss);
	      free (yyvs);
#ifdef YYLSP_NEEDED
	      free (yyls);
#endif
	    }
	  return 2;
	}
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;
#ifndef YYSTACK_USE_ALLOCA
      yyfree_stacks = 1;
#endif
      yyss = (short *) YYSTACK_ALLOC (yystacksize * sizeof (*yyssp));
      __yy_memcpy ((char *)yyss, (char *)yyss1,
		   size * (unsigned int) sizeof (*yyssp));
      yyvs = (YYSTYPE *) YYSTACK_ALLOC (yystacksize * sizeof (*yyvsp));
      __yy_memcpy ((char *)yyvs, (char *)yyvs1,
		   size * (unsigned int) sizeof (*yyvsp));
#ifdef YYLSP_NEEDED
      yyls = (YYLTYPE *) YYSTACK_ALLOC (yystacksize * sizeof (*yylsp));
      __yy_memcpy ((char *)yyls, (char *)yyls1,
		   size * (unsigned int) sizeof (*yylsp));
#endif
#endif /* no yyoverflow */

      yyssp = yyss + size - 1;
      yyvsp = yyvs + size - 1;
#ifdef YYLSP_NEEDED
      yylsp = yyls + size - 1;
#endif

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Stack size increased to %d\n", yystacksize);
#endif

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Entering state %d\n", yystate);
#endif

  goto yybackup;
 yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Reading a token: ");
#endif
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)		/* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more */

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Now at end of input.\n");
#endif
    }
  else
    {
      yychar1 = YYTRANSLATE(yychar);

#if YYDEBUG != 0
      if (yydebug)
	{
	  fprintf (stderr, "Next token is %d (%s", yychar, yytname[yychar1]);
	  /* Give the individual parser a way to print the precise meaning
	     of a token, for further debugging info.  */
#ifdef YYPRINT
	  YYPRINT (stderr, yychar, yylval);
#endif
	  fprintf (stderr, ")\n");
	}
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting token %d (%s), ", yychar, yytname[yychar1]);
#endif

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  /* count tokens shifted since error; after three, turn off error status.  */
  if (yyerrstatus) yyerrstatus--;

  yystate = yyn;
  goto yynewstate;

/* Do the default action for the current state.  */
yydefault:

  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;

/* Do a reduction.  yyn is the number of a rule to reduce with.  */
yyreduce:
  yylen = yyr2[yyn];
  if (yylen > 0)
    yyval = yyvsp[1-yylen]; /* implement default value of the action */

#if YYDEBUG != 0
  if (yydebug)
    {
      int i;

      fprintf (stderr, "Reducing via rule %d (line %d), ",
	       yyn, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (i = yyprhs[yyn]; yyrhs[i] > 0; i++)
	fprintf (stderr, "%s ", yytname[yyrhs[i]]);
      fprintf (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif


  switch (yyn) {

case 1:
#line 529 "parser.yxx"
{ 
                    {
		      int ii;
		      for (ii = 0; ii < 256; ii++) {
			handler_stack[ii] = 0;
		      }
		      handler_stack[0] = comment_handler;
		    }
                    doc_stack[0] = doctitle;
                 ;
    break;}
case 2:
#line 538 "parser.yxx"
{
		   CommentHandler::cleanup();
                   cplus_cleanup();
		   doc_entry = doctitle;
		   if (lang_init) {
		     lang->close();
		   }
               ;
    break;}
case 3:
#line 548 "parser.yxx"
{ 
		     scanner_clear_start();
                     Error = 0;
                ;
    break;}
case 4:
#line 552 "parser.yxx"
{
	       ;
    break;}
case 5:
#line 556 "parser.yxx"
{
                     yyvsp[-2].loc.filename = copy_string(input_file);
		     yyvsp[-2].loc.line = line_number;
		     input_file = copy_string(yyvsp[-1].id);
		     line_number = 0;
               ;
    break;}
case 6:
#line 561 "parser.yxx"
{
                     input_file = yyvsp[-5].loc.filename;
		     line_number = yyvsp[-5].loc.line;
               ;
    break;}
case 7:
#line 568 "parser.yxx"
{
		 yyvsp[-2].loc.flag = WrapExtern;
		 WrapExtern = 1;
		 yyvsp[-2].loc.filename = copy_string(input_file);
		 yyvsp[-2].loc.line = line_number;
		 input_file = copy_string(yyvsp[-1].id);
		 line_number = 0;
	       ;
    break;}
case 8:
#line 575 "parser.yxx"
{
		 input_file = yyvsp[-5].loc.filename;
		 line_number = yyvsp[-5].loc.line;
		 WrapExtern = yyvsp[-5].loc.flag;
	       ;
    break;}
case 9:
#line 583 "parser.yxx"
{
		 yyvsp[-2].loc.flag = WrapExtern;
		 WrapExtern = 1;
		 yyvsp[-2].loc.filename = copy_string(input_file);
		 yyvsp[-2].loc.line = line_number;
		 input_file = copy_string(yyvsp[-1].id);
		 line_number = 0;
		 lang->import(yyvsp[-1].id);
	       ;
    break;}
case 10:
#line 591 "parser.yxx"
{
		 input_file = yyvsp[-5].loc.filename;
		 line_number = yyvsp[-5].loc.line;
		 WrapExtern = yyvsp[-5].loc.flag;
	       ;
    break;}
case 11:
#line 597 "parser.yxx"
{
		 yyvsp[-6].loc.filename = copy_string(input_file);
		 yyvsp[-6].loc.line = line_number;
		 input_file = copy_string(yyvsp[-3].id);
		 line_number = atoi(yyvsp[-1].id) - 1;
	       ;
    break;}
case 12:
#line 602 "parser.yxx"
{
		 input_file = yyvsp[-9].loc.filename;
		 line_number = yyvsp[-9].loc.line;
	       ;
    break;}
case 13:
#line 609 "parser.yxx"
{
                  doc_entry = 0;
		  if (Verbose) {
		    fprintf(stderr,"%s : Line %d.  CPP %s ignored.\n", input_file, line_number,yyvsp[0].id);
		  }
		;
    break;}
case 14:
#line 618 "parser.yxx"
{
		    init_language();
		    if (Active_type) delete Active_type;
		    Active_type = new DataType(yyvsp[-3].type);
		    Active_extern = yyvsp[-4].ivalue;
		    yyvsp[-3].type->is_pointer += yyvsp[-2].decl.is_pointer;
		    if (yyvsp[-1].ivalue > 0) {
		      yyvsp[-3].type->is_pointer++;
		      yyvsp[-3].type->status = STAT_READONLY;
                      yyvsp[-3].type->arraystr = copy_string(ArrayString);
		    }
		    if (yyvsp[-2].decl.is_reference) {
		      fprintf(stderr,"%s : Line %d. Error. Linkage to C++ reference not allowed.\n", input_file, line_number);
		      FatalError();
		    } else {
		      if (yyvsp[-3].type->qualifier) {
			if ((strcmp(yyvsp[-3].type->qualifier,"const") == 0)) {
			  if (yyvsp[0].dtype.type != T_ERROR)
			    create_constant(yyvsp[-2].decl.id, yyvsp[-3].type, yyvsp[0].dtype.id);
			} else 
			  create_variable(yyvsp[-4].ivalue,yyvsp[-2].decl.id,yyvsp[-3].type);
		      } else
			create_variable(yyvsp[-4].ivalue,yyvsp[-2].decl.id,yyvsp[-3].type);
		    }
		  delete yyvsp[-3].type;
                ;
    break;}
case 15:
#line 643 "parser.yxx"
{ ;
    break;}
case 16:
#line 647 "parser.yxx"
{ 
                   skip_decl();
		   fprintf(stderr,"%s : Line %d. Function pointers not currently supported.\n",
			   input_file, line_number);
		;
    break;}
case 17:
#line 655 "parser.yxx"
{
		  if (Verbose) {
		    fprintf(stderr,"static variable %s ignored.\n",yyvsp[-2].decl.id);
		  }
		  Active_static = 1;
		  delete yyvsp[-3].type;
		;
    break;}
case 18:
#line 661 "parser.yxx"
{
		  Active_static = 0;
		;
    break;}
case 19:
#line 667 "parser.yxx"
{ 
                   skip_decl();
		   fprintf(stderr,"%s : Line %d. Function pointers not currently supported.\n",
			   input_file, line_number);
		;
    break;}
case 20:
#line 676 "parser.yxx"
{
		    init_language();
		    if (Active_type) delete Active_type;
		    Active_type = new DataType(yyvsp[-5].type);
		    Active_extern = yyvsp[-6].ivalue;
		    yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		    yyvsp[-5].type->is_reference = yyvsp[-4].decl.is_reference;
		    create_function(yyvsp[-6].ivalue, yyvsp[-4].decl.id, yyvsp[-5].type, yyvsp[-2].pl);
		  delete yyvsp[-5].type;
		  delete yyvsp[-2].pl;
		;
    break;}
case 21:
#line 686 "parser.yxx"
{ ;
    break;}
case 22:
#line 690 "parser.yxx"
{
		    init_language();
		    yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		    yyvsp[-5].type->is_reference = yyvsp[-4].decl.is_reference;
		    create_function(yyvsp[-6].ivalue, yyvsp[-4].decl.id, yyvsp[-5].type, yyvsp[-2].pl);
		  delete yyvsp[-5].type;
		  delete yyvsp[-2].pl;
		;
    break;}
case 23:
#line 701 "parser.yxx"
{ 
                    init_language();
		    DataType *t = new DataType(T_INT);
                    t->is_pointer += yyvsp[-4].decl.is_pointer;
		    t->is_reference = yyvsp[-4].decl.is_reference;
		    create_function(yyvsp[-5].ivalue,yyvsp[-4].decl.id,t,yyvsp[-2].pl);
		    delete t;
                ;
    break;}
case 24:
#line 708 "parser.yxx"
{ ;
    break;}
case 25:
#line 712 "parser.yxx"
{
		  if (Inline) {
		    if (strlen(CCode.get())) {
		      init_language();
		      yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		      yyvsp[-5].type->is_reference = yyvsp[-4].decl.is_reference;
		      create_function(0, yyvsp[-4].decl.id, yyvsp[-5].type, yyvsp[-2].pl);
		    }
		  }
		  delete yyvsp[-5].type;
		  delete yyvsp[-2].pl;
		;
    break;}
case 26:
#line 727 "parser.yxx"
{
		    init_language();
		    yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		    yyvsp[-5].type->is_reference = yyvsp[-4].decl.is_reference;
		    if (Inline) {
		      fprintf(stderr,"%s : Line %d. Repeated %%inline directive.\n",input_file,line_number);
		      FatalError();
		    } else {
		      if (strlen(CCode.get())) {
			fprintf(f_header,"static ");
			emit_extern_func(yyvsp[-4].decl.id,yyvsp[-5].type,yyvsp[-2].pl,3,f_header);
			fprintf(f_header,"%s\n",CCode.get());
		      }
		      create_function(0, yyvsp[-4].decl.id, yyvsp[-5].type, yyvsp[-2].pl);
		    }
		  delete yyvsp[-5].type;
		  delete yyvsp[-2].pl;
		;
    break;}
case 27:
#line 748 "parser.yxx"
{
		  if (Verbose) {
		    fprintf(stderr,"static function %s ignored.\n", yyvsp[-4].decl.id);
		  }
		  Active_static = 1;
		  delete yyvsp[-5].type;
		  delete yyvsp[-2].pl;
		;
    break;}
case 28:
#line 755 "parser.yxx"
{
		  Active_static = 0;
		 ;
    break;}
case 29:
#line 761 "parser.yxx"
{
		  Status = Status | STAT_READONLY;
	       ;
    break;}
case 30:
#line 767 "parser.yxx"
{
		 Status = Status & ~STAT_READONLY;
	       ;
    break;}
case 31:
#line 772 "parser.yxx"
{
		 strcpy(yy_rename,yyvsp[-1].id);
		 Rename_true = 1;
               ;
    break;}
case 32:
#line 778 "parser.yxx"
{ 
		 if (name_hash.lookup(yyvsp[-2].id)) {
		   name_hash.remove(yyvsp[-2].id);
		 }
		 name_hash.add(yyvsp[-2].id,copy_string(yyvsp[-1].id));
	       ;
    break;}
case 33:
#line 787 "parser.yxx"
{
                     NewObject = 1;
                ;
    break;}
case 34:
#line 789 "parser.yxx"
{
                     NewObject = 0;
               ;
    break;}
case 35:
#line 795 "parser.yxx"
{
		   fprintf(stderr,"%s : Lind %d. Empty %%name() is no longer supported.\n",
			   input_file, line_number);
		   FatalError();
	       ;
    break;}
case 36:
#line 799 "parser.yxx"
{
		 Rename_true = 0;
	       ;
    break;}
case 37:
#line 805 "parser.yxx"
{
		 if (!WrapExtern) {
		   init_language();
		   if (add_symbol(yyvsp[-4].id,(DataType *) 0, (char *) 0)) {
		     fprintf(stderr,"%s : Line %d. Name of native function %s conflicts with previous declaration (ignored)\n",
			     input_file, line_number, yyvsp[-4].id);
		   } else {
		     doc_entry = new DocDecl(yyvsp[-4].id,doc_stack[doc_stack_top]);
		     lang->add_native(yyvsp[-4].id,yyvsp[-1].id,0,0);
		   }
		 }
	       ;
    break;}
case 38:
#line 817 "parser.yxx"
{
		 if (!WrapExtern) {
		   init_language();
		   yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		   if (add_symbol(yyvsp[-8].id,(DataType *) 0, (char *) 0)) {
		     fprintf(stderr,"%s : Line %d. Name of native function %s conflicts with previous declaration (ignored)\n",
			     input_file, line_number, yyvsp[-8].id);
		   } else {
		     if (yyvsp[-6].ivalue) {
		       emit_extern_func(yyvsp[-4].decl.id, yyvsp[-5].type, yyvsp[-2].pl, yyvsp[-6].ivalue, f_header);
		     }
		     doc_entry = new DocDecl(yyvsp[-8].id,doc_stack[doc_stack_top]);
		     lang->add_native(yyvsp[-8].id,yyvsp[-4].decl.id,yyvsp[-5].type,yyvsp[-2].pl);
		   }
		 }
		 delete yyvsp[-5].type;
		 delete yyvsp[-2].pl;
	       ;
    break;}
case 39:
#line 838 "parser.yxx"
{
		 if (!WrapExtern) {
		   if (!title_init) {
		     title_init = 1;
		     doc_init = 1;
		     if (!comment_handler) {
		       comment_handler = new CommentHandler();
		     }
		     { 
		       int ii;
		       for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
			 comment_handler->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		       }
		     }
		     // Create a new title for documentation 
		     {
		       int temp = line_number;
		       line_number = yyvsp[-2].ivalue;
		       if (!doctitle)
			 doctitle = new DocTitle(yyvsp[-1].id,0);
		       else {
			 doctitle->name = copy_string(title);
			 doctitle->line_number = yyvsp[-2].ivalue;
			 doctitle->end_line = yyvsp[-2].ivalue;
		       }
		       line_number = temp;
		     }
		     doctitle->usage = yyvsp[-1].id;
		     doc_entry = doctitle;
		     doc_stack[0] = doc_entry;
		     doc_stack_top = 0;
		     handler_stack[0] = comment_handler;
		     { 
		       int ii;
		       for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
			 doc_stack[doc_stack_top]->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		       }
		     }

		   } else {
		     // Ignore it
		   }
		 }
	       ;
    break;}
case 40:
#line 886 "parser.yxx"
{
		 if ((!WrapExtern) && (!IgnoreDoc)) {
		   // Copy old comment handler
		   // if (handler_stack[1]) delete handler_stack[1];
		   handler_stack[1] = new CommentHandler(handler_stack[0]);  
		   comment_handler = handler_stack[1];
		   { 
		     int ii;
		     for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
		       comment_handler->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		     }
		   }
		   {
		     int temp = line_number;
		     line_number = yyvsp[-2].ivalue;
		     doc_entry = new DocSection(yyvsp[-1].id,doc_stack[0]);
		     line_number = temp;
		   }
		   doc_stack_top = 1;
		   doc_stack[1] = doc_entry;
		   { 
		     int ii;
		     for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
		       doc_stack[doc_stack_top]->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		     }
		   }
		 }
	       ;
    break;}
case 41:
#line 916 "parser.yxx"
{
		 if ((!WrapExtern) && (!IgnoreDoc)) {
		   if (doc_stack_top < 1) {
		     fprintf(stderr,"%s : Line %d. Can't apply %%subsection here.\n", input_file,line_number);
		     FatalError();
		   } else {

		     // Copy old comment handler
		     // if (handler_stack[2]) delete handler_stack[2];
		     handler_stack[2] = new CommentHandler(handler_stack[1]);
		     comment_handler = handler_stack[2];
		     { 
		       int ii;
		       for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
			 comment_handler->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		       }
		     }
		     {
		       int temp = line_number;
		       line_number = yyvsp[-2].ivalue;
		       doc_entry = new DocSection(yyvsp[-1].id,doc_stack[1]);
		       line_number = temp;
		     }
		     doc_stack_top = 2;
		     doc_stack[2] = doc_entry;
		     { 
		       int ii;
		       for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
			 doc_stack[doc_stack_top]->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		       }
		     }
		   }
		 }
	       ;
    break;}
case 42:
#line 952 "parser.yxx"
{
		 if ((!WrapExtern) && (!IgnoreDoc)) {
		   if (doc_stack_top < 2) {
		     fprintf(stderr,"%s : Line %d. Can't apply %%subsubsection here.\n", input_file,line_number);
		     FatalError();
		   } else {

		     // Copy old comment handler

		     // if (handler_stack[3]) delete handler_stack[3];
		     handler_stack[3] = new CommentHandler(handler_stack[2]);
		     comment_handler = handler_stack[3];
		     { 
		       int ii;
		       for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
			 comment_handler->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		       }
		     }
		     {
		       int temp = line_number;
		       line_number = yyvsp[-2].ivalue;
		       doc_entry = new DocSection(yyvsp[-1].id,doc_stack[2]);
		       line_number = temp;
		     }
		     doc_stack_top = 3;
		     doc_stack[3] = doc_entry;
		     { 
		       int ii;
		       for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
			 doc_stack[doc_stack_top]->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		       }
		     }
		   }
		 }
	       ;
    break;}
case 43:
#line 989 "parser.yxx"
{
		 if (!WrapExtern) {
		   fprintf(stderr,"%%alpha directive is obsolete.  Use '%%style sort' instead.\n");
		   handler_stack[0]->style("sort",0);
		   doc_stack[0]->style("sort",0);
		 }
	       ;
    break;}
case 44:
#line 997 "parser.yxx"
{
		 if (!WrapExtern) {
		   fprintf(stderr,"%%raw directive is obsolete. Use '%%style nosort' instead.\n");
		   handler_stack[0]->style("nosort",0);
		   doc_stack[0]->style("nosort",0);
		 }
	       ;
    break;}
case 45:
#line 1005 "parser.yxx"
{ ;
    break;}
case 46:
#line 1009 "parser.yxx"
{
		 if (!WrapExtern) {
		   yyvsp[0].id[strlen(yyvsp[0].id) - 1] = 0;
		   doc_entry = new DocText(yyvsp[0].id,doc_stack[doc_stack_top]);
		   doc_entry = 0;
		 }
	       ;
    break;}
case 47:
#line 1018 "parser.yxx"
{ ;
    break;}
case 48:
#line 1022 "parser.yxx"
{
		 if (!WrapExtern) {
		   init_language();
		   yyvsp[0].id[strlen(yyvsp[0].id) - 1] = 0;
//		   fprintf(f_header,"#line %d \"%s\"\n", start_line, input_file);
		   fprintf(f_header, "%s\n", yyvsp[0].id);
		 }
	       ;
    break;}
case 49:
#line 1033 "parser.yxx"
{
                 if (!WrapExtern) {
		   init_language();
		   yyvsp[0].id[strlen(yyvsp[0].id) - 1] = 0;
		   fprintf(f_wrappers,"%s\n",yyvsp[0].id);
		 }
	       ;
    break;}
case 50:
#line 1043 "parser.yxx"
{
		 if (!WrapExtern) {
		   init_language();
		   yyvsp[0].id[strlen(yyvsp[0].id) -1] = 0;
		   fprintf(f_init,"%s\n", yyvsp[0].id);
		 }
	       ;
    break;}
case 51:
#line 1052 "parser.yxx"
{
		 if (!WrapExtern) {
		   init_language();
		   yyvsp[0].id[strlen(yyvsp[0].id) - 1] = 0;
		   fprintf(f_header, "%s\n", yyvsp[0].id);
		   start_inline(yyvsp[0].id,start_line);
		 }
	       ;
    break;}
case 52:
#line 1062 "parser.yxx"
{
		 if (!WrapExtern) {
		   fprintf(stderr,"%s\n", yyvsp[0].id);
		 }
	       ;
    break;}
case 53:
#line 1068 "parser.yxx"
{
                 if (!WrapExtern) {
                   fprintf(stderr,"%s\n", yyvsp[0].id);
                 }
               ;
    break;}
case 54:
#line 1075 "parser.yxx"
{
                   DocOnly = 1;
               ;
    break;}
case 55:
#line 1081 "parser.yxx"
{
		   if (!module_init) {
		     lang->set_init(yyvsp[-1].id);
		     module_init = 1;
		     init_language();
		   } else {
		     if (Verbose)
		       fprintf(stderr,"%s : Line %d. %%init %s ignored.\n",
			       input_file, line_number, yyvsp[-1].id);
		   }
		   if (yyvsp[0].ilist.count > 0) {
		     fprintf(stderr,"%s : Line %d. Warning. Init list no longer supported.\n",
			     input_file,line_number);
		   }
		 for (i = 0; i < yyvsp[0].ilist.count; i++)
		   if (yyvsp[0].ilist.names[i]) delete [] yyvsp[0].ilist.names[i];
		 delete [] yyvsp[0].ilist.names;
	       ;
    break;}
case 56:
#line 1101 "parser.yxx"
{
		   if (yyvsp[0].ilist.count)
		     lang->set_module(yyvsp[-1].id,yyvsp[0].ilist.names);
		   else
		     lang->set_module(yyvsp[-1].id,0);
		   module_init = 1;
		   init_language();
		 for (i = 0; i < yyvsp[0].ilist.count; i++)
		   if (yyvsp[0].ilist.names[i]) delete [] yyvsp[0].ilist.names[i];
		 delete [] yyvsp[0].ilist.names;
	       ;
    break;}
case 57:
#line 1115 "parser.yxx"
{
		   if ((yyvsp[-1].dtype.type != T_ERROR) && (yyvsp[-1].dtype.type != T_SYMBOL)) {
		     init_language();
		     temp_typeptr = new DataType(yyvsp[-1].dtype.type);
		     create_constant(yyvsp[-2].id, temp_typeptr, yyvsp[-1].dtype.id);
		     delete temp_typeptr;
		   } else if (yyvsp[-1].dtype.type == T_SYMBOL) {
		     // Add a symbol to the SWIG symbol table
		     if (add_symbol(yyvsp[-2].id,(DataType *) 0, (char *) 0)) {
		       fprintf(stderr,"%s : Line %d. Warning. Symbol %s already defined.\n", 
			       input_file,line_number, yyvsp[-2].id);
		     }
		   }
	       ;
    break;}
case 58:
#line 1132 "parser.yxx"
{ scanner_clear_start(); ;
    break;}
case 59:
#line 1132 "parser.yxx"
{ 
		   init_language();
		   if (yyvsp[-5].id) {
		     temp_type.type = T_INT;
		     temp_type.is_pointer = 0;
		     temp_type.implicit_ptr = 0;
		     sprintf(temp_type.name,"int");
		     temp_type.typedef_add(yyvsp[-5].id,1);
		   }
	       ;
    break;}
case 60:
#line 1145 "parser.yxx"
{ scanner_clear_start(); ;
    break;}
case 61:
#line 1145 "parser.yxx"
{
		   init_language();
		   temp_type.type = T_INT;
		   temp_type.is_pointer = 0;
		   temp_type.implicit_ptr = 0;
		   sprintf(temp_type.name,"int");
		   Active_typedef = new DataType(&temp_type);
		   temp_type.typedef_add(yyvsp[0].id,1);
	       ;
    break;}
case 62:
#line 1153 "parser.yxx"
{ ;
    break;}
case 63:
#line 1163 "parser.yxx"
{
		   TMParm *p;
                   skip_brace();
		   p = yyvsp[-1].tmparm;
		   while (p) {
		     typemap_register(yyvsp[-3].id,yyvsp[-5].id,p->p->t,p->p->name,CCode,p->args);
		     p = p->next;
                   }
		   delete yyvsp[-5].id;
		   delete yyvsp[-3].id;
	       ;
    break;}
case 64:
#line 1176 "parser.yxx"
{
		 if (!typemap_lang) {
		   fprintf(stderr,"SWIG internal error. No typemap_lang specified.\n");
		   fprintf(stderr,"typemap on %s : Line %d. will be ignored.\n",input_file,line_number);
		   FatalError();
		 } else {
		   TMParm *p;
		   skip_brace();
		   p = yyvsp[-1].tmparm;
		   while (p) {
		     typemap_register(yyvsp[-3].id,typemap_lang,p->p->t,p->p->name,CCode,p->args);
		     p = p->next;
		   }
		 }
		 delete yyvsp[-3].id;
	       ;
    break;}
case 65:
#line 1195 "parser.yxx"
{
		 TMParm *p;
		 p = yyvsp[-1].tmparm;
		 while (p) {
                   typemap_clear(yyvsp[-3].id,yyvsp[-5].id,p->p->t,p->p->name);
		   p = p->next;
		 }
		 delete yyvsp[-5].id;
		 delete yyvsp[-3].id;
	       ;
    break;}
case 66:
#line 1207 "parser.yxx"
{
		 if (!typemap_lang) {
		   fprintf(stderr,"SWIG internal error. No typemap_lang specified.\n");
		   fprintf(stderr,"typemap on %s : Line %d. will be ignored.\n",input_file,line_number);
		   FatalError();
		 } else {
		   TMParm *p;
		   p = yyvsp[-1].tmparm;
		   while (p) {
		     typemap_clear(yyvsp[-3].id,typemap_lang,p->p->t,p->p->name);
		     p = p->next;
		   }
		 }
		 delete yyvsp[-3].id;
	       ;
    break;}
case 67:
#line 1225 "parser.yxx"
{
                   TMParm *p;
		   p = yyvsp[-3].tmparm;
		   while (p) {
		     typemap_copy(yyvsp[-5].id,yyvsp[-7].id,yyvsp[-1].tmparm->p->t,yyvsp[-1].tmparm->p->name,p->p->t,p->p->name);
		     p = p->next;
		   }
		   delete yyvsp[-7].id;
		   delete yyvsp[-5].id;
		   delete yyvsp[-1].tmparm->p;
		   delete yyvsp[-1].tmparm;
	       ;
    break;}
case 68:
#line 1240 "parser.yxx"
{
		 if (!typemap_lang) {
		   fprintf(stderr,"SWIG internal error. No typemap_lang specified.\n");
		   fprintf(stderr,"typemap on %s : Line %d. will be ignored.\n",input_file,line_number);
		   FatalError();
		 } else {
                   TMParm *p;
		   p = yyvsp[-3].tmparm;
		   while (p) {
		     typemap_copy(yyvsp[-5].id,typemap_lang,yyvsp[-1].tmparm->p->t,yyvsp[-1].tmparm->p->name,p->p->t,p->p->name);
		     p = p->next;
		   }
		 }
		 delete yyvsp[-5].id;
		 delete yyvsp[-1].tmparm->p;
		 delete yyvsp[-1].tmparm;
	       ;
    break;}
case 69:
#line 1261 "parser.yxx"
{
		 TMParm *p;
		 p = yyvsp[-1].tmparm;
		 while(p) {
		   typemap_apply(yyvsp[-3].tmparm->p->t,yyvsp[-3].tmparm->p->name,p->p->t,p->p->name);
		   p = p->next;
		 }
		 delete yyvsp[-1].tmparm;
		 delete yyvsp[-3].tmparm->args;
		 delete yyvsp[-3].tmparm;
               ;
    break;}
case 70:
#line 1272 "parser.yxx"
{
		 TMParm *p;
		 p = yyvsp[-1].tmparm;
		 while (p) {
		   typemap_clear_apply(p->p->t, p->p->name);
		   p = p->next;
		 }
               ;
    break;}
case 71:
#line 1289 "parser.yxx"
{
                    skip_brace();
                    fragment_register("except",yyvsp[-2].id, CCode);
		    delete yyvsp[-2].id;
	       ;
    break;}
case 72:
#line 1296 "parser.yxx"
{
                    skip_brace();
                    fragment_register("except",typemap_lang, CCode);
               ;
    break;}
case 73:
#line 1303 "parser.yxx"
{
                     fragment_clear("except",yyvsp[-2].id);
               ;
    break;}
case 74:
#line 1308 "parser.yxx"
{
                     fragment_clear("except",typemap_lang);
	       ;
    break;}
case 75:
#line 1314 "parser.yxx"
{ ;
    break;}
case 76:
#line 1315 "parser.yxx"
{ ;
    break;}
case 77:
#line 1316 "parser.yxx"
{ ;
    break;}
case 78:
#line 1317 "parser.yxx"
{
		 if (!Error) {
		   {
		     static int last_error_line = -1;
		     if (last_error_line != line_number) {
		       fprintf(stderr,"%s : Line %d. Syntax error in input.\n", input_file, line_number);
		       FatalError();
		       last_error_line = line_number;
                       // Try to make some kind of recovery.
		       skip_decl();
		     }
		     Error = 1;
		   }
		 }
	       ;
    break;}
case 79:
#line 1335 "parser.yxx"
{ ;
    break;}
case 80:
#line 1339 "parser.yxx"
{ ;
    break;}
case 81:
#line 1343 "parser.yxx"
{
		 { 
		   int ii,jj;
		   for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
		     comment_handler->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		     for (jj = 0; jj < doc_stack_top; jj++) 
		       doc_stack[jj]->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		     if (doctitle)
		       doctitle->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		     doc->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		   }
		 }
	       ;
    break;}
case 82:
#line 1359 "parser.yxx"
{
		 { 
		   int ii;
		   for (ii = 0; ii < yyvsp[0].dlist.count; ii++) {
		     comment_handler = new CommentHandler(comment_handler);
		     handler_stack[doc_stack_top] = comment_handler;
		     comment_handler->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		     doc_stack[doc_stack_top]->style(yyvsp[0].dlist.names[ii],yyvsp[0].dlist.values[ii]);
		   }
		 }
	       ;
    break;}
case 83:
#line 1372 "parser.yxx"
{ ;
    break;}
case 84:
#line 1378 "parser.yxx"
{
		   if (IgnoreDoc) {
		     /* Already in a disabled documentation */
		     doc_scope++;
		   } else {
		     if (Verbose)
		       fprintf(stderr,"%s : Line %d. Documentation disabled.\n", input_file, line_number);
		     IgnoreDoc = 1;
		     doc_scope = 1;
		   }
	       ;
    break;}
case 85:
#line 1390 "parser.yxx"
{
		   if (IgnoreDoc) {
		     if (doc_scope > 1) {
		       doc_scope--;
		     } else {
		       if (Verbose)
			 fprintf(stderr,"%s : Line %d. Documentation enabled.\n", input_file, line_number);
		       IgnoreDoc = 0;
		       doc_scope = 0;
		     }
		   }
	       ;
    break;}
case 86:
#line 1407 "parser.yxx"
{
		   init_language();
		   /* Add a new typedef */
		   Active_typedef = new DataType(yyvsp[-1].type);
		   yyvsp[-1].type->is_pointer += yyvsp[0].decl.is_pointer;
		   yyvsp[-1].type->typedef_add(yyvsp[0].decl.id);
		   /* If this is %typedef, add it to the header */
		   if (yyvsp[-2].ivalue) 
		     fprintf(f_header,"typedef %s %s;\n", yyvsp[-1].type->print_full(), yyvsp[0].decl.id);
		   cplus_register_type(yyvsp[0].decl.id);
	       ;
    break;}
case 87:
#line 1417 "parser.yxx"
{ ;
    break;}
case 88:
#line 1421 "parser.yxx"
{
		   init_language();
		   /* Typedef'd pointer */
		   if (yyvsp[-9].ivalue) {
		     sprintf(temp_name,"(*%s)",yyvsp[-5].id);
		     fprintf(f_header,"typedef ");
		     emit_extern_func(temp_name, yyvsp[-8].type,yyvsp[-2].pl,0,f_header);
		   }
		   strcpy(yyvsp[-8].type->name,"<function ptr>");
		   yyvsp[-8].type->type = T_USER;
		   yyvsp[-8].type->is_pointer = 1;
		   yyvsp[-8].type->typedef_add(yyvsp[-5].id,1);
		   cplus_register_type(yyvsp[-5].id);
		 delete yyvsp[-8].type;
		 delete yyvsp[-5].id;
		 delete yyvsp[-2].pl;
	       ;
    break;}
case 89:
#line 1441 "parser.yxx"
{
		   init_language();
		   if (yyvsp[-10].ivalue) {
		     yyvsp[-9].type->is_pointer += yyvsp[-8].ivalue;
		     sprintf(temp_name,"(*%s)",yyvsp[-5].id);
		     fprintf(f_header,"typedef ");
		     emit_extern_func(temp_name, yyvsp[-9].type,yyvsp[-2].pl,0,f_header);
		   }

		   /* Typedef'd pointer */
		   strcpy(yyvsp[-9].type->name,"<function ptr>");
		   yyvsp[-9].type->type = T_USER;
		   yyvsp[-9].type->is_pointer = 1;
		   yyvsp[-9].type->typedef_add(yyvsp[-5].id,1);
		   cplus_register_type(yyvsp[-5].id);
		 delete yyvsp[-9].type;
		 delete yyvsp[-5].id;
		 delete yyvsp[-2].pl;
	       ;
    break;}
case 90:
#line 1463 "parser.yxx"
{
		   init_language();
		   Active_typedef = new DataType(yyvsp[-2].type);
		   // This datatype is going to be readonly
			
		   yyvsp[-2].type->status = STAT_READONLY | STAT_REPLACETYPE;
		   yyvsp[-2].type->is_pointer += yyvsp[-1].decl.is_pointer;
		   // Turn this into a "pointer" corresponding to the array
		   yyvsp[-2].type->is_pointer++;
		   yyvsp[-2].type->arraystr = copy_string(ArrayString);
		   yyvsp[-2].type->typedef_add(yyvsp[-1].decl.id);
		   fprintf(stderr,"%s : Line %d. Warning. Array type %s will be read-only without a typemap\n",input_file,line_number, yyvsp[-1].decl.id);
		   cplus_register_type(yyvsp[-1].decl.id);

	       ;
    break;}
case 91:
#line 1477 "parser.yxx"
{ ;
    break;}
case 92:
#line 1490 "parser.yxx"
{
		  if (Active_typedef) {
		    DataType *t;
		    t = new DataType(Active_typedef);
		    t->is_pointer += yyvsp[-1].decl.is_pointer;
		    t->typedef_add(yyvsp[-1].decl.id);
		    cplus_register_type(yyvsp[-1].decl.id);
		    delete t;
		  }
              ;
    break;}
case 93:
#line 1500 "parser.yxx"
{
		    DataType *t;
		    t = new DataType(Active_typedef);
		    t->status = STAT_READONLY | STAT_REPLACETYPE;
		    t->is_pointer += yyvsp[-1].decl.is_pointer + 1;
		    t->arraystr = copy_string(ArrayString);
		    t->typedef_add(yyvsp[-1].decl.id);
		    cplus_register_type(yyvsp[-1].decl.id);
		    delete t;
    		    fprintf(stderr,"%s : Line %d. Warning. Array type %s will be read-only without a typemap.\n",input_file,line_number, yyvsp[-1].decl.id);
	      ;
    break;}
case 94:
#line 1511 "parser.yxx"
{ ;
    break;}
case 95:
#line 1514 "parser.yxx"
{
		 if (!WrapExtern)
		   lang->pragma(yyvsp[-4].id,yyvsp[-2].id,yyvsp[-1].id);
		   fprintf(stderr,"%s : Line %d. Warning. '%%pragma(lang,opt=value)' syntax is obsolete.\n",
			   input_file,line_number);
		   fprintf(stderr,"        Use '%%pragma(lang) opt=value' instead.\n");
	       ;
    break;}
case 96:
#line 1522 "parser.yxx"
{
                 if (!WrapExtern) 
		   swig_pragma(yyvsp[-1].id,yyvsp[0].id);
    	       ;
    break;}
case 97:
#line 1526 "parser.yxx"
{
		 if (!WrapExtern)
		   lang->pragma(yyvsp[-3].id,yyvsp[-1].id,yyvsp[0].id);
	       ;
    break;}
case 98:
#line 1534 "parser.yxx"
{ ;
    break;}
case 99:
#line 1535 "parser.yxx"
{
		 if (allow) {
		   init_language();
		   temp_typeptr = new DataType(Active_type);
		   temp_typeptr->is_pointer += yyvsp[-2].decl.is_pointer;
		   if (yyvsp[-1].ivalue > 0) {
		     temp_typeptr->is_pointer++;
		     temp_typeptr->status = STAT_READONLY;
		     temp_typeptr->arraystr = copy_string(ArrayString);
		   }
		   if (yyvsp[-2].decl.is_reference) {
		     fprintf(stderr,"%s : Line %d. Error. Linkage to C++ reference not allowed.\n", input_file, line_number);
		     FatalError();
		   } else {
		     if (temp_typeptr->qualifier) {
		       if ((strcmp(temp_typeptr->qualifier,"const") == 0)) {
			 /* Okay.  This is really some sort of C++ constant here. */
			 if (yyvsp[0].dtype.type != T_ERROR)
			   create_constant(yyvsp[-2].decl.id, temp_typeptr, yyvsp[0].dtype.id);
		       } else 
			 create_variable(Active_extern,yyvsp[-2].decl.id, temp_typeptr);
		     } else
		       create_variable(Active_extern, yyvsp[-2].decl.id, temp_typeptr);
		   }
		   delete temp_typeptr;
		 }
	       ;
    break;}
case 100:
#line 1561 "parser.yxx"
{ ;
    break;}
case 101:
#line 1562 "parser.yxx"
{
		 if (allow) {
		   init_language();
		   temp_typeptr = new DataType(Active_type);
		   temp_typeptr->is_pointer += yyvsp[-4].decl.is_pointer;
		   temp_typeptr->is_reference = yyvsp[-4].decl.is_reference;
		   create_function(Active_extern, yyvsp[-4].decl.id, temp_typeptr, yyvsp[-2].pl);
		   delete temp_typeptr;
		 }
		 delete yyvsp[-2].pl;
	       ;
    break;}
case 102:
#line 1572 "parser.yxx"
{ ;
    break;}
case 103:
#line 1575 "parser.yxx"
{ yyval.ivalue = 1; ;
    break;}
case 104:
#line 1576 "parser.yxx"
{yyval.ivalue = 0; ;
    break;}
case 105:
#line 1577 "parser.yxx"
{
		 if (strcmp(yyvsp[0].id,"C") == 0) {
		   yyval.ivalue = 2;
		 } else {
		   fprintf(stderr,"%s : Line %d.  Unrecognized extern type \"%s\" (ignored).\n", input_file, line_number, yyvsp[0].id);
		   FatalError();
		 }
	       ;
    break;}
case 106:
#line 1589 "parser.yxx"
{ skip_brace(); ;
    break;}
case 107:
#line 1598 "parser.yxx"
{
                 if ((yyvsp[-1].p->t->type != T_VOID) || (yyvsp[-1].p->t->is_pointer))
		   yyvsp[0].pl->insert(yyvsp[-1].p,0);
		 yyval.pl = yyvsp[0].pl;
		 delete yyvsp[-1].p;
		;
    break;}
case 108:
#line 1604 "parser.yxx"
{ yyval.pl = new ParmList;;
    break;}
case 109:
#line 1607 "parser.yxx"
{
		 yyvsp[0].pl->insert(yyvsp[-1].p,0);
		 yyval.pl = yyvsp[0].pl;
		 delete yyvsp[-1].p;
                ;
    break;}
case 110:
#line 1612 "parser.yxx"
{ yyval.pl = new ParmList;;
    break;}
case 111:
#line 1615 "parser.yxx"
{
                  yyval.p = yyvsp[0].p;
		  if (typemap_check("ignore",typemap_lang,yyval.p->t,yyval.p->name))
		    yyval.p->ignore = 1;
               ;
    break;}
case 112:
#line 1620 "parser.yxx"
{
                  yyval.p = yyvsp[0].p;
                  yyval.p->call_type = yyval.p->call_type | yyvsp[-1].ivalue;
		  if (InArray && (yyval.p->call_type & CALL_VALUE)) {
		     fprintf(stderr,"%s : Line %d. Error. Can't use %%val with an array.\n", input_file, line_number);
		     FatalError();
		  }
		  if (!yyval.p->t->is_pointer) {
		     fprintf(stderr,"%s : Line %d. Error. Can't use %%val or %%out with a non-pointer argument.\n", input_file, line_number);
		     FatalError();
		  } else {
		    yyval.p->t->is_pointer--;
		  }
		;
    break;}
case 113:
#line 1635 "parser.yxx"
{
		    if (InArray) {
		      yyvsp[-1].type->is_pointer++;
		      if (Verbose) {
			fprintf(stderr,"%s : Line %d. Warning. Array %s", input_file, line_number, yyvsp[-1].type->print_type());
			print_array();
			fprintf(stderr," has been converted to %s.\n", yyvsp[-1].type->print_type());
		      }
		      // Add array string to the type
		      yyvsp[-1].type->arraystr = copy_string(ArrayString.get());
		    } 
		    yyval.p = new Parm(yyvsp[-1].type,yyvsp[0].id);
		    yyval.p->call_type = 0;
		    yyval.p->defvalue = DefArg;
		    if ((yyvsp[-1].type->type == T_USER) && !(yyvsp[-1].type->is_pointer)) {
		      if (Verbose)
			fprintf(stderr,"%s : Line %d. Warning : Parameter of type '%s'\nhas been remapped to '%s *' and will be called using *((%s *) ptr).\n",
				input_file, line_number, yyvsp[-1].type->name, yyvsp[-1].type->name, yyvsp[-1].type->name);

		      yyval.p->call_type = CALL_REFERENCE;
		      yyval.p->t->is_pointer++;
		    }
		    delete yyvsp[-1].type;
		    delete yyvsp[0].id;
                 ;
    break;}
case 114:
#line 1661 "parser.yxx"
{
		   yyval.p = new Parm(yyvsp[-2].type,yyvsp[0].id);
		   yyval.p->t->is_pointer += yyvsp[-1].ivalue;
		   yyval.p->call_type = 0;
		   yyval.p->defvalue = DefArg;
		   if (InArray) {
		     yyval.p->t->is_pointer++;
		     if (Verbose) {
		       fprintf(stderr,"%s : Line %d. Warning. Array %s", input_file, line_number, yyval.p->t->print_type());
		       print_array();
		       fprintf(stderr," has been converted to %s.\n", yyval.p->t->print_type());
		     }
		     // Add array string to the type
		     yyval.p->t->arraystr = copy_string(ArrayString.get());
		    }
		   delete yyvsp[-2].type;
		   delete yyvsp[0].id;
		;
    break;}
case 115:
#line 1680 "parser.yxx"
{
		  yyval.p = new Parm(yyvsp[-2].type,yyvsp[0].id);
		  yyval.p->t->is_reference = 1;
		  yyval.p->call_type = 0;
		  yyval.p->t->is_pointer++;
		  yyval.p->defvalue = DefArg;
		  if (!CPlusPlus) {
			fprintf(stderr,"%s : Line %d. Warning.  Use of C++ Reference detected.  Use the -c++ option.\n", input_file, line_number);
		  }
		  delete yyvsp[-2].type;
		  delete yyvsp[0].id;
		;
    break;}
case 116:
#line 1692 "parser.yxx"
{
                  fprintf(stderr,"%s : Line %d. Error. Function pointer not allowed (remap with typedef).\n", input_file, line_number);
		  FatalError();
		  yyval.p = new Parm(yyvsp[-7].type,yyvsp[-4].id);
		  yyval.p->t->type = T_ERROR;
		  yyval.p->name = copy_string(yyvsp[-4].id);
		  strcpy(yyval.p->t->name,"<function ptr>");
		  delete yyvsp[-7].type;
		  delete yyvsp[-4].id;
		  delete yyvsp[-1].pl;
		;
    break;}
case 117:
#line 1703 "parser.yxx"
{
                  fprintf(stderr,"%s : Line %d. Variable length arguments not supported (ignored).\n", input_file, line_number);
		  yyval.p = new Parm(new DataType(T_INT),"varargs");
		  yyval.p->t->type = T_ERROR;
		  yyval.p->name = copy_string("varargs");
		  strcpy(yyval.p->t->name,"<varargs>");
		  FatalError();
		;
    break;}
case 118:
#line 1713 "parser.yxx"
{
                    yyval.id = yyvsp[-1].id; 
                    InArray = 0;
		    if (yyvsp[0].dtype.type == T_CHAR)
		      DefArg = copy_string(ConstChar);
		    else
		      DefArg = copy_string(yyvsp[0].dtype.id);
                    if (yyvsp[0].dtype.id) delete yyvsp[0].dtype.id;
                ;
    break;}
case 119:
#line 1722 "parser.yxx"
{
                    yyval.id = yyvsp[-1].id; 
                    InArray = yyvsp[0].ivalue; 
                    DefArg = 0;
               ;
    break;}
case 120:
#line 1727 "parser.yxx"
{
                         yyval.id = new char[1];
                         yyval.id[0] = 0;
                         InArray = yyvsp[0].ivalue;
                         DefArg = 0;
               ;
    break;}
case 121:
#line 1733 "parser.yxx"
{ yyval.id = new char[1];
	                 yyval.id[0] = 0;
                         InArray = 0;
                         DefArg = 0;
               ;
    break;}
case 122:
#line 1740 "parser.yxx"
{ yyval.dtype = yyvsp[0].dtype; ;
    break;}
case 123:
#line 1741 "parser.yxx"
{
		 yyval.dtype.id = new char[strlen(yyvsp[0].id)+2];
		 yyval.dtype.id[0] = '&';
		 strcpy(&yyval.dtype.id[1], yyvsp[0].id);
		 yyval.dtype.type = T_USER;
	       ;
    break;}
case 124:
#line 1747 "parser.yxx"
{
		 skip_brace();
		 yyval.dtype.id = 0; yyval.dtype.type = T_INT;
	       ;
    break;}
case 125:
#line 1751 "parser.yxx"
{
               ;
    break;}
case 126:
#line 1753 "parser.yxx"
{yyval.dtype.id = 0; yyval.dtype.type = T_INT;;
    break;}
case 127:
#line 1756 "parser.yxx"
{ yyval.ivalue = CALL_VALUE; ;
    break;}
case 128:
#line 1757 "parser.yxx"
{ yyval.ivalue = CALL_OUTPUT; ;
    break;}
case 129:
#line 1760 "parser.yxx"
{
                 yyval.ivalue = yyvsp[-1].ivalue | yyvsp[0].ivalue;
               ;
    break;}
case 130:
#line 1763 "parser.yxx"
{
                 yyval.ivalue = yyvsp[0].ivalue;
	       ;
    break;}
case 131:
#line 1770 "parser.yxx"
{ yyval.decl.id = yyvsp[0].id;
                      yyval.decl.is_pointer = 0;
		      yyval.decl.is_reference = 0;
                ;
    break;}
case 132:
#line 1774 "parser.yxx"
{
                      yyval.decl.id = yyvsp[0].id;
		      yyval.decl.is_pointer = yyvsp[-1].ivalue;
		      yyval.decl.is_reference = 0;
	       ;
    break;}
case 133:
#line 1779 "parser.yxx"
{
		      yyval.decl.id = yyvsp[0].id;
		      yyval.decl.is_pointer = 1;
		      yyval.decl.is_reference = 1;
		      if (!CPlusPlus) {
			fprintf(stderr,"%s : Line %d. Warning.  Use of C++ Reference detected.  Use the -c++ option.\n", input_file, line_number);
		      }
	       ;
    break;}
case 134:
#line 1789 "parser.yxx"
{ yyval.ivalue = 1; ;
    break;}
case 135:
#line 1790 "parser.yxx"
{ yyval.ivalue = yyvsp[0].ivalue + 1;;
    break;}
case 136:
#line 1794 "parser.yxx"
{
		 yyval.ivalue = yyvsp[0].ivalue + 1;
		 "[]" >> ArrayString;
              ;
    break;}
case 137:
#line 1798 "parser.yxx"
{
                 yyval.ivalue = yyvsp[0].ivalue + 1;
		 "]" >> ArrayString;
		 yyvsp[-2].dtype.id >> ArrayString;
		 "[" >> ArrayString;
              ;
    break;}
case 138:
#line 1805 "parser.yxx"
{
                 yyval.ivalue = yyvsp[0].ivalue;
              ;
    break;}
case 139:
#line 1808 "parser.yxx"
{ yyval.ivalue = 0;
                        ArrayString = "";
              ;
    break;}
case 140:
#line 1816 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
               ;
    break;}
case 141:
#line 1819 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 142:
#line 1822 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 143:
#line 1825 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 144:
#line 1828 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 145:
#line 1831 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 146:
#line 1834 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 147:
#line 1837 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 148:
#line 1840 "parser.yxx"
{
                   if (yyvsp[0].type) yyval.type = yyvsp[0].type;
		   else yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 149:
#line 1844 "parser.yxx"
{
                   if (yyvsp[0].type) yyval.type = yyvsp[0].type;
		   else yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 150:
#line 1848 "parser.yxx"
{
		 yyval.type = yyvsp[-1].type;
		 if (strlen(yyvsp[0].id) > 0) {
		    if ((strlen(yyvsp[0].id) + strlen(yyval.type->name)) >= MAX_NAME) {
		      fprintf(stderr,"%s : Line %d. Fatal error. Type-name is too long!\n", 
			      input_file, line_number);
		    } else {
		      strcat(yyval.type->name,yyvsp[0].id);
		    }
		  }
	       ;
    break;}
case 151:
#line 1859 "parser.yxx"
{
		  yyval.type = new DataType;
		  strcpy(yyval.type->name,yyvsp[-1].id);
		  yyval.type->type = T_USER;
		  /* Do a typedef lookup */
		  yyval.type->typedef_resolve();
		  if (strlen(yyvsp[0].id) > 0) {
		    if ((strlen(yyvsp[0].id) + strlen(yyval.type->name)) >= MAX_NAME) {
		      fprintf(stderr,"%s : Line %d. Fatal error. Type-name is too long!\n", 
			      input_file, line_number);
		    } else {
		      strcat(yyval.type->name,yyvsp[0].id);
		    }
		  }
	       ;
    break;}
case 152:
#line 1874 "parser.yxx"
{
		  yyval.type = yyvsp[0].type;
                  yyval.type->qualifier = new char[6];
		  strcpy(yyval.type->qualifier,"const");
     	       ;
    break;}
case 153:
#line 1879 "parser.yxx"
{
                  yyval.type = new DataType;
		  sprintf(yyval.type->name,"%s %s",yyvsp[-1].id, yyvsp[0].id);
		  yyval.type->type = T_USER;
	       ;
    break;}
case 154:
#line 1884 "parser.yxx"
{
                  yyval.type = new DataType;
                  sprintf(yyval.type->name,"%s::%s",yyvsp[-2].id,yyvsp[0].id);
                  yyval.type->type = T_USER;
		  yyval.type->typedef_resolve();
               ;
    break;}
case 155:
#line 1893 "parser.yxx"
{
                  yyval.type = new DataType;
                  sprintf(yyval.type->name,"%s", yyvsp[0].id);
                  yyval.type->type = T_USER;
                  yyval.type->typedef_resolve(1);
               ;
    break;}
case 156:
#line 1899 "parser.yxx"
{
                  yyval.type = new DataType;
                  sprintf(yyval.type->name,"enum %s", yyvsp[0].id);
                  yyval.type->type = T_INT;
                  yyval.type->typedef_resolve(1);
               ;
    break;}
case 157:
#line 1909 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
               ;
    break;}
case 158:
#line 1912 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 159:
#line 1915 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 160:
#line 1918 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 161:
#line 1921 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 162:
#line 1924 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 163:
#line 1927 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 164:
#line 1930 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
	       ;
    break;}
case 165:
#line 1933 "parser.yxx"
{
                   if (yyvsp[0].type) yyval.type = yyvsp[0].type;
		   else yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 166:
#line 1937 "parser.yxx"
{
                   if (yyvsp[0].type) yyval.type = yyvsp[0].type;
		   else yyval.type = yyvsp[-1].type;
	       ;
    break;}
case 167:
#line 1941 "parser.yxx"
{
		   yyval.type = yyvsp[-1].type;
		   strcat(yyval.type->name,yyvsp[0].id);
	       ;
    break;}
case 168:
#line 1945 "parser.yxx"
{
		  yyval.type = yyvsp[0].type;
                  yyval.type->qualifier = new char[6];
		  strcpy(yyval.type->qualifier,"const");
     	       ;
    break;}
case 169:
#line 1950 "parser.yxx"
{
                  yyval.type = new DataType;
		  sprintf(yyval.type->name,"%s %s",yyvsp[-1].id, yyvsp[0].id);
		  yyval.type->type = T_USER;
	       ;
    break;}
case 170:
#line 1959 "parser.yxx"
{
                   yyval.type = (DataType *) 0;
               ;
    break;}
case 171:
#line 1962 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
		   yyval.type->type = T_INT;
		   sprintf(temp_name,"signed %s",yyvsp[0].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 172:
#line 1968 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
		   yyval.type->type = T_SHORT;
		   sprintf(temp_name,"signed %s",yyvsp[-1].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 173:
#line 1974 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
		   yyval.type->type = T_LONG;
		   sprintf(temp_name,"signed %s",yyvsp[-1].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 174:
#line 1980 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
		   yyval.type->type = T_SCHAR;
		   sprintf(temp_name,"signed %s",yyvsp[0].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 175:
#line 1990 "parser.yxx"
{
                   yyval.type = (DataType *) 0;
               ;
    break;}
case 176:
#line 1993 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
		   yyval.type->type = T_UINT;
		   sprintf(temp_name,"unsigned %s",yyvsp[0].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 177:
#line 1999 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
		   yyval.type->type = T_USHORT;
		   sprintf(temp_name,"unsigned %s",yyvsp[-1].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 178:
#line 2005 "parser.yxx"
{
                   yyval.type = yyvsp[-1].type;
		   yyval.type->type = T_ULONG;
		   sprintf(temp_name,"unsigned %s",yyvsp[-1].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 179:
#line 2011 "parser.yxx"
{
                   yyval.type = yyvsp[0].type;
		   yyval.type->type = T_UCHAR;
		   sprintf(temp_name,"unsigned %s",yyvsp[0].type->name);
		   strcpy(yyval.type->name,temp_name);
	       ;
    break;}
case 180:
#line 2019 "parser.yxx"
{ ;
    break;}
case 181:
#line 2020 "parser.yxx"
{ ;
    break;}
case 182:
#line 2023 "parser.yxx"
{ scanner_check_typedef(); ;
    break;}
case 183:
#line 2023 "parser.yxx"
{
                   yyval.dtype = yyvsp[0].dtype;
		   scanner_ignore_typedef();
		   if (ConstChar) delete ConstChar;
		   ConstChar = 0;
                ;
    break;}
case 184:
#line 2029 "parser.yxx"
{
                   yyval.dtype.id = yyvsp[0].id;
                   yyval.dtype.type = T_CHAR;
		   if (ConstChar) delete ConstChar;
		   ConstChar = new char[strlen(yyvsp[0].id)+3];
		   sprintf(ConstChar,"\"%s\"",yyvsp[0].id);
		;
    break;}
case 185:
#line 2036 "parser.yxx"
{
                   yyval.dtype.id = yyvsp[0].id;
		   yyval.dtype.type = T_CHAR;
		   if (ConstChar) delete ConstChar;
		   ConstChar = new char[strlen(yyvsp[0].id)+3];
		   sprintf(ConstChar,"'%s'",yyvsp[0].id);
		 ;
    break;}
case 186:
#line 2048 "parser.yxx"
{
                 yyval.ilist = yyvsp[-2].ilist;
		 yyval.ilist.names[yyval.ilist.count] = copy_string(yyvsp[0].id);
		 yyval.ilist.count++;
		 yyval.ilist.names[yyval.ilist.count] = (char *) 0;
                ;
    break;}
case 187:
#line 2054 "parser.yxx"
{
                 yyval.ilist.names = new char *[NI_NAMES];
		 yyval.ilist.count = 0;
		 for (i = 0; i < NI_NAMES; i++) 
		   yyval.ilist.names[i] = (char *) 0;
	       ;
    break;}
case 188:
#line 2064 "parser.yxx"
{ yyval.id = yyvsp[0].id; ;
    break;}
case 189:
#line 2065 "parser.yxx"
{ yyval.id = (char *) 0;;
    break;}
case 190:
#line 2071 "parser.yxx"
{;
    break;}
case 191:
#line 2072 "parser.yxx"
{;
    break;}
case 192:
#line 2076 "parser.yxx"
{
		   temp_typeptr = new DataType(T_INT);
		   create_constant(yyvsp[0].id, temp_typeptr, yyvsp[0].id);
		   delete temp_typeptr;
		 ;
    break;}
case 193:
#line 2081 "parser.yxx"
{ scanner_check_typedef();;
    break;}
case 194:
#line 2081 "parser.yxx"
{
		   temp_typeptr = new DataType(yyvsp[0].dtype.type);
// Use enum name instead of value
// OLD		   create_constant($1, temp_typeptr, $4.id);
                   create_constant(yyvsp[-3].id, temp_typeptr, yyvsp[-3].id);
		   delete temp_typeptr;
                 ;
    break;}
case 195:
#line 2088 "parser.yxx"
{ ;
    break;}
case 196:
#line 2091 "parser.yxx"
{
                   yyval.dtype = yyvsp[0].dtype;
		   if ((yyval.dtype.type != T_INT) && (yyval.dtype.type != T_UINT) &&
		       (yyval.dtype.type != T_LONG) && (yyval.dtype.type != T_ULONG) &&
		       (yyval.dtype.type != T_SHORT) && (yyval.dtype.type != T_USHORT) && 
		       (yyval.dtype.type != T_SCHAR) && (yyval.dtype.type != T_UCHAR)) {
		     fprintf(stderr,"%s : Lind %d. Type error. Expecting an int\n",
			     input_file, line_number);
		     FatalError();
		   }

                ;
    break;}
case 197:
#line 2103 "parser.yxx"
{
                   yyval.dtype.id = yyvsp[0].id;
		   yyval.dtype.type = T_CHAR;
		 ;
    break;}
case 198:
#line 2114 "parser.yxx"
{ 
                  yyval.dtype.id = yyvsp[0].id;
                  yyval.dtype.type = T_INT;
                 ;
    break;}
case 199:
#line 2118 "parser.yxx"
{
                  yyval.dtype.id = yyvsp[0].id;
                  yyval.dtype.type = T_DOUBLE;
               ;
    break;}
case 200:
#line 2122 "parser.yxx"
{
                  yyval.dtype.id = yyvsp[0].id;
		  yyval.dtype.type = T_UINT;
	       ;
    break;}
case 201:
#line 2126 "parser.yxx"
{
                  yyval.dtype.id = yyvsp[0].id;
		  yyval.dtype.type = T_LONG;
	       ;
    break;}
case 202:
#line 2130 "parser.yxx"
{
                  yyval.dtype.id = yyvsp[0].id;
		  yyval.dtype.type = T_ULONG;
	       ;
    break;}
case 203:
#line 2134 "parser.yxx"
{
	          yyval.dtype.id = new char[strlen(yyvsp[-1].type->name)+9];
		  sprintf(yyval.dtype.id,"sizeof(%s)", yyvsp[-1].type->name);
		  yyval.dtype.type = T_INT;
	       ;
    break;}
case 204:
#line 2139 "parser.yxx"
{
		  yyval.dtype.id = new char[strlen(yyvsp[0].dtype.id)+strlen(yyvsp[-2].type->name)+3];
		  sprintf(yyval.dtype.id,"(%s)%s",yyvsp[-2].type->name,yyvsp[0].dtype.id);
		  yyval.dtype.type = yyvsp[-2].type->type;
	       ;
    break;}
case 205:
#line 2144 "parser.yxx"
{
		 yyval.dtype.id = lookup_symvalue(yyvsp[0].id);
		 if (yyval.dtype.id == (char *) 0)
		   yyval.dtype.id = yyvsp[0].id;
		 else {
		   yyval.dtype.id = new char[strlen(yyval.dtype.id)+3];
		   sprintf(yyval.dtype.id,"(%s)",lookup_symvalue(yyvsp[0].id));
		 }
		 temp_typeptr = lookup_symtype(yyvsp[0].id);
		 if (temp_typeptr) yyval.dtype.type = temp_typeptr->type;
		 else yyval.dtype.type = T_INT;
               ;
    break;}
case 206:
#line 2156 "parser.yxx"
{
                  yyval.dtype.id = new char[strlen(yyvsp[-2].id)+strlen(yyvsp[0].id)+3];
		  sprintf(yyval.dtype.id,"%s::%s",yyvsp[-2].id,yyvsp[0].id);
                  yyval.dtype.type = T_INT;
		  delete yyvsp[-2].id;
		  delete yyvsp[0].id;
               ;
    break;}
case 207:
#line 2163 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"+");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;
	       ;
    break;}
case 208:
#line 2169 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"-");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;
	       ;
    break;}
case 209:
#line 2175 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"*");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 210:
#line 2182 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"/");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 211:
#line 2189 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"&");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 if ((yyvsp[-2].dtype.type == T_DOUBLE) || (yyvsp[0].dtype.type == T_DOUBLE)) {
		   fprintf(stderr,"%s : Line %d. Type error in constant expression (expecting integers).\n", input_file, line_number);
		   FatalError();
		 }
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 212:
#line 2200 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"|");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 if ((yyvsp[-2].dtype.type == T_DOUBLE) || (yyvsp[0].dtype.type == T_DOUBLE)) {
		   fprintf(stderr,"%s : Line %d. Type error in constant expression (expecting integers).\n", input_file, line_number);
		   FatalError();
		 }
		 yyval.dtype.type = T_INT;
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 213:
#line 2212 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"^");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 if ((yyvsp[-2].dtype.type == T_DOUBLE) || (yyvsp[0].dtype.type == T_DOUBLE)) {
		   fprintf(stderr,"%s : Line %d. Type error in constant expression (expecting integers).\n", input_file, line_number);
		   FatalError();
		 }
		 yyval.dtype.type = T_INT;
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 214:
#line 2224 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,"<<");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 if ((yyvsp[-2].dtype.type == T_DOUBLE) || (yyvsp[0].dtype.type == T_DOUBLE)) {
		   fprintf(stderr,"%s : Line %d. Type error in constant expression (expecting integers).\n", input_file, line_number);
		   FatalError();
		 }
		 yyval.dtype.type = T_INT;
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 215:
#line 2236 "parser.yxx"
{
	         E_BINARY(yyval.dtype.id,yyvsp[-2].dtype.id,yyvsp[0].dtype.id,">>");
		 yyval.dtype.type = promote(yyvsp[-2].dtype.type,yyvsp[0].dtype.type);
		 if ((yyvsp[-2].dtype.type == T_DOUBLE) || (yyvsp[0].dtype.type == T_DOUBLE)) {
		   fprintf(stderr,"%s : Line %d. Type error in constant expression (expecting integers).\n", input_file, line_number);
		   FatalError();
		 }
		 yyval.dtype.type = T_INT;
		 delete yyvsp[-2].dtype.id;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 216:
#line 2248 "parser.yxx"
{
	          yyval.dtype.id = new char[strlen(yyvsp[0].dtype.id)+2];
		  sprintf(yyval.dtype.id,"-%s",yyvsp[0].dtype.id);
		  yyval.dtype.type = yyvsp[0].dtype.type;
		 delete yyvsp[0].dtype.id;

	       ;
    break;}
case 217:
#line 2255 "parser.yxx"
{
	          yyval.dtype.id = new char[strlen(yyvsp[0].dtype.id)+2];
		  sprintf(yyval.dtype.id,"~%s",yyvsp[0].dtype.id);
		  if (yyvsp[0].dtype.type == T_DOUBLE) {
		   fprintf(stderr,"%s : Line %d. Type error in constant expression (expecting integers).\n", input_file, line_number);
		   FatalError();
		  }
		  yyval.dtype.type = yyvsp[0].dtype.type;
		  delete yyvsp[0].dtype.id;
	       ;
    break;}
case 218:
#line 2265 "parser.yxx"
{
	          yyval.dtype.id = new char[strlen(yyvsp[-1].dtype.id)+3];
	          sprintf(yyval.dtype.id,"(%s)", yyvsp[-1].dtype.id);
		  yyval.dtype.type = yyvsp[-1].dtype.type;
		  delete yyvsp[-1].dtype.id;
	       ;
    break;}
case 219:
#line 2276 "parser.yxx"
{ ;
    break;}
case 220:
#line 2277 "parser.yxx"
{;
    break;}
case 221:
#line 2283 "parser.yxx"
{
	       char *iname;
	       if (allow) {
		 init_language();
		 DataType::new_scope();

		 sprintf(temp_name,"CPP_CLASS:%s\n",yyvsp[-2].id);
		 if (add_symbol(temp_name, (DataType *) 0, (char *) 0)) {
		   fprintf(stderr,"%s : Line %d. Error. %s %s is multiply defined.\n", input_file, line_number, yyvsp[-3].id, yyvsp[-2].id);
		   FatalError();
		 }
		 if ((!CPlusPlus) && (strcmp(yyvsp[-3].id,"class") == 0))
		   fprintf(stderr,"%s : Line %d. *** WARNING ***. C++ mode is disabled (enable using -c++)\n", input_file, line_number);

		 iname = make_name(yyvsp[-2].id);
		 doc_entry = new DocClass(iname, doc_parent());
		 if (iname == yyvsp[-2].id) 
		   cplus_open_class(yyvsp[-2].id, 0, yyvsp[-3].id);
		 else
		   cplus_open_class(yyvsp[-2].id, iname, yyvsp[-3].id);
		 if (strcmp(yyvsp[-3].id,"class") == 0)
		   cplus_mode = CPLUS_PRIVATE;
		 else
		   cplus_mode = CPLUS_PUBLIC;
		 doc_stack_top++;
		 doc_stack[doc_stack_top] = doc_entry;
		 scanner_clear_start();
		 nested_list = 0;
		 // Merge in scope from base classes
		 cplus_inherit_scope(yyvsp[-1].ilist.count,yyvsp[-1].ilist.names);
	       }
              ;
    break;}
case 222:
#line 2314 "parser.yxx"
{
		if (allow) {
		  if (yyvsp[-4].ilist.names) {
		    if (strcmp(yyvsp[-6].id,"union") != 0)
		      cplus_inherit(yyvsp[-4].ilist.count, yyvsp[-4].ilist.names);
		    else {
		      fprintf(stderr,"%s : Line %d.  Inheritance not allowed for unions.\n",input_file, line_number);
		      FatalError();
		    }
		  }
		  // Clean up the inheritance list
		  if (yyvsp[-4].ilist.names) {
		    int j;
		    for (j = 0; j < yyvsp[-4].ilist.count; j++) {
		      if (yyvsp[-4].ilist.names[j]) delete [] yyvsp[-4].ilist.names[j];
		    }
		    delete [] yyvsp[-4].ilist.names;
		  }

		  // Dumped nested declarations (if applicable)
		  dump_nested(yyvsp[-5].id);

		  // Save and collapse current scope
		  cplus_register_scope(DataType::collapse_scope(yyvsp[-5].id));

		  // Restore the original doc entry for this class
		  doc_entry = doc_stack[doc_stack_top];
		  cplus_class_close((char *) 0); 
		  doc_entry = 0;
		  // Bump the documentation stack back down
		  doc_stack_top--;
		  cplus_mode = CPLUS_PUBLIC;
		}
	      ;
    break;}
case 223:
#line 2351 "parser.yxx"
{
	       if (allow) {
		 char *iname;
		 init_language();
		 DataType::new_scope();

		 sprintf(temp_name,"CPP_CLASS:%s\n",yyvsp[-2].id);
		 if (add_symbol(temp_name, (DataType *) 0, (char *) 0)) {
		   fprintf(stderr,"%s : Line %d. Error. %s %s is multiply defined.\n", input_file, line_number, yyvsp[-3].id, yyvsp[-2].id);
		   FatalError();
		 }
		 if ((!CPlusPlus) && (strcmp(yyvsp[-3].id,"class") == 0))
		   fprintf(stderr,"%s : Line %d. *** WARNING ***. C++ mode is disabled (enable using -c++)\n", input_file, line_number);
		 
		 iname = make_name(yyvsp[-2].id);
		 doc_entry = new DocClass(iname, doc_parent());
		 if (yyvsp[-2].id == iname) 
		   cplus_open_class(yyvsp[-2].id, 0, yyvsp[-3].id);
		 else
		   cplus_open_class(yyvsp[-2].id, iname, yyvsp[-3].id);
		 if (strcmp(yyvsp[-3].id,"class") == 0)
		   cplus_mode = CPLUS_PRIVATE;
		 else
		   cplus_mode = CPLUS_PUBLIC;
		 // Create a documentation entry for the class
		 doc_stack_top++;
		 doc_stack[doc_stack_top] = doc_entry;
		 scanner_clear_start();
		 nested_list = 0;

		 // Merge in scope from base classes
		 cplus_inherit_scope(yyvsp[-1].ilist.count,yyvsp[-1].ilist.names);

	       }
              ;
    break;}
case 224:
#line 2385 "parser.yxx"
{
		if (allow) {
		  if (yyvsp[-5].ilist.names) {
		    if (strcmp(yyvsp[-7].id,"union") != 0)
		      cplus_inherit(yyvsp[-5].ilist.count, yyvsp[-5].ilist.names);
		    else {
		      fprintf(stderr,"%s : Line %d.  Inheritance not allowed for unions.\n",input_file, line_number);
		      FatalError();
		    }
		  }
		  // Create a datatype for correctly processing the typedef
		  Active_typedef = new DataType();
		  Active_typedef->type = T_USER;
		  sprintf(Active_typedef->name,"%s %s", yyvsp[-7].id,yyvsp[-6].id);
		  Active_typedef->is_pointer = 0;
		  Active_typedef->implicit_ptr = 0;

		  // Clean up the inheritance list
		  if (yyvsp[-5].ilist.names) {
		    int j;
		    for (j = 0; j < yyvsp[-5].ilist.count; j++) {
		      if (yyvsp[-5].ilist.names[j]) delete [] yyvsp[-5].ilist.names[j];
		    }
		    delete [] yyvsp[-5].ilist.names;
		  }

		  if (yyvsp[0].decl.is_pointer > 0) {
		    fprintf(stderr,"%s : Line %d.  typedef struct { } *id not supported properly. Winging it...\n", input_file, line_number);

		  }
		  // Create dump nested class code
		  if (yyvsp[0].decl.is_pointer > 0) {
		    dump_nested(yyvsp[-6].id);
		  } else {
		    dump_nested(yyvsp[0].decl.id);
		  }
		    
		  // Collapse any datatypes created in the the class

		  cplus_register_scope(DataType::collapse_scope(yyvsp[-6].id));

		  doc_entry = doc_stack[doc_stack_top];
		  if (yyvsp[0].decl.is_pointer > 0) {
		    cplus_class_close(yyvsp[-6].id);
		  } else {
		    cplus_class_close(yyvsp[0].decl.id); 
		  }
		  doc_stack_top--;
		  doc_entry = 0;

		  // Create a typedef in global scope

		  if (yyvsp[0].decl.is_pointer == 0)
		    Active_typedef->typedef_add(yyvsp[0].decl.id);
		  else {
		    DataType *t = new DataType(Active_typedef);
		    t->is_pointer += yyvsp[0].decl.is_pointer;
		    t->typedef_add(yyvsp[0].decl.id);
		    cplus_register_type(yyvsp[0].decl.id);
		    delete t;
		  }
		  cplus_mode = CPLUS_PUBLIC;
		}
	      ;
    break;}
case 225:
#line 2448 "parser.yxx"
{ ;
    break;}
case 226:
#line 2452 "parser.yxx"
{
	       char *iname;
	       if (allow) {
		 init_language();
		 DataType::new_scope();
		 if ((!CPlusPlus) && (strcmp(yyvsp[-1].id,"class") == 0))
		   fprintf(stderr,"%s : Line %d. *** WARNING ***. C++ mode is disabled (enable using -c++)\n", input_file, line_number);
		 
		 iname = make_name("");
		 doc_entry = new DocClass(iname,doc_parent());
		 if (strlen(iname))
		   cplus_open_class("", iname, yyvsp[-1].id);
		 else
		   cplus_open_class("",0,yyvsp[-1].id);
		 if (strcmp(yyvsp[-1].id,"class") == 0)
		   cplus_mode = CPLUS_PRIVATE;
		 else
		   cplus_mode = CPLUS_PUBLIC;
		 doc_stack_top++;
		 doc_stack[doc_stack_top] = doc_entry;
		 scanner_clear_start();
		 nested_list = 0;
	       }
              ;
    break;}
case 227:
#line 2475 "parser.yxx"
{
		if (allow) {
		  if (yyvsp[0].decl.is_pointer > 0) {
		    fprintf(stderr,"%s : Line %d. typedef %s {} *%s not supported correctly. Will be ignored.\n", input_file, line_number, yyvsp[-5].id, yyvsp[0].decl.id);
		    cplus_abort();
		  } else {
		    sprintf(temp_name,"CPP_CLASS:%s\n",yyvsp[0].decl.id);
		    if (add_symbol(temp_name, (DataType *) 0, (char *) 0)) {
		      fprintf(stderr,"%s : Line %d. Error. %s %s is multiply defined.\n", input_file, line_number, yyvsp[-5].id, yyvsp[0].decl.id);
		      FatalError();
		    }
		  }
		  // Create a datatype for correctly processing the typedef
		  Active_typedef = new DataType();
		  Active_typedef->type = T_USER;
		  sprintf(Active_typedef->name,"%s",yyvsp[0].decl.id);
		  Active_typedef->is_pointer = 0;
		  Active_typedef->implicit_ptr = 0;
		  
		  // Dump nested classes
		  if (yyvsp[0].decl.is_pointer == 0)  
		    dump_nested(yyvsp[0].decl.id);

		  // Go back to previous scope

		  cplus_register_scope(DataType::collapse_scope((char *) 0));
		  
		  doc_entry = doc_stack[doc_stack_top];
		  // Change name of doc_entry
		  doc_entry->name = copy_string(yyvsp[0].decl.id);
		  if (yyvsp[0].decl.is_pointer == 0) 
		    cplus_class_close(yyvsp[0].decl.id); 
		  doc_entry = 0;
		  doc_stack_top--;
		  cplus_mode = CPLUS_PUBLIC;
		}
	      ;
    break;}
case 228:
#line 2511 "parser.yxx"
{ ;
    break;}
case 229:
#line 2516 "parser.yxx"
{
	       char *iname;
		 if (allow) {
		   init_language();
		   iname = make_name(yyvsp[-1].id);
		   lang->cpp_class_decl(yyvsp[-1].id,iname,yyvsp[-2].id);
		 }
	     ;
    break;}
case 230:
#line 2527 "parser.yxx"
{
	       if (allow) {
		 init_language();
		 if (!CPlusPlus) 
		   fprintf(stderr,"%s : Line %d. *** WARNING ***. C++ mode is disabled (enable using -c++)\n", input_file, line_number);
		 
		 yyvsp[-7].type->is_pointer += yyvsp[-6].decl.is_pointer;
		 yyvsp[-7].type->is_reference = yyvsp[-6].decl.is_reference;
		 // Fix up the function name
		 sprintf(temp_name,"%s::%s",yyvsp[-6].decl.id,yyvsp[-4].id);
		 if (!Rename_true) {
		   Rename_true = 1;
		   sprintf(yy_rename,"%s_%s",yyvsp[-6].decl.id,yyvsp[-4].id);
		 }
		 create_function(yyvsp[-8].ivalue, temp_name, yyvsp[-7].type, yyvsp[-2].pl);
	       }
	       delete yyvsp[-7].type;
	       delete yyvsp[-2].pl;
	      ;
    break;}
case 231:
#line 2548 "parser.yxx"
{
	       if (allow) {
		 init_language();
		 if (!CPlusPlus) 
		   fprintf(stderr,"%s : Line %d. *** WARNING ***. C++ mode is disabled (enable using -c++)\n", input_file, line_number);

		 yyvsp[-4].type->is_pointer += yyvsp[-3].decl.is_pointer;
		 // Fix up the function name
		 sprintf(temp_name,"%s::%s",yyvsp[-3].decl.id,yyvsp[-1].id);
		 if (!Rename_true) {
		   Rename_true = 1;
		   sprintf(yy_rename,"%s_%s",yyvsp[-3].decl.id,yyvsp[-1].id);
		 }
		 create_variable(yyvsp[-5].ivalue,temp_name, yyvsp[-4].type);
	       }
	       delete yyvsp[-4].type;
	     ;
    break;}
case 232:
#line 2568 "parser.yxx"
{
	       fprintf(stderr,"%s : Line %d. Operator overloading not supported (ignored).\n", input_file, line_number);
		skip_decl();
		delete yyvsp[-3].type;
	     ;
    break;}
case 233:
#line 2576 "parser.yxx"
{
	       fprintf(stderr,"%s : Line %d. Templates not currently supported (ignored).\n",
		       input_file, line_number);
	       skip_decl();
	     ;
    break;}
case 234:
#line 2584 "parser.yxx"
{
	       cplus_mode = CPLUS_PUBLIC;
               doc_entry = cplus_set_class(yyvsp[-1].id);
	       if (!doc_entry) {
		 doc_entry = new DocClass(yyvsp[-1].id,doc_parent());
	       };
	       doc_stack_top++;
	       doc_stack[doc_stack_top] = doc_entry;
	       scanner_clear_start();
	       AddMethods = 1;
	     ;
    break;}
case 235:
#line 2594 "parser.yxx"
{
	       cplus_unset_class();
	       doc_entry = 0;
	       doc_stack_top--;
	       AddMethods = 0;
	     ;
    break;}
case 236:
#line 2602 "parser.yxx"
{ ;
    break;}
case 237:
#line 2603 "parser.yxx"
{ ;
    break;}
case 238:
#line 2604 "parser.yxx"
{ ;
    break;}
case 239:
#line 2607 "parser.yxx"
{;
    break;}
case 240:
#line 2608 "parser.yxx"
{
	           AddMethods = 1;
	     ;
    break;}
case 241:
#line 2610 "parser.yxx"
{
	           AddMethods = 0;
	     ;
    break;}
case 242:
#line 2612 "parser.yxx"
{ ;
    break;}
case 243:
#line 2613 "parser.yxx"
{
	       skip_decl();
		   {
		     static int last_error_line = -1;
		     if (last_error_line != line_number) {
		       fprintf(stderr,"%s : Line %d. Syntax error in input.\n", input_file, line_number);
		       FatalError();
		       last_error_line = line_number;
		     }
		   }
	     ;
    break;}
case 244:
#line 2623 "parser.yxx"
{ ;
    break;}
case 245:
#line 2624 "parser.yxx"
{ ;
    break;}
case 246:
#line 2627 "parser.yxx"
{
                char *iname;
                if (allow) {
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		    Stat_func++;
		    yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		    yyvsp[-5].type->is_reference = yyvsp[-4].decl.is_reference;
		    if (Verbose) {
		      fprintf(stderr,"Wrapping member function : %s\n",yyvsp[-4].decl.id);
		    }
		    iname = make_name(yyvsp[-4].decl.id);
		    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		    if (iname == yyvsp[-4].decl.id) iname = 0;
		    cplus_member_func(yyvsp[-4].decl.id, iname, yyvsp[-5].type,yyvsp[-2].pl,0);
		  }
		  scanner_clear_start();
		}
		delete yyvsp[-5].type;
		delete yyvsp[-2].pl;
              ;
    break;}
case 247:
#line 2651 "parser.yxx"
{
	       char *iname;
	       if (allow) {
		 init_language();
		 if (cplus_mode == CPLUS_PUBLIC) {
		   Stat_func++;
		   yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		   yyvsp[-5].type->is_reference = yyvsp[-4].decl.is_reference;
		   if (Verbose) {
		     fprintf(stderr,"Wrapping virtual member function : %s\n",yyvsp[-4].decl.id);
		   }
		   iname = make_name(yyvsp[-4].decl.id);
		   doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		   if (iname == yyvsp[-4].decl.id) iname = 0;
		   cplus_member_func(yyvsp[-4].decl.id,iname,yyvsp[-5].type,yyvsp[-2].pl,1);
		 }
		 scanner_clear_start();
	       }
	       delete yyvsp[-5].type;
	       delete yyvsp[-2].pl;
	     ;
    break;}
case 248:
#line 2674 "parser.yxx"
{
		char *iname;
		if (allow) {
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		    Stat_func++;
		    if (Verbose) {
		      fprintf(stderr,"Wrapping C++ constructor %s\n", yyvsp[-4].id);
		    }
		    iname = make_name(yyvsp[-4].id);
		    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		    if (iname == yyvsp[-4].id) iname = 0;
		    cplus_constructor(yyvsp[-4].id,iname, yyvsp[-2].pl);
		  }
		  scanner_clear_start();
		}
		delete yyvsp[-2].pl;
	      ;
    break;}
case 249:
#line 2695 "parser.yxx"
{
		char *iname;
		if (allow) {
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		    Stat_func++;
		    if (Verbose) {
		      fprintf(stderr,"Wrapping C++ destructor %s\n", yyvsp[-4].id);
		    }
		    iname = make_name(yyvsp[-4].id);
		    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		    if (iname == yyvsp[-4].id) iname = 0;
		    cplus_destructor(yyvsp[-4].id,iname);
		  }
		}
		scanner_clear_start();
	      ;
    break;}
case 250:
#line 2715 "parser.yxx"
{
 	        char *iname;
		if (allow) {
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		    Stat_func++;
		    if (Verbose) {
		      fprintf(stderr,"Wrapping C++ destructor %s\n", yyvsp[-3].id);
		    }
		    iname = make_name(yyvsp[-3].id);
		    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		    if (iname == yyvsp[-3].id) iname = 0;
		    cplus_destructor(yyvsp[-3].id,iname);
		  }
		}
		scanner_clear_start();
	      ;
    break;}
case 251:
#line 2735 "parser.yxx"
{
		if (allow) {
		  char *iname;
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		    if (Active_type) delete Active_type;
		    Active_type = new DataType(yyvsp[-2].type);
		    yyvsp[-2].type->is_pointer += yyvsp[-1].decl.is_pointer;
		    yyvsp[-2].type->is_reference = yyvsp[-1].decl.is_reference;
		    if (yyvsp[-2].type->qualifier) {
		      if ((strcmp(yyvsp[-2].type->qualifier,"const") == 0) && (yyvsp[-2].type->is_pointer == 0)) {
			// Okay.  This is really some sort of C++ constant here.
	  	          if (yyvsp[0].dtype.type != T_ERROR) {
			    iname = make_name(yyvsp[-1].decl.id);
			    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
			    if (iname == yyvsp[-1].decl.id) iname = 0;
			    cplus_declare_const(yyvsp[-1].decl.id,iname, yyvsp[-2].type, yyvsp[0].dtype.id);
			  }
		      } else {
			int oldstatus = Status;
			char *tm;
			if (yyvsp[-2].type->status & STAT_READONLY) {
			  if (!(tm = typemap_lookup("memberin",typemap_lang,yyvsp[-2].type,yyvsp[-1].decl.id,"",""))) 
			    Status = Status | STAT_READONLY;
			}
			iname = make_name(yyvsp[-1].decl.id);
			doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
			if (iname == yyvsp[-1].decl.id) iname = 0;
			cplus_variable(yyvsp[-1].decl.id,iname,yyvsp[-2].type);
			Status = oldstatus;
		      }
		    } else {
		      char *tm = 0;
		      int oldstatus = Status;
		      if (yyvsp[-2].type->status & STAT_READONLY) {
			if (!(tm = typemap_lookup("memberin",typemap_lang,yyvsp[-2].type,yyvsp[-1].decl.id,"",""))) 
			  Status = Status | STAT_READONLY;
		      }
		      iname = make_name(yyvsp[-1].decl.id);
		      doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		      if (iname == yyvsp[-1].decl.id) iname = 0;
		      cplus_variable(yyvsp[-1].decl.id,iname,yyvsp[-2].type);
		      Status = oldstatus;
		      if (Verbose) {
			fprintf(stderr,"Wrapping member data %s\n", yyvsp[-1].decl.id);
		      }
		    }
		  }
		  scanner_clear_start();
		}
		delete yyvsp[-2].type;
	      ;
    break;}
case 252:
#line 2786 "parser.yxx"
{ ;
    break;}
case 253:
#line 2788 "parser.yxx"
{
		char *iname;
		if (allow) {
		  int oldstatus = Status;
		  char *tm = 0;
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		    if (Active_type) delete Active_type;
		    Active_type = new DataType(yyvsp[-3].type);
		    yyvsp[-3].type->is_pointer += yyvsp[-2].decl.is_pointer + 1;
		    yyvsp[-3].type->is_reference = yyvsp[-2].decl.is_reference;
		    yyvsp[-3].type->arraystr = copy_string(ArrayString);
		    if (!(tm = typemap_lookup("memberin",typemap_lang,yyvsp[-3].type,yyvsp[-2].decl.id,"",""))) 
		      Status = STAT_READONLY;

		    iname = make_name(yyvsp[-2].decl.id);
		    doc_entry = new DocDecl(iname, doc_stack[doc_stack_top]);
		    if (iname == yyvsp[-2].decl.id) iname = 0;
		    cplus_variable(yyvsp[-2].decl.id,iname,yyvsp[-3].type);
		    Status = oldstatus;
		    if (!tm)
		      fprintf(stderr,"%s : Line %d. Warning. Array member will be read-only.\n",input_file,line_number);
		  }
		scanner_clear_start();
		}
		delete yyvsp[-3].type;
	      ;
    break;}
case 254:
#line 2819 "parser.yxx"
{
		char *iname;
		if (allow) {
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		    yyvsp[-1].type->is_pointer += yyvsp[0].decl.is_pointer;
		    iname = make_name(yyvsp[0].decl.id);
		    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		    if (iname == yyvsp[0].decl.id) iname = 0;
		    cplus_static_var(yyvsp[0].decl.id,iname,yyvsp[-1].type);
		    if (Active_type) delete Active_type;
		    Active_type = new DataType(yyvsp[-1].type);
		    if (Verbose) {
		      fprintf(stderr,"Wrapping static member data %s\n", yyvsp[0].decl.id);
		    }
		  }
		  scanner_clear_start();
		}
		delete yyvsp[-1].type;
	      ;
    break;}
case 255:
#line 2838 "parser.yxx"
{ ;
    break;}
case 256:
#line 2842 "parser.yxx"
{
		char *iname;
		if (allow) {
		  yyvsp[-5].type->is_pointer += yyvsp[-4].decl.is_pointer;
		  yyvsp[-5].type->is_reference = yyvsp[-4].decl.is_reference;
		  if (cplus_mode == CPLUS_PUBLIC) {
		    iname = make_name(yyvsp[-4].decl.id);
		    doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		    if (iname == yyvsp[-4].decl.id) iname = 0;
		    cplus_static_func(yyvsp[-4].decl.id, iname, yyvsp[-5].type, yyvsp[-2].pl);
		    if (Verbose)
		      fprintf(stderr,"Wrapping static member function %s\n",yyvsp[-4].decl.id);
		  }
		  scanner_clear_start();
		}
		delete yyvsp[-5].type;
		delete yyvsp[-2].pl;
	      ;
    break;}
case 257:
#line 2862 "parser.yxx"
{
		if (allow) {
		  cplus_mode = CPLUS_PUBLIC;
		  if (Verbose)
		    fprintf(stderr,"Public mode\n");
		  scanner_clear_start();
		}
	      ;
    break;}
case 258:
#line 2873 "parser.yxx"
{
		if (allow) {
		  cplus_mode = CPLUS_PRIVATE;
		  if (Verbose)
		    fprintf(stderr,"Private mode\n");
		  scanner_clear_start();
		}
	      ;
    break;}
case 259:
#line 2884 "parser.yxx"
{
		if (allow) {
		  cplus_mode = CPLUS_PROTECTED;
		  if (Verbose)
		    fprintf(stderr,"Protected mode\n");
		  scanner_clear_start();
		}
	      ;
    break;}
case 260:
#line 2895 "parser.yxx"
{
	       if (allow) {
		 strcpy(yy_rename,yyvsp[-1].id);
		 Rename_true = 1;
	       }
	     ;
    break;}
case 261:
#line 2903 "parser.yxx"
{
                 NewObject = 1;
             ;
    break;}
case 262:
#line 2905 "parser.yxx"
{
                 NewObject = 0;
             ;
    break;}
case 263:
#line 2910 "parser.yxx"
{scanner_clear_start();;
    break;}
case 264:
#line 2910 "parser.yxx"
{

		 // if ename was supplied.  Install it as a new integer datatype.

		if (allow) {
		  init_language();
		  if (cplus_mode == CPLUS_PUBLIC) {
		   if (yyvsp[-5].id) {
		     cplus_register_type(yyvsp[-5].id);
		     temp_type.type = T_INT;
		     temp_type.is_pointer = 0;
		     temp_type.implicit_ptr = 0;
		     sprintf(temp_type.name,"int");
		     temp_type.typedef_add(yyvsp[-5].id,1); 
		   }
		 }
	       }
	      ;
    break;}
case 265:
#line 2928 "parser.yxx"
{
		if (allow)
		  Status = Status | STAT_READONLY;
		scanner_clear_start();
              ;
    break;}
case 266:
#line 2933 "parser.yxx"
{
		if (allow) 
		  Status = Status & ~(STAT_READONLY);
		scanner_clear_start();
	      ;
    break;}
case 267:
#line 2939 "parser.yxx"
{
		if (allow)
		  fprintf(stderr,"%s : Line %d. Friends are not allowed--members only! (ignored)\n", input_file, line_number);
		skip_decl();
		scanner_clear_start();
	      ;
    break;}
case 268:
#line 2947 "parser.yxx"
{
		if (allow)
		  fprintf(stderr,"%s : Line %d. Operator overloading not supported (ignored).\n", input_file, line_number);
		skip_decl();
		scanner_clear_start();
	      ;
    break;}
case 269:
#line 2955 "parser.yxx"
{ ;
    break;}
case 270:
#line 2959 "parser.yxx"
{
	      		scanner_clear_start();
	      ;
    break;}
case 271:
#line 2964 "parser.yxx"
{
                 if (allow && (!WrapExtern)) { }
    	       ;
    break;}
case 272:
#line 2967 "parser.yxx"
{
		 if (allow && (!WrapExtern))
                   cplus_add_pragma(yyvsp[-3].id,yyvsp[-1].id,yyvsp[0].id);
	       ;
    break;}
case 273:
#line 2990 "parser.yxx"
{ start_line = line_number; skip_brace(); 
	      ;
    break;}
case 274:
#line 2991 "parser.yxx"
{ 

		if (cplus_mode == CPLUS_PUBLIC) {
		  cplus_register_type(yyvsp[-4].id);
		  if (yyvsp[-1].decl.id) {
		    if (strcmp(yyvsp[-5].id,"class") == 0) {
		      fprintf(stderr,"%s : Line %d.  Warning. Nested classes not currently supported (ignored).\n", input_file, line_number);
		      /* Generate some code for a new class */
		    } else {
		      Nested *n = new Nested;
		      n->code << "typedef " << yyvsp[-5].id << " " 
			      << CCode.get() << " $classname_" << yyvsp[-1].decl.id << ";\n";
		      n->name = copy_string(yyvsp[-1].decl.id);
		      n->line = start_line;
		      n->type = new DataType;
		      n->type->type = T_USER;
		      n->type->is_pointer = yyvsp[-1].decl.is_pointer;
		      n->type->is_reference = yyvsp[-1].decl.is_reference;
		      n->next = 0;
		      add_nested(n);
		    }
		  }
		}
	      ;
    break;}
case 275:
#line 3016 "parser.yxx"
{ start_line = line_number; skip_brace();
              ;
    break;}
case 276:
#line 3017 "parser.yxx"
{ 
		if (cplus_mode == CPLUS_PUBLIC) {
		  if (strcmp(yyvsp[-4].id,"class") == 0) {
		    fprintf(stderr,"%s : Line %d.  Warning. Nested classes not currently supported (ignored)\n", input_file, line_number);
		    /* Generate some code for a new class */
		  } else {
		    /* Generate some code for a new class */

		    Nested *n = new Nested;
		    n->code << "typedef " << yyvsp[-4].id << " " 
			    << CCode.get() << " $classname_" << yyvsp[-1].decl.id << ";\n";
		    n->name = copy_string(yyvsp[-1].decl.id);
		    n->line = start_line;
		    n->type = new DataType;
		    n->type->type = T_USER;
		    n->type->is_pointer = yyvsp[-1].decl.is_pointer;
		    n->type->is_reference = yyvsp[-1].decl.is_reference;
		    n->next = 0;
		    add_nested(n);

		  }
		}
	      ;
    break;}
case 277:
#line 3041 "parser.yxx"
{
  		    if (cplus_mode == CPLUS_PUBLIC) {
                       cplus_register_type(yyvsp[-1].id);
                    }
              ;
    break;}
case 278:
#line 3048 "parser.yxx"
{ 
                     skip_decl();
                     fprintf(stderr,"%s : Line %d. Function pointers not currently supported (ignored).\n", input_file, line_number);
		     
	      ;
    break;}
case 279:
#line 3053 "parser.yxx"
{
                     skip_decl();
                     fprintf(stderr,"%s : Line %d. Function pointers not currently supported (ignored).\n", input_file, line_number);
		     
	      ;
    break;}
case 280:
#line 3058 "parser.yxx"
{ 
                     skip_decl();
                     fprintf(stderr,"%s : Line %d. Function pointers not currently supported (ignored).\n", input_file, line_number);
		     
	      ;
    break;}
case 281:
#line 3063 "parser.yxx"
{ ;
    break;}
case 282:
#line 3064 "parser.yxx"
{ ;
    break;}
case 283:
#line 3067 "parser.yxx"
{ yyval.decl = yyvsp[0].decl;;
    break;}
case 284:
#line 3068 "parser.yxx"
{ yyval.decl.id = 0; ;
    break;}
case 285:
#line 3071 "parser.yxx"
{;
    break;}
case 286:
#line 3072 "parser.yxx"
{;
    break;}
case 287:
#line 3073 "parser.yxx"
{;
    break;}
case 288:
#line 3076 "parser.yxx"
{ ;
    break;}
case 289:
#line 3077 "parser.yxx"
{
		 if (allow) {
		   int oldstatus = Status;
		   char *tm;

		   init_language();
		   if (cplus_mode == CPLUS_PUBLIC) {
		     temp_typeptr = new DataType(Active_type);
		     temp_typeptr->is_pointer += yyvsp[-1].decl.is_pointer;
		     if (Verbose) {
		       fprintf(stderr,"Wrapping member variable : %s\n",yyvsp[-1].decl.id);
		     }
		     Stat_var++;
		     doc_entry = new DocDecl(yyvsp[-1].decl.id,doc_stack[doc_stack_top]);
		     if (temp_typeptr->status & STAT_READONLY) {
		       if (!(tm = typemap_lookup("memberin",typemap_lang,temp_typeptr,yyvsp[-1].decl.id,"",""))) 
			 Status = Status | STAT_READONLY;
		     }
		     cplus_variable(yyvsp[-1].decl.id,(char *) 0,temp_typeptr);		
		     Status = oldstatus;
		     delete temp_typeptr;
		   }
		   scanner_clear_start();
		 }
	       ;
    break;}
case 290:
#line 3101 "parser.yxx"
{ ;
    break;}
case 291:
#line 3102 "parser.yxx"
{
		 if (allow) {
		   int oldstatus = Status;
		   char *tm;

		   init_language();
		   if (cplus_mode == CPLUS_PUBLIC) {
		     temp_typeptr = new DataType(Active_type);
		     temp_typeptr->is_pointer += yyvsp[-2].decl.is_pointer;
		     if (Verbose) {
		       fprintf(stderr,"Wrapping member variable : %s\n",yyvsp[-2].decl.id);
		     }
		     Stat_var++;
		     if (!(tm = typemap_lookup("memberin",typemap_lang,temp_typeptr,yyvsp[-2].decl.id,"",""))) 
		       Status = Status | STAT_READONLY;
		     doc_entry = new DocDecl(yyvsp[-2].decl.id,doc_stack[doc_stack_top]);
		     if (temp_typeptr->status & STAT_READONLY) Status = Status | STAT_READONLY;
		     cplus_variable(yyvsp[-2].decl.id,(char *) 0,temp_typeptr);		
		     Status = oldstatus;
		     if (!tm)
		       fprintf(stderr,"%s : Line %d. Warning. Array member will be read-only.\n",input_file,line_number);
		     delete temp_typeptr;
		   }
		   scanner_clear_start();
		 }
	       ;
    break;}
case 292:
#line 3127 "parser.yxx"
{ ;
    break;}
case 293:
#line 3130 "parser.yxx"
{ 
                    CCode = "";
               ;
    break;}
case 294:
#line 3133 "parser.yxx"
{ skip_brace(); ;
    break;}
case 295:
#line 3136 "parser.yxx"
{ CCode = ""; ;
    break;}
case 296:
#line 3137 "parser.yxx"
{ CCode = ""; ;
    break;}
case 297:
#line 3138 "parser.yxx"
{ skip_brace(); ;
    break;}
case 298:
#line 3141 "parser.yxx"
{;
    break;}
case 299:
#line 3142 "parser.yxx"
{;
    break;}
case 300:
#line 3145 "parser.yxx"
{
                    if (allow) {
		      if (cplus_mode == CPLUS_PUBLIC) {
			if (Verbose) {
			  fprintf(stderr,"Creating enum value %s\n", yyvsp[0].id);
			}
			Stat_const++;
			temp_typeptr = new DataType(T_INT);
			doc_entry = new DocDecl(yyvsp[0].id,doc_stack[doc_stack_top]);
			cplus_declare_const(yyvsp[0].id, (char *) 0, temp_typeptr, (char *) 0);
			delete temp_typeptr;
			scanner_clear_start();
		      }
		    }
                  ;
    break;}
case 301:
#line 3160 "parser.yxx"
{
		   if (allow) {
		     if (cplus_mode == CPLUS_PUBLIC) {
		       if (Verbose) {
			 fprintf(stderr, "Creating enum value %s = %s\n", yyvsp[-2].id, yyvsp[0].dtype.id);
		       }
		       Stat_const++;
		       temp_typeptr = new DataType(T_INT);
		       doc_entry = new DocDecl(yyvsp[-2].id,doc_stack[doc_stack_top]);
		       cplus_declare_const(yyvsp[-2].id,(char *) 0, temp_typeptr,(char *) 0);
// OLD : Bug with value     cplus_declare_const($1,(char *) 0, temp_typeptr,$3.id);
		       delete temp_typeptr;
		       scanner_clear_start();
		     }
		   }
		 ;
    break;}
case 302:
#line 3176 "parser.yxx"
{
		   if (allow) {
		     if (cplus_mode == CPLUS_PUBLIC) {
		       if (Verbose) {
			 fprintf(stderr,"Creating enum value %s\n", yyvsp[0].id);
		       }
		       Stat_const++;
		       temp_typeptr = new DataType(T_INT);
		       doc_entry = new DocDecl(yyvsp[-2].id,doc_stack[doc_stack_top]);
		       cplus_declare_const(yyvsp[0].id, yyvsp[-2].id, temp_typeptr, (char *) 0);
		       delete temp_typeptr;
		       scanner_clear_start();
		     }
		   }
		 ;
    break;}
case 303:
#line 3191 "parser.yxx"
{
		     if (cplus_mode == CPLUS_PUBLIC) {
		       if (Verbose) {
			 fprintf(stderr, "Creating enum value %s = %s\n", yyvsp[-2].id, yyvsp[0].dtype.id);
		       }
		       Stat_const++;
		       temp_typeptr = new DataType(T_INT);
		       doc_entry = new DocDecl(yyvsp[-4].id,doc_stack[doc_stack_top]);
		       cplus_declare_const(yyvsp[-2].id,yyvsp[-4].id, temp_typeptr, (char *) 0);
// Old : bug with value	       cplus_declare_const($5,$3, temp_typeptr,$7.id);
		       delete temp_typeptr;
		       scanner_clear_start();
		     }
		 ;
    break;}
case 304:
#line 3205 "parser.yxx"
{ ;
    break;}
case 305:
#line 3208 "parser.yxx"
{
		   yyval.ilist = yyvsp[0].ilist;
                ;
    break;}
case 306:
#line 3211 "parser.yxx"
{
                   yyval.ilist.names = (char **) 0;
		   yyval.ilist.count = 0;
                ;
    break;}
case 307:
#line 3217 "parser.yxx"
{ 
                   int i;
                   yyval.ilist.names = new char *[NI_NAMES];
		   yyval.ilist.count = 0;
		   for (i = 0; i < NI_NAMES; i++){
		     yyval.ilist.names[i] = (char *) 0;
		   }
                   if (yyvsp[0].id) {
                       yyval.ilist.names[yyval.ilist.count] = copy_string(yyvsp[0].id);
                       yyval.ilist.count++;
		   }
               ;
    break;}
case 308:
#line 3230 "parser.yxx"
{ 
                   yyval.ilist = yyvsp[-2].ilist;
                   if (yyvsp[0].id) {
		     yyval.ilist.names[yyval.ilist.count] = copy_string(yyvsp[0].id);
		     yyval.ilist.count++;
		   }
               ;
    break;}
case 309:
#line 3239 "parser.yxx"
{     
                  fprintf(stderr,"%s : Line %d. No access specifier given for base class %s (ignored).\n",
			  input_file,line_number,yyvsp[0].id);
		  yyval.id = (char *) 0;
               ;
    break;}
case 310:
#line 3244 "parser.yxx"
{ 
                  fprintf(stderr,"%s : Line %d. No access specifier given for base class %s (ignored).\n",
			  input_file,line_number,yyvsp[0].id);
		  yyval.id = (char *) 0;
	       ;
    break;}
case 311:
#line 3249 "parser.yxx"
{
		 if (strcmp(yyvsp[-1].id,"public") == 0) {
		   yyval.id = yyvsp[0].id;
		 } else {
		   fprintf(stderr,"%s : Line %d. %s inheritance not supported (ignored).\n",
			   input_file,line_number,yyvsp[-1].id);
		   yyval.id = (char *) 0;
		 }
               ;
    break;}
case 312:
#line 3258 "parser.yxx"
{
		 if (strcmp(yyvsp[-1].id,"public") == 0) {
		   yyval.id = yyvsp[0].id;
		 } else {
		   fprintf(stderr,"%s : Line %d. %s inheritance not supported (ignored).\n",
			   input_file,line_number,yyvsp[-1].id);
		   yyval.id = (char *) 0;
		 }
	       ;
    break;}
case 313:
#line 3267 "parser.yxx"
{
                 if (strcmp(yyvsp[-2].id,"public") == 0) {
		   yyval.id = yyvsp[0].id;
		 } else {
		   fprintf(stderr,"%s : Line %d. %s inheritance not supported (ignored).\n",
			   input_file,line_number,yyvsp[-2].id);
		   yyval.id = (char *) 0;
		 }
               ;
    break;}
case 314:
#line 3278 "parser.yxx"
{ yyval.id = "public"; ;
    break;}
case 315:
#line 3279 "parser.yxx"
{ yyval.id = "private"; ;
    break;}
case 316:
#line 3280 "parser.yxx"
{ yyval.id = "protected"; ;
    break;}
case 317:
#line 3284 "parser.yxx"
{ yyval.id = "class"; ;
    break;}
case 318:
#line 3285 "parser.yxx"
{ yyval.id = "struct"; ;
    break;}
case 319:
#line 3286 "parser.yxx"
{yyval.id = "union"; ;
    break;}
case 320:
#line 3289 "parser.yxx"
{;
    break;}
case 321:
#line 3290 "parser.yxx"
{ delete yyvsp[-1].pl;;
    break;}
case 322:
#line 3291 "parser.yxx"
{;
    break;}
case 323:
#line 3296 "parser.yxx"
{ 
                    CCode = "";
               ;
    break;}
case 324:
#line 3299 "parser.yxx"
{ skip_brace(); ;
    break;}
case 325:
#line 3302 "parser.yxx"
{;
    break;}
case 326:
#line 3303 "parser.yxx"
{;
    break;}
case 327:
#line 3306 "parser.yxx"
{ ;
    break;}
case 328:
#line 3307 "parser.yxx"
{ ;
    break;}
case 329:
#line 3310 "parser.yxx"
{ ;
    break;}
case 330:
#line 3311 "parser.yxx"
{ ;
    break;}
case 331:
#line 3314 "parser.yxx"
{ ;
    break;}
case 332:
#line 3315 "parser.yxx"
{ ;
    break;}
case 333:
#line 3323 "parser.yxx"
{ 
                   ObjCClass = 1;
                   init_language();
		   cplus_mode = CPLUS_PROTECTED;
		   sprintf(temp_name,"CPP_CLASS:%s\n",yyvsp[-1].id);
		   if (add_symbol(temp_name,(DataType *) 0, (char *) 0)) {
		     fprintf(stderr,"%s : Line %d.  @interface %s is multiple defined.\n",
			     input_file,line_number,yyvsp[-1].id);
		     FatalError();
		   }
		   // Create a new documentation entry
		   doc_entry = new DocClass(yyvsp[-1].id,doc_parent());
		   doc_stack_top++;
		   doc_stack[doc_stack_top] = doc_entry;
		   scanner_clear_start();
		   cplus_open_class(yyvsp[-1].id, (char *) 0, "");     // Open up a new C++ class
                ;
    break;}
case 334:
#line 3339 "parser.yxx"
{ 
		  if (yyvsp[-6].id) {
		      char *inames[1];
		      inames[0] = yyvsp[-6].id;
		      cplus_inherit(1,inames);
		  }
		  // Restore original doc entry for this class
		  doc_entry = doc_stack[doc_stack_top];
		  cplus_class_close(yyvsp[-7].id);
		  doc_entry = 0;
		  doc_stack_top--;
		  cplus_mode = CPLUS_PUBLIC;
		  ObjCClass = 0;
		  delete yyvsp[-7].id;
		  delete yyvsp[-6].id;
                ;
    break;}
case 335:
#line 3356 "parser.yxx"
{
                 ObjCClass = 1;
		 init_language();
                 cplus_mode = CPLUS_PROTECTED;
                 doc_entry = cplus_set_class(yyvsp[-4].id);
		 if (!doc_entry) {
		   doc_entry = new DocClass(yyvsp[-4].id,doc_parent());
		 }
		 doc_stack_top++;
		 doc_stack[doc_stack_top] = doc_entry;
		 scanner_clear_start();
	       ;
    break;}
case 336:
#line 3367 "parser.yxx"
{
                 cplus_unset_class();
                 doc_entry = 0;
                 doc_stack_top--;
               ;
    break;}
case 337:
#line 3372 "parser.yxx"
{ skip_to_end(); ;
    break;}
case 338:
#line 3373 "parser.yxx"
{ skip_to_end(); ;
    break;}
case 339:
#line 3374 "parser.yxx"
{
		 char *iname = make_name(yyvsp[-2].id);
                 init_language();
                 lang->cpp_class_decl(yyvsp[-2].id,iname,"");
		 for (int i = 0; i <yyvsp[-1].ilist.count; i++) {
		   if (yyvsp[-1].ilist.names[i]) {
		     iname = make_name(yyvsp[-1].ilist.names[i]);
		     lang->cpp_class_decl(yyvsp[-1].ilist.names[i],iname,"");
		     delete [] yyvsp[-1].ilist.names[i];
		   }
		 } 
		 delete [] yyvsp[-1].ilist.names;
	       ;
    break;}
case 340:
#line 3389 "parser.yxx"
{ yyval.id = yyvsp[-1].id;;
    break;}
case 341:
#line 3390 "parser.yxx"
{ yyval.id = 0; ;
    break;}
case 342:
#line 3394 "parser.yxx"
{ skip_template(); 
                   CCode.strip();           // Strip whitespace
		   CCode.replace("<","< ");
		   CCode.replace(">"," >");
                   yyval.id = CCode.get();
                 ;
    break;}
case 343:
#line 3400 "parser.yxx"
{
                   yyval.id = "";
               ;
    break;}
case 344:
#line 3405 "parser.yxx"
{ ;
    break;}
case 345:
#line 3406 "parser.yxx"
{ 
                    cplus_mode = CPLUS_PUBLIC;
                 ;
    break;}
case 346:
#line 3408 "parser.yxx"
{ ;
    break;}
case 347:
#line 3409 "parser.yxx"
{
                    cplus_mode = CPLUS_PRIVATE;
                 ;
    break;}
case 348:
#line 3411 "parser.yxx"
{ ;
    break;}
case 349:
#line 3412 "parser.yxx"
{ 
                    cplus_mode = CPLUS_PROTECTED;
                 ;
    break;}
case 350:
#line 3414 "parser.yxx"
{ ;
    break;}
case 351:
#line 3415 "parser.yxx"
{
		 if (!Error) {
		   skip_decl();
		   {
		     static int last_error_line = -1;
		     if (last_error_line != line_number) {
		       fprintf(stderr,"%s : Line %d. Syntax error in input.\n", input_file, line_number);
		       FatalError();
		       last_error_line = line_number;
		     }
		     Error = 1;
		   }
		 }
	       ;
    break;}
case 352:
#line 3428 "parser.yxx"
{ ;
    break;}
case 353:
#line 3429 "parser.yxx"
{ ;
    break;}
case 354:
#line 3432 "parser.yxx"
{
  
                ;
    break;}
case 355:
#line 3439 "parser.yxx"
{ 
                 if (cplus_mode == CPLUS_PUBLIC) {
		   int oldstatus = Status;
		   char *tm;
		   char *iname;
		   if (Active_type) delete Active_type;
		   Active_type = new DataType(yyvsp[-1].type);
		   yyvsp[-1].type->is_pointer += yyvsp[0].decl.is_pointer;
		   yyvsp[-1].type->is_reference = yyvsp[0].decl.is_reference;
		   if (yyvsp[-1].type->status & STAT_READONLY) {
		     if (!(tm = typemap_lookup("memberin",typemap_lang,yyvsp[-1].type,yyvsp[0].decl.id,"",""))) 
		       Status = Status | STAT_READONLY;
		   }
		   iname = make_name(yyvsp[0].decl.id);
		   doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		   if (iname == yyvsp[0].decl.id) iname = 0;
		   cplus_variable(yyvsp[0].decl.id,iname,yyvsp[-1].type);
		   Status = oldstatus; 
		 }
		 scanner_clear_start();
		 delete yyvsp[-1].type;
               ;
    break;}
case 356:
#line 3461 "parser.yxx"
{ 
		 if (cplus_mode == CPLUS_PUBLIC) {
		   int oldstatus = Status;
		   char *tm, *iname;
		   if (Active_type) delete Active_type;
		   Active_type = new DataType(yyvsp[-2].type);
		   yyvsp[-2].type->is_pointer += yyvsp[-1].decl.is_pointer;
		   yyvsp[-2].type->is_reference = yyvsp[-1].decl.is_reference;
		   yyvsp[-2].type->arraystr = copy_string(ArrayString);
		   if (yyvsp[-2].type->status & STAT_READONLY) {
		     if (!(tm = typemap_lookup("memberin",typemap_lang,yyvsp[-2].type,yyvsp[-1].decl.id,"",""))) 
		       Status = Status | STAT_READONLY;
		   }
		   iname = make_name(yyvsp[-1].decl.id);
		   doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		   if (iname == yyvsp[-1].decl.id) iname = 0;
		   cplus_variable(yyvsp[-1].decl.id,iname,yyvsp[-2].type);
		   Status = oldstatus; 
		 }
		 scanner_clear_start();
		 delete yyvsp[-2].type;
	       ;
    break;}
case 357:
#line 3483 "parser.yxx"
{
                    strcpy(yy_rename,yyvsp[-1].id);
                    Rename_true = 1;
	       ;
    break;}
case 358:
#line 3486 "parser.yxx"
{ ;
    break;}
case 359:
#line 3488 "parser.yxx"
{ 
                 if (cplus_mode == CPLUS_PUBLIC) {
		   int oldstatus = Status;
		   char *tm, *iname;
		   DataType *t = new DataType (Active_type);
		   t->is_pointer += yyvsp[-1].decl.is_pointer;
		   t->is_reference = yyvsp[-1].decl.is_reference;
		   if (t->status & STAT_READONLY) {
		     if (!(tm = typemap_lookup("memberin",typemap_lang,t,yyvsp[-1].decl.id,"",""))) 
		       Status = Status | STAT_READONLY;
		   }
		   iname = make_name(yyvsp[-1].decl.id);
		   doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		   if (iname == yyvsp[-1].decl.id) iname = 0;
		   cplus_variable(yyvsp[-1].decl.id,iname,t);
		   Status = oldstatus; 
		   delete t;
		 }
		 scanner_clear_start();
               ;
    break;}
case 360:
#line 3508 "parser.yxx"
{
		 char *iname;
                 if (cplus_mode == CPLUS_PUBLIC) {
		   int oldstatus = Status;
		   char *tm;
		   DataType *t = new DataType (Active_type);
		   t->is_pointer += yyvsp[-2].decl.is_pointer;
		   t->is_reference = yyvsp[-2].decl.is_reference;
		   t->arraystr = copy_string(ArrayString);
		   if (t->status & STAT_READONLY) {
		     if (!(tm = typemap_lookup("memberin",typemap_lang,t,yyvsp[-2].decl.id,"",""))) 
		       Status = Status | STAT_READONLY;
		   }
		   iname = make_name(yyvsp[-2].decl.id);
		   doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		   if (iname == yyvsp[-2].decl.id) iname = 0;
		   cplus_variable(yyvsp[-2].decl.id,iname,t);
		   Status = oldstatus; 
		   delete t;
		 }
		 scanner_clear_start();
               ;
    break;}
case 361:
#line 3530 "parser.yxx"
{ ;
    break;}
case 362:
#line 3533 "parser.yxx"
{ ;
    break;}
case 363:
#line 3534 "parser.yxx"
{
                   AddMethods = 1;
	       ;
    break;}
case 364:
#line 3536 "parser.yxx"
{
                   AddMethods = 0;
               ;
    break;}
case 365:
#line 3539 "parser.yxx"
{
                     strcpy(yy_rename,yyvsp[-1].id);
                     Rename_true = 1;
	       ;
    break;}
case 366:
#line 3542 "parser.yxx"
{ ;
    break;}
case 367:
#line 3543 "parser.yxx"
{
                 skip_decl();		                
		 if (!Error) {
		   {
		     static int last_error_line = -1;
		     if (last_error_line != line_number) {
		       fprintf(stderr,"%s : Line %d. Syntax error in input.\n", input_file, line_number);
		       FatalError();
		       last_error_line = line_number;
		     }
		     Error = 1;
		   }
		 }
	       ;
    break;}
case 368:
#line 3556 "parser.yxx"
{ ;
    break;}
case 369:
#line 3557 "parser.yxx"
{ ;
    break;}
case 370:
#line 3560 "parser.yxx"
{
                 char *iname;
                 // An objective-C instance function
                 // This is like a C++ member function

		 if (strcmp(yyvsp[-2].id,objc_destruct) == 0) {
		   // This is an objective C destructor
                   doc_entry = new DocDecl(yyvsp[-2].id,doc_stack[doc_stack_top]);
                   cplus_destructor(yyvsp[-2].id,(char *) 0);
		 } else {
		   iname = make_name(yyvsp[-2].id);
		   doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		   if (iname == yyvsp[-2].id) iname = 0;
		   cplus_member_func(yyvsp[-2].id,iname,yyvsp[-3].type,yyvsp[-1].pl,0);
		   scanner_clear_start();
		   delete yyvsp[-3].type;
		   delete yyvsp[-2].id;
		   delete yyvsp[-1].pl;
		 }
               ;
    break;}
case 371:
#line 3580 "parser.yxx"
{ 
                 char *iname;
                 // An objective-C class function
                 // This is like a c++ static member function
                 if (strcmp(yyvsp[-2].id,objc_construct) == 0) {
		   // This is an objective C constructor
		   doc_entry = new DocDecl(yyvsp[-2].id,doc_stack[doc_stack_top]);
                   cplus_constructor(yyvsp[-2].id,0,yyvsp[-1].pl);
		 } else {
		   iname = make_name(yyvsp[-2].id);
		   doc_entry = new DocDecl(iname,doc_stack[doc_stack_top]);
		   if (iname == yyvsp[-2].id) iname = 0;
		   cplus_static_func(yyvsp[-2].id,iname,yyvsp[-3].type,yyvsp[-1].pl);
		 }
                 scanner_clear_start();
                 delete yyvsp[-3].type;
                 delete yyvsp[-2].id;
                 delete yyvsp[-1].pl;
               ;
    break;}
case 372:
#line 3601 "parser.yxx"
{ CCode = ""; ;
    break;}
case 373:
#line 3602 "parser.yxx"
{ skip_brace(); ;
    break;}
case 374:
#line 3605 "parser.yxx"
{ 
                  yyval.type = yyvsp[-1].type;
                ;
    break;}
case 375:
#line 3608 "parser.yxx"
{ 
                  yyval.type = yyvsp[-2].type;
                  yyval.type->is_pointer += yyvsp[-1].ivalue;
               ;
    break;}
case 376:
#line 3612 "parser.yxx"
{       /* Empty type means "id" type */
                  yyval.type = new DataType(T_VOID);
		  sprintf(yyval.type->name,"id");
                  yyval.type->is_pointer = 1;
                  yyval.type->implicit_ptr = 1;
               ;
    break;}
case 377:
#line 3620 "parser.yxx"
{ 
                  yyval.type = new DataType(yyvsp[-1].p->t);
                  delete yyvsp[-1].p;
                 ;
    break;}
case 378:
#line 3624 "parser.yxx"
{ 
                  yyval.type = new DataType(T_VOID);
		  sprintf(yyval.type->name,"id");
                  yyval.type->is_pointer = 1;
                  yyval.type->implicit_ptr = 1;
               ;
    break;}
case 379:
#line 3632 "parser.yxx"
{ 
                   Parm *p= new Parm(yyvsp[-1].type,yyvsp[0].id);
		   p->objc_separator = yyvsp[-2].id;
                   yyval.pl = yyvsp[-3].pl;
                   yyval.pl->append(p);
               ;
    break;}
case 380:
#line 3638 "parser.yxx"
{ 
                 yyval.pl = new ParmList;
               ;
    break;}
case 381:
#line 3643 "parser.yxx"
{ yyval.id = copy_string(":"); ;
    break;}
case 382:
#line 3644 "parser.yxx"
{ yyval.id = new char[strlen(yyvsp[-1].id)+2]; 
                    strcpy(yyval.id,yyvsp[-1].id);
		    strcat(yyval.id,":");
		    delete yyvsp[-1].id;
	        ;
    break;}
case 383:
#line 3655 "parser.yxx"
{
                    yyval.dlist = yyvsp[0].dlist;
		    yyval.dlist.names[yyval.dlist.count] = copy_string(yyvsp[-2].id);
		    yyval.dlist.values[yyval.dlist.count] = copy_string(yyvsp[-1].id);
		    format_string(yyval.dlist.values[yyval.dlist.count]);
		    yyval.dlist.count++;
                 ;
    break;}
case 384:
#line 3665 "parser.yxx"
{
                    yyval.dlist = yyvsp[-3].dlist;
		    yyval.dlist.names[yyval.dlist.count] = copy_string(yyvsp[-1].id);
		    yyval.dlist.values[yyval.dlist.count] = copy_string(yyvsp[0].id);
		    format_string(yyval.dlist.values[yyval.dlist.count]);
		    yyval.dlist.count++;
                 ;
    break;}
case 385:
#line 3672 "parser.yxx"
{
                    yyval.dlist.names = new char *[NI_NAMES];
		    yyval.dlist.values = new char *[NI_NAMES];
		    yyval.dlist.count = 0;
	       ;
    break;}
case 386:
#line 3679 "parser.yxx"
{
                     yyval.id = yyvsp[0].id;
                 ;
    break;}
case 387:
#line 3682 "parser.yxx"
{
                     yyval.id = yyvsp[0].id;
	       ;
    break;}
case 388:
#line 3685 "parser.yxx"
{ 
                     yyval.id = 0;
                ;
    break;}
case 389:
#line 3695 "parser.yxx"
{
                 yyval.id = yyvsp[0].id;
               ;
    break;}
case 390:
#line 3698 "parser.yxx"
{
                 yyval.id = copy_string("const");
               ;
    break;}
case 391:
#line 3703 "parser.yxx"
{
                 yyval.tmparm = yyvsp[-1].tmparm;
                 yyval.tmparm->next = yyvsp[0].tmparm;
		;
    break;}
case 392:
#line 3709 "parser.yxx"
{
                 yyval.tmparm = yyvsp[-1].tmparm;
                 yyval.tmparm->next = yyvsp[0].tmparm;
                ;
    break;}
case 393:
#line 3713 "parser.yxx"
{ yyval.tmparm = 0;;
    break;}
case 394:
#line 3716 "parser.yxx"
{
		    if (InArray) {
		      yyvsp[-1].type->is_pointer++;
		      yyvsp[-1].type->arraystr = copy_string(ArrayString);
		    }
		    yyval.tmparm = new TMParm;
                    yyval.tmparm->p = new Parm(yyvsp[-1].type,yyvsp[0].id);
		    yyval.tmparm->p->call_type = 0;
		    yyval.tmparm->args = tm_parm;
		    delete yyvsp[-1].type;
		    delete yyvsp[0].id;
                 ;
    break;}
case 395:
#line 3729 "parser.yxx"
{
		  yyval.tmparm = new TMParm;
		   yyval.tmparm->p = new Parm(yyvsp[-2].type,yyvsp[0].id);
		   yyval.tmparm->p->t->is_pointer += yyvsp[-1].ivalue;
		   yyval.tmparm->p->call_type = 0;
		   if (InArray) {
		     yyval.tmparm->p->t->is_pointer++;
		     yyval.tmparm->p->t->arraystr = copy_string(ArrayString);
		    }
		   yyval.tmparm->args = tm_parm;
		   delete yyvsp[-2].type;
		   delete yyvsp[0].id;
		;
    break;}
case 396:
#line 3743 "parser.yxx"
{
                  yyval.tmparm = new TMParm;
		  yyval.tmparm->p = new Parm(yyvsp[-2].type,yyvsp[0].id);
		  yyval.tmparm->p->t->is_reference = 1;
		  yyval.tmparm->p->call_type = 0;
		  yyval.tmparm->p->t->is_pointer++;
		  if (!CPlusPlus) {
			fprintf(stderr,"%s : Line %d. Warning.  Use of C++ Reference detected.  Use the -c++ option.\n", input_file, line_number);
		  }
		  yyval.tmparm->args = tm_parm;
		  delete yyvsp[-2].type;
		  delete yyvsp[0].id;
		;
    break;}
case 397:
#line 3756 "parser.yxx"
{
                  fprintf(stderr,"%s : Line %d. Error. Function pointer not allowed (remap with typedef).\n", input_file, line_number);
		  FatalError();
                  yyval.tmparm = new TMParm;
		  yyval.tmparm->p = new Parm(yyvsp[-7].type,yyvsp[-4].id);
		  yyval.tmparm->p->t->type = T_ERROR;
		  yyval.tmparm->p->name = copy_string(yyvsp[-4].id);
		  strcpy(yyval.tmparm->p->t->name,"<function ptr>");
		  yyval.tmparm->args = tm_parm;
		  delete yyvsp[-7].type;
		  delete yyvsp[-4].id;
		  delete yyvsp[-1].pl;
		;
    break;}
case 398:
#line 3771 "parser.yxx"
{
                    yyval.id = yyvsp[-1].id; 
                    InArray = 0;
                ;
    break;}
case 399:
#line 3775 "parser.yxx"
{ 
                    ArrayBackup = "";
		    ArrayBackup << ArrayString;
                  ;
    break;}
case 400:
#line 3778 "parser.yxx"
{
                    yyval.id = yyvsp[-3].id;
                    InArray = yyvsp[-2].ivalue;
                    ArrayString = "";
		    ArrayString << ArrayBackup;
                ;
    break;}
case 401:
#line 3784 "parser.yxx"
{ 
                    ArrayBackup = "";
		    ArrayBackup << ArrayString;
		;
    break;}
case 402:
#line 3787 "parser.yxx"
{
		    yyval.id = new char[1];
		    yyval.id[0] = 0;
		    InArray = yyvsp[-2].ivalue;
                    ArrayString = "";
                    ArrayString << ArrayBackup;
		;
    break;}
case 403:
#line 3794 "parser.yxx"
{ yyval.id = new char[1];
  	                  yyval.id[0] = 0;
                          InArray = 0;
                ;
    break;}
case 404:
#line 3800 "parser.yxx"
{
                  tm_parm = yyvsp[-1].pl;
                ;
    break;}
case 405:
#line 3803 "parser.yxx"
{
                  tm_parm = 0;
                ;
    break;}
case 406:
#line 3810 "parser.yxx"
{ ;
    break;}
case 407:
#line 3811 "parser.yxx"
{ ;
    break;}
case 408:
#line 3814 "parser.yxx"
{ ;
    break;}
case 409:
#line 3815 "parser.yxx"
{ ;
    break;}
case 410:
#line 3816 "parser.yxx"
{ ;
    break;}
}
   /* the action file gets copied in in place of this dollarsign */
#line 542 "/usr/lib/bison.simple"

  yyvsp -= yylen;
  yyssp -= yylen;
#ifdef YYLSP_NEEDED
  yylsp -= yylen;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;

#ifdef YYLSP_NEEDED
  yylsp++;
  if (yylen == 0)
    {
      yylsp->first_line = yylloc.first_line;
      yylsp->first_column = yylloc.first_column;
      yylsp->last_line = (yylsp-1)->last_line;
      yylsp->last_column = (yylsp-1)->last_column;
      yylsp->text = 0;
    }
  else
    {
      yylsp->last_line = (yylsp+yylen-1)->last_line;
      yylsp->last_column = (yylsp+yylen-1)->last_column;
    }
#endif

  /* Now "shift" the result of the reduction.
     Determine what state that goes to,
     based on the state we popped back to
     and the rule number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;

yyerrlab:   /* here on detecting error */

  if (! yyerrstatus)
    /* If not already recovering from an error, report this error.  */
    {
      ++yynerrs;

#ifdef YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (yyn > YYFLAG && yyn < YYLAST)
	{
	  int size = 0;
	  char *msg;
	  int x, count;

	  count = 0;
	  /* Start X at -yyn if nec to avoid negative indexes in yycheck.  */
	  for (x = (yyn < 0 ? -yyn : 0);
	       x < (sizeof(yytname) / sizeof(char *)); x++)
	    if (yycheck[x + yyn] == x)
	      size += strlen(yytname[x]) + 15, count++;
	  msg = (char *) malloc(size + 15);
	  if (msg != 0)
	    {
	      strcpy(msg, "parse error");

	      if (count < 5)
		{
		  count = 0;
		  for (x = (yyn < 0 ? -yyn : 0);
		       x < (sizeof(yytname) / sizeof(char *)); x++)
		    if (yycheck[x + yyn] == x)
		      {
			strcat(msg, count == 0 ? ", expecting `" : " or `");
			strcat(msg, yytname[x]);
			strcat(msg, "'");
			count++;
		      }
		}
	      yyerror(msg);
	      free(msg);
	    }
	  else
	    yyerror ("parse error; also virtual memory exceeded");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror("parse error");
    }

  goto yyerrlab1;
yyerrlab1:   /* here on error raised explicitly by an action */

  if (yyerrstatus == 3)
    {
      /* if just tried and failed to reuse lookahead token after an error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYABORT;

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Discarding token %d (%s).\n", yychar, yytname[yychar1]);
#endif

      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token
     after shifting the error token.  */

  yyerrstatus = 3;		/* Each real token shifted decrements this */

  goto yyerrhandle;

yyerrdefault:  /* current state does not do anything special for the error token. */

#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */
  yyn = yydefact[yystate];  /* If its default is to accept any token, ok.  Otherwise pop it.*/
  if (yyn) goto yydefault;
#endif

yyerrpop:   /* pop the current state because it cannot handle the error token */

  if (yyssp == yyss) YYABORT;
  yyvsp--;
  yystate = *--yyssp;
#ifdef YYLSP_NEEDED
  yylsp--;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "Error: state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

yyerrhandle:

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting error token, ");
#endif

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  yystate = yyn;
  goto yynewstate;

 yyacceptlab:
  /* YYACCEPT comes here.  */
  if (yyfree_stacks)
    {
      free (yyss);
      free (yyvs);
#ifdef YYLSP_NEEDED
      free (yyls);
#endif
    }
  return 0;

 yyabortlab:
  /* YYABORT comes here.  */
  if (yyfree_stacks)
    {
      free (yyss);
      free (yyvs);
#ifdef YYLSP_NEEDED
      free (yyls);
#endif
    }
  return 1;
}
#line 3850 "parser.yxx"


void error_recover() {
  int c;
  c = yylex();
  while ((c > 0) && (c != SEMI)) 
    c = yylex();
}

/* Called by the parser (yyparse) when an error is found.*/
void yyerror (char *) {
  //  Fprintf(stderr,"%s : Line %d. Syntax error.\n", input_file, line_number);
  //  error_recover();
}

