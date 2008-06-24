struct_value

b = struct_value.Bar();

b.a.x = 3;
if (b.a.x != 3)
  error
endif

b.b.x = 3;
if (b.b.x != 3)
  error
endif
