%module rust_ownership

%newobject make_owned_lifetime;

%inline %{

class LifetimeThing {
public:
  LifetimeThing(int value) : value_(value) {
    ++alive_count;
  }
  ~LifetimeThing() {
    --alive_count;
  }
  int value() const {
    return value_;
  }
  void set(int value) {
    value_ = value;
  }
  static int alive() {
    return alive_count;
  }
private:
  int value_;
  static int alive_count;
};

int LifetimeThing::alive_count = 0;

LifetimeThing *global_lifetime() {
  static LifetimeThing global(100);
  return &global;
}

LifetimeThing *make_owned_lifetime(int value) {
  return new LifetimeThing(value);
}

LifetimeThing *maybe_lifetime(int use_global) {
  return use_global ? global_lifetime() : 0;
}

LifetimeThing &lifetime_ref(LifetimeThing &thing) {
  return thing;
}

int lifetime_value(LifetimeThing *thing) {
  return thing ? thing->value() : -1;
}

int const_lifetime_value(const LifetimeThing *thing) {
  return thing ? thing->value() : -1;
}

const LifetimeThing &const_lifetime_ref(const LifetimeThing &thing) {
  return thing;
}

void set_lifetime_value(LifetimeThing &thing, int value) {
  thing.set(value);
}

%}
