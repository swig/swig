%module namewarn_rename


%inline %{

  void Empty() {};
  

  class stdClass 
  {
  };

  struct Hello 
  {
    void empty() {}    
  };
  
  

%}
