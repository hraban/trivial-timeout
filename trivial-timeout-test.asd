#|
Author: Gary King

See file COPYING for details
|#

(defpackage #:trivial-timeout-test-system (:use #:cl #:asdf))
(in-package #:trivial-timeout-test-system)

(defsystem trivial-timeout-test
  :author "Gary Warren King <gwking@metabang.com>"
  :maintainer "Gary Warren King <gwking@metabang.com>"
  :licence "MIT Style License"
  :description "Tests for trivial-timeout"
  :components ((:module 
		"setup"
		:pathname "tests/"
		:components 
		((:file "package")
		 (:file "tests" :depends-on ("package"))))
	       #+(or)
	       (:module 
		"tests"
		:depends-on ("setup")
		:components ((:file "test-timeout"))))
  :depends-on (:lift :trivial-timeout))


