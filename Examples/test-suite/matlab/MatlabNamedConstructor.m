classdef MatlabNamedConstructor < matlab_director.NamedConstructor
  methods
    function self = MatlabNamedConstructor(varargin)
      self@matlab_director.NamedConstructor(varargin{:});
    end
    function result = method(self)
      result = 19;
    end
  end
end
