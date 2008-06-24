# file: runme.m

example

# Call some templated functions
example.maxint(3,7)
example.maxdouble(3.14,2.18)

# Create some class

iv = example.vecint(100)
dv = example.vecdouble(1000)

for i=0:99,
  iv.setitem(i,2*i);
end

for i=0:999,
  dv.setitem(i, 1.0/(i+1));
end;

sum = 0;
for i=0:99
      sum = sum + iv.getitem(i);
end
sum

sum = 0.0;
for i=0:999,
      sum = sum + dv.getitem(i);
end
sum

clear iv
clear dv

      
