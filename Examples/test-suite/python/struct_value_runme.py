import struct_value

b = struct_value.Bar()

b.a.x = 3
if b.a.x != 3: raise RuntimeError

b.b.x = 3
if b.b.x != 3: raise RuntimeError
