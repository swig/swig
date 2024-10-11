var keyword_rename = require("keyword_rename");
/* await */(keyword_rename._instanceof(1));
/* await */(keyword_rename._finally(1));
/* await */(keyword_rename._yield(0));

var s = new keyword_rename.S;

if (s.yield !== 0)
  throw new Error;

// @ts-expect-error
if (s._yield === 17)
  throw new Error;

// @ts-expect-error
if (typeof s._yield === 'number') throw new Error('S._yield included');
if (typeof s.yield !== 'number') throw new Error('S.yield not included');
