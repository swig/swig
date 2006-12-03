%module namespace_spaces 
%inline %{ 
 
class Foo { 
public: 
    Foo(); 
    ~Foo(); 
    typedef int Integer; 
    int blah(int x); 
    int spam(int x); 
    Integer bar(Integer x); 
    void (Foo:: *func_ptr) (int);
}; 
 
inline Foo :: Foo () {}
 
inline Foo :: ~Foo () {}
     
inline int Foo  
::blah(int x) { return 2*x; } 
 
inline int Foo :: spam(int x) { return -x; } 
 
inline Foo :: Integer Foo :: bar(Foo :: Integer x) { return x; } 
 
%} 
