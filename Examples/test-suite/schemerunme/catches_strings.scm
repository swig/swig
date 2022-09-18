(expect-throw 'swig-exception
              (StringsThrower-charstring))
; TODO: check the exception message

(expect-throw 'swig-exception
              (StringsThrower-stdstring))
; TODO: check the exception message

(exit 0)
