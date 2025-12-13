/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_H_INCLUDED
# define YY_YY_PARSER_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    END = 0,                       /* END  */
    YYerror = 1,                   /* error  */
    YYUNDEF = 2,                   /* "invalid token"  */
    ID = 3,                        /* ID  */
    HBLOCK = 4,                    /* HBLOCK  */
    POUND = 5,                     /* POUND  */
    STRING = 6,                    /* STRING  */
    WSTRING = 7,                   /* WSTRING  */
    INCLUDE = 8,                   /* INCLUDE  */
    IMPORT = 9,                    /* IMPORT  */
    INSERT = 10,                   /* INSERT  */
    CHARCONST = 11,                /* CHARCONST  */
    WCHARCONST = 12,               /* WCHARCONST  */
    NUM_INT = 13,                  /* NUM_INT  */
    NUM_DOUBLE = 14,               /* NUM_DOUBLE  */
    NUM_FLOAT = 15,                /* NUM_FLOAT  */
    NUM_LONGDOUBLE = 16,           /* NUM_LONGDOUBLE  */
    NUM_UNSIGNED = 17,             /* NUM_UNSIGNED  */
    NUM_LONG = 18,                 /* NUM_LONG  */
    NUM_ULONG = 19,                /* NUM_ULONG  */
    NUM_LONGLONG = 20,             /* NUM_LONGLONG  */
    NUM_ULONGLONG = 21,            /* NUM_ULONGLONG  */
    NUM_BOOL = 22,                 /* NUM_BOOL  */
    TYPEDEF = 23,                  /* TYPEDEF  */
    TYPE_INT = 24,                 /* TYPE_INT  */
    TYPE_UNSIGNED = 25,            /* TYPE_UNSIGNED  */
    TYPE_SHORT = 26,               /* TYPE_SHORT  */
    TYPE_LONG = 27,                /* TYPE_LONG  */
    TYPE_FLOAT = 28,               /* TYPE_FLOAT  */
    TYPE_DOUBLE = 29,              /* TYPE_DOUBLE  */
    TYPE_CHAR = 30,                /* TYPE_CHAR  */
    TYPE_WCHAR = 31,               /* TYPE_WCHAR  */
    TYPE_VOID = 32,                /* TYPE_VOID  */
    TYPE_SIGNED = 33,              /* TYPE_SIGNED  */
    TYPE_BOOL = 34,                /* TYPE_BOOL  */
    TYPE_COMPLEX = 35,             /* TYPE_COMPLEX  */
    TYPE_NON_ISO_INT8 = 36,        /* TYPE_NON_ISO_INT8  */
    TYPE_NON_ISO_INT16 = 37,       /* TYPE_NON_ISO_INT16  */
    TYPE_NON_ISO_INT32 = 38,       /* TYPE_NON_ISO_INT32  */
    TYPE_NON_ISO_INT64 = 39,       /* TYPE_NON_ISO_INT64  */
    LPAREN = 40,                   /* LPAREN  */
    RPAREN = 41,                   /* RPAREN  */
    COMMA = 42,                    /* COMMA  */
    SEMI = 43,                     /* SEMI  */
    EXTERN = 44,                   /* EXTERN  */
    LBRACE = 45,                   /* LBRACE  */
    RBRACE = 46,                   /* RBRACE  */
    PERIOD = 47,                   /* PERIOD  */
    ELLIPSIS = 48,                 /* ELLIPSIS  */
    CONST_QUAL = 49,               /* CONST_QUAL  */
    VOLATILE = 50,                 /* VOLATILE  */
    REGISTER = 51,                 /* REGISTER  */
    STRUCT = 52,                   /* STRUCT  */
    UNION = 53,                    /* UNION  */
    EQUAL = 54,                    /* EQUAL  */
    SIZEOF = 55,                   /* SIZEOF  */
    ALIGNOF = 56,                  /* ALIGNOF  */
    MODULE = 57,                   /* MODULE  */
    LBRACKET = 58,                 /* LBRACKET  */
    RBRACKET = 59,                 /* RBRACKET  */
    BEGINFILE = 60,                /* BEGINFILE  */
    ENDOFFILE = 61,                /* ENDOFFILE  */
    CONSTANT = 62,                 /* CONSTANT  */
    RENAME = 63,                   /* RENAME  */
    NAMEWARN = 64,                 /* NAMEWARN  */
    EXTEND = 65,                   /* EXTEND  */
    PRAGMA = 66,                   /* PRAGMA  */
    FEATURE = 67,                  /* FEATURE  */
    VARARGS = 68,                  /* VARARGS  */
    ENUM = 69,                     /* ENUM  */
    CLASS = 70,                    /* CLASS  */
    TYPENAME = 71,                 /* TYPENAME  */
    PRIVATE = 72,                  /* PRIVATE  */
    PUBLIC = 73,                   /* PUBLIC  */
    PROTECTED = 74,                /* PROTECTED  */
    COLON = 75,                    /* COLON  */
    STATIC = 76,                   /* STATIC  */
    VIRTUAL = 77,                  /* VIRTUAL  */
    FRIEND = 78,                   /* FRIEND  */
    THROW = 79,                    /* THROW  */
    CATCH = 80,                    /* CATCH  */
    EXPLICIT = 81,                 /* EXPLICIT  */
    STATIC_ASSERT = 82,            /* STATIC_ASSERT  */
    CONSTEXPR = 83,                /* CONSTEXPR  */
    THREAD_LOCAL = 84,             /* THREAD_LOCAL  */
    DECLTYPE = 85,                 /* DECLTYPE  */
    AUTO = 86,                     /* AUTO  */
    NOEXCEPT = 87,                 /* NOEXCEPT  */
    OVERRIDE = 88,                 /* OVERRIDE  */
    FINAL = 89,                    /* FINAL  */
    USING = 90,                    /* USING  */
    NAMESPACE = 91,                /* NAMESPACE  */
    NATIVE = 92,                   /* NATIVE  */
    INLINE = 93,                   /* INLINE  */
    TYPEMAP = 94,                  /* TYPEMAP  */
    ECHO = 95,                     /* ECHO  */
    APPLY = 96,                    /* APPLY  */
    CLEAR = 97,                    /* CLEAR  */
    SWIGTEMPLATE = 98,             /* SWIGTEMPLATE  */
    FRAGMENT = 99,                 /* FRAGMENT  */
    WARN = 100,                    /* WARN  */
    LESSTHAN = 101,                /* LESSTHAN  */
    GREATERTHAN = 102,             /* GREATERTHAN  */
    DELETE_KW = 103,               /* DELETE_KW  */
    DEFAULT = 104,                 /* DEFAULT  */
    LESSTHANOREQUALTO = 105,       /* LESSTHANOREQUALTO  */
    GREATERTHANOREQUALTO = 106,    /* GREATERTHANOREQUALTO  */
    EQUALTO = 107,                 /* EQUALTO  */
    NOTEQUALTO = 108,              /* NOTEQUALTO  */
    LESSEQUALGREATER = 109,        /* LESSEQUALGREATER  */
    ARROW = 110,                   /* ARROW  */
    QUESTIONMARK = 111,            /* QUESTIONMARK  */
    TYPES = 112,                   /* TYPES  */
    PARMS = 113,                   /* PARMS  */
    NONID = 114,                   /* NONID  */
    DSTAR = 115,                   /* DSTAR  */
    DCNOT = 116,                   /* DCNOT  */
    TEMPLATE = 117,                /* TEMPLATE  */
    OPERATOR = 118,                /* OPERATOR  */
    CONVERSIONOPERATOR = 119,      /* CONVERSIONOPERATOR  */
    PARSETYPE = 120,               /* PARSETYPE  */
    PARSEPARM = 121,               /* PARSEPARM  */
    PARSEPARMS = 122,              /* PARSEPARMS  */
    DOXYGENSTRING = 123,           /* DOXYGENSTRING  */
    DOXYGENPOSTSTRING = 124,       /* DOXYGENPOSTSTRING  */
    LOR = 125,                     /* LOR  */
    LAND = 126,                    /* LAND  */
    OR = 127,                      /* OR  */
    XOR = 128,                     /* XOR  */
    AND = 129,                     /* AND  */
    LSHIFT = 130,                  /* LSHIFT  */
    RSHIFT = 131,                  /* RSHIFT  */
    PLUS = 132,                    /* PLUS  */
    MINUS = 133,                   /* MINUS  */
    STAR = 134,                    /* STAR  */
    SLASH = 135,                   /* SLASH  */
    MODULO = 136,                  /* MODULO  */
    UMINUS = 137,                  /* UMINUS  */
    NOT = 138,                     /* NOT  */
    LNOT = 139,                    /* LNOT  */
    CAST = 140,                    /* CAST  */
    DCOLON = 141                   /* DCOLON  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 1605 "parser.y"

  const char  *id;
  List  *bases;
  struct Define {
    // The value of the expression as C/C++ code.
    String *val;
    // If type is a string or char type, this is the actual value of that
    // string or char type as a String (in cases where SWIG can determine
    // it - currently that means for literals).  This is useful in cases where
    // we want to emit a string or character literal in the target language -
    // we could just try emitting the C/C++ code for the literal, but that
    // won't always be correct in most target languages.
    //
    // SWIG's scanner reads the string or character literal in the source code
    // and interprets quoting and escape sequences.  Concatenation of adjacent
    // string literals is currently handled here in the parser (though
    // technically it should happen before parsing).
    //
    // stringval holds the actual value of the string (from the scanner,
    // taking into account concatenation of adjacent string literals).
    // Then val is created by escaping stringval using SWIG's %(escape)s
    // Printf specification, and adding the appropriate quotes (and
    // an L-prefix for wide literals).  So val is also a C/C++ source
    // representation of the string, but may not be the same representation
    // as in the source code (it should be equivalent though).
    //
    // Some examples:
    //
    // C/C++ source  stringval   val       Notes
    // ------------- ----------- --------- -------
    // "bar"         bar         "bar"
    // "b\x61r"      bar         "bar"
    // "b\141r"      bar         "bar"
    // "b" "ar"      bar         "bar"
    // u8"bar"       bar         "bar"     C++11
    // R"bar"        bar         "bar"     C++11
    // "\228\22"     "8"         "\"8\""
    // "\\\"\'"      \"'         "\\\"\'"
    // R"(\"')"      \"'         "\\\"\'"  C++11
    // L"bar"        bar         L"bar"
    // L"b" L"ar"    bar         L"bar"
    // L"b" "ar"     bar         L"bar"    C++11
    // "b" L"ar"     bar         L"bar"    C++11
    // 'x'           x           'x'
    // '\"'          "           '\"'
    // '\42'         "           '\"'
    // '\042'        "           '\"'
    // '\x22'        "           '\"'
    //
    // Zero bytes are allowed in stringval (DOH's String can hold a string
    // with embedded zero bytes), but handling may currently be buggy in
    // places.
    String *stringval;
    // If type is an integer or boolean type, this is the actual value of that
    // type as a base 10 integer in a String (in cases where SWIG can determine
    // this value - currently that means for literals).  This is useful in
    // cases where we want to emit an integer or boolean literal in the target
    // language - we could just try emitting the C/C++ code for the literal,
    // but that won't always be correct in most target languages.
    //
    // SWIG doesn't attempt to evaluate constant expressions, except that it
    // can handle unary - (because a negative integer literal is actually
    // syntactically unary minus applied to a positive integer literal),
    // unary + (for consistency with unary -) and parentheses (because
    // literals in #define are often in parentheses).  These operators are
    // handled in the parser so whitespace is also handled within such
    // expressions.
    //
    // Some examples:
    //
    // C/C++ source  numval      val       Notes
    // ------------- ----------- --------- -------
    // 123           123         123
    // 0x7b          123         0x7b
    // 0x7B          123         0x7B
    // 0173          123         0173
    // 0b1111011     123         0b1111011 C++14
    // -10           -10         -10	   numval not set for unsigned type
    // -0x00a        -10         -0x00a    numval not set for unsigned type
    // -012          -10         -012      numval not set for unsigned type
    // -0b1010       -10         -0b1010   C++14; numval not set for unsigned
    // (42)          42          (42)
    // +42           42          +42
    // +(42)         42          +(42)
    // -(42)         -42         -(42)     numval not set for unsigned type
    // (-(42))       -42         (-(42))   numval not set for unsigned type
    // false         0           false
    // (false)       0           (false)
    // true          1           true
    // (true)        1           (true)
    String *numval;
    int     type;
    /* The type code for the argument when the top level operator is unary.
     * This is useful because our grammar parses cases such as (7)*6 as a
     * cast applied to an unary operator.
     */
    int	    unary_arg_type;
    String *qualifier;
    String *refqualifier;
    String *bitfield;
    Parm   *throws;
    String *throwf;
    String *nexcept;
    String *final;
  } dtype;
  struct {
    String *filename;
    int   line;
  } loc;
  struct Decl {
    char      *id;
    SwigType  *type;
    String    *defarg;
    String    *stringdefarg;
    String    *numdefarg;
    ParmList  *parms;
    short      have_parms;
    ParmList  *throws;
    String    *throwf;
    String    *nexcept;
    String    *final;
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
  enum { INCLUDE_INCLUDE, INCLUDE_IMPORT } includetype;
  Node         *node;
  struct {
    Parm       *parms;
    Parm       *last;
  } pbuilder;
  struct {
    Node       *node;
    Node       *last;
  } nodebuilder;

#line 353 "parser.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_H_INCLUDED  */
