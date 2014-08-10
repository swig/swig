import array_member.*

f = Foo();
f.data = global_data();

for i=0:7,
    if (get_value(f.data,i) ~= get_value(global_data,i))
      error('Bad array assignment');
    end
end

for i=0:7,
    set_value(f.data,i,-i);
end

global_data = f.data;

for i=0:7,
  if (get_value(f.data,i) ~= get_value(global_data,i))
    error('Bad array assignment')
  end
end



