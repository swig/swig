const napi_callback = require('napi_callback');

/**
 * Sync callback
 */
{
  // Nominal
  const r1 = /* await */(napi_callback.GiveMeFive((pass, name) => {
    if (pass !== 420) throw new Error('expected 420 as pass');
    if (typeof name !== 'string') throw new Error('expected a string as name');
    return 'sent from JS ' + name;
  }));
  if (r1 !== 'received from JS: sent from JS with cheese')
    throw new Error(`not the expected value, received "${r1}"`);

  const r2 = /* await */(napi_callback.GiveMeFive_C((pass, name) => {
    if (pass !== 420) throw new Error('expected 420 as pass');
    if (typeof name !== 'string') throw new Error('expected a string as name');
    return 'sent from JS ' + name;
  }));
  if (r2 !== 'received from JS: sent from JS with extra cheese')
    throw new Error(`not the expected value, received "${r2}"`);

  const values = [];
  const repeat = /* await */(napi_callback.GiveMeFiveRepeats((i, s) => {
    values.push(i);
    if (typeof s !== 'string') throw new Error('expected a string as name');
    return '!' + s;
  }));
  if (JSON.stringify(values.sort()) !== '[0,1,2,3,4,5,6,7,8,9]')
    throw new Error(`not the expected value, result is ${values}`);
  if (repeat !== '!.!.!.!.!.!.!.!.!.!.')
    throw new Error(`not the expected value, received "${repeat}"`);

  let called = false;
  /* await */(napi_callback.JustCall(() => {
    called = true;
  }));
  if (!called)
    throw new Error('did not call');

  // Exception
  let first = false;
  try {
    /* await */(napi_callback.GiveMeFive(() => {
      throw new Error('First');
  }));
  } catch (e) {
    if (e.message.match(/First/))
      first = true;
  }
  if (!first) throw new Error('First exception not correctly propagated');

  let second = false;
  try {
    /* await */(napi_callback.GiveMeFive_C(() => {
      throw new Error('Second');
  }));
  } catch (e) {
    if (e.message.match(/Second/))
      second = true;
  }
  if (!second) throw new Error('Second exception not correctly propagated');

  let third = false;
  try {
    /* await */(napi_callback.JustCall(() => {
      throw new Error('Third');
    }));
  } catch (e) {
    if (e.message.match(/Third/))
      third = true;
  }
  if (!third) throw new Error('Third exception not correctly propagated');
}

/**
 * Async callback (only in async mode)
 */
{
  // Nominal
  const r1 = /* await */(napi_callback.GiveMeFive(/* async */(pass, name) => {
    if (pass !== 420) throw new Error('expected 420 as pass');
    if (typeof name !== 'string') throw new Error('expected a string as name');
    return 'sent from JS ' + name;
  }));
  if (r1 !== 'received from JS: sent from JS with cheese')
    throw new Error(`not the expected value, received "${r1}"`);

  const r2 = /* await */(napi_callback.GiveMeFive_C(/* async */(pass, name) => {
    if (pass !== 420) throw new Error('expected 420 as pass');
    if (typeof name !== 'string') throw new Error('expected a string as name');
    return 'sent from JS ' + name;
  }));
  if (r2 !== 'received from JS: sent from JS with extra cheese')
    throw new Error(`not the expected value, received "${r2}"`);

  try {
    const values = [];
    const repeat = /* await */(napi_callback.GiveMeFiveRepeats((i, s) => {
      values.push(i);
      if (typeof s !== 'string') throw new Error('expected a string as name');
      return new Promise(res => setTimeout(res, 100)).then(() => '!' + s);
    }));
    if (JSON.stringify(values.sort()) !== '[0,1,2,3,4,5,6,7,8,9]')
      throw new Error(`not the expected value, result is ${values}`);
    if (repeat !== '!.!.!.!.!.!.!.!.!.!.')
      throw new Error(`not the expected value, received "${repeat}"`);
  } catch(e) {
    if (!(e.message.match(/Can't resolve a Promise when called synchronously/) ||
        e.message.match(/No multithreading support/)))
      throw new Error(`Unexpected exception ${e.message}`);
  }

  let called = false;
  /* await */(napi_callback.JustCall(/* async */() => {
    called = true;
  }));
  if (!called)
    throw new Error('did not call');

  // Exception
  let first = false;
  try {
    /* await */(napi_callback.GiveMeFive(/* async */() => {
      throw new Error('First');
    }));
  } catch (e) {
    if (e.message.match(/First/))
      first = true;
  }
  if (!first) throw new Error('First exception not correctly propagated');

  let second = false;
  try {
    /* await */(napi_callback.GiveMeFive_C(/* async */() => {
      throw new Error('Second');
    }));
  } catch (e) {
    if (e.message.match(/Second/))
      second = true;
  }
  if (!second) throw new Error('Second exception not correctly propagated');

  let third = false;
  try {
    /* await */(napi_callback.JustCall(/* async */() => {
      throw new Error('Third');
    }));
  } catch (e) {
    if (e.message.match(/Third/))
      third = true;
  }
  if (!third) throw new Error('Third exception not correctly propagated');
}
