(uiop:define-package #:trivial-timeout/ci
  (:use #:cl))
(in-package #:trivial-timeout/ci)

(ql:quickload :40ants-ci)

;;;; To update workflow in the .github/workflows/ci.yml do in the REPL:
;;;; 
;;;; (ql:quickload :trivial-timeout)
;;;; (load "ci.lisp")

(40ants-ci/workflow:defworkflow ci
  :on-push-to "master"
  :on-pull-request t
  :jobs ((40ants-ci/jobs/run-tests:run-tests
          :os ("ubuntu-latest"
               "macos-latest")
          :lisp ("sbcl-bin"
                 ;; Because of this issue:
                 ;; https://github.com/roswell/roswell/issues/534
                 ;; we have to pin version of CCL
                 "ccl-bin/1.12.1"
                 "allegro"
                 "lispworks"
                 "clisp"
                 "ecl")
          :asdf-system "trivial-timeout"
          :coverage t)))
