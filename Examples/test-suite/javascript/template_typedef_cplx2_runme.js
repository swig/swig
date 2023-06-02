var template_typedef_cplx2 = require("template_typedef_cplx2");

//
// double case
//

var d, e;

try {
    d = template_typedef_cplx2.make_Identity_double();
    // This test is not possible in JSC where all SWIG proxies inherit from Object
    if (typeof print === 'undefined')
        if (!d.constructor.name.includes('ArithUnaryFunction')) throw new Error;
} catch {
    throw new Error(`${d} is not an ArithUnaryFunction`);
}

try {
    e = template_typedef_cplx2.make_Multiplies_double_double_double_double(d, d);
    if (typeof print === 'undefined')
        if (!e.constructor.name.includes('ArithUnaryFunction')) throw new Error;
} catch {
    throw new Error(`${e} is not an ArithUnaryFunction`);
}
