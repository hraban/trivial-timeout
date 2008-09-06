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
    (declare (ignore result))
    (ensure (< (first measures) 0.75) :report "timeout worked")
    (ensure (and condition (typep condition 'timeout-error))
	    :report "Received timeout error")))



#|

(deffixture remote-triple-store ()
  ((port 12346))
  :implements opens-triple-store
  (:setup
   (stop-local-server)
   (start-local-server port)
   (apply #'create-triple-store "scratch" 
	  :connection (allegrograph-connection :port port)
	  :triple-store-class 'remote-triple-store args))
  (:teardown
   (close-triple-store)
   (stop-local-server)))

(deffixture federated-triple-store ()
  ()
  :implements opens-triple-store
  (:setup
   (create-triple-store "scratch-1")
   (create-triple-store "scratch-2")
   (federate-triple-stores "scratch" (list (find-triple-store "scratch-1")
					   (find-triple-store "scratch-2"))))
(deffixture basic-triple-store ()
  ()
  :implements opens-triple-store
  (:setup
   (create-triple-store "scratch")))


(deftest foo
    :requires opens-triple-store
    )

|#
