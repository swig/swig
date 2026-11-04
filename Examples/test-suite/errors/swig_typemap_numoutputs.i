%module xxx

// GetInt() uses atoi(), so an unparseable numoutputs value would otherwise be quietly
// treated as numoutputs=0, wrongly saying the typemap returns nothing.
%typemap(out, numoutputs="abc") int * ""
%typemap(argout, numoutputs="") int & ""
%typemap(argout, numoutputs="-1") short * ""
%typemap(argout, numoutputs=2) long * ""
%typemap(out, numoutputs=2) char * ""
