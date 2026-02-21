require("import") -- the import fn
import("director_alternating") -- import lib

assert(director_alternating.getBar():id() == director_alternating.idFromGetBar())
