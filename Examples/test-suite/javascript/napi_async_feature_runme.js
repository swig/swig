// This test works only with NAPI in async mode
const napi_async_feature = require('napi_async_feature');

napi_async_feature.GlobalAsync(2).then((r) => {
  if (r !== 4)
   throw new Error;
});

if (napi_async_feature.GlobalSync(2) !== 4)
  throw new Error;


const obj = new napi_async_feature.Klass;

obj.Method(2).then((r) => {
  if (r !== 6)
    throw new Error;
});

// (obviously TS detects that we are referencing undefined methods)
// @ts-expect-error
if (obj.MethodSync !== undefined || obj.MethodAsync !== undefined)
  throw new Error;
