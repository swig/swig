import contract.*

contract.test_preassert(1,2);
try
	contract.test_preassert(-1,0)
	error('Failed~ Preassertions are broken')
catch
end

contract.test_postassert(3);
try
	contract.test_postassert(-3);
	error('Failed~ Postassertions are broken')
catch
end

contract.test_prepost(2,3);
contract.test_prepost(5,-4);
try
	contract.test_prepost(-3,4);
	error('Failed~ Preassertions are broken')
catch
end

try
	contract.test_prepost(4,-10);
	error('Failed~ Postassertions are broken')

catch
end

f = contract.Foo();
f.test_preassert(4,5);
try
	f.test_preassert(-2,3);
	error('Failed~ Method preassertion.')
catch
end

f.test_postassert(4);
try
	f.test_postassert(-4);
	error('Failed~ Method postassertion')
catch
end

f.test_prepost(3,4);
f.test_prepost(4,-3);
try
	f.test_prepost(-4,2);
	error('Failed~ Method preassertion.')
catch
end

try
	f.test_prepost(4,-10);
	error('Failed~ Method postassertion.')
catch
end

contract.Foo_stest_prepost(4,0);
try
	contract.Foo_stest_prepost(-4,2);
	error('Failed~ Static method preassertion')
catch
end

try
	contract.Foo_stest_prepost(4,-10);
	error('Failed~ Static method posteassertion')
catch
end
	
b = contract.Bar();
try
	b.test_prepost(2,-4);
	error('Failed~ Inherited preassertion.')
catch
end


d = contract.D();
try
	d.foo(-1,1,1,1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.foo(1,-1,1,1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.foo(1,1,-1,1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.foo(1,1,1,-1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.foo(1,1,1,1,-1);
	error('Failed~ Inherited preassertion (D).')
catch
end


try
	d.bar(-1,1,1,1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.bar(1,-1,1,1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.bar(1,1,-1,1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.bar(1,1,1,-1,1);
	error('Failed~ Inherited preassertion (D).')
catch
end
try
	d.bar(1,1,1,1,-1);
	error('Failed~ Inherited preassertion (D).')
catch
end

