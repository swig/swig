%module A

%rename($ignore) B::C;

namespace B {
    class C {
    public:
        struct D {
        };
    };

    class E {
    public:
        typedef C::D D;
    };

    struct F
    {
        const E::D func();
    };
}