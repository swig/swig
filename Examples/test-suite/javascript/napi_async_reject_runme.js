
// This test works only with NAPI in async mode
const napi_async_reject = require('napi_async_reject');
const notRej = Symbol();

function isRejected(promise) {
  if (!(promise instanceof Promise)) throw new Error('Expected a Promise');
  return promise
    .then(() => {
      throw notRej;
    })
    .catch((e) => {
      if (e === notRej) throw new Error('Promise resolved');
      return e;
    });
}

const counter = new napi_async_reject.FreeCounter;

counter.reset();
if (/* await */(napi_async_reject.fnAsync(1, counter)) !== 2)
  throw new Error;
if (counter.freearg_calls !== 1)
  throw new Error(`freeargs_calls = ${counter.freearg_calls}`);

counter.reset();
if (napi_async_reject.fnSync(1, counter) !== 2)
  throw new Error;
if (counter.freearg_calls !== 1)
  throw new Error(`freeargs_calls = ${counter.freearg_calls}`);

let fail = false;
counter.reset();
try {
  napi_async_reject.fnSync(-1, counter);
  fail = true;
} catch (e) {
  if (!e.message.match('must be positive')) throw e;
}
if (fail) throw new Error('Did not throw');
if (counter.freearg_calls !== 1)
  throw new Error(`freeargs_calls = ${counter.freearg_calls}`);

counter.reset();
// Async functions must return a rejected Promise instead of a synchronous throw
const rej = /* await */(isRejected(napi_async_reject.fnAsync(-1, counter)));
if (!rej.message.match('must be positive')) throw new Error(rej);
if (counter.freearg_calls !== 1)
  throw new Error(`freeargs_calls = ${counter.freearg_calls}`);


// Synchronous throwing of random objects
try {
  napi_async_reject.throwsSync();
  fail = true;
} catch (e) {
  if (!(e instanceof napi_async_reject.CustomError))
    throw new Error('Error not of the expected type');
  if (e.msg !== 'expected error')
    throw new Error('Unexpected error');
}
if (fail) throw new Error('Did not throw');

// Asynchronous throwing of random objects
/* await */(napi_async_reject.throwsAsync())
  .then(() => {
    fail = true;
  })
  .catch((e) => {
    if (!(e instanceof napi_async_reject.CustomError))
      throw new Error('Error not of the expected type');
    if (e.msg !== 'expected error')
      throw new Error('Unexpected error');
  });
if (fail) throw new Error('Did not throw');
