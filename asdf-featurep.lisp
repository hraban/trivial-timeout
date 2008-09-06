(in-package #:asdf)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(featurep-source-file)))

(unless (and (find-symbol (symbol-name 'featurep) '#:asdf)
	     (fboundp (find-symbol (symbol-name 'featurep) '#:asdf)))
(defun featurep (feature-expression)
  (when feature-expression
    (etypecase feature-expression
      (symbol
       (member feature-expression *features*))
      (cons
       (let ((bool (intern (etypecase (car feature-expression)
			     (symbol (symbol-name (car feature-expression)))
			     (string (car feature-expression)))
			   (load-time-value (find-package :keyword)))))
         (ecase bool
           (:and
            (every #'featurep (rest feature-expression)))
           (:or
            (some #'featurep (rest feature-expression)))
           (:not
            (not (featurep (cadr feature-expression)))))))))))

(defclass featurep-source-file (cl-source-file)
  ((feature :initform nil
	    :initarg :feature
	    :reader feature)))

(defmethod operation-done-p ((o operation) (c featurep-source-file))
  (not (featurep (feature c))))

(defmethod perform :around ((o load-op) (c featurep-source-file))
  (when (featurep (feature c))
    (call-next-method)))

(defmethod perform :around ((o compile-op) (c featurep-source-file))
  (when (featurep (feature c))
    (call-next-method)))

