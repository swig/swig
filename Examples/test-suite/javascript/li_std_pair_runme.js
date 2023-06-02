var li_std_pair = require("li_std_pair");

function check(flag) {
    if (!flag) {
        throw new Error("Check failed");
    }
}

intPair = li_std_pair.makeIntPair(7, 6);
check(typeof intPair === 'object');
if (Object.keys(intPair).length) {
    // When using raw V8, intPair will be an object with two properties
    check(Object.keys(intPair).length == 2);
} else {
    // When using NAPI, intPair will be an object of class intPair whose
    // prototype will have two properties
    check(Object.keys(Object.getPrototypeOf(intPair)).length == 2);
}
check(intPair.first === 7);
check(intPair.second === 6);

intPairConstRef = li_std_pair.makeIntPairConstRef(7, 6);
check(typeof intPairConstRef === 'object');
check(intPairConstRef.first === 7);
check(intPairConstRef.second === 6);

//
// Each of these should return a reference to a wrapped
// std:: pair < int, int > object(i.e.an intPair instance).
intPairPtr = li_std_pair.makeIntPairPtr(7, 6);
check(typeof intPairPtr === 'object');
check(intPairPtr.first === 7);
check(intPairPtr.second === 6);

intPairRef = li_std_pair.makeIntPairRef(7, 6);
check(typeof intPairRef === 'object');
check(intPairRef.first === 7);
check(intPairRef.second === 6);

// Now test various input typemaps.Each of the wrapped C++ functions
//(product1, product2 and product3) is expecting an argument of a
// different type(see li_std_pair.i).Typemaps should be in place to
// convert this tuple into the expected argument type.
check(li_std_pair.product1(intPair) === 42);
check(li_std_pair.product2(intPair) === 42);
// check(product3(intPair) == 42) # TODO, if (desirable to match Ruby wrappers behaviour.Requires equivalent to typemap(in) std:: pair * in Lib / ruby / std_pair.i and further fixes to stop recursive calls to swig:) {asptr which this testcase shows.Plus further changes for any type of sequence type(including other STL containers) to be accepted by all methods taking an STL container to match Ruby behaviour.

//
// Similarly, each of the input typemaps should know what to do
// with an intPair instance.
check(li_std_pair.product1(intPairPtr) === 42);
check(li_std_pair.product2(intPairPtr) === 42);
check(li_std_pair.product3(intPairPtr) === 42);
