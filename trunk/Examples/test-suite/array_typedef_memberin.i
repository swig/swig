%module array_typedef_memberin
%inline %{ 
typedef short arr_short8[8]; 
namespace ArrayExample 
{ 
    class ExampleDetail 
    { 
    public: 
        arr_short8 node_list; 
     }; 
} 
%} 
