%module cast_operator

%rename(tochar) A::operator char*() const;
%inline %{
struct A 
{ 
operator char*() const; 
}; 

inline 
A::operator char*() const 
{ return "hi"; } 

%}

