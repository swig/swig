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

// As above with braced defaults
template<struct Point = Point{1, 2}>
struct BraceDefault {
  Point get() const { return Point{4, 5}; }
};

template<struct Point = Point{}>
struct EmptyBraceDefault {
  Point get() const { return Point{6, 7}; }
};

template<struct Point P = Point{1, 2}>
struct NamedBraceDefault {
  Point get() const { return P; }
};

// Accept a BraceDefault<> or EmptyBraceDefault<> only if the default value is recorded as written
int brace_default_x(const BraceDefault<Point{1, 2}> &b) { return b.get().x; }
int empty_brace_default_x(const EmptyBraceDefault<Point{}> &e) { return e.get().x; }

// A designated initializer default, whose '.' is not a type separator
template<struct Point P = Point{.x = 8, .y = 9}>
struct NamedDesignatedDefault {
  Point get() const { return P; }
};

int designated_default_x(const NamedDesignatedDefault<Point{.x = 8, .y = 9}> &d) { return d.get().x; }

template<int N>
struct IntValue {
  int get() const { return N; }
};

// Named like the member in 'unit.y' and the designators '.y', which are not types
typedef int y;

int unit_y_value(const IntValue<unit.y> &i) { return i.get(); }
%}

%template(OriginDefaultDef) OriginDefault<>;
%template(OriginDefaultUnit) OriginDefault<unit>;
%template(NamedOriginDefaultDef) NamedOriginDefault<>;
%template(NamedOriginDefaultUnit) NamedOriginDefault<unit>;
%template(BraceDefaultDef) BraceDefault<>;
%template(BraceDefaultOther) BraceDefault<Point{3, 4}>;
%template(EmptyBraceDefaultDef) EmptyBraceDefault<>;
%template(NamedBraceDefaultDef) NamedBraceDefault<>;
%template(NamedBraceDefaultOther) NamedBraceDefault<Point{3, 4}>;

// Template arguments containing a '.'
%template(BraceDefaultDesignated) BraceDefault<Point{.x = 3, .y = 7}>;
%template(NamedBraceDefaultDesignated) NamedBraceDefault<Point{.x = 5, .y = 6}>;
%template(NamedDesignatedDefaultDef) NamedDesignatedDefault<>;
%template(IntValueUnitY) IntValue<unit.y>;
%template(IntValueCast) IntValue<(int)2.5>;

// A default value whose name after the '.' is also a typedef
%feature("compactdefaultargs") unit_y_default;
%inline %{
int unit_y_default(const int &v = unit.y) { return v; }
%}

// A named parameter introduced with 'struct' is a value, so this overload with a type parameter is not ambiguous
%inline %{
template<typename T> int kind() { return 1; }
template<struct Point P> int kind() { return 2; }
%}

%template(kind_type) kind<int>;
%template(kind_value) kind<origin>;
