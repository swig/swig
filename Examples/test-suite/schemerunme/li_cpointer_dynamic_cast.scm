(define (swig_assert b msg)
  (unless b
    (begin
    (display msg)
    (newline)
    (exit 1))))
(define (swig_assert_equal a b msg)
  (swig_assert (equal? a b) msg))
(define null '())
(define (swig_assert_isnotnull o msg)
  (swig_assert (not (equal? o null)) msg))
(define (swig_assert_isnull o msg)
  (swig_assert_equal o null msg))

;; Get a Derived object using a Base pointer
(define base_point_derived (Derived-NewDerived))
(swig_assert_equal (Base-val1 base_point_derived) 11 "base_point_derived fail calling Derived::val1()")
(swig_assert_equal (Base-val2 base_point_derived) 2 "base_point_derived fail calling Base::val2()")
;; Dynamic cast to original Derived class
(define derived_dyn (dynDerivedCast base_point_derived))
(swig_assert_isnotnull derived_dyn "dynamic cast to derived_dyn fail")
(swig_assert_equal (Derived-val1 derived_dyn) 11 "derived_dyn fail calling Derived::val1()")
(swig_assert_equal (Derived-val2 derived_dyn) 12 "derived_dyn fail calling Derived::val2()")
;; Static cast work the same as dynamic cast, when used with the derived class!
(define derived_static (staticDerivedCast base_point_derived))
(swig_assert_isnotnull derived_static "static cast to derived_static fail")
(swig_assert_equal (Derived-val1 derived_static) 11 "derived_static fail calling Derived::val1()")
(swig_assert_equal (Derived-val2 derived_static) 12 "derived_static fail calling Derived::val2()")

;; Get an Other object using a Base pointer
(define base_point_other (Other-NewOther))
(swig_assert_equal (Base-val1 base_point_other) 21 "base_point_other fail calling Other::val1()")
(swig_assert_equal (Base-val2 base_point_other) 2 "base_point_other fail calling Base::val2()")
;; Dynamic cast to original Other class
(define other_dyn (dynOtherCast base_point_other))
(swig_assert_isnotnull other_dyn "dynamic cast to other_dyn fail")
(swig_assert_equal (Other-val1 other_dyn) 21 "other_dyn fail calling Other::val1()")
(swig_assert_equal (Other-val2 other_dyn) 22 "other_dyn fail calling Other::val2()")
;; Static cast work the same as dynamic cast, when used with the other class!
(define other_static (staticOtherCast base_point_other))
(swig_assert_isnotnull other_static "static cast to other_static fail")
(swig_assert_equal (Other-val1 other_static) 21 "other_static fail calling Other::val1()")
(swig_assert_equal (Other-val2 other_static) 22 "other_static fail calling Other::val2()")

;; Get a Base object
(define base (new-Base))
(swig_assert_equal (Base-val1 base) 1 "base fail calling Base::val1()")
(swig_assert_equal (Base-val2 base) 2 "base fail calling Base::val2()")

;; Dynamic cast gives NULL as expected
(swig_assert_isnull (dynOtherCast base_point_derived) "'Derived' object can not cast to 'Other'")
(swig_assert_isnull (dynDerivedCast base_point_other) "'Other' object can not cast to 'Derived'")
(swig_assert_isnull (dynOtherCast base) "'Base' object can not cast to 'Other'")
(swig_assert_isnull (dynDerivedCast base) "'Base' object can not cast to 'Derived'")

;; Static cast gives a hybrid result
;; The virtual method point to original object class, as we expect!
;; While the non-virtual method uses the new pointed class method!
(define non_cpp_other_derived (staticOtherCast base_point_derived))
(swig_assert_isnotnull non_cpp_other_derived "static cast to non_cpp_other_derived fail")
(swig_assert_equal (Other-val1 non_cpp_other_derived) 11 "non_cpp_other_derived fail calling Derived::val1()")
(swig_assert_equal (Other-val2 non_cpp_other_derived) 22 "non_cpp_other_derived fail calling Other::val2()")
(define non_cpp_derived_other (staticDerivedCast base_point_other))
(swig_assert_isnotnull non_cpp_derived_other "static cast to non_cpp_derived_other fail")
(swig_assert_equal (Derived-val1 non_cpp_derived_other) 21 "non_cpp_derived_other fail calling Other::val1()")
(swig_assert_equal (Derived-val2 non_cpp_derived_other) 12 "non_cpp_derived_other fail calling Derived::val2()")
(define non_cpp_base_derived (staticDerivedCast base))
(swig_assert_isnotnull non_cpp_base_derived "static cast to non_cpp_base_derived fail")
(swig_assert_equal (Derived-val1 non_cpp_base_derived) 1 "non_cpp_base_derived fail calling Base::val1()")
(swig_assert_equal (Derived-val2 non_cpp_base_derived) 12 "non_cpp_base_derived fail calling Derived::val2()")
(define non_cpp_base_other (staticOtherCast base))
(swig_assert_isnotnull non_cpp_base_other "static cast to non_cpp_base_other fail")
(swig_assert_equal (Other-val1 non_cpp_base_other) 1 "non_cpp_base_other fail calling Base::val1()")
(swig_assert_equal (Other-val2 non_cpp_base_other) 22 "non_cpp_base_other fail calling Other::val2()")

(exit 0)
