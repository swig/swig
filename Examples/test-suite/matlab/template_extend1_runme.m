import template_extend1.*

a = template_extend1.lBaz();
b = template_extend1.dBaz();

if (~strcmp(a.foo(),'lBaz::foo'))
    error
end

if (~strcmp(b.foo(),'dBaz::foo'))
    error
end
