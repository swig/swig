import enum_template.*

if (enum_template.MakeETest() ~= 1)
  error
end

enum_template.TakeETest(0);
try
  a=enum_template.TakeETest(0);
  error
catch
end
  
