var cpp11_variadic_function_templates = require("cpp11_variadic_function_templates");

const {A, B, C, D, variadicmix1} = cpp11_variadic_function_templates;

ec = new cpp11_variadic_function_templates.EmplaceContainer();
ec.emplace(new A());
ec.emplace(new A(), new B());
ec.emplace(new A(), new B(), new C());
ec.emplace(new A(), new B(), new C(), new D());

function check(expected, got) {
    if (expected != got) {
        throw new Error("failed: {} != {}".format(expected, got));
    }
}
a = new A();
b = new B();
c = new C();
check(variadicmix1(), 20);
check(variadicmix1(a), 20);
check(variadicmix1(a, b), 10);
check(variadicmix1(a, b, c), 20);
check(variadicmix1(11, 22), 10);
