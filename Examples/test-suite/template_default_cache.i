%module template_default_cache;

%inline %{
    namespace d {
        template< typename T > class d {};
    }
%}

%ignore ns__a::iface1::Model;

%inline %{
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
        ns__a::ModelPtr get_mp_a() { return ns__a::ModelPtr(); }
        ModelPtr get_mp_b() { return ModelPtr(); }
    }
 }
%}
%template(AModelPtr) d::d<ns__a::iface1::Model>;
%template(BModelPtr) d::d<ns__b::iface1::Model>;
