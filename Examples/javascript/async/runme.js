var example = require("example");

const pi = new example.Pi(1e6);

// Call the sync method
console.log('sync method  (us) Pi=', pi.approxSync(), '(them) Pi=', Math.PI);

// Call the async method
pi.approxAsync()
  .then((pi) => console.log('async method (us) Pi=', pi, '(them) Pi=', Math.PI));

// Call the global sync function
var result = example.calcSync(pi);
console.log('global sync function (us) Pi=', result, '(them) result=', Math.PI);

// Call the global async function
example.calcAsync(pi)
        .then((r) => console.log('global async function (us) result=', r, '(them) Pi=', Math.PI));

// Call the handwritten %native async wrapper
example.piAsync(pi)
  .then((pi) => console.log('handwritten async function (us) Pi=', pi, '(them) Pi=', Math.PI));
