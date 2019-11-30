/* File : example.i */
%module example

%{
    #include "example.h"
%}


%extend Shape{
    %pythoncode %{
        __slots__ = ["this"]
    %}
};

%extend Circle{
    %pythoncode %{
        __slots__ = []
    %}
};

%extend Square{
    %pythoncode %{
        __slots__ = []
    %}
};

/* Let's just grab the original header file here */
%include "example.h"
