%module cpp11_template_pack

%include <std_string.i>

%rename(call) *::operator();

%inline %{
  template <typename T, typename... U>
  class Objekt {
    int v;
  public:
    Objekt(int x): v{x} {}
  };

  template <typename T, typename... U>
  class Unique {
    int v;
  public:
    Unique() = delete;
    Unique(const Unique &) = delete;
    Unique(Unique &&) = default;
    Unique(int x): v{x} {}
  };
%}

%template(Objekt_3int) Objekt<int, int, int>;
%template(Unique_3int) Unique<int, int, int>;

%template(Objekt_String) Objekt<const std::string &>;
%template(Unique_String) Unique<const std::string &>;

%inline %{
#if 1
  template <typename T, typename... U>
  int fnObjekt(Objekt<T, U...>) {
    return 1;
  }
#else
  template <typename T, typename U, typename V>
  int fnObjekt(Objekt<T, U, V>) {
    return 1;
  }
#endif

  template <typename T, typename... U>
  int fnUnique(Unique<T, U...> &&) {
    return 2;
  }

  template <typename T, typename... U>
  int fnFuncPtr(T (*fn)(U...)) {
    return 3;
  }
%}

%{
#include <string>
%}

%template(fnObjekt_3int) fnObjekt<int, int, int>;
%template(fnUnique_3int) fnUnique<int, int, int>;
%template(fnFunctPtr_3int) fnFuncPtr<int, int, int>;

%template(fnObjekt_Objekt_Unique) fnObjekt<Objekt<const std::string &>, Unique<const std::string &>>;
%template(fnUnique_Objekt_Unique) fnUnique<Objekt<const std::string &>, Unique<const std::string &>>;
%template(fnFunctPtr_void_Objekt_Unique) fnFuncPtr<void, Objekt<const std::string &>, Unique<const std::string &>>;
