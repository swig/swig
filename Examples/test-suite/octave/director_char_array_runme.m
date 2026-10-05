director_char_array

function self=Director()
  global director_char_array;
  self=subclass(director_char_array.CharArrayDirector());
  self.take_array=@Director_take;
  self.take_const_array=@Director_take;
  self.take_array_ref=@Director_take;
  self.take_const_array_ref=@Director_take;
end
function ret=Director_take(self, s)
  ret = length(s);
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
