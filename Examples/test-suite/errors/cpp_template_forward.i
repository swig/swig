%module xxx


namespace Space {
  template <typename T> struct ForwardDeclaredTemplate;
  %template(ForwardDeclaredTemplate_double) ForwardDeclaredTemplate<double>;

  template <typename T> struct ForwardDeclaredSpecialized;
  %template(ForwardDeclaredTemplate_int) ForwardDeclaredSpecialized<int>; // no primary defined
  %template(ForwardDeclaredTemplate_double) ForwardDeclaredSpecialized<double>; // needs to be after the specialized template definition.
  template <> struct ForwardDeclaredSpecialized<double> {
    void specialized(const ForwardDeclaredSpecialized& other) { }
  };

  template <typename T> struct ForwardDeclaredMisplacedPrimary;
  %template(ForwardDeclaredTemplate_double) ForwardDeclaredMisplacedPrimary<double>; // needs to be after the primary template definition.
  template <typename T> struct ForwardDeclaredMisplacedPrimary {
    void primary(const ForwardDeclaredMisplacedPrimary& other) { }
  };
}
