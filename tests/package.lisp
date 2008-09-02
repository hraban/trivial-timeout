(in-package #:common-lisp-user)

(defpackage #:trivial-timeout-test
  (:use #:common-lisp #:lift #:trivial-timeout)
  (:shadowing-import-from #:trivial-timeout 
			  #:with-timeout
			  #:timeout-error))

#|
(defpackage #:p1
  (:use #:common-lisp))

(defpackage #:p2
  (:use #:common-lisp))


(defun p1::f ()
  :p1)

(defun p2::f ()
  :p2)

(defpackage p3
  (:use #:common-lisp)
  (:shadowing-import-from #:p1 #:f))

(p3::f)

|#