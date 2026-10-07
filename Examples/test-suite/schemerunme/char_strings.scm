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

(exit 0)
