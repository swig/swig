%module cast_operator
%inline %{
struct A 
{ 
operator char*() const; 
}; 

inline 
A::operator char*() const 
{ return "hi"; } 

%}

