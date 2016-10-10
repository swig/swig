%module template_default_cache;

%import "amodel.i"

%{ // C++ code to make this compilable
    namespace d {
        template< typename T > class d {};
    }
    namespace ns__a {
        namespace iface1 {
            class Model {};
            typedef d::d<Model> ModelPtr;
        }
        using iface1::ModelPtr;
    }
%}

%inline %{
namespace ns__b {
    namespace iface1 {
        class Model {
        public:
            ns__a::ModelPtr foo() { return ns__a::ModelPtr(); };
        };
        typedef d::d<Model> ModelPtr;
    }
 }
%}
