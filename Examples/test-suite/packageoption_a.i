%module(package="C") "packageoption_a";

%inline %{
class A
{
 public:
  int testInt() { return 2;}
};

%}
