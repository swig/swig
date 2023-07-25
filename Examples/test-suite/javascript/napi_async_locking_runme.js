// This test works only with NAPI in async mode
var napi_async_locking = require('napi_async_locking');

async function test(async, sync) {
  // This tests locking
  var a = new napi_async_locking.Integer(42);
  var b = new napi_async_locking.Integer(9000);

  var q = [];
  for (let i = 0; i < 1e4; i++) {
    // Test the deadlock prevention too
    q.push(async.call(a, b));
    q.push(async.call(b, a));

    // Test the recursive lock avoidance
    q.push(async.call(a, a));
  }

  // Test mixing sync and async
  if (sync) {
    for (let i = 0; i < 1e4; i++) {
      sync.call(a, b);
      sync.call(b, a);
    }
  }

  await Promise.all(q);

  return a.val;
}

var result;
const Klass = napi_async_locking.Integer.prototype;

// Test async locking
result = await test(Klass.computeAsync);
if (result !== 42)
  throw new Error('Locking w/o sync mixing failed, obtained ' + result);

// Test locking when mixing sync and async
result = await test(Klass.computeAsync, Klass.computeSync);
if (result !== 42)
  throw new Error('Locking w/ sync mixing failed, obtained ' + result);

// Test validity of the first test (ie without locking it fails)
result = await test(Klass.computeUnlockedAsync);
if (result === 42)
  throw new Error('Locking w/o sync mixing should have failed, obtained ' + result);

// Test validity of the second test (if omitting locking of only the sync access, it still fails)
result = await test(Klass.computeAsync, Klass.computeUnlockedSync);
if (result === 42)
  throw new Error('Locking w/ sync mixing should have failed, obtained ' + result);
