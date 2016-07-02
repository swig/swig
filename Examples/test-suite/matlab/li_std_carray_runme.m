v3 = li_std_carray.Vector3();
for i=0:len(v3),
    v3(i) = i;
end

i = 0;
for d in v3,
  if (d ~= i)
    error
  end
  i = i + 1;
end


m3 = li_std_carray.Matrix3();

for i=0:len(m3),
  v3 = m3(i);
  for j=0:len(v3),
    v3(j) = i + j;
  end
end

i = 0;
for v3 in m3,
  j = 0;
  for d in v3,
    if (d ~= i + j)
      error
    end
    j = j + 1;
  end
  i = i + 1
end

for i=0:len(m3),
  for j=0:len(m3),
    if (m3(i,j) ~= i + j)
      error
    end
  end
end

da = li_std_carray.Vector3([1,2,3]);
ma = li_std_carray.Matrix3({[1,2,3],[4,5,6],[7,8,9]});




