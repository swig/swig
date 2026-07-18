%module(directors="1") rust_enums

%include <enums.swg>
%include <enumsimple.swg>
%include <enumtypesafe.swg>

%feature("director") RustEnumDirector;

%inline %{
enum RustColor {
  RustRed = 1,
  RustGreen = 2,
  RustBlue = 3,
  RustCyan = 8,
  RustMagenta = 13
};

enum RustSigned {
  RustNegative = -7,
  RustZero = 0,
  RustLarge = 42
};

RustColor rust_next_color(RustColor color) {
  return color == RustRed ? RustGreen : RustBlue;
}

int rust_color_value(RustColor color) {
  return (int)color;
}

RustColor rust_color_from_int(int value) {
  return (RustColor)value;
}

const RustColor &rust_color_ref(const RustColor &color) {
  static RustColor stored;
  stored = color;
  return stored;
}

class RustEnumBox {
public:
  enum Mode {
    ModeIdle = 0,
    ModeRunning = 10,
    ModeStopped = 20
  };

  RustEnumBox() : color(RustRed), signed_value(RustZero), mode_(ModeIdle) {
  }

  RustColor select(RustColor color) const {
    return color == RustGreen ? RustBlue : RustGreen;
  }

  RustSigned select_signed(const RustSigned &value) const {
    return value == RustNegative ? RustLarge : RustNegative;
  }

  Mode mode() const {
    return mode_;
  }

  void set_mode(Mode mode) {
    mode_ = mode;
  }

  static Mode next_mode(Mode mode) {
    return mode == ModeIdle ? ModeRunning : ModeStopped;
  }

  RustColor color;
  RustSigned signed_value;

private:
  Mode mode_;
};

class RustEnumDirector {
public:
  virtual ~RustEnumDirector() {
  }

  virtual RustColor choose(RustColor color) {
    return color;
  }

  virtual RustSigned choose_signed(const RustSigned &value) {
    return value;
  }
};

RustColor rust_call_choose(RustEnumDirector *director, RustColor color) {
  return director->choose(color);
}

RustSigned rust_call_choose_signed(RustEnumDirector *director, const RustSigned &value) {
  return director->choose_signed(value);
}
%}
