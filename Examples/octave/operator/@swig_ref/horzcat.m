% test octaves concatenation operator
function ret=horzcat(a, b)
  % return the concatenation of two ComplexVal values as a cell array.
  % (not really useful but it tests the concatenation of swig_ref objects)
  ret={a, b};
end
