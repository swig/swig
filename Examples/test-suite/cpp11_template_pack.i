%module cpp11_template_pack

%inline %{
  template <typename T, typename... U>
  class Object {
    int v;
  public:
    Object(int x): v{x} {};
  };

  template <typename T, typename... U>
  class Unique {
    int v;
  public:
    Unique() = delete;
    Unique(const Unique &) = delete;
    Unique(const Unique &&) = default;
    Unique(int x): v{x} {};
  };

  template <typename T, typename... U>
  int fnObject(Object<T, U...>) {
    return 1;
  }

  template <typename T, typename... U>
  int fnUnique(Unique<T, U...> &&) {
    return 2;
  }

  template <typename T, typename... U>
  int fnFuncPtr(T (*fn)(U...)) {
    return 3;
  }

  // The special case of std::function
  template <typename> class cpp_function {};
  template <typename RET, typename... ARGS> class cpp_function<RET(ARGS...)> {
    public:
    cpp_function() = default;
  };
  template <typename RET, typename... ARGS>
  RET callFunction(cpp_function<RET(ARGS...)> fn, ARGS && ...args) {
    return fn(args...);
  }
%}


%template(fnObject_3int) fnObject<int, int, int>;
%template(fnUnique_3int) fnUnique<int, int, int>;
%template(fnFunctPtr_3int) fnFuncPtr<int, int, int>;

%template(fnObject_Object_Unique) fnObject<Object<const std::string &>, Unique<const std::string &>>;
%template(fnUnique_Object_Unique) fnUnique<Object<const std::string &>, Unique<const std::string &>>;
%template(fnFunctPtr_void_Object_Unique) fnFuncPtr<void, Object<const std::string &>, Unique<const std::string &>>;

%template(CPPFunction) cpp_function<std::string(int, const std::string &)>;
