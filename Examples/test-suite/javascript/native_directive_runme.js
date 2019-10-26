var native_directive = require("native_directive");

(function main() {
  var s = "abc.DEF-123";
  if (native_directive.CountAlphas(s) !== 6)
    throw "CountAlphas failed";
  if (native_directive.CountAlphaCharacters(s) !== 6)
    throw "CountAlphaCharacters failed";
})();
