if (li_cwstring.count('ab\0ab\0ab\0', 0) ~= 3)
    error    
end

if (~strcmp(li_cwstring.test1(),'Hello World'))
    error
end

if (~strcmp(li_cwstring.test2(),' !\'#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'))
    error
end

if (~strcmp(li_cwstring.test3('hello'),'hello-suffix'))
    error
end

if (~strcmp(li_cwstring.test4('hello'),'hello-suffix'))
    error
end
    
if (~strcmp(li_cwstring.test5(4),'xxxx'))
    error
end

if (~strcmp(li_cwstring.test6(10),'xxxxx'))
    error
end
    
if (~strcmp(li_cwstring.test7(),'Hello world!'))
    error
end

if (~strcmp(li_cwstring.test8(),' !\'#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'))
    error
end

