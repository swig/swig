director_char_array

function self=Director()
  global director_char_array;
  self=subclass(director_char_array.CharArrayDirector());
  self.take_array=@Director_take;
  self.take_const_array=@Director_take;
  self.take_array_ref=@Director_take;
  self.take_const_array_ref=@Director_take;
  self.is_null_array=@Director_is_null_array;
end
function ret=Director_take(self, s)
  ret = length(s);
end
% Octave has no null string, NULL gives an empty string
function ret=Director_is_null_array(self, s)
  ret = isempty(s);
end

d = Director();
if (d.call_take_array() != 4)
  error("take_array");
end
if (d.call_take_const_array() != 4)
  error("take_const_array");
end
if (d.call_take_array_ref() != 4)
  error("take_array_ref");
end
if (d.call_take_const_array_ref() != 4)
  error("take_const_array_ref");
end
if (d.call_take_array_short() != 2)
  error("take_array short");
end
if (d.call_take_array_ref_short() != 2)
  error("take_array_ref short");
end
if (d.call_is_null_array() != 1)
  error("is_null_array");
end
