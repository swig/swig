%module xxx

void climbed(auto x) { }

%template(iclimbed) climbed<int>;
%template(iiclimbed) climbed<int>;
%template(dclimbed) climbed<double>;
