%module import_fragments_b

%fragment("ImportB", "header") %{
ImportB_this_will_not_compile;
%}

%fragment("ImportB");


