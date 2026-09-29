const assert = require('assert');
require('./typemap_cleanup_wrap.js')().then((m) => {
  function check(action, releases) {
    const before = m.released_resources();
    action();
    assert.strictEqual(m.live_resources(), 0);
    assert.strictEqual(m.released_resources() - before, releases);
  }
  for (let i = 0; i < 20; ++i) {
    check(() => assert.strictEqual(m.consume(2, 3), 5), 2);
    check(() => assert.throws(() => m.consume(-1, 3)), 1);
    check(() => assert.throws(() => m.consume(2, -1)), 2);
    check(() => assert.throws(() => m.consume(2, 3, true)), 2);
    check(() => assert.throws(() => m.fail_output(2, 3)), 2);
  }
}).catch((error) => { console.error(error); process.exitCode = 1; });
