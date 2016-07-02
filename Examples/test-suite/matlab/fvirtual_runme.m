sw = fvirtual.NodeSwitch();
n = fvirtual.Node();
i = sw.addChild(n);

if (i ~= 2)
  error('addChild')
end

