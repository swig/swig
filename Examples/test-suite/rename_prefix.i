%module rename_prefix

#ifdef SWIGFORTRAN
%fortranbindc "";
%nofortranbindc should_not_match_or_error;
#endif

// Test renaming of identifiers with a prefix.
%rename("%(strip:[my])s", prefixtarget=1) "myprefix_";
%inline %{
void myprefix_prea() {}
void myprefix_preb() {}
void myprefixnot() {}
%}

%warnfilter(SWIGWARN_LANG_IDENTIFIER) badprefix_bada;
%warnfilter(SWIGWARN_LANG_IDENTIFIER) badprefix_badb;

// Note that if we used "" instead of "badprefix_", the "badprefixnot" would
// emit false warnings.
%namewarn(%warningmsg(SWIGWARN_LANG_IDENTIFIER, "Bad prefix"),
          rename="%(strip:[badprefix_])s", prefixtarget=1) "badprefix_";
%inline %{
void badprefix_bada() {}
void badprefix_badb() {}
void badprefixnot() {}
%}

%namewarn(%warningmsg(SWIGWARN_LANG_IDENTIFIER, "Worse prefix"),
          rename="%(strip:[worseprefix_])s", error=1) "worseprefix_";

%inline %{
int should_not_match_or_error;
%}
