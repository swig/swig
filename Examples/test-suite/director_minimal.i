%module(directors="1") director_minimal;

%feature("director") Minimal;

%inline %{

class Minimal {
public:
  virtual bool run() const { return false; }
  bool get() const { return run(); }
  virtual ~Minimal() {}
};

%}
