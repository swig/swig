%module xxx

// GetInt() uses atoi(), so an unparseable numinputs value would otherwise be quietly
// treated as numinputs=0 and the parameter dropped from the wrapped function.
// Note the errors are reported against the line following the typemap.
%typemap(in, numinputs="abc") int * ""
%typemap(in, numinputs="") int & ""
%typemap(in, numinputs="-1") short * ""
%typemap(in, numinputs="1x") long * ""
%typemap(in, numinputs="0x1") float * ""
