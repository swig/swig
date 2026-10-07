;; Test case for char based strings, mirroring the canonical
;; go/char_strings_runme.go parity set.

(define-macro (check test)
  `(if (not ,test) (error "Error in test" ',test)))

(define CPLUSPLUS_MSG "A message from the deep dark world of C++, where anything is possible.")
(define OTHERLAND_MSG "Little message from the safe world.")

(define count 5)

(define (msg i) (string-append OTHERLAND_MSG (number->string i)))

(do ((i 0 (+ i 1))) ((= i count))
  ;; get functions
  (check (string=? (GetCharHeapString) CPLUSPLUS_MSG))
  (DeleteCharHeapString)
  (check (string=? (GetConstCharProgramCodeString) CPLUSPLUS_MSG))
  (DeleteCharHeapString)
  (check (string=? (GetCharStaticString) CPLUSPLUS_MSG))
  (check (string=? (GetCharStaticStringFixed) CPLUSPLUS_MSG))
  (check (string=? (GetConstCharStaticStringFixed) CPLUSPLUS_MSG))

  ;; set functions
  (check (SetCharHeapString (msg i) i))
  (check (SetCharStaticString (msg i) i))
  (check (SetConstCharHeapString (msg i) i))
  (check (SetConstCharStaticString (msg i) i))
  (check (SetCharConstStaticString (msg i) i))
  (check (SetConstCharConstStaticString (msg i) i))
  (check (SetConstCharTypedefString (msg i) i))
  (check (SetCharArrayStaticString (msg i) i))
  (check (SetConstCharArrayStaticString (msg i) i))

  ;; get set function (ping pong round-trip)
  (check (string=? (CharPingPong (msg i)) (msg i)))
  (check (string=? (CharArrayPingPong (msg i)) (msg i)))
  (let ((ping (string-append "Ping" (number->string i))))
    (check (string=? (CharArrayDimsPingPong ping) ping)))

  ;; variables
  (global-char (msg i))
  (check (string=? (global-char) (msg i)))
  (check (string=? (global-const-char) CPLUSPLUS_MSG))
  (check (string=? (global-char-array1) CPLUSPLUS_MSG))
  (global-char-array2 (msg i))
  (check (string=? (global-char-array2) (msg i)))
  (check (string=? (global-const-char-array1) CPLUSPLUS_MSG))
  (check (string=? (global-const-char-array2) CPLUSPLUS_MSG))

  ;; char *& tests
  (check (string=? (GetCharPointerRef) CPLUSPLUS_MSG))
  (check (SetCharPointerRef (msg i) i))
  (check (string=? (GetConstCharPointerRef) CPLUSPLUS_MSG))
  (check (SetConstCharPointerRef (msg i) i)))

;; A string too long for a char[16] argument is an error rather than read past the end of the array.
(check (string=? (CharArrayDimsPingPong "fifteen chars..") "fifteen chars.."))
(expect-throw 'wrong-type-arg (CharArrayDimsPingPong "sixteen chars..."))
(check (= (CharArrayDimsLength "Ping") 4))
(check (= (CharArrayDimsLength "0123456789abcde") 15))

;; global_char_array1 is a char[] with no size, so it is read only
(expect-throw 'wrong-type-arg (global-char-array1 "x"))
(check (string=? (global-char-array1) CPLUSPLUS_MSG))

;; A string that does not fit in a global char array along with its NUL is an error rather than truncated.
(global-char-array2 (string-append CPLUSPLUS_MSG "!"))
(check (string=? (global-char-array2) (string-append CPLUSPLUS_MSG "!")))
(expect-throw 'wrong-type-arg (global-char-array2 (string-append CPLUSPLUS_MSG "!!")))
(check (string=? (global-char-array2) (string-append CPLUSPLUS_MSG "!")))

(check (string=? (CharArrayNoNul-full-get (char-array-no-nul)) "abcd"))
(check (string=? (CharArrayNoNul-after-get (char-array-no-nul)) "XYZ"))
(global-char-one "a")
(check (string=? (global-char-one) "a"))
(define one (new-CharArrayOne))
(CharArrayOne-one-set one "b")
(check (string=? (CharArrayOne-one-get one) "b"))

(expect-throw 'wrong-type-arg (CharArrayPingPong #nil))
(expect-throw 'wrong-type-arg (CharArrayDimsPingPong #nil))
(expect-throw 'wrong-type-arg (CharArrayNull-four-set (char-array-null) #nil))
(expect-throw 'wrong-type-arg (global-char-array-null #nil))
(check (string=? (CharArrayNull-four-get (char-array-null)) "qqq"))
(check (string=? (global-char-array-null) "qqq"))

(check (char=? (PlainCharPingPong #\a) #\a))
(check (char=? (PlainCharPingPong (integer->char 255)) (integer->char 255)))
(expect-throw 'wrong-type-arg (PlainCharPingPong #nil))
(expect-throw 'wrong-type-arg (PlainCharPingPong 97))
(expect-throw 'wrong-type-arg (PlainCharPingPong "a"))
(expect-throw 'out-of-range (PlainCharPingPong (integer->char 256)))

(exit 0)
