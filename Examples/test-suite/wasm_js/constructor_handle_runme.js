const assert = require('assert');
require('./constructor_handle_wrap.js')().then((m) => {
  const explicit = new m.HandleConsumer({value: 7}, 3);
  const implicit = new m.HandleConsumer({value: 7});
  assert.strictEqual(explicit.result, 21);
  assert.strictEqual(implicit.result, 14);
  explicit.delete();
  implicit.delete();
}).catch((error) => { console.error(error); process.exitCode = 1; });
