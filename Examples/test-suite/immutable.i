// test to make sure setters are not generated for constants

%module immutable


%immutable;
%mutable;

%inline %{
#define ABC -11
enum count {zero, one, two};
%}


%clearimmutable;

%inline %{
#define XYZ -22
enum backwards {tre=3, duo=2, uno=1};
%}

