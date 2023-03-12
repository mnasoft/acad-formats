;;;; acad-formats.lisp

(in-package :acad-formats)

(defun f (an x y)
  (loop for i from 1 to 9
     do
       (format t "~ax~a (~ax~a)~%" an i (min (* x i ) y) (max (* x i ) y) ))
  (format t "~%"))

(defun a-formats ()
  (progn
    (f "A5" (/ 297 2.0) 210)
    (f "A4" 210 297)
    (f "A3"  297 420)
    (f "A2" 420 (* 2 297))
    (f "A1" (* 2 297) (* 420 2))
    (f "A0" (* 420 2) (* 2 2 297))))

;;;;(a-formats)
