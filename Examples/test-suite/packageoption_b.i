%module(package="C") "packageoption_b";

%inline %{
class B
{
 public:
  int testInt() { return 4; }
};

%}
