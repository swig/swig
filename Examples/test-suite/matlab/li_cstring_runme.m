import li_cstring.*


if (count('ab\0ab\0ab\0', 0) ~= 3)
    error    
end

if (~strcmp(test1(),'Hello World'))
    error
end

if (~strcmp(test2(),' !\'#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'))
    error
end

if (~strcmp(test3('hello'),'hello-suffix'))
    error(test3('hello'))
end

if (~strcmp(test4('hello'),'hello-suffix'))
    error(test4('hello'))
end
    
if (~strcmp(test5(4),'xxxx'))
    error
end

if (~strcmp(test6(10),'xxxxx'))
    error
end
    
if (~strcmp(test7(),'Hello world!'))
    error
end

if (~strcmp(test8(),' !\'#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'))
    error
end

