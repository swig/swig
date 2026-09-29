const assert = require('assert');
require('./stl_typemaps_wrap.js')().then((m) => {
  assert.deepStrictEqual(m.custom_values({items: [1, 2]}), {items: [1, 2, 7]});
  assert.deepStrictEqual(m.ordinary_values([1, 2]), [1, 2]);
  assert.throws(() => m.custom_values([1, 2]));
  assert.throws(() => m.custom_values({items: ['wrong']}));
  const proxy = new m.IntVector();
  proxy.push_back(3);
  assert.deepStrictEqual(m.ordinary_values(proxy), [3]);
  proxy.delete();
}).catch((error) => { console.error(error); process.exitCode = 1; });
