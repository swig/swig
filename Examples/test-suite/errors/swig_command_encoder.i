%module xxx

// This feature was removed in SWIG 4.1.0 so check it gives an error.
%define SedCmd "%(command:sed -e 's/\([a-z]\)/\U\\1/' -e 's/\(_\)\([a-z]\)/\U\\2/g' <<<)s" %enddef
%rename(SedCmd) "";
int x;
