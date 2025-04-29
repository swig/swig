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

#ifndef YY_YY_CPARSE_PARSER_H_INCLUDED
# define YY_YY_CPARSE_PARSER_H_INCLUDED
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
    TYPE_RAW = 36,                 /* TYPE_RAW  */
    TYPE_NON_ISO_INT8 = 37,        /* TYPE_NON_ISO_INT8  */
    TYPE_NON_ISO_INT16 = 38,       /* TYPE_NON_ISO_INT16  */
    TYPE_NON_ISO_INT32 = 39,       /* TYPE_NON_ISO_INT32  */
    TYPE_NON_ISO_INT64 = 40,       /* TYPE_NON_ISO_INT64  */
    LPAREN = 41,                   /* LPAREN  */
    RPAREN = 42,                   /* RPAREN  */
    COMMA = 43,                    /* COMMA  */
    SEMI = 44,                     /* SEMI  */
    EXTERN = 45,                   /* EXTERN  */
    LBRACE = 46,                   /* LBRACE  */
    RBRACE = 47,                   /* RBRACE  */
    PERIOD = 48,                   /* PERIOD  */
    ELLIPSIS = 49,                 /* ELLIPSIS  */
    CONST_QUAL = 50,               /* CONST_QUAL  */
    VOLATILE = 51,                 /* VOLATILE  */
    REGISTER = 52,                 /* REGISTER  */
    STRUCT = 53,                   /* STRUCT  */
    UNION = 54,                    /* UNION  */
    EQUAL = 55,                    /* EQUAL  */
    SIZEOF = 56,                   /* SIZEOF  */
    ALIGNOF = 57,                  /* ALIGNOF  */
    MODULE = 58,                   /* MODULE  */
    LBRACKET = 59,                 /* LBRACKET  */
    RBRACKET = 60,                 /* RBRACKET  */
    BEGINFILE = 61,                /* BEGINFILE  */
    ENDOFFILE = 62,                /* ENDOFFILE  */
    CONSTANT = 63,                 /* CONSTANT  */
    RENAME = 64,                   /* RENAME  */
    NAMEWARN = 65,                 /* NAMEWARN  */
    EXTEND = 66,                   /* EXTEND  */
    PRAGMA = 67,                   /* PRAGMA  */
    FEATURE = 68,                  /* FEATURE  */
    VARARGS = 69,                  /* VARARGS  */
    ENUM = 70,                     /* ENUM  */
    CLASS = 71,                    /* CLASS  */
    TYPENAME = 72,                 /* TYPENAME  */
    PRIVATE = 73,                  /* PRIVATE  */
    PUBLIC = 74,                   /* PUBLIC  */
    PROTECTED = 75,                /* PROTECTED  */
    COLON = 76,                    /* COLON  */
    STATIC = 77,                   /* STATIC  */
    VIRTUAL = 78,                  /* VIRTUAL  */
    FRIEND = 79,                   /* FRIEND  */
    THROW = 80,                    /* THROW  */
    CATCH = 81,                    /* CATCH  */
    EXPLICIT = 82,                 /* EXPLICIT  */
    STATIC_ASSERT = 83,            /* STATIC_ASSERT  */
    CONSTEXPR = 84,                /* CONSTEXPR  */
    THREAD_LOCAL = 85,             /* THREAD_LOCAL  */
    DECLTYPE = 86,                 /* DECLTYPE  */
    AUTO = 87,                     /* AUTO  */
    NOEXCEPT = 88,                 /* NOEXCEPT  */
    OVERRIDE = 89,                 /* OVERRIDE  */
    FINAL = 90,                    /* FINAL  */
    USING = 91,                    /* USING  */
    NAMESPACE = 92,                /* NAMESPACE  */
    NATIVE = 93,                   /* NATIVE  */
    INLINE = 94,                   /* INLINE  */
    TYPEMAP = 95,                  /* TYPEMAP  */
    ECHO = 96,                     /* ECHO  */
    APPLY = 97,                    /* APPLY  */
    CLEAR = 98,                    /* CLEAR  */
    SWIGTEMPLATE = 99,             /* SWIGTEMPLATE  */
    FRAGMENT = 100,                /* FRAGMENT  */
    WARN = 101,                    /* WARN  */
    LESSTHAN = 102,                /* LESSTHAN  */
    GREATERTHAN = 103,             /* GREATERTHAN  */
    DELETE_KW = 104,               /* DELETE_KW  */
    DEFAULT = 105,                 /* DEFAULT  */
    LESSTHANOREQUALTO = 106,       /* LESSTHANOREQUALTO  */
    GREATERTHANOREQUALTO = 107,    /* GREATERTHANOREQUALTO  */
    EQUALTO = 108,                 /* EQUALTO  */
    NOTEQUALTO = 109,              /* NOTEQUALTO  */
    LESSEQUALGREATER = 110,        /* LESSEQUALGREATER  */
    ARROW = 111,                   /* ARROW  */
    QUESTIONMARK = 112,            /* QUESTIONMARK  */
    TYPES = 113,                   /* TYPES  */
    PARMS = 114,                   /* PARMS  */
    NONID = 115,                   /* NONID  */
    DSTAR = 116,                   /* DSTAR  */
    DCNOT = 117,                   /* DCNOT  */
    TEMPLATE = 118,                /* TEMPLATE  */
    OPERATOR = 119,                /* OPERATOR  */
    CONVERSIONOPERATOR = 120,      /* CONVERSIONOPERATOR  */
    PARSETYPE = 121,               /* PARSETYPE  */
    PARSEPARM = 122,               /* PARSEPARM  */
    PARSEPARMS = 123,              /* PARSEPARMS  */
    DOXYGENSTRING = 124,           /* DOXYGENSTRING  */
    DOXYGENPOSTSTRING = 125,       /* DOXYGENPOSTSTRING  */
    CAST = 126,                    /* CAST  */
    LOR = 127,                     /* LOR  */
    LAND = 128,                    /* LAND  */
    OR = 129,                      /* OR  */
    XOR = 130,                     /* XOR  */
    AND = 131,                     /* AND  */
    LSHIFT = 132,                  /* LSHIFT  */
    RSHIFT = 133,                  /* RSHIFT  */
    PLUS = 134,                    /* PLUS  */
    MINUS = 135,                   /* MINUS  */
    STAR = 136,                    /* STAR  */
    SLASH = 137,                   /* SLASH  */
    MODULO = 138,                  /* MODULO  */
    UMINUS = 139,                  /* UMINUS  */
    NOT = 140,                     /* NOT  */
    LNOT = 141,                    /* LNOT  */
    DCOLON = 142                   /* DCOLON  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 1608 "./CParse/parser.y"

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

#line 354 "CParse/parser.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_CPARSE_PARSER_H_INCLUDED  */
