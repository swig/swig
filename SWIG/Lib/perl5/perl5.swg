/* -----------------------------------------------------------------------------
 * perl5.swg
 *
 * Perl 5 configuration file
 * ----------------------------------------------------------------------------- */

%runtime "common.swg"         // common type checking code
%runtime "perlrun.swg"        // Perl runtime functions

// Typemap for character array returns

%typemap(perl5,out) char [ANY] "ST(argvi) = sv_newmortal();\n sv_setpv((SV*)ST(argvi++),(char *) result);";
