%module kotlin_enum_companion

// Regression test for the kcompanion typemap injecting extra members into the companion
// object of a proper Kotlin enum, alongside the default swigToEnum.

%include <enums.swg>

%typemap(kcompanion) Direction %{
    @JvmStatic
    fun fromName(name: String): $kotlinclassname = valueOf(name)
%}

%inline %{
enum Direction { North, East, South, West };

Direction opposite(Direction d) {
  switch (d) {
    case North: return South;
    case South: return North;
    case East:  return West;
    case West:  return East;
  }
  return North;
}
%}
