(in-package #:com.metabang.trivial-timeout)

(define-condition timeout-error (error) ()
  (:report (lambda (c s)
             (declare (ignore c))
             (format s "Process timeout")))
  (:documentation "An error signaled when the duration specified in 
the [with-timeout][] is exceeded."))

#+allegro
(defun generate-platform-specific-code (seconds-symbol doit-symbol)
  `(mp:with-timeout (,seconds-symbol (error 'timeout-error)) 
     (,doit-symbol)))


#+(and sbcl (not sb-thread))
(defun generate-platform-specific-code (seconds-symbol doit-symbol)
  (let ((glabel (gensym "label-"))
        (gused-timer? (gensym "used-timer-")))
    `(let ((,gused-timer? nil))
       (catch ',glabel
         (sb-ext:schedule-timer
          (sb-ext:make-timer (lambda ()
                               (setf ,gused-timer? t)
                               (throw ',glabel nil)))
          ,seconds-symbol)
         (,doit-symbol))
       (when ,gused-timer?
         (error 'timeout-error)))))

#+(and sbcl sb-thread)
(defun generate-platform-specific-code (seconds-symbol doit-symbol)
  `(handler-case 
       (sb-ext:with-timeout ,seconds-symbol (,doit-symbol))
     (sb-ext::timeout (c)
       (declare (ignore c))
       (error 'timeout-error))))

#+cmu
;;; Run function in separate process since SLEEP in initial process is blocking.
;;; It still doesn't resolve the infinite loop problem
(defun generate-platform-specific-code (seconds-symbol doit-symbol)
  (let ((result (gensym))
        (function-process (gensym)))
    `(let* ((,result nil)
            (,function-process (mp:make-process (lambda ()
                                                  (setf ,result (multiple-value-list (,doit-symbol))))
                                                :name "Timeout function process")))
       (mp:process-wait-with-timeout "Timeout sleep" ,seconds-symbol
                                     (lambda ()
                                       (not (mp:process-alive-p ,function-process))))
       (if (mp:process-alive-p ,function-process)
           (progn
             (mp:destroy-process ,function-process)
             (error 'timeout-error))
           (apply #'values ,result)))))

#+(or)
;;; Version using CMUCL's with-timeout.
;;; Left in case it becomes better than the version above.
(defun generate-platform-specific-code (seconds-symbol doit-symbol)
  `(mp:with-timeout (,seconds-symbol (error 'timeout-error))
     (,doit-symbol)))

#+(or digitool openmcl ccl)
(defun generate-platform-specific-code (seconds-symbol doit-symbol)
  (let ((gsemaphore (gensym "semaphore"))
	(gresult (gensym "result"))
	(gprocess (gensym "process")))
    `(let* ((,gsemaphore (ccl:make-semaphore))
            (,gresult)
            (,gprocess
              (ccl:process-run-function
               ,(format nil "Timed Process ~S" gprocess)
               (lambda ()
                 (setf ,gresult (multiple-value-list (,doit-symbol)))
                 (ccl:signal-semaphore ,gsemaphore)))))
       (cond ((ccl:timed-wait-on-semaphore ,gsemaphore ,seconds-symbol)
              (values-list ,gresult))
             (t
              (ccl:process-kill ,gprocess)
              (error 'timeout-error))))))

#+lispworks
(defun generate-platform-specific-code (seconds-symbol doit-symbol)
  ;; For LispWorks, we'll start a separate "guard" thread which
  ;; will interrupt the current thread when timeout will happen.
  ;; 
  ;; If a computation finishes before timeout, it terminates "guard"
  ;; thread.
  (let ((g-main-process (gensym "main-process-"))
        (g-guard-process (gensym "guard-process-")))
    `(let* ((,g-main-process (mp:get-current-process))
            (,g-guard-process
              (mp:process-run-function
               "WITH-TIMEOUT" ()
               (lambda ()
                 (mp:process-wait-with-timeout "WITH-TIMEOUT" ,seconds-symbol)

                 ;; body didn't return yet
                 (mp:process-interrupt ,g-main-process
                                       (lambda ()
                                         (cerror "Timeout" 'timeout-error)))))))
       (unwind-protect
            (,doit-symbol)
         (mp:process-terminate ,g-guard-process)))))

(unless (let ((symbol
                (find-symbol (symbol-name '#:generate-platform-specific-code)
                             '#:com.metabang.trivial-timeout)))
          (and symbol (fboundp symbol)))
  (defun generate-platform-specific-code (seconds-symbol doit-symbol)
    (declare (ignore seconds-symbol))
    `(,doit-symbol)))

(defmacro with-timeout ((seconds) &body body)
  "Execute `body` for no more than `seconds` time. 

If `seconds` is exceeded, then a [timeout-error][] will be signaled. 

If `seconds` is nil, then the body will be run normally until it completes
or is interrupted."
  (build-with-timeout seconds body))

(defun build-with-timeout (seconds body)
  (let ((gseconds (gensym "seconds-"))
        (gdoit (gensym "doit-")))
    `(let ((,gseconds ,seconds))
       (flet ((,gdoit ()
                (progn ,@body)))
         (cond (,gseconds
                ,(generate-platform-specific-code gseconds gdoit))
               (t
                (,gdoit)))))))
