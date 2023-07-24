// This test works only with NAPI in async mode
var napi_async_locking = require('napi_async_locking');

// This tests locking
var a = new napi_async_locking.Integer(42);
var b = new napi_async_locking.Integer(9000);

var q = [];
for (let i = 0; i < 1e4; i++) {
  // Test the deadlock prevention too
  q.push(a.compute(b));
  q.push(b.compute(a));

  // Test the recursive lock avoidance
  q.push(a.compute(a));
}

await Promise.all(q);

if (a.val !== 42) throw new Error('Locking failed, obtained ' + a.val);

// This tests the test (ie w/o locking it should fail)
var a = new napi_async_locking.UnlockedInteger(42);
var b = new napi_async_locking.UnlockedInteger(9000);

var q = [];
for (let i = 0; i < 1e4; i++) {
  q.push(a.compute(b));
  q.push(b.compute(a));
  q.push(a.compute(a));
}

await Promise.all(q);

if (a.val === 42) throw new Error('Locking should have failed, obtained ' + a.val);
