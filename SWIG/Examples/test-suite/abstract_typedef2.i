%module abstract_typedef2

 /*
   After the fix for abstract_typedef, this simpler
   example got broken.
 */

%inline %{
    
  struct Engine
  {
  };      
  
  struct Object
  {
    virtual bool write(Engine& archive) const = 0;
  };    
  
  
  class A : public Object
  {
    A(int a = 0)
    {
    }
    
    bool write(Engine& archive) const
    {
      return true;
    }
  };
%}
