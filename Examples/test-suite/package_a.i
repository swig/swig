%module(package="C") "package_a";

%inline %{
class A
{
 public:
  int testInt() { return 2;}
};

%}