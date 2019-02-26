%module using_member;

%rename(greater) one::two::three::interface1::AA::great(int);
%rename(greater) one::two::three::interface1::AA::great(float);

%inline %{
namespace interface1
{
    class A
    {
    public:
        int get(int) {return 10;}
    };
}
using interface1::A;

class B : public A
{
 public:
    using A::get;
    int get(double) {return 20;}
};


namespace one {
    namespace two {
        namespace three {
            namespace interface1
            {
                class AA
                {
                public:
                    int great(int) {return 0;}
                    int great(float) {return 1;}
                };
            }
            using interface1::AA;
        }
    }
    namespace twotwo {
        namespace threetwo {
            class BB : public two::three::AA
            {
            public:
                using two::three::AA::great;
                int great(bool) {return 2;}
                int jj() {return 3;};
            };
        }
    }
}
%}
