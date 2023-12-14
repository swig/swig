var director_alternating = require("director_alternating");

var bar = /* await */(director_alternating.getBar());
var id = /* await */(bar.id());
if (id != /* await */(director_alternating.idFromGetBar()))
  throw ("Error, Got wrong id: " + id.toString());
