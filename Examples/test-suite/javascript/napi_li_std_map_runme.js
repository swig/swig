var napi_li_std_map = require('napi_li_std_map');

// This tests the generic STL conversion typemaps that work only with Node-API

{
  const r = /* await */(napi_li_std_map.valueAverage({ a: 5, b: 10, c: 3 }));
  if (r !== 6) throw new Error('valueAverage failed');
}

{
  const r = /* await */(napi_li_std_map.stringifyKeys({ a: 5, b: 10, c: 3 }));
  if (r !== ' a b c') throw new Error('stringifyKeys failed');
}

{
  const r = /* await */(napi_li_std_map.populate());
  if (r.a !== 1 || r.zzz !== 3) throw new Error('populate failed');
}

{
  const r = /* await */(napi_li_std_map.return_map());
  if (r.a !== true || r.b !== false) throw new Error('return_map failed');
}

{
  const r = /* await */(napi_li_std_map.return_map_map());
  if (r.map.a !== true || r.map.b !== false) throw new Error('return_map_map failed');
}
