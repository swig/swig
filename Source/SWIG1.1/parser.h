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


extern YYSTYPE yylval;
