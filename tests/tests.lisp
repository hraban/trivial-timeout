#|

these tests are both very unixy

|#

(in-package #:trivial-timeout-test)

(deftestsuite trivial-timeout-test ()
  ())

(addtest (trivial-timeout-test)
  test-1
  (multiple-value-bind (result measures condition)
      (handler-case
	  (lift::while-measuring (seconds)
	    (with-timeout (0.5) 
	      (sleep 1.0)))
	(error (c)
	  (declare (ignore c))))
    (ensure (< (first measures) 0.75) :report "timeout worked")
    (ensure (and condition (typep condition 'timeout-error))
	    :report "Received timeout error")))



