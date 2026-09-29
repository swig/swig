const assert = require('assert');
require('./stl_legacy_vector_wrap.js')().then((m) => {
  assert.deepStrictEqual(m.echo([1, 2]), [1, 2]);
  assert.deepStrictEqual(m.echo_ref([3, 4]), [3, 4]);
  const handles = m.handle_count();
  for (let i = 0; i < 20; ++i) {
    assert.deepStrictEqual(m.echo([i, 2]), [i, 2]);
    assert.throws(() => m.echo([1, 'wrong']));
    assert.throws(() => m.echo_two([1, 2], [3, 'wrong']));
    assert.deepStrictEqual(m.echo_two([1], [2]), [1, 2]);
    assert.throws(() => m.fail([1, 2]));
  }
  assert.strictEqual(m.handle_count(), handles);
  const originalDelete = m.IntVector.prototype.delete;
  let temporaryDeletes = 0;
  m.IntVector.prototype.delete = function () {
    ++temporaryDeletes;
    return originalDelete.call(this);
  };
  try {
    let reads = 0;
    const changing = [0];
    Object.defineProperty(changing, 0, {get() { return ++reads === 1 ? 3 : 'wrong'; }});
    assert.throws(() => m.echo_two([1, 2], changing));
    assert.strictEqual(temporaryDeletes, 2);
    assert.throws(() => m.fail([1, 2]));
    assert.strictEqual(temporaryDeletes, 3);
    const consumer = new m.VectorConsumer([1, 2]);
    assert.strictEqual(consumer.size(), 2);
    consumer.delete();
    assert.strictEqual(temporaryDeletes, 4);
    assert.throws(() => new m.VectorConsumer([1, 2], true));
    assert.strictEqual(temporaryDeletes, 5);
  } finally {
    m.IntVector.prototype.delete = originalDelete;
  }
  const proxy = new m.IntVector();
  proxy.push_back(3);
  assert.deepStrictEqual(m.echo(proxy), [3]);
  assert.strictEqual(proxy.at(0), 3);
  proxy.delete();
}).catch((error) => { console.error(error); process.exitCode = 1; });
