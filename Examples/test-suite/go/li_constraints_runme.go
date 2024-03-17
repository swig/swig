package main

import wrap "swigtests/li_constraints"
import "fmt";

func check_double(except bool, f func (float64), val float64, name string) {
    actual := true
    proper := false
	func() {
		defer func() {
            r := recover();
			if r != nil {
                actual = false
                proper = fmt.Sprintf("%s", r) == fmt.Sprintf("Expected a %s value.", name)
			}
		}()
        f(val);
	}()
    if actual {
      if !except {
        panic(fmt.Sprintf("function '%s' with %d should perform an exception", name, val));
      }
    } else {
      if except {
        panic(fmt.Sprintf("function '%s' with %d should not perform an exception", name, val));
      } else if !proper {
        panic(fmt.Sprintf("function '%s' with %d should perform a proper exception", name, val));
      }
    }
}

func main() {
    check_double(true, wrap.Test_nonnegative, 10, "non-negative");
    check_double(true, wrap.Test_nonnegative, 0, "non-negative");
    check_double(false, wrap.Test_nonnegative, -10, "non-negative");

    check_double(false, wrap.Test_nonpositive, 10, "non-positive");
    check_double(true, wrap.Test_nonpositive, 0, "non-positive");
    check_double(true, wrap.Test_nonpositive, -10, "non-positive");

    check_double(true, wrap.Test_positive, 10, "positive");
    check_double(false, wrap.Test_positive, 0, "positive");
    check_double(false, wrap.Test_positive, -10, "positive");

    check_double(false, wrap.Test_negative, 10, "negative");
    check_double(false, wrap.Test_negative, 0, "negative");
    check_double(true, wrap.Test_negative, -10, "negative");

    check_double(true, wrap.Test_nonzero, 10, "nonzero");
    check_double(false, wrap.Test_nonzero, 0, "nonzero");
    check_double(true, wrap.Test_nonzero, -10, "nonzero");

    have_exception := false
	func() {
		defer func() {
            r := recover()
			if r != nil {
                have_exception = "Received a NULL pointer." == fmt.Sprintf("%s", r)
			}
		}()
        // The NULL value
        // We can not use Go `nil` as is it can not be convert to a uintptr value.
        wrap.Test_nonnull(uintptr(0));
	}()
    if !have_exception {
        panic("test_nonnull should perform exception with 'null' value")
    }
    nonnull := wrap.Get_nonnull();
    wrap.Test_nonnull(nonnull);
}
