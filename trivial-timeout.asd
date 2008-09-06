#|

Author: Gary King

|#

(defpackage :trivial-timeout-system (:use #:cl #:asdf))
(in-package :trivial-timeout-system)

(load (let ((*default-pathname-defaults* *load-pathname*))
	(merge-pathnames "asdf-featurep.lisp")))

(defsystem trivial-timeout
  :version "0.1.0"
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
		((:featurep-source-file 
		  "package"
		  :feature (not :com.metabang.trivial-timeout))))
	       (:module 
		"timeout"
		:pathname "dev/"
		:depends-on ("setup")
		:components 
		((:featurep-source-file 
		  "with-timeout"
		  :feature (not :com.metabang.trivial-timeout))))
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


