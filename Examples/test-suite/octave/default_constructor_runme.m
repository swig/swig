default_constructor

dc = default_constructor;

a = dc.new_A();
dc.delete_A(a);

aa = dc.new_AA();
dc.delete_AA(aa);

try
    b = dc.new_B();
    error("Whoa. new_BB created.")
catch
end_try_catch

del_b = dc.delete_B;

try
    bb = dc.new_BB();
    error("Whoa. new_BB created.")
catch
end_try_catch

del_bb = dc.delete_BB;

try
    c = dc.new_C();
    error("Whoa. new_C created.")
catch
end_try_catch

del_c = dc.delete_C;

cc = dc.new_CC();
dc.delete_CC(cc);

try
    d = dc.new_D();
    error("Whoa. new_D created")
catch
end_try_catch

del_d = dc.delete_D;

try
    dd = dc.new_DD();
    error("Whoa. new_DD created")
catch
end_try_catch

dd = dc.delete_DD;

try
    ad = dc.new_AD();
    error("Whoa. new_AD created")
catch
end_try_catch

del_ad = dc.delete_AD;

e = dc.new_E();
dc.delete_E(e);

ee = dc.new_EE();
dc.delete_EE(ee);

try
    eb = dc.new_EB();
    error("Whoa. new_EB created")
catch
end_try_catch

del_eb = dc.delete_EB;

f = dc.new_F();

try
    del_f = dc.delete_F;
    error("Whoa. delete_F created")
catch
end_try_catch

dc.F_destroy(f);

ff = dc.new_FFF();
try
    del_ff = dc.delete_FFF;
    error("Whoa. delete_FFF created")
catch
end_try_catch

dc.F_destroy(ff);

g = dc.new_G();

try
    del_g = dc.delete_G;
    error("Whoa. delete_G created")
catch
end_try_catch

dc.G_destroy(g);

gg = dc.new_GG();
dc.delete_GG(gg);


hh = default_constructor.HH(1,1);


