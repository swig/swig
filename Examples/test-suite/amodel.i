%module amodel;

%inline %{
namespace ns__a {
    namespace iface1 {
        class Model {};
        typedef d::d<Model> ModelPtr;
    }
}
 %}
