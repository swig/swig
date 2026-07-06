%module swift_shared_ptr
// Swift-specific test: std::shared_ptr managed objects.
%include <std_shared_ptr.i>
%shared_ptr(Widget)
%inline %{
#include <memory>
struct Widget { int v; Widget(int x) : v(x) {} int get() const { return v; } };
int widget_value(std::shared_ptr<Widget> w) { return w ? w->get() : -1; }
std::shared_ptr<Widget> make_widget(int x) { return std::make_shared<Widget>(x); }
%}
