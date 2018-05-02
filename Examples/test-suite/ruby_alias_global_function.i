%module ruby_alias_global_function

%alias get_my_name "nickname,fullname";

%inline %{

const char *get_my_name(){
  return "Chester Tester";
}

%}
