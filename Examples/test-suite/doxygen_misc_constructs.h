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
 * Backslash following\c word is valid doxygen command. Output contains
 * 'followingword' with word in 'code' font.
 */
void backslashA()
{}

/**
 * Doxy command without trailing \cspace space is ignored. Standalone
 * \ and '\' get to output.  Commands not recognized by Doxygen \blah
 * are ignored.  Backslashes in DOS paths d:\xyz\c\myfile and words
 * following them do not appear on output, we must quote them with
 * double quotes: "d:\xyz\c\myfile", single quotes do not help:
 * 'd:\xyz\c\myfile'. Escaping works: d:\\xyz\\c\\myfile. Unix
 * paths of course have no such problems: /xyz/c/myfile
 */
void backslashB()
{}

/**
 *
 */
void htmlTags()
{}

