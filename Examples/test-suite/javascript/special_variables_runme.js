var special_variables = require("special_variables");

const r = /* await */(special_variables.ExceptionVars(1.0, 2.0));
if (!r.endsWith('Space::exceptionvars  ExceptionVars   _wrap_ExceptionVars  '))
  throw new Error(`received "${r}"`);
