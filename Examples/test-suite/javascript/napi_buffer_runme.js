const napi_buffer = require('napi_buffer');

// Test producing a Buffer
{
  const buf = /* await */(napi_buffer.return_buffer());
  if (!(buf instanceof Buffer)) throw new Error(`Expected a Buffer, got ${buf}`);

  const uint32 = new Uint32Array(buf.buffer, buf.byteOffset);
  if (uint32[0] !== 17) throw new Error(`Expected 17, got ${uint32[0]}`);
}

// Test producing a zero-length Buffer
{
  const ab = /* await */(napi_buffer.return_zerolen_buffer());
  if (!(ab instanceof Buffer)) throw new Error(`Expected an Buffer, got ${ab}`);
  const uint32 = new Uint32Array(ab);
  if (uint32.length) throw new Error(`Expected length 0, got ${uint32.length} 0`);
}

// Test producing a null Buffer
{
  const ab = /* await */(napi_buffer.return_null_buffer());
  if (ab !== null) throw new Error(`Expected null, got ${ab}`);
}

// Test producing an ArrayBuffer
{
  const ab = /* await */(napi_buffer.return_arraybuffer());
  if (!(ab instanceof ArrayBuffer)) throw new Error(`Expected an ArrayBuffer, got ${ab}`);
  const uint32 = new Uint32Array(ab);
  if (uint32[0] !== 17) throw new Error(`Expected 17, got ${uint32[0]}`);
}

// Test producing a zero-length ArrayBuffer
{
  const ab = /* await */(napi_buffer.return_zerolen_arraybuffer());
  if (!(ab instanceof ArrayBuffer)) throw new Error(`Expected an ArrayBuffer, got ${ab}`);
  const uint32 = new Uint32Array(ab);
  if (uint32.length) throw new Error(`Expected length 0, got ${uint32.length} 0`);
}

// Test producing a null ArrayBuffer
{
  const ab = /* await */(napi_buffer.return_null_arraybuffer());
  if (ab !== null) throw new Error(`Expected null, got ${ab}`);
}

// Test consuming a Buffer
/* await */(napi_buffer.consume_buffer(Buffer.from(new Uint32Array([42]).buffer)));

// Test consuming a Buffer slice
/* await */(napi_buffer.consume_buffer(Buffer.from(new Uint32Array([893, 42]).buffer).subarray(4, 8)));

// Test consuming an ArrayBuffer
{
  const ab = new ArrayBuffer(4);
  const ab32 = new Uint32Array(ab);
  ab32[0] = 42;
  /* await */(napi_buffer.consume_arraybuffer(ab));
}

// Test filling an existing ArrayBuffer
// This triggers the memory sync problem in WASM
{
  const ab = new ArrayBuffer(32);
  const view8 = new Uint8Array(ab);
  /* await */(napi_buffer.fill_arraybuffer(ab));
  if (view8[14] !== 0x17) throw new Error(`Expected 0x17, got ${view8[14]}`);
}
