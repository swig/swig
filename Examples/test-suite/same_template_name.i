%module same_template_name;

namespace ns__a {

    template< typename T > class TName {};

}

namespace ns__a {
    namespace ns__b {

        template< typename T > class TName : public TName<T> {};

    }
}
