(dynamic-call "scm_init_member_funcptr_galore_module" (dynamic-link "./libmember_funcptr_galore"))
(load "testsuite.scm")

(define m (new-MemberFuncPtrs))
(expect-result 0 = (MemberFuncPtrs-aaa1 m (cc1)))
(expect-result 0 = (MemberFuncPtrs-aaa6 m (cc6)))
(expect-result 0 = (MemberFuncPtrs-aaa7 m (cc7)))
(expect-result 0 = (MemberFuncPtrs-bbb1 m (pp1)))
(expect-result 0 = (MemberFuncPtrs-bbb6 m (pp6)))
(expect-result 0 = (MemberFuncPtrs-bbb7 m (pp7)))
(expect-result 3 = (call1 (ADD-BY-VALUE) 1 2))

;; A const reference to a member pointer is passed and returned as the member pointer
(expect-result 0 = (MemberFuncPtrs-aaa7 m (cc1)))
(expect-result 0 = (MemberFuncPtrs-aaa1 m (cc7)))

;; A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
(expect-throw 'wrong-type-arg (MemberFuncPtrs-aaa1 m (pp1)))
(expect-throw 'wrong-type-arg (MemberFuncPtrs-aaa7 m (pp7)))
(expect-throw 'wrong-type-arg (MemberFuncPtrs-bbb1 m (cc1)))
(expect-throw 'wrong-type-arg (MemberFuncPtrs-bbb7 m (cc7)))

(exit 0)
