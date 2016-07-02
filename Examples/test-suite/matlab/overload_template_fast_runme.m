% unless explicitly casted via {{u}int{8,16,32,64},double,single},
% octave will take numeric literals as doubles.

f = overload_template_fast.foo();

a = overload_template_fast.maximum(3,4);
b = overload_template_fast.maximum(3.4,5.2);

% mix 1
if (overload_template_fast.mix1('hi') ~= 101)
  error('mix1(const char*)')
end

if (overload_template_fast.mix1(1.1, 1.1) ~= 102)
  error('mix1(double, const double &)')
end

if (overload_template_fast.mix1(1.1) ~= 103)
  error('mix1(double)')
end

% mix 2
if (overload_template_fast.mix2('hi') ~= 101)
  error('mix2(const char*)')
end

if (overload_template_fast.mix2(1.1, 1.1) ~= 102)
  error('mix2(double, const double &)')
end

if (overload_template_fast.mix2(1.1) ~= 103)
  error('mix2(double)')
end

% mix 3
if (overload_template_fast.mix3('hi') ~= 101)
  error('mix3(const char*)')
end

if (overload_template_fast.mix3(1.1, 1.1) ~= 102)
  error('mix3(double, const double &)')
end

if (overload_template_fast.mix3(1.1) ~= 103)
  error('mix3(double)')
end

% Combination 1
if (overload_template_fast.overtparams1(100) ~= 10)
  error('overtparams1(int)')
end

if (overload_template_fast.overtparams1(100.1, 100) ~= 20)
  error('overtparams1(double, int)')
end

% Combination 2
if (overload_template_fast.overtparams2(100.1, 100) ~= 40)
  error('overtparams2(double, int)')
end

% Combination 3
if (overload_template_fast.overloaded() ~= 60)
  error('overloaded()')
end

if (overload_template_fast.overloaded(100.1, 100) ~= 70)
  error('overloaded(double, int)')
end

% Combination 4
if (overload_template_fast.overloadedagain('hello') ~= 80)
  error('overloadedagain(const char *)')
end

if (overload_template_fast.overloadedagain() ~= 90)
  error('overloadedagain(double)')
end

% specializations
if (overload_template_fast.specialization(10) ~= 202)
  error('specialization(int)')
end

if (overload_template_fast.specialization(10.1) ~= 203)
  error('specialization(double)')
end

if (overload_template_fast.specialization(10, 10) ~= 204)
  error('specialization(int, int)')
end

if (overload_template_fast.specialization(10.1, 10.1) ~= 205)
  error('specialization(double, double)')
end

if (overload_template_fast.specialization('hi', 'hi') ~= 201)
  error('specialization(const char *, const char *)')
end


% simple specialization
overload_template_fast.xyz();
overload_template_fast.xyz_int();
overload_template_fast.xyz_double();

% a bit of everything
if (overload_template_fast.overload('hi') ~= 0)
  error('overload()')
end

if (overload_template_fast.overload(1) ~= 10)
  error('overload(int t)')
end

if (overload_template_fast.overload(1, 1) ~= 20)
  error('overload(int t, const int &)')
end

if (overload_template_fast.overload(1, 'hello') ~= 30)
  error('overload(int t, const char *)')
end

k = overload_template_fast.Klass();
if (overload_template_fast.overload(k) ~= 10)
  error('overload(Klass t)')
end

if (overload_template_fast.overload(k, k) ~= 20)
  error('overload(Klass t, const Klass &)')
end

if (overload_template_fast.overload(k, 'hello') ~= 30)
  error('overload(Klass t, const char *)')
end

if (overload_template_fast.overload(10.1, 'hi') ~= 40)
  error('overload(double t, const char *)')
end

if (overload_template_fast.overload() ~= 50)
  error('overload(const char *)')
end


% everything put in a namespace
if (overload_template_fast.nsoverload('hi') ~= 1000)
  error('nsoverload()')
end

if (overload_template_fast.nsoverload(1) ~= 1010)
  error('nsoverload(int t)')
end

if (overload_template_fast.nsoverload(1, 1) ~= 1020)
  error('nsoverload(int t, const int &)')
end

if (overload_template_fast.nsoverload(1, 'hello') ~= 1030)
  error('nsoverload(int t, const char *)')
end

if (overload_template_fast.nsoverload(k) ~= 1010)
  error('nsoverload(Klass t)')
end

if (overload_template_fast.nsoverload(k, k) ~= 1020)
  error('nsoverload(Klass t, const Klass &)')
end

if (overload_template_fast.nsoverload(k, 'hello') ~= 1030)
  error('nsoverload(Klass t, const char *)')
end

if (overload_template_fast.nsoverload(10.1, 'hi') ~= 1040)
  error('nsoverload(double t, const char *)')
end

if (overload_template_fast.nsoverload() ~= 1050)
  error('nsoverload(const char *)')
end


overload_template_fast.A.foo(1);
b = overload_template_fast.B();
b.foo(1);
