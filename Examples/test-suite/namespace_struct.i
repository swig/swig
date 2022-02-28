%module namespace_struct

%inline %{

// SWIG/R generated bad code for copyToR for a struct in a namespace in SWIG < 4.1.0
namespace X { struct Y { int x, y; }; }

%}
