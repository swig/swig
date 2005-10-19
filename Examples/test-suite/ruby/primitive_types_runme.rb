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
