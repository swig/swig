import preproc.*

if (preproc.cvar.end ~= 1)
  error
end

if (preproc.cvar.define ~= 1)
  error
end

if (preproc.cvar.defined ~= 1)
  error
end

if (2*preproc.one ~= preproc.two)
  error
end

