var napi_li_std_pair = require('napi_li_std_pair');

function check(flag) {
  if (!flag) {
    throw new Error('Check failed');
  }
}

var intPair = /* await */(napi_li_std_pair.makeIntPair(7, 6));
check(typeof intPair === 'object');
check(intPair.length === 2);
check(intPair[0] === 7);
check(intPair[1] === 6);

var intPairConstRef = /* await */(napi_li_std_pair.makeIntPairConstRef(7, 6));
check(typeof intPairConstRef === 'object');
check(intPairConstRef[0] === 7);
check(intPairConstRef[1] === 6);

//
// Each of these should return a reference to a wrapped
// std:: pair < int, int > object(i.e.an intPair instance).
var intPairPtr = /* await */(napi_li_std_pair.makeIntPairPtr(7, 6));
check(typeof intPairPtr === 'object');
check(intPairPtr[0] === 7);
check(intPairPtr[1] === 6);

var intPairRef = /* await */(napi_li_std_pair.makeIntPairRef(7, 6));
check(typeof intPairRef === 'object');
check(intPairRef[0] === 7);
check(intPairRef[1] === 6);

// Now test various input typemaps.Each of the wrapped C++ functions
//(product1, product2 and product3) is expecting an argument of a
// different type(see napi_li_std_pair.i).Typemaps should be in place to
// convert this tuple into the expected argument type.
check(/* await */(napi_li_std_pair.product1(intPair)) === 42);
check(/* await */(napi_li_std_pair.product2(intPair)) === 42);
//
// Similarly, each of the input typemaps should know what to do
// with an intPair instance.
check(/* await */(napi_li_std_pair.product1(intPairPtr)) === 42);
check(/* await */(napi_li_std_pair.product2(intPairPtr)) === 42);
check(/* await */(napi_li_std_pair.product3(intPairPtr)) === 42);

/* Node-API specific tests */
check(/* await */(napi_li_std_pair.product1([5, 401])) === 2005);
check(/* await */(napi_li_std_pair.product2([5, 401])) === 2005);
check(/* await */(napi_li_std_pair.product3([401, 5])) === 2005);

var p1 = /* await */(napi_li_std_pair.return_pair_in_arg_ref());
check(p1[0] === 2005);
check(p1[1] === true);

var p2 = /* await */(napi_li_std_pair.return_pair_in_arg_ptr());
check(p2[0] === 2005);
check(p2[1] === false);

var { Integer } = napi_li_std_pair;
{
  const r = /* await */(napi_li_std_pair.return_pair_unique_ptr());
  if (r[0] !== 'answer' || !(r[1] instanceof Integer) || r[1].value !== 42) throw new Error('return_pair_unique_ptr failed');
}

{
  const r = /* await */(napi_li_std_pair.receive_pair_unique_ptr(['answer', new Integer(42)]));
  if (r !== 42) throw new Error('receive_pair_unique_ptr failed');
}
