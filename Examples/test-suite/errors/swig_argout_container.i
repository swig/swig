%module xxx

// All the argout typemaps for a function append into the same $result, so they must all
// build the same container. An overwriting typemap sets the container for the ones after it.
// Note the warning is reported against the line following the declaration.

%typemap(in, numinputs=0) int *LIST (int temp) ""
%typemap(argout) int *LIST ""

%typemap(in, numinputs=0) int *TUPLE (int temp) ""
%typemap(argout, container="tuple") int *TUPLE ""

%typemap(in, numinputs=0) int *TUPLEREPLACE (int temp) ""
%typemap(argout, overwrite=1, container="tuple") int *TUPLEREPLACE ""

// Returns nothing, so the container it names is not the one anything appends into.
%typemap(in, numinputs=0) int *TUPLEDROP (int temp) ""
%typemap(argout, overwrite=1, numoutputs=0, container="tuple") int *TUPLEDROP ""

%apply int *TUPLE { int *TUPLE2 };

// Consistent - no warning.
void agree(int *TUPLE, int *TUPLE2);
void agree_after_overwrite(int *TUPLEREPLACE, int *TUPLE);
void overwrite_returning_nothing(int *TUPLEDROP, int *LIST);

// Inconsistent - warning 478.
void clash(int *LIST, int *TUPLE);
void clash_after_overwrite(int *TUPLEREPLACE, int *LIST);
