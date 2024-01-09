const napi_buffer = require('napi_buffer');

// Test producing a Buffer
{
  const buf = /* await */(napi_buffer.return_buffer());
  if (!(buf instanceof Buffer)) throw new Error(`Expected a Buffer, got ${buf}`);

  const uint32 = new Uint32Array(buf.buffer, buf.byteOffset);
  if (uint32[0] !== 17) throw new Error(`Expected 17, got ${uint32[0]}`);
}

// Test producing an ArrayBuffer
{
  const ab = /* await */(napi_buffer.return_arraybuffer());
  if (!(ab instanceof ArrayBuffer)) throw new Error(`Expected an ArrayBuffer, got ${ab}`);
  const uint32 = new Uint32Array(ab);
  if (uint32[0] !== 17) throw new Error(`Expected 17, got ${uint32[0]}`);
}

// Test consuming a Buffer
/* await */(napi_buffer.consume_buffer(Buffer.from(new Uint32Array([42]).buffer)));

// Test consuming an ArrayBuffer
{
  const ab = new ArrayBuffer(4);
  const ab32 = new Uint32Array(ab);
  ab32[0] = 42;
/* await */(napi_buffer.consume_arraybuffer(ab));
}
