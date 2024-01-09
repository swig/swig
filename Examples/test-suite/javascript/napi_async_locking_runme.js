// This test works only with NAPI in async mode
const napi_async_locking = require('napi_async_locking');

async function test(name, fail, async, sync) {
  // This tests locking
  const a = new napi_async_locking.Integer(42);
  const b = new napi_async_locking.Integer(9000);

  const q = [];
  for (let i = 0; i < 1e4; i++) {
    // Test the deadlock prevention too
    q.push(async.call(a, b));
    q.push(async.call(b, a));

    // Test the recursive lock avoidance
    q.push(async.call(a, a));
  }

  try {
    // Test mixing sync and async
    for (let i = 0; i < 1e4; i++) {
      if (sync) sync.call(a, b);
      if (sync) sync.call(b, a);
    }

    await Promise.all(q);

    if (a.val !== 42) throw new Error(`Failed, a.val = ${a.val}`);
  } catch (e) {
    if (fail) return;
    else throw e;
  }

  if (fail) throw new Error(`${name} should have failed`);
}

const Klass = napi_async_locking.Integer.prototype;

// Test async locking
await test('Locking w/o sync mixing', false, Klass.computeAsync, undefined);

// Test locking when mixing sync and async
await test('Locking w/ sync mixing', false, Klass.computeAsync, Klass.computeSync);

// Test validity of the first test (ie without locking it fails)
await test('Locking w/o sync mixing', true, Klass.computeUnlockedAsync, undefined);

// Test validity of the second test (if omitting locking of only the sync access, it still fails)
await test('Locking w/ sync mixing', true, Klass.computeAsync, Klass.computeUnlockedSync);



// Test locking when mixing getter and async
await test('Locking w/ getter mixing', false, Klass.computeAsync, function (b) {
  const val = this.val;
  if (val !== 42 && val !== 9000) throw new Error(`Getter failed, this.val = ${val}`)
});

// Test locking when mixing setter and async
await test('Locking w/ setter mixing', false, Klass.computeAsync, function (b) {
  this.val = 42;
});
