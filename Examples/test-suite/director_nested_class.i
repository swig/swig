%module(directors="1") director_nested_class


%feature("director") DirectorOuter::DirectorInner;

%inline %{
struct DirectorOuter {
  struct DirectorInner {
    virtual ~DirectorInner() {}
    virtual int vmethod(int input) const = 0;
  };
  static int callMethod(const DirectorInner &di, int value) {
    return di.vmethod(value);
  } 
};
%}
