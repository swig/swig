%module swift_shared_ptr
// Swift-specific test: std::shared_ptr managed objects.
%include <std_shared_ptr.i>
%shared_ptr(Widget)
%inline %{
#include <memory>
struct Widget {
  int v;
  Widget(int x) : v(x) { ++live_count(); }
  ~Widget() { --live_count(); }
  int get() const { return v; }
  // Live-instance counter: lets the runme verify that a returned shared_ptr is
  // owned by the Swift proxy (ARC frees it), guarding against a non-owning proxy
  // that would leak the heap-allocated shared_ptr.
  static int &live_count() { static int n = 0; return n; }
};
int widget_value(std::shared_ptr<Widget> w) { return w ? w->get() : -1; }
std::shared_ptr<Widget> make_widget(int x) { return std::make_shared<Widget>(x); }
int widget_live_count() { return Widget::live_count(); }
%}
