var v = require('li_std_except');

var test = new v.Test();
// JavaScript error store the message only, without any code or class information!
try { test.throw_bad_exception(); throw new Error('throw_bad_exception failed'); } catch (e) { if (e.message !== 'std::bad_exception') throw e; }
try { test.throw_domain_error(); throw new Error('throw_domain_error failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_exception(); throw new Error('throw_exception failed'); } catch (e) { if (e.message !== 'std::exception') throw e; }
try { test.throw_invalid_argument(); throw new Error('throw_invalid_argument failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_length_error(); throw new Error('throw_length_error failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_logic_error(); throw new Error('throw_logic_error failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_out_of_range(); throw new Error('throw_out_of_range failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_overflow_error(); throw new Error('throw_overflow_error failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_range_error(); throw new Error('throw_range_error failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_runtime_error(); throw new Error('throw_runtime_error failed'); } catch (e) { if (e.message !== 'oops') throw e; }
try { test.throw_underflow_error(); throw new Error('throw_underflow_error failed'); } catch (e) { if (e.message !== 'oops') throw e; }
