%module rust_default_args

%inline %{
enum RustDefaultMode {
  ModeLow = 1,
  ModeHigh = 2
};

int rust_default_add(int x, int y = 2, int z = 3) {
  return x + y + z;
}

class RustDefaults {
public:
  RustDefaults(int base = 10) : base_(base) {
  }

  int sum(int x = 1, int y = 2) const {
    return base_ + x + y;
  }

  static int stat(int x = 3, int y = 4) {
    return x * y;
  }

  RustDefaultMode next(RustDefaultMode mode = ModeLow) const {
    return mode == ModeLow ? ModeHigh : ModeLow;
  }

private:
  int base_;
};
%}
