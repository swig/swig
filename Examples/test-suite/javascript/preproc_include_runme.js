var preproc_include = require("preproc_include");

if (preproc_include.multiply10(10) != 100)
  throw "RuntimeError";

if (preproc_include.multiply20(10) != 200)
  throw "RuntimeError";

if (preproc_include.multiply30(10) != 300)
  throw "RuntimeError";

if (preproc_include.multiply40(10) != 400)
  throw "RuntimeError";

if (preproc_include.multiply50(10) != 500)
  throw "RuntimeError";
