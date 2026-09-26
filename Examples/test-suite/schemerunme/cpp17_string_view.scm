;; Checking expected use of %typemap(in) std::string_view {}
(test-value "Fee")

;; Checking expected result of %typemap(out) std::string_view {}
(expect-result "Fi" equal? (test-value "Fi"))

;; Checking expected use of %typemap(in) const std::string_view & {}
(test-const-reference "Fo")

;; Checking expected result of %typemap(out) const std::string_view& {}
(expect-result "Fum" equal? (test-const-reference "Fum"))

;; Input and output typemaps for pointers and non-const references to
;; std::string_view are *not* supported; the following tests confirm
;; that none of these cases are slipping through.

(test-pointer (test-pointer-out))
(test-const-pointer (test-const-pointer-out))
(test-reference (test-reference-out))
(test-multiple "fee" "fi" "fo" "fum")

;; Global variables
(expect-result "const global string" equal? (ConstGlobalString))

;; Member variables
(expect-result "const member string"
               equal?
               (Structure-ConstMemberString-get (new-Structure)))

(expect-result "const static member string"
               equal?
               (Structure-ConstStaticMemberString))

(test-const-reference-returning-void "foo")

(expect-result "" equal? (stdstringview-empty))
(expect-result "" equal? (c-empty))
(expect-false (c-null))
(expect-result "non-null" equal? (get-null (c-empty)))
(expect-result "non-null" equal? (get-null (stdstringview-empty)))

(exit 0)
