;;;; acad-formats.lisp

(defpackage :acad-formats
  (:use #:cl)
  (:export *a0*
           *b0*
           *c0*)
  (:export fmt)
  (:export a-formats
           b-formats
           c-formats)
  )

(in-package :acad-formats)

(defparameter *A0*
  (list (/ 1000 (sqrt (sqrt 2))) (* 1000 (sqrt (sqrt 2)))))

(defparameter *B0*
  (list 1000.0 (* 1000 (sqrt 2))))

(defparameter *C0*
  (list (sqrt (*  (first *A0*)(first *B0*) ))
        (sqrt (* (second *A0*)(second *B0*) ))))


(defun fmt (fmt number &optional (kratnost 1))
  (let ((rez fmt))
    (loop :for i :from 0 :below number
          :do
          (setf rez (reverse rez)
                (first rez) (/ (first rez) 2)))
                (when (>= kratnost 3)
    (setf (first rez) (* kratnost (first rez))
    rez (reverse rez)
    ))
    (mapcar
      #'(lambda (el)
          (floor el))
      rez)))

(defun a-formats ()
  (progn
    (f "A5" (/ 297 2.0) 210)
    (f "A4" 210 297)
    (f "A3"  297 420)
    (f "A2" 420 (* 2 297))
    (f "A1" (* 2 297) (* 420 2))
    (f "A0" (* 420 2) (* 2 2 297))))

;;;;

(a-formats)

(defun b-formats ()
  nil
  )

(defun c-formats ()
  nil
  )

(defun f (an x y)
  (loop :for i :from 1 :to 9
        :do
           (when (/= i 2)
             (format t "~ax~a (~ax~a)~%" an i (min (* x i ) y) (max (* x i ) y) )))
  (format t "~%"))


(fmt *a0* 2 6)
