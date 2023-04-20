% test octaves concatenation operator
function ret=horzcat(varargin)
  % return the concatenation of several ComplexVal values as a cell array.
  % (not really useful but it tests the concatenation of swig_ref objects)
  ret={};
  for i=1:length(varargin)
    ret{i}=varargin{i};
  end
end
