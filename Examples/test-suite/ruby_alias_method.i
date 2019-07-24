%module ruby_alias_method
%include <std_string.i>

%alias Synonym::getMyName "nickname,fullname"

%inline %{

class Synonym {
private:
  std::string myName;

public:
  Synonym(std::string myName);

  std::string getMyName();
};

Synonym::Synonym(std::string myName){
  this->myName = myName;
};

std::string Synonym::getMyName(){
  return this->myName;
};

%}
