require('import')       -- the import fn
import('li_constraints') -- import lib into global
cn=li_constraints --alias

function check_func(except, f, val, name)
  actual, err = pcall(f, val);
  assert(actual == except, 'function perform exception wrongly');
  if name == nil then
    r = 'SWIG_ValueError:Received a NULL pointer.';
  else
    r = 'SWIG_ValueError:Expected a ' .. name .. ' value.';
  end
  if not actual then
    assert(err == r, 'function perform the wrong exception');
  end
end

check_func(true, cn.test_nonnegative, 10, 'non-negative');
check_func(true, cn.test_nonnegative, 0, 'non-negative');
check_func(false, cn.test_nonnegative, -10, 'non-negative');

check_func(false, cn.test_nonpositive, 10, 'non-positive');
check_func(true, cn.test_nonpositive, 0, 'non-positive');
check_func(true, cn.test_nonpositive, -10, 'non-positive');

check_func(true, cn.test_positive, 10, 'positive');
check_func(false, cn.test_positive, 0, 'positive');
check_func(false, cn.test_positive, -10, 'positive');

check_func(false, cn.test_negative, 10, 'negative');
check_func(false, cn.test_negative, 0, 'negative');
check_func(true, cn.test_negative, -10, 'negative');

check_func(true, cn.test_nonzero, 10, 'nonzero');
check_func(false, cn.test_nonzero, 0, 'nonzero');
check_func(true, cn.test_nonzero, -10, 'nonzero');

check_func(false, cn.test_nonnull, nil);
nonnull = cn.get_nonnull();
check_func(true, cn.test_nonnull, nonnull);
