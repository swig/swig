/*
 * This file contains comments which demonstrate details about Doxygen processing,
 * so they can be emulated in SWIG doxy comment translation
 */



/**This comment without space after '*' is valid in Doxygen.
 *
 */
void isNoSpaceValidA()
{}

/**.This comment without space after '*' is valid in Doxygen.
 *
 */
void isNoSpaceValidB()
{}


/***This is not Doxygen comment.
 *
 */
void isNoSpaceValidC()
{}


/**
 * Backslash following\c word is a valid doxygen command. Output contains
 * 'followingword' with 'word' in 'code' font.
 */
void backslashA()
{}

// Output of escaped symbols below in doxygen generated HTML:
// Rendered: Escaped symbols: $ @ \ & < > # % " \. :: @text ::text
// HTML source: Escaped symbols: $ @ \ &amp; &lt; &gt; # % " \. :: @text ::text


/**
 * Doxy command without trailing \cspace space is ignored - nothing appears
 * on output. Standalone \ and '\' get to output.
 * Standalone @ and '@' get to output.
 * Commands not recognized by Doxygen \blah @blah are ignored.
 * Backslashes in DOS paths d:\xyz\c\myfile and
 * words following them do not appear on output, we must quote them with
 * double quotes: "d:\xyz\c\myfile", "@something". single quotes do not help:
 * 'd:\xyz\c\myfile'. Escaping works: d:\\xyz\\c\\myfile. Unix
 * paths of course have no such problems: /xyz/c/myfile
 * Commands for escaped symbols:
 * \$ \@ \\ \& \~ \< \> \# \% \" \. \:: \@text \::text
 */
void backslashB()
{}

/**
 * Backslash e at end of \e line froze SWIG \e
 * with old comment parser.
 * \arg some list item
 */
void backslashC()
{}

/**
 *
 */
void htmlTags()
{}

