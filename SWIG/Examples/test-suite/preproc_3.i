%module preproc_3

%inline %{

#define Sum( A, B, \
             C)    \
        A + B + C 

%}

