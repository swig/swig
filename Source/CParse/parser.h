
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ID = 258,
     HBLOCK = 259,
     POUND = 260,
     STRING = 261,
     INCLUDE = 262,
     IMPORT = 263,
     INSERT = 264,
     CHARCONST = 265,
     NUM_INT = 266,
     NUM_FLOAT = 267,
     NUM_UNSIGNED = 268,
     NUM_LONG = 269,
     NUM_ULONG = 270,
     NUM_LONGLONG = 271,
     NUM_ULONGLONG = 272,
     NUM_BOOL = 273,
     TYPEDEF = 274,
     TYPE_INT = 275,
     TYPE_UNSIGNED = 276,
     TYPE_SHORT = 277,
     TYPE_LONG = 278,
     TYPE_FLOAT = 279,
     TYPE_DOUBLE = 280,
     TYPE_CHAR = 281,
     TYPE_WCHAR = 282,
     TYPE_VOID = 283,
     TYPE_SIGNED = 284,
     TYPE_BOOL = 285,
     TYPE_COMPLEX = 286,
     TYPE_TYPEDEF = 287,
     TYPE_RAW = 288,
     TYPE_NON_ISO_INT8 = 289,
     TYPE_NON_ISO_INT16 = 290,
     TYPE_NON_ISO_INT32 = 291,
     TYPE_NON_ISO_INT64 = 292,
     LPAREN = 293,
     RPAREN = 294,
     COMMA = 295,
     SEMI = 296,
     EXTERN = 297,
     INIT = 298,
     LBRACE = 299,
     RBRACE = 300,
     PERIOD = 301,
     CONST_QUAL = 302,
     VOLATILE = 303,
     REGISTER = 304,
     STRUCT = 305,
     UNION = 306,
     EQUAL = 307,
     SIZEOF = 308,
     MODULE = 309,
     LBRACKET = 310,
     RBRACKET = 311,
     BEGINFILE = 312,
     ENDOFFILE = 313,
     ILLEGAL = 314,
     CONSTANT = 315,
     NAME = 316,
     RENAME = 317,
     NAMEWARN = 318,
     EXTEND = 319,
     PRAGMA = 320,
     FEATURE = 321,
     VARARGS = 322,
     ENUM = 323,
     CLASS = 324,
     TYPENAME = 325,
     PRIVATE = 326,
     PUBLIC = 327,
     PROTECTED = 328,
     COLON = 329,
     STATIC = 330,
     VIRTUAL = 331,
     FRIEND = 332,
     THROW = 333,
     CATCH = 334,
     EXPLICIT = 335,
     USING = 336,
     NAMESPACE = 337,
     NATIVE = 338,
     INLINE = 339,
     TYPEMAP = 340,
     EXCEPT = 341,
     ECHO = 342,
     APPLY = 343,
     CLEAR = 344,
     SWIGTEMPLATE = 345,
     FRAGMENT = 346,
     WARN = 347,
     LESSTHAN = 348,
     GREATERTHAN = 349,
     DELETE_KW = 350,
     LESSTHANOREQUALTO = 351,
     GREATERTHANOREQUALTO = 352,
     EQUALTO = 353,
     NOTEQUALTO = 354,
     QUESTIONMARK = 355,
     TYPES = 356,
     PARMS = 357,
     NONID = 358,
     DSTAR = 359,
     DCNOT = 360,
     TEMPLATE = 361,
     OPERATOR = 362,
     COPERATOR = 363,
     PARSETYPE = 364,
     PARSEPARM = 365,
     PARSEPARMS = 366,
     CAST = 367,
     LOR = 368,
     LAND = 369,
     OR = 370,
     XOR = 371,
     AND = 372,
     RSHIFT = 373,
     LSHIFT = 374,
     MINUS = 375,
     PLUS = 376,
     MODULO = 377,
     SLASH = 378,
     STAR = 379,
     LNOT = 380,
     NOT = 381,
     UMINUS = 382,
     DCOLON = 383
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 1593 "parser.y"

  char  *id;
  List  *bases;
  struct Define {
    String *val;
    String *rawval;
    int     type;
    String *qualifier;
    String *bitfield;
    Parm   *throws;
    String *throwf;
  } dtype;
  struct {
    char *type;
    String *filename;
    int   line;
  } loc;
  struct {
    char      *id;
    SwigType  *type;
    String    *defarg;
    ParmList  *parms;
    short      have_parms;
    ParmList  *throws;
    String    *throwf;
  } decl;
  Parm         *tparms;
  struct {
    String     *method;
    Hash       *kwargs;
  } tmap;
  struct {
    String     *type;
    String     *us;
  } ptype;
  SwigType     *type;
  String       *str;
  Parm         *p;
  ParmList     *pl;
  int           intvalue;
  Node         *node;



/* Line 1676 of yacc.c  */
#line 225 "parser.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


