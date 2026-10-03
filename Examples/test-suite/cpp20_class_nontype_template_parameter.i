%module cpp20_class_nontype_template_parameter

%inline %{
struct Point {
  int x;
  int y;
};

constexpr Point origin{0, 0};
constexpr Point unit{1, 1};

// An unnamed non-type parameter of class type with a default, so 'Point' in the body is not a template parameter
template<struct Point = origin>
struct OriginDefault {
  Point get() const { return Point{2, 3}; }
};

// Accepts an OriginDefault<> only if the default value is recorded as 'origin'
int origin_default_x(const OriginDefault<origin> &o) { return o.get().x; }

// A named one, whose value can be used in the body
template<struct Point P = origin>
struct NamedOriginDefault {
  Point get() const { return P; }
};
%}

%template(OriginDefaultDef) OriginDefault<>;
%template(OriginDefaultUnit) OriginDefault<unit>;
%template(NamedOriginDefaultDef) NamedOriginDefault<>;
%template(NamedOriginDefaultUnit) NamedOriginDefault<unit>;
