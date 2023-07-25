// This test works only with NAPI in async mode
var napi_async_locking = require('napi_async_locking');

async function test(ctor, mix) {
  // This tests locking
  var a = new ctor(42);
  var b = new ctor(9000);

  var q = [];
  for (let i = 0; i < 1e4; i++) {
    // Test the deadlock prevention too
    q.push(a.computeAsync(b));
    q.push(b.computeAsync(a));

    // Test the recursive lock avoidance
    q.push(a.computeAsync(a));
  }

  // Test mixing sync and async
  if (mix) {
    for (let i = 0; i < 1e4; i++) {
      a.computeSync(b);
      b.computeSync(a);
    }
  }

  await Promise.all(q);

  return a.val;
}

var result;
result = await test(napi_async_locking.Integer);
if (result !== 42)
  throw new Error('Locking w/o sync mixing failed, obtained ' + result);

result = await test(napi_async_locking.Integer, true);
if (result !== 42)
  throw new Error('Locking w/ sync mixing failed, obtained ' + result);

result = await test(napi_async_locking.UnlockedInteger);
if (result === 42)
  throw new Error('Locking w/o sync mixing should have failed, obtained ' + result);

result = await test(napi_async_locking.UnlockedInteger, true);
if (result === 42)
  throw new Error('Locking w/ sync mixing should have failed, obtained ' + result);
