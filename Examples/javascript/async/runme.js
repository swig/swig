var example = require("example");

const pi = new example.Pi(1e6);

console.log('(us) Pi=', pi.approxSync(), '(them) Pi=', Math.PI);

pi.approxAsync()
  .then((pi) => console.log('(us) Pi=', pi, '(them) Pi=', Math.PI));

var result = example.calcFromPtrSync(pi);
console.log('(us) Pi=', result, '(them) Pi=', Math.PI);

example.calcFromPtrAsync(pi)
  .then((r) => console.log('(us) Pi=', r, '(them) Pi=', Math.PI));

result = example.calcFromRefSync(pi);
console.log('(us) Pi=', result, '(them) Pi=', Math.PI);

example.calcFromRefAsync(pi)
  .then((r) => console.log('(us) Pi=', r, '(them) Pi=', Math.PI));
