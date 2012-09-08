// file: runme.js

//Call some templated functions
print(example.maxint(3,7));
print(example.maxdouble(3.14,2.18));

// Create some class

iv = new example.vecint(100);
dv = new example.vecdouble(1000);

for(i=0;i<=100;i++)
      iv.setitem(i,2*i);

for(i=0;i<=1000;i++)
      dv.setitem(i, 1.0/(i+1));

sum = 0;
for(i=0;i<=100;i++)
      sum = sum + iv.getitem(i);

print(sum);

sum = 0.0;
for(i=0;i<=1000;i++)
      sum = sum + dv.getitem(i);
print(sum);

delete iv;
delete dv;

      
