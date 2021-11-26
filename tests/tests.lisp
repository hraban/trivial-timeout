#|

these tests are both very unixy

|#

(in-package #:trivial-timeout-test)

(deftestsuite trivial-timeout-test ()
  ())

(addtest (trivial-timeout-test)
  test-1
  (multiple-value-bind (result measures condition)
      (lift:while-measuring (t :measure-seconds)
	(with-timeout (0.5)
	  (sleep 1.0)))
    (declare (ignore result))
    (ensure (= (length measures) 1) :report "Measures received")
    (ensure (< (first measures) 0.75) :report "Timeout worked")
    (ensure (and condition (typep condition 'timeout-error))
	    :report "Received timeout error")))


(define-condition custom-error (error)
  ())

(addtest (trivial-timeout-test)
  test-2
  ;; If some signal is raised inside WITH-TIMEOUT block,
  ;; should be signaled in the current thread
  ;; and we must be able to ignore it using IGNORE-ERRORS
  ;; or catch using HANDLER-BIND or HANDLER-CASE.
  ;;
  ;; In this test WHILE-MEASURING macro uses HANDLER-BIND
  ;; to catch our CUSTOM-ERROR and to return it as third value.
  ;;
  ;; There was a bug on LispWorks when this didn't work and
  ;; error was signaled in a separate thread.
  (multiple-value-bind (result measures condition)
      (lift:while-measuring (t :measure-seconds)
	(with-timeout (0.5)
          (error 'custom-error)))
    (declare (ignore result))
    (ensure (= (length measures) 1) :report "Measures received")
    (ensure (< (first measures) 0.5)
            :report "Code should return less than timeout. I've got ~A seconds."
            :arguments ((first measures)))
    (ensure (and condition (typep condition 'custom-error))
	    :report "Received condition ~A, but it should be a CUSTOM-ERROR."
            :arguments ((type-of condition)))))


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
