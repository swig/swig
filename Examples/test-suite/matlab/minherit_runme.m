import minherit.*

a = minherit.Foo();
b = minherit.Bar();
c = minherit.FooBar();
d = minherit.Spam();

if (a.xget() ~= 1)
    error('Bad attribute value')
end

if (b.yget() ~= 2)
    error('Bad attribute value')
end

if (c.xget() ~= 1 || c.yget() ~= 2 || c.zget() ~= 3)
    error('Bad attribute value')
end

if (d.xget() ~= 1 || d.yget() ~= 2 || d.zget() ~= 3 || d.wget() ~= 4)
    error('Bad attribute value')
end


if (minherit.xget(a) ~= 1)
    error('Bad attribute value %d',minherit.xget(a))
end

if (minherit.yget(b) ~= 2)
    error('Bad attribute value %d',minherit.yget(b))
end

if (minherit.xget(c) ~= 1 || minherit.yget(c) ~= 2 || minherit.zget(c) ~= 3)
    error('Bad attribute value %d %d %d',minherit.xget(c),minherit.yget(c),minherit.zget(c))
end

if (minherit.xget(d) ~= 1 || minherit.yget(d) ~= 2 || minherit.zget(d) ~= 3 || minherit.wget(d) ~= 4)
    error('Bad attribute value %d %d %d %d',minherit.xget(d),minherit.yget(d),minherit.zget(d),minherit.wget(d))
end

% Cleanse all of the pointers and see what happens

aa = minherit.toFooPtr(a);
bb = minherit.toBarPtr(b);
cc = minherit.toFooBarPtr(c);
dd = minherit.toSpamPtr(d);

if (aa.xget() ~= 1)
    error('Bad attribute value');
end

if (bb.yget() ~= 2)
    error('Bad attribute value');
end

if (cc.xget() ~= 1 || cc.yget() ~= 2 || cc.zget() ~= 3)
    error('Bad attribute value')
end

if (dd.xget() ~= 1 || dd.yget() ~= 2 || dd.zget() ~= 3 || dd.wget() ~= 4)
    error('Bad attribute value')
end

if (minherit.xget(aa) ~= 1)
    error('Bad attribute value %d',minherit.xget(aa));
end

if (minherit.yget(bb) ~= 2)
    error('Bad attribute value %d',minherit.yget(bb));
end

if (minherit.xget(cc) ~= 1 || minherit.yget(cc) ~= 2 || minherit.zget(cc) ~= 3)
    error('Bad attribute value %d %d %d',minherit.xget(cc),minherit.yget(cc),minherit.zget(cc));
end

if (minherit.xget(dd) ~= 1 || minherit.yget(dd) ~= 2 || minherit.zget(dd) ~= 3 || minherit.wget(dd) ~= 4)
    error('Bad attribute value %d %d %d %d',minherit.xget(dd),minherit.yget(dd),minherit.zget(dd),minherit.wget(dd))
end








