/* -----------------------------------------------------------------------------
 * ddirectives.swg
 *
 * D-specifiv directives.
 * ----------------------------------------------------------------------------- */

#define %dnativeconst               %feature("d:nativeconst")
#define %dconstvalue(value)         %feature("d:constvalue",value)
#define %dmethodmodifiers           %feature("d:methodmodifiers")
#define %dstripprefix               %feature("d:stripprefix")
#define %dnothrowexception          %feature("except")
