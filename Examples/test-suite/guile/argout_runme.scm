;; tests support for native guile pointers
;; https://www.gnu.org/software/guile/manual/html_node/Void-Pointers-and-Byte-Access.html
(dynamic-call "scm_init_argout_module" (dynamic-link "./libargout"))

(use-modules (srfi srfi-4) (system foreign))

(define initial-value 42)
(define some-s32-data (s32vector initial-value))

(if (not (= (incp (bytevector->pointer some-s32-data)) initial-value))
    (error "Didn't read s32 data" initial-value some-s32-data))

(if (not (= (s32vector-ref some-s32-data 0) (+ initial-value 1)))
    (error "Failed to increment s32 data" some-s32-data))

(exit 0)
