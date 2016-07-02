if (li_cstring.count('ab\0ab\0ab\0', 0) ~= 3)
    error    
end

if (~strcmp(li_cstring.test1(),'Hello World'))
    error
end

if (~strcmp(li_cstring.test2(),' !\'#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'))
    error
end

if (~strcmp(li_cstring.test3('hello'),'hello-suffix'))
    error(test3('hello'))
end

if (~strcmp(li_cstring.test4('hello'),'hello-suffix'))
    error(li_cstring.test4('hello'))
end
    
if (~strcmp(li_cstring.test5(4),'xxxx'))
    error
end

if (~strcmp(li_cstring.test6(10),'xxxxx'))
    error
end
    
if (~strcmp(li_cstring.test7(),'Hello world!'))
    error
end

if (~strcmp(li_cstring.test8(),' !\'#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'))
    error
end

