typedef union {
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
} YYSTYPE;
#define	ID	257
#define	TYPE_TYPEDEF	258
#define	HBLOCK	259
#define	STRING	260
#define	NUM_INT	261
#define	NUM_FLOAT	262
#define	CHARCONST	263
#define	NUM_UNSIGNED	264
#define	NUM_LONG	265
#define	NUM_ULONG	266
#define	LPAREN	267
#define	RPAREN	268
#define	LBRACE	269
#define	RBRACE	270
#define	COMMA	271
#define	SEMI	272
#define	PERIOD	273
#define	LBRACKET	274
#define	RBRACKET	275
#define	EQUAL	276
#define	COLON	277
#define	POUND	278
#define	CONST	279
#define	DEFINED	280
#define	ENUM	281
#define	EXTERN	282
#define	SIZEOF	283
#define	STATIC	284
#define	STRUCT	285
#define	TYPEDEF	286
#define	UNION	287
#define	CLASS	288
#define	FRIEND	289
#define	OPERATOR	290
#define	PRIVATE	291
#define	PROTECTED	292
#define	PUBLIC	293
#define	TEMPLATE	294
#define	THROW	295
#define	VIRTUAL	296
#define	OC_INTERFACE	297
#define	OC_END	298
#define	OC_PUBLIC	299
#define	OC_PRIVATE	300
#define	OC_PROTECTED	301
#define	OC_CLASS	302
#define	OC_IMPLEMENT	303
#define	OC_PROTOCOL	304
#define	TYPE_INT	305
#define	TYPE_UNSIGNED	306
#define	TYPE_SHORT	307
#define	TYPE_LONG	308
#define	TYPE_FLOAT	309
#define	TYPE_DOUBLE	310
#define	TYPE_CHAR	311
#define	TYPE_VOID	312
#define	TYPE_SIGNED	313
#define	TYPE_BOOL	314
#define	ADDMETHODS	315
#define	ALPHA_MODE	316
#define	APPLY	317
#define	CHECKOUT	318
#define	CLEAR	319
#define	CONSTANT	320
#define	DOCONLY	321
#define	DOC_DISABLE	322
#define	DOC_ENABLE	323
#define	ECHO	324
#define	EXCEPT	325
#define	ILLEGAL	326
#define	IMPORT	327
#define	INCLUDE	328
#define	INIT	329
#define	INLINE	330
#define	LOCALSTYLE	331
#define	MACRO	332
#define	MODULE	333
#define	NAME	334
#define	NATIVE	335
#define	NEW	336
#define	PRAGMA	337
#define	RAW_MODE	338
#define	READONLY	339
#define	READWRITE	340
#define	RENAME	341
#define	SECTION	342
#define	STYLE	343
#define	SUBSECTION	344
#define	SUBSUBSECTION	345
#define	TEXT	346
#define	TITLE	347
#define	TYPE	348
#define	TYPEMAP	349
#define	USERDIRECTIVE	350
#define	WEXTERN	351
#define	WRAPPER	352
#define	LOR	353
#define	LAND	354
#define	EQUALTO	355
#define	NOTEQUAL	356
#define	GREATERTHAN	357
#define	LESSTHAN	358
#define	LTEQUAL	359
#define	GTEQUAL	360
#define	OR	361
#define	XOR	362
#define	AND	363
#define	LSHIFT	364
#define	RSHIFT	365
#define	PLUS	366
#define	MINUS	367
#define	STAR	368
#define	SLASH	369
#define	UMINUS	370
#define	NOT	371
#define	LNOT	372
#define	DCOLON	373


extern YYSTYPE yylval;
