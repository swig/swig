
%module arrays_dimensionless

%warnfilter(462) globalints;    /* Unable to set variable of type int [] */
%warnfilter(462) ints;          /* Unable to set variable of type int [] */

%inline %{

int globalints[] = {100, 200, 300};
const int constglobalints[] = {400, 500, 600};

struct Bar {
    static int ints[];
};
int Bar::ints[] = {700, 800, 900};

%}

