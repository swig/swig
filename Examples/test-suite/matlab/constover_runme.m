import constover.*

p = constover.test('test');
if (~strcmp(p,'test'))
    error('test failed~')
end

p = constover.test_pconst('test');
if (~strcmp(p,'test_pconst'))
    error('test_pconst failed~')
end
    
f = constover.Foo();
p = f.test('test');
if (~strcmp(p,'test'))
    error('member-test failed~')
end

p = f.test_pconst('test');
if (~strcmp(p,'test_pconst'))
    error('member-test_pconst failed~')
end

p = f.test_constm('test');
if (~strcmp(p,'test_constmethod'))
    error('member-test_constm failed~')
end

p = f.test_pconstm('test');
if (~strcmp(p,'test_pconstmethod'))
    error('member-test_pconstm failed~')
end


