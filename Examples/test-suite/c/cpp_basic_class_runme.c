#include "cpp_basic_class/cpp_basic_class_wrap.h"

int main(int argc, const char *argv[])
{
    MyClass *mc;
    mc = MyClass_new();

    MyClass_delete(mc);

    return 0;
}
