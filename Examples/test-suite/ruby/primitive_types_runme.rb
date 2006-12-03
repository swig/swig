require 'primitive_types'

include Primitive_types


raise RuntimeError if val_uchar(255) != 255

fail = 0
begin
  val_uchar(-1)
rescue RangeError
  fail = 1
end

fail = 0
begin
  val_uchar(256)
rescue RangeError
  fail = 1
end

raise RuntimeError if fail != 1

fail = 0
begin
  val_uchar(256.0)
rescue TypeError
  fail = 1
end

raise RuntimeError if fail != 1

fail = 0
begin
  val_uchar("caca")
rescue TypeError
  fail = 1
end

raise RuntimeError if fail != 1


raise RuntimeError if val_double_2(1.0) != 4.0
raise RuntimeError if val_double_2(1) != 4
raise RuntimeError if val_double_2(1,1) != 2

fail = 0
begin
  val_double_2("1.0",1.0)
rescue 
  fail = 1
end
raise RuntimeError if fail != 1


fail = 0
begin
  val_double_2(1.0,"1.0")
rescue 
  fail = 1
end
raise RuntimeError if fail != 1


raise RuntimeError if val_float_2(1.0) != 4.0
raise RuntimeError if val_float_2(1) != 4
raise RuntimeError if val_float_2(1,1) != 2

fail = 0
begin
  val_float_2("1.0",1.0)
rescue 
  fail = 1
end
raise RuntimeError if fail != 1


fail = 0
begin
  val_float_2(1.0,"1.0")
rescue 
  fail = 1
end
raise RuntimeError if fail != 1
