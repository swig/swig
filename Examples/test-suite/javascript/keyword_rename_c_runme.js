var keyword_rename_c = require("keyword_rename_c");
/* await */(keyword_rename_c._instanceof(1));
/* await */(keyword_rename_c._finally(1));
/* await */(keyword_rename_c._yield(0));
var s = new keyword_rename_c.S;
// @ts-expect-error
if (typeof s._yield === 'number') throw new Error('S._yield included');
if (typeof s.yield !== 'number') throw new Error('S.yield not included');
