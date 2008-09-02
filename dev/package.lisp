(in-package #:common-lisp-user)

(defpackage #:com.metabang.trivial-timeout
  (:use #:common-lisp)
  (:nicknames #:trivial-timeout)
  (:export 
   #:with-timeout
   #:timeout-error
   #:timeout-error-command))
