//
// Ascetic wrapper that spawns pair of instances of the same script
// as Node.js Workers.
//
if (process.argv.length < 3) {
    console.error("usage: node " + process.argv[1] +
                  " <absolute-or-relative-path-to-a-script>");
    process.exit(1);
}

// Even though 'worker_threads' appeared in Node.js v10.5, they weren't
// available out-of-the-box till v12. For smoother use with 'make test'
// silently ignore prior versions.
if (parseInt(process.versions['node']) < 12) process.exit(0);

const { Worker } = require("worker_threads");
var workers = [];

for (let i = 0; i < 2; i++) {
    workers[i] = new Worker(process.argv[2]);
    workers[i].on('exit', (code) => {
        if (i == 1) {
            try {
                const path = require("path");
                require(path.basename(process.argv[2], "_runme.js"));
                new Worker(process.argv[2]);
            } catch (error) {
                // ignore, the argv[2] knows best...
            }
        }
    });
}
