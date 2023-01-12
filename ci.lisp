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
                 "ccl-bin"
                 "allegro"
                 "lispworks"
                 "clisp"
                 "ecl")
          :asdf-system "trivial-timeout"
          :coverage t)))
