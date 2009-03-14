#|

Author: Gary King

|#

(defpackage :trivial-timeout-system (:use #:cl #:asdf))
(in-package :trivial-timeout-system)

(defsystem trivial-timeout
  :version "0.1.5"
  :author "Gary Warren King <gwking@metabang.com>"
  :maintainer "Gary Warren King <gwking@metabang.com>"
  :licence "MIT Style License"
  :description "OS and Implementation independent access to timeouts"
  :components ((:module 
		"notes"
		:pathname "dev/"
		:components 
		((:static-file "notes.text")))

	       (:module 
		"setup"
		:pathname "dev/"
		:components 
		((:file "package")))
	       (:module 
		"timeout"
		:pathname "dev/"
		:depends-on ("setup")
		:components 
		((:file "with-timeout")))

               (:module 
		"website"
		:components
		((:module "source"
			  :components ((:static-file "index.md"))))))
  :in-order-to ((test-op (load-op trivial-timeout-test)))
  :perform (test-op :after (op c)
		    (funcall
		      (intern (symbol-name '#:run-tests) :lift)
		      :config :generic))
  :depends-on ())

(defmethod operation-done-p 
           ((o test-op)
            (c (eql (find-system 'trivial-timeout))))
  (values nil))


