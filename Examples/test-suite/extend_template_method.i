%module extend_template_method

%include <std_string.i>

%inline %{
namespace Space {
class ExtendMe {
public:
  template <typename T>
  T do_stuff_impl(int a, T b, double d) {
    return b;
  }
};
}
%}

%extend Space::ExtendMe {
  template<typename T>
  T do_stuff(int a, T b) {
    return $self->do_stuff_impl(a, b, 4.0);
  }
  template<typename T>
  T do_overloaded_stuff(T b) {
    return $self->do_stuff_impl(0, b, 4.0);
  }
  template<typename T>
  static T static_method(T t) { return t; }
}
%template(do_stuff_double) Space::ExtendMe::do_stuff<double>;
%template(do_stuff_string) Space::ExtendMe::do_stuff<std::string>;

%template(do_overloaded_stuff) Space::ExtendMe::do_overloaded_stuff<std::string>;
%template(do_overloaded_stuff) Space::ExtendMe::do_overloaded_stuff<double>;

%template(static_method) Space::ExtendMe::static_method<int>;

%inline %{
namespace Space {
template<typename X>
class TemplateExtendMe {
public:
  template <typename T>
  T template_stuff_impl(X a, T b, double d) {
    return b;
  }
};
}
%}

%extend Space::TemplateExtendMe {
  template<typename T>
  T do_template_stuff(int a, T b) {
    return $self->template_stuff_impl(a, b, 4.0);
  }
  template<typename T>
  T do_template_overloaded_stuff(T b) {
    return $self->template_stuff_impl(0, b, 4.0);
  }
  template<typename T>
  static T static_template_method(T t) { return t; }

%template(do_template_stuff_double) do_template_stuff<double>;
%template(do_template_stuff_string) do_template_stuff<std::string>;

%template(do_template_overloaded_stuff) do_template_overloaded_stuff<std::string>;
%template(do_template_overloaded_stuff) do_template_overloaded_stuff<double>;

%template(static_template_method) static_template_method<int>;
}

%template(TemplateExtend) Space::TemplateExtendMe<int>;

