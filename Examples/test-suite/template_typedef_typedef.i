%module template_typedef_typedef

// Github issue #50
// The Object2::getBlabla2 and Object::getBlabla1 functions were not resolving to the correct template types

%inline%{

class Factory;
class Base {
public:
  typedef Factory ABCD;

};

namespace TT{
        template <typename T>
        class Object2:public T {
        public:
                void getBlabla2(typename T::ABCD::CC2 c) {
                };
        };
        template <typename T>
        class Object:public T {
        public:
                void getBlabla1(typename T::ABCD::CC1 c) {
                };
        };
}

class Factory {
        public:
        typedef TT::Object<Base> CC1;
        typedef TT::Object2<Base> CC2;
        void getBlabla4(CC2 c) {
        };
        void getBlabla3(CC1 c) {
        };
};
%}

%template(ObjectBase) TT::Object<Base>;
%template(Object2Base) TT::Object2<Base>;

