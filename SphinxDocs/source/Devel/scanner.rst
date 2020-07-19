SWIG C/C++ Scanning
===================

| David M. Beazley
| dave-swig@dabeaz.com
| January 11, 2007

Introduction
------------

This document describes functions that can be used to tokenize C/C++
input text. These functions are relatively low-level and are meant to be
used in the implementation of scanners that can be plugged into yacc or
used for other purposes. For instance, the preprocessor uses these
functions to evaluate and test constant expressions.

All of these functions are declared in ``Source/Swig/swigscan.h``. This
API is considered to be stable.

Creation and Deletion of Scanners
---------------------------------

The following functions are used to create and destroy a scanner object.
More than one scanner object can be created and used as necessary.

**``Scanner *NewScanner()``**

   Creates a new scanner object. The scanner contains initially contains
   no text. To feed text to the scanner use ``Scanner_push()``.

**``Scanner *DelScanner()``**

   Deletes a scanner object.

Scanner Functions
-----------------

**``void Scanner_clear(Scanner *s)``**

   Clears all text from the scanner. This can be used to reset a scanner
   to its initial state, ready to receive new input text.

**``void Scanner_push(Scanner *s, String *text)``**

   Pushes an input string into the scanner. Subsequent tokens will be
   returned from the new string. If the scanner is already processing a
   string, the pushed string takes precedence--in effect, interrupting
   the scanning of the previous string. This behavior is used to
   implement certain SWIG features such as the ``%inline`` directive.
   Once the pushed string has been completely scanned, the scanner will
   return to scanning the previous string (if any). The scanning of text
   relies upon the DOH file interface to strings (``Getc()``,
   ``Ungetc()``, etc.). Prior to calling this function, the input string
   should be set so that its file pointer is in the location where you
   want scanning to begin. You may have to use ``Seek()`` to set the
   file pointer back to the beginning of a string prior to using this
   function.

**``void Scanner_pushtoken(Scanner *s, int tokvalue, String_or_char *val)``**

   Pushes a token into the scanner. This exact token will be returned by
   the next call to ``Scanner_token()``. ``tokvalue`` is the integer
   token value to return and ``val`` is the token text to return. This
   function is only used to handle very special parsing cases. For
   instance, if you need the scanner to return a fictitious token into
   order to enter a special parsing case.

**``int Scanner_token(Scanner *s)``**

   Returns the next token. An integer token code is returned (see table
   below) on success. If no more input text is available 0 is returned.
   If a scanning error occurred, -1 is returned. In this case, error
   information can be obtained using ``Scanner_errinfo()``.

**``String *Scanner_text(Scanner *s)``**

   Returns the scanned text corresponding to the last token returned by
   ``Scanner_token()``. The returned string is only valid until the next
   call to ``Scanner_token()``. If you need to save it, make a copy.

**``void Scanner_skip_line(Scanner *s)``**

   Skips to the end of the current line. The text skipped can be
   obtained using ``Scanner_text()`` afterwards.

**``void Scanner_skip_balanced(Scanner *s, int startchar, int endchar)``**

   Skips to the end of a block of text denoted by starting and ending
   characters. For example, ``{`` and ``}``. The function is smart about
   how it skips text. String literals and comments are ignored. The
   function also is aware of nesting. The skipped text can be obtained
   using ``Scanner_text()`` afterwards. Returns 0 on success, -1 if no
   matching ``endchar`` could be found.

**``void Scanner_set_location(Scanner *s, int startchar, int endchar)``**

   Changes the current filename and line number of the scanner.

**``String *Scanner_file(Scanner *s)``**

   Gets the current filename associated with text in the scanner.

**``int Scanner_line(Scanner *s)``**

   Gets the current line number associated with text in the scanner.

**``int Scanner_start_line(Scanner *s)``**

   Gets the starting line number of the last token returned by the
   scanner.

**``void Scanner_idstart(Scanner *s, char *idchar)``**

   Sets additional characters (other than the C default) that may be
   used to start C identifiers. ``idchar`` is a string containing the
   characters (e.g., "%@"). The purpose of this function is to up
   special keywords such as "%module" or "@directive" as simple
   identifiers.

**``String *Scanner_errmsg(Scanner *s)``**

   Returns the error message associated with the last scanner error (if
   any). This will only return a meaningful result if
   ``Scanner_token()`` returned -1.

**``int Scanner_errline(Scanner *s)``**

   Returns the line number associated with the last scanner error (if
   any). This will only return a meaningful result if
   ``Scanner_token()`` returned -1. The line number usually corresponds
   to the starting line number of a particular token (e.g., for
   unterminated strings, comments, etc.).

**``int Scanner_isoperator(int tokval)``**

   A convenience function that returns 0 or 1 depending on whether
   ``tokval`` is a valid C/C++ operator (i.e., a candidate for operator
   overloading).

**``void Scanner_freeze_line(int val)``**

   Freezes the current line number depending upon whether or not ``val``
   is 1 or 0. When the line number is frozen, newline characters will
   not result in updates to the line number. This is sometimes useful in
   tracking line numbers through complicated macro expansions.

Token Codes
-----------

The following table shows token codes returned by the scanner. These are
integer codes returned by the ``Scanner_token()`` function.

   ::

      Token code                   C Token
      -------------------------    -------------
      SWIG_TOKEN_LPAREN            (
      SWIG_TOKEN_RPAREN            )
      SWIG_TOKEN_SEMI              ; 
      SWIG_TOKEN_COMMA             , 
      SWIG_TOKEN_STAR              * 
      SWIG_TOKEN_TIMES             *
      SWIG_TOKEN_LBRACE            { 
      SWIG_TOKEN_RBRACE            } 
      SWIG_TOKEN_EQUAL             = 
      SWIG_TOKEN_EQUALTO           == 
      SWIG_TOKEN_NOTEQUAL          != 
      SWIG_TOKEN_PLUS              + 
      SWIG_TOKEN_MINUS             - 
      SWIG_TOKEN_AND               & 
      SWIG_TOKEN_LAND              && 
      SWIG_TOKEN_OR                | 
      SWIG_TOKEN_LOR               || 
      SWIG_TOKEN_XOR               ^ 
      SWIG_TOKEN_LESSTHAN          < 
      SWIG_TOKEN_GREATERTHAN       > 
      SWIG_TOKEN_LTEQUAL           <= 
      SWIG_TOKEN_GTEQUAL           >= 
      SWIG_TOKEN_NOT               ~ 
      SWIG_TOKEN_LNOT              ! 
      SWIG_TOKEN_LBRACKET          [ 
      SWIG_TOKEN_RBRACKET          ] 
      SWIG_TOKEN_SLASH             / 
      SWIG_TOKEN_DIVIDE            /
      SWIG_TOKEN_BACKSLASH         \ 
      SWIG_TOKEN_POUND             # 
      SWIG_TOKEN_PERCENT           % 
      SWIG_TOKEN_MODULO            %
      SWIG_TOKEN_COLON             : 
      SWIG_TOKEN_DCOLON            :: 
      SWIG_TOKEN_DCOLONSTAR        ::*
      SWIG_TOKEN_LSHIFT            << 
      SWIG_TOKEN_RSHIFT            >> 
      SWIG_TOKEN_QUESTION          ? 
      SWIG_TOKEN_PLUSPLUS          ++ 
      SWIG_TOKEN_MINUSMINUS        -- 
      SWIG_TOKEN_PLUSEQUAL         += 
      SWIG_TOKEN_MINUSEQUAL        -= 
      SWIG_TOKEN_TIMESEQUAL        *= 
      SWIG_TOKEN_DIVEQUAL          /= 
      SWIG_TOKEN_ANDEQUAL          &= 
      SWIG_TOKEN_OREQUAL           |= 
      SWIG_TOKEN_XOREQUAL          ^= 
      SWIG_TOKEN_LSEQUAL           <<= 
      SWIG_TOKEN_RSEQUAL           >>= 
      SWIG_TOKEN_MODEQUAL          %= 
      SWIG_TOKEN_ARROW             -> 
      SWIG_TOKEN_ARROWSTAR         ->* 
      SWIG_TOKEN_PERIOD            . 
      SWIG_TOKEN_AT                @ 
      SWIG_TOKEN_DOLLAR            $ 
      SWIG_TOKEN_ENDLINE           Literal newline
      SWIG_TOKEN_ID                identifier 
      SWIG_TOKEN_FLOAT             Floating point with F suffix (e.g., 3.1415F)
      SWIG_TOKEN_DOUBLE            Floating point (e.g., 3.1415 )
      SWIG_TOKEN_INT               Integer (e.g., 314)
      SWIG_TOKEN_UINT              Unsigned integer (e.g., 314U)
      SWIG_TOKEN_LONG              Long integer (e.g., 314L) 
      SWIG_TOKEN_ULONG             Unsigned long integer (e.g., 314UL)
      SWIG_TOKEN_LONGLONG          Long long integer (e.g., 314LL )
      SWIG_TOKEN_ULONGLONG         Unsigned long long integer (e.g., 314ULL) 
      SWIG_TOKEN_CHAR              Character literal in single quotes ('c')
      SWIG_TOKEN_STRING            String literal in double quotes ("str")
      SWIG_TOKEN_RSTRING           Reverse quote string (`str`)
      SWIG_TOKEN_CODEBLOCK         SWIG code literal block %{ ... %}
      SWIG_TOKEN_COMMENT           C or C++ comment  (// or /* ... */)
      SWIG_TOKEN_ILLEGAL           Illegal character

**Notes**

-  When more than one token code exist for the same token text, those
   codes are identical (e.g., ``SWIG_TOKEN_STAR`` and
   ``SWIG_TOKEN_TIMES``).
-  String literals are returned in their exact representation in which
   escape codes (if any) have been interpreted.
-  All C identifiers and keywords are simply returned as
   ``SWIG_TOKEN_ID``. To check for specific keywords, you will need to
   add extra checking on the returned text.
-  C and C++ comments include the comment starting and ending text
   (e.g., "//", "/*").
-  The maximum token integer value is found in the constant
   ``SWIG_MAXTOKENS``. This can be used if you wanted to create an array
   or table for the purposes of remapping tokens to a different set of
   codes. For instance, if you are using these functions to write a
   yacc-compatible lexer.
