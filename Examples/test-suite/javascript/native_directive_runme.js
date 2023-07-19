var native_directive = require("native_directive");

/* await */((/* async */ function main() {
  var s = "abc.DEF-123";
  if (/* await */(native_directive.CountAlphas(s)) !== 6)
    throw "CountAlphas failed";
  if (/* await */(native_directive./* async */CountAlphaCharacters(s)) !== 6)
    throw "CountAlphaCharacters failed";
})());
