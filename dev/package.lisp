(in-package #:common-lisp-user)

(unless (and (find-package '#:hajovonta.trivial-timeout)
	     (find-symbol (symbol-name '#:with-timeout)
			  '#:hajovonta.trivial-timeout)
	     (fboundp (find-symbol (symbol-name '#:with-timeout)
			  '#:hajovonta.trivial-timeout)))
(defpackage #:hajovonta.trivial-timeout
  (:use #:common-lisp)
  (:nicknames #:trivial-timeout)
  (:export 
   #:with-timeout
   #:timeout-error)))
