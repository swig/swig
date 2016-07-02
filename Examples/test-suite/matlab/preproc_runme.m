if (preproc.endif ~= 1)
  error('failed')
end

if (preproc.define ~= 1)
  error('failed')
end

if (preproc.defined ~= 1)
  error('failed')
end

if (2*preproc.one ~= preproc.two)
  error('failed')
end

