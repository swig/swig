
// This test works only with NAPI in async mode
const napi_async_reject = require('napi_async_reject');
const notRej = Symbol();

function isRejected(promise) {
  if (!promise instanceof Promise) throw new Error('Expected a Promise');
  return promise
  .then(() => {
    throw notRej;
  })
  .catch((e) => {
    if (e === notRej) throw new Error('Promise resolved');
    return e;
  })
}

if (/* await */(napi_async_reject.fnAsync(1)) !== 2)
  throw new Error;
if (napi_async_reject.fnSync(1) !== 2)
  throw new Error;

let fail = false;
try {
  napi_async_reject.fnSync(-1);
  fail = true;
} catch (e) {
  if (!e.message.match('must be positive')) throw e;
}
if (fail) throw new Error('Did not throw');

// Async functions must return a rejected Promise instead of a synchronous throw
const rej = /* await */(isRejected(napi_async_reject.fnAsync(-1)));
if (!rej.message.match('must be positive')) throw new Error(rej);

