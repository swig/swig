classdef MatlabDirector < matlab_director.Callback
  properties
    mode = 0;
  end
  methods
    function self = MatlabDirector()
      self@matlab_director.Callback();
    end
    function [result, extra] = split(self, value)
      result = value + 20;
      extra = value + 30;
    end
    function result = value(self, value)
      if self.mode == 1
        result = 'invalid integer';
      elseif self.mode == 2
        error('Callback:Failure', 'callback failed');
      else
        result = value + 10;
      end
    end
  end
end
