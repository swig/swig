%module li_std_unique_ptr_deleter

#if defined(SWIGPYTHON)

%include "std_unique_ptr.i"

%inline %{
#include <memory>

struct Widget {
  int value;
  Widget(int v) : value(v) {}
  ~Widget() {}
};

struct WidgetDeleter {
  void operator()(Widget* w) const {
    delete w;
  }
};
%}

%unique_ptr_custom_deleter(Widget, WidgetDeleter)

%inline %{

  std::unique_ptr<Widget, WidgetDeleter> make_widget(int val) {
    return std::unique_ptr<Widget, WidgetDeleter>(new Widget(val));
  }

  int widget_value(std::unique_ptr<Widget, WidgetDeleter> w) {
    return w ? w->value : -1;
  }
%}

#endif
