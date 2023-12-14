var template_default_cache = require("template_default_cache");

var ap = /* await */(template_default_cache.get_mp_a());
var bp = /* await */(template_default_cache.get_mp_b());

if (!ap instanceof template_default_cache.AModelPtr) {
    throw new Error("get_mp_a fail");
}
if (!bp instanceof template_default_cache.BModelPtr) {
    throw new Error("get_mp_b fail");
}
