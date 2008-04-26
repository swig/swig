%module(package="C") "package_b";

%inline %{
class B
{
 public:
  int testInt() { return 4; }
};

%}