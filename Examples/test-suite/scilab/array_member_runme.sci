exec("swigtest.start", -1);

f = new_Foo();
Foo_data_set(f, [0:7]);
if ~isequal(Foo_data_get(f), [0:7]) then swigtesterror(); end

Foo_text_set(f, 'abcdefgh');
if ~isequal(Foo_text_get(f), 'abcdefgh') then swigtesterror(); end
delete_Foo(f);

m = new_MyBuff();
MyBuff_x_set(m, uint8([0:11]));
if ~isequal(MyBuff_x_get(m), uint8([0:11])) then swigtesterror(); end
delete_MyBuff(m);

exec("swigtest.quit", -1);
