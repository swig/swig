/* -----------------------------------------------------------------------------
 * parser_internal.h
 *
 *     Internal definitions for the SWIG parser
 *
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

typedef struct {
    char *id;
    int   is_pointer;
    int   is_reference;
    int   is_post_type_const; /* const declared after the type, eg int* const */
} Declaration;


