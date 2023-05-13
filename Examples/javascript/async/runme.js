var example = require("example");

const pi = new example.Pi(1e6);

console.log('(us) Pi=', pi.approxSync(), '(them) Pi=', Math.PI);

pi.approxAsync()
  .then((pi) => console.log('(us) Pi=', pi, '(them) Pi=', Math.PI));
