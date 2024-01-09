
// This test works only with NAPI in async mode
const napi_async_overloading = require('napi_async_overloading');

if (/* await */(napi_async_overloading.global_overload_1Async('test')) !== 'test')
  throw new Error;
if (napi_async_overloading.global_overload_1Sync('test') !== 'test')
  throw new Error;

if (/* await */(napi_async_overloading.global_overload_2Async(10)) !== 12)
  throw new Error;
if (napi_async_overloading.global_overload_2(10) !== 12)
  throw new Error;



const obj = new napi_async_overloading.Klass;

if (/* await */(obj.overload_1Async('test')) !== 'test')
  throw new Error;
if (obj.overload_1Sync('test') !== 'test')
  throw new Error;

if (/* await */(obj.overload_2Async(10)) !== 12)
  throw new Error;
if (obj.overload_2(10) !== 12)
  throw new Error;
