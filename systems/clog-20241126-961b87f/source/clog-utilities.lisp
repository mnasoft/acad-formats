;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CLOG - The Common Lisp Omnificent GUI                                 ;;;;
;;;; (c) David Botton                                                      ;;;;
;;;;                                                                       ;;;;
;;;; clog-utilities.lisp                                                   ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Utilites for use with the CLOG framework

(cl:in-package :clog)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - with-clog-create ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro with-clog-create (obj spec &body body)
"To use the macro you remove the create- from the create
functions. The clog-obj passed as the first parameter of the macro is
passed as the parent obj to the declared object, after that nested
levels of decleraton are used as the parent clog-obj. To bind a
variable to any created clog object using :bind var. See tutorial 33
and 22 for examples. All create- symbols must be in or used by
package."
  (flet ((extract-bind (args)
           (when args
             (let ((fargs ())
                    bind)
               (do* ((i 0)
                      (x (nth i args) (nth i args)))
                 ((>= i (length args)))
                 (if (eql x :bind)
                   (progn
                     (setf bind (nth (1+ i) args))
                     (incf i 2))
                   (progn
                     (push x fargs)
                     (incf i))))
               (values (reverse fargs) bind)))))
    (let ((let-bindings ())
           (used-bindings ()))
      (labels ((create-from-spec (spec parent-binding)
                 (destructuring-bind (gui-func-name args &body children)
                   spec
                   (multiple-value-bind (gui-func-args bind) (extract-bind args)
                     (let* ((binding (or bind (gensym)))
                             (create-func-name (intern (concatenate 'string "CREATE-" (symbol-name gui-func-name)))))
                       (push `(,binding (,create-func-name ,parent-binding ,@gui-func-args)) let-bindings)
                       (when (or bind children)
                         (push binding used-bindings))
                       (dolist (child-spec children)
                         (create-from-spec child-spec binding)))))))
        (create-from-spec spec obj)
        `(let* ,(reverse let-bindings)
           (declare (ignore ,@(set-difference (mapcar #'first let-bindings) used-bindings)))
           ,@body)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - JS Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;
;; escape-for-html ;;
;;;;;;;;;;;;;;;;;;;;;

(defun escape-for-html (value)
  "Returns a string where < and > are replaced with html entities. This is
particularly useful as #<> is used for unprintable objects in Lisp. Value is
converted with format to a string first."
  (setf value (format nil "~A" value))
  (setf value (ppcre:regex-replace-all "<" value "&lt;"))
  (setf value (ppcre:regex-replace-all ">" value "&gt;"))
  value)

;;;;;;;;;;;;;;;
;; js-true-p ;;
;;;;;;;;;;;;;;;

(defun js-true-p (value)
  "Return true if VALUE equalp the string true"
  (equalp value "true"))

;;;;;;;;;;;;;;;
;; p-true-js ;;
;;;;;;;;;;;;;;;

(defun p-true-js (value)
  "Return \"true\" if VALUE t"
  (if value
      "true"
      "false"))

;;;;;;;;;;;;;
;; js-on-p ;;
;;;;;;;;;;;;;

(defun js-on-p (value)
  "Return true if VALUE equalp the string on"
  (equalp value "on"))

;;;;;;;;;;;;;
;; p-on-js ;;
;;;;;;;;;;;;;

(defun p-on-js (value)
  "Return \"on\" if VALUE t or return \"off\""
  (if value
      "on"
      "off"))

;;;;;;;;;;;;;;;;;;;
;; js-to-integer ;;
;;;;;;;;;;;;;;;;;;;

(defun js-to-integer (value &key (default 0))
  "Returns two values first as an integer and second the original value"
  (cond ((typep value 'integer)
	 (values value value))
	((typep value 'string)
	 (let ((r (parse-integer value :junk-allowed t)))
	   (if r
	       (values r value)
	       (values default value))))
	(t
	 (values default value))))

;;;;;;;;;;;;;;;;;
;; js-to-float ;;
;;;;;;;;;;;;;;;;;

(defun js-to-float (value &key (default 0.0d0))
  "Returns two values first as a float and second the original value"
  (cond ((typep value 'float)
	 (values value value))
	((typep value 'string)
	 (let ((r (parse-float value :type 'double-float :junk-allowed t)))
	   (if r
	       (values r value)
	       (values default value))))
	(t
	 (values default value))))

;;;;;;;;;;;;;;
;; lf-to-br ;;
;;;;;;;;;;;;;;

(defun lf-to-br (str)
  "Change line feeds to <br>."
  (ppcre:regex-replace-all "\\x0A" str "<br>"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - Color Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; rgb ;;
;;;;;;;;;

(defun rgb (red green blue)
  "Return RGB string, red green and blue may be 0-255"
  (format nil "rgb(~A, ~A, ~A)" red green blue))

;;;;;;;;;;;;;;;;
;; rgb-to-hex ;;
;;;;;;;;;;;;;;;;

(defun rgb-to-hex (rgb)
  "Return hex #rrggbb from rgb(red,green,blue)"
  (multiple-value-bind (m l)
      (ppcre:scan-to-strings "rgba?\\s?\\((\\d+),\\s?(\\d+),\\s?(\\d+),?\\s?(\\d|\.*)\\)" rgb)
    (declare (ignore m))
    (format nil "#~2,'0x~2,'0x~2,'0x"
            (parse-integer (aref l 0))
            (parse-integer (aref l 1))
            (parse-integer (aref l 2)))))

;;;;;;;;;;
;; rgba ;;
;;;;;;;;;;

(defun rgba (red green blue alpha)
  "Return RGBA string, red green and blue may be 0-255, alpha 0.0 - 1.0"
  (format nil "rgba(~A, ~A, ~A, ~A)" red green blue alpha))

;;;;;;;;;
;; hsl ;;
;;;;;;;;;

(defun hsl (hue saturation lightness)
  "Return HSL string, hue 0-360, saturation and lightness 0%-100%"
  (format nil "hsl(~A, ~A, ~A)" hue saturation lightness))

;;;;;;;;;;
;; hsla ;;
;;;;;;;;;;

(defun hsla (hue saturation lightness alpha)
  "Return HSLA string, hue 0-360, saturation and lightness 0%-100%,
alpha 0.0 - 1.0"
  (format nil "hsla(~A, ~A, ~A, ~A)" hue saturation lightness alpha))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - Units
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
;; unit ;;
;;;;;;;;;;

;; cm   centimeters
;; mm   millimeters
;; in   inches (1in = 96px = 2.54cm
;; px   pixels (1px = 1/96th of 1in)
;; pt   points (1pt = 1/72 of 1in)
;; pc   picas (1pc = 12 pt)
;; em   Relative to the font-size of the element (2em means 2 times the size of the current font)
;; ex   Relative to the x-height of the current font (rarely used)
;; ch   Relative to the width of the "0" (zero)
;; rem  Relative to font-size of the root element
;; vw   Relative to 1% of the width of the viewport*
;; vh   Relative to 1% of the height of the viewport*
;; vmin Relative to 1% of viewport's* smaller dimension
;; vmax Relative to 1% of viewport's* larger dimension
;; %    Relative to the parent element
;;
;; * Viewport = the browser window size. If the viewport is 50cm wide, 1vw = 0.5cm.

(deftype unit-type () '(member :cm :mm :in :px :pt :pc :em :ex :ch :rem :vw
                         :vh :vmin :vmax :%))

(defun unit (unit-type value)
  "produce a string from numeric value with UNIT-TYPE appended."
  (format nil "~A~A" value unit-type))

(defun unit* (unit-type value)
  "Returns value and if no unit was specified on value
unit added unless value is empty string or nil."
  (cond ((or (equal value "")
             (eq value nil))
         value)
        (t
         (let* ((str (format nil "~A" value))
                (l   (char-code (uiop:last-char str))))
           (if (or (numberp value)
                   (and (>= l 48) (<= l 57)))
               (format nil "~A~A" str unit-type)
               str)))))

;; https://www.w3schools.com/colors/colors_names.asp
;;
;; From - https://www.w3schools.com/
;;
;; linear-gradient(direction, color-stop1, color-stop2, ...);
;; radial-gradient(shape size at position, start-color, ..., last-color);
;; repeating-linear-gradient(angle | to side-or-corner, color-stop1, color-stop2, ...);
;; repeating-radial-gradient(shape size at position, start-color, ..., last-color);
;;
;;
;; The following list are the best web safe fonts for HTML and CSS:
;;
;; Arial (sans-serif)
;; Verdana (sans-serif)
;; Helvetica (sans-serif)
;; Tahoma (sans-serif)
;; Trebuchet MS (sans-serif)
;; Times New Roman (serif)
;; Georgia (serif)
;; Garamond (serif)
;; Courier New (monospace)
;; Brush Script MT (cursive)
