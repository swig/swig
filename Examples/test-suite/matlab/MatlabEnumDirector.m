classdef MatlabEnumDirector < cpp11_matlab_enum_widths.EnumCallback
  properties
    invalid = false;
  end
  methods
    function self = MatlabEnumDirector()
      self@cpp11_matlab_enum_widths.EnumCallback();
    end
    function result = signed_value(self, value)
      if self.invalid
        result = intmax('uint64');
      else
        result = value;
      end
    end
    function result = unsigned_value(self, value)
      if self.invalid
        result = int64(-1);
      else
        result = value;
      end
    end
  end
end
