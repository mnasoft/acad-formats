;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CLOG - The Common Lisp Omnificent GUI                                 ;;;;
;;;; (c) David Botton                                                      ;;;;
;;;;                                                                       ;;;;
;;;; clog-panel.lisp                                                       ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(cl:in-package :clog)

;;; CLOG-PANELs are for doing layouts, base class for pluggins and custom
;;; widgets and is the base class for CLOG Builder's panels.
;;; Various layout functions for use on panels and divs
;;; CLOG-PANEL-BOXes are to layout a classic 5 panel layout in a panel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - clog-panel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-panel (clog-element)()
  (:documentation "CLOG Panel objects."))

;;;;;;;;;;;;;;;;;;
;; create-panel ;;
;;;;;;;;;;;;;;;;;;

(defgeneric create-panel (clog-obj &key left top right bottom
                                     width height units
                                     margin-left margin-top
                                     margin-right margin-bottom
                                     border-style border-width border-color
                                     background-color
                                     positioning overflow resizable content
                                     style hidden class html-id auto-place)
  (:documentation "Create a new CLOG-Panel as child of
CLOG-OBJ. Optionally you can set the :X, :Y, :WIDTH and :HEIGHT (in
:UNITS defulting to :px, if set to nil unit type must be provided for
x,y,width and height), BORDER-STYLE (see BORDER-STYLE-TYPE),
BORDER-WIDTH, BORDER-COLOR, :POSITIONING (default is :FIXED the
default builder panels are :STATIC) (see POSITIONING-TYPE),
:OVERFLOW (default is :CLIP) with :CONTENT (default \"\") and
:RESIZABLE defaults to :NONE. Additional css styles can be set in
:STYLE (default \"\") if :AUTO-PLACE (default t)
place-inside-bottom-of CLOG-OBJ. If hidden is true visiblep is set to
nil. Resizable only works if overflow is set to :SCROLL"))

(defmethod create-panel ((obj clog-obj) &key
                                          (left nil)
                                          (top nil)
                                          (right nil)
                                          (bottom nil)
                                          (width nil)
                                          (height nil)
                                          (units :px)
                                          (margin-left nil)
                                          (margin-top nil)
                                          (margin-right nil)
                                          (margin-bottom nil)
                                          (border-style nil)
                                          (border-width nil)
                                          (border-color nil)
                                          (background-color nil)
                                          (positioning :absolute)
                                          (overflow :clip)
                                          (display nil)
                                          (resizable nil)
                                          (content "")
                                          (style "")
                                          (hidden nil)
                                          (class nil)
                                          (html-id nil)
                                          (auto-place t))
  (create-child obj
     (format nil "<div~A style='~A~A~A~A~A~A~A~A~A~A~A~A~A~A~A~A~A~A~A~A'>~A</div>"
             (if class
                 (format nil " class='~A'" (escape-string class :html t))
                 "")
             (if style
                 (format nil "~A;" (escape-string style :html t))
                 "")
             (if left
                 (format nil "left:~A~A;" left units)
                 "")
             (if top
                 (format nil "top:~A~A;" top units)
                 "")
             (if right
                 (format nil "right:~A~A;" right units)
                 "")
             (if bottom
                 (format nil "bottom:~A~A;" bottom units)
                 "")
             (if margin-left
                 (format nil "margin-left:~A~A;" margin-left units)
                 "")
             (if margin-top
                 (format nil "margin-top:~A~A;" margin-top units)
                 "")
             (if margin-right
                 (format nil "margin-right:~A~A;" margin-right units)
                 "")
             (if margin-bottom
                 (format nil "margin-bottom:~A~A;" margin-bottom units)
                 "")
             (if width
                 (format nil "width:~A~A;" width units)
                 "")
             (if height
                 (format nil "height:~A~A;" height units)
                 "")
             (if border-style
                 (format nil "border-style:~A;" border-style)
                 "")
             (if border-width
                 (format nil "border-width:~A;" border-width)
                 "")
             (if border-color
                 (format nil "border-color:~A;" border-color)
                 "")
             (if background-color
                 (format nil "background-color:~A;" background-color)
                 "")
             (if overflow
                 (format nil "overflow:~A;" overflow)
                 "")
             (if display
                 (format nil "display:~A;" display)
                 "")
             (if resizable
                 (format nil "resize:~A;" resizable)
                 "")
             (if positioning
                 (format nil "position:~A;"
                         (escape-string positioning :html t))
                 "")
             (if hidden
                 "visibility:hidden;"
                 "")
             (escape-string content :html t))
     :clog-type  'clog-panel
     :html-id    html-id
     :auto-place auto-place))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - Layout tools for panels, divs, etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;
;; envelope-panel ;;
;;;;;;;;;;;;;;;;;;;;

(defgeneric envelope-panel (clog-element panel width height
                            &key class style units)
  (:documentation "Create a envelope of WIDTH and HEIGHT with :relative
positioning to envelope PANEL. The envelope is a child of CLOG-ELEMENT.
This allows any type of clog-panel (including those created by CLOG Builder,
to be positioned within a DISPLAY :flex or :grid layout or otherwise treat the
panel as an inline object. Returns the new envelope of PANEL"))

(defmethod envelope-panel ((obj clog-element) (panel clog-element)
                           width height
                           &key (units :px) class (style ""))
  (let ((e (create-div obj :class class
                       :style (format nil "position:relative;width:~A~A;height:~A~A;~A"
                                          width units height units style))))
    (place-inside-top-of e panel)
    e))

;;;;;;;;;;;;;;;;;;;;
;; envelope-panel ;;
;;;;;;;;;;;;;;;;;;;;

(defgeneric envelope-panel* (panel width height
                             &key class style units)
  (:documentation "Like envelope panel, but usses the panels parent as the
parent of the envelope. Returns the new envelope of PANEL"))

(defmethod envelope-panel* ((panel clog-element)
                            width height
                            &key (units :px) class (style ""))
  (envelope-panel (parent panel) panel width height
                  :units units :class class :style style))

;;;;;;;;;;;;;;;;;;;;;
;; center-children ;;
;;;;;;;;;;;;;;;;;;;;;

(defgeneric center-children (clog-element &key vertical horizontal)
  (:documentation "Align children of CLOG-ELEMENT VERTICAL (default t)
and/or HORIZONTAL (default t). This will set the DISPLAY property of
CLOG-ELEMENT to :FLEX.

Note: if children of CLOG-ELEMENT are using :absolute positioning they will
not flow with flex and will not be centered. Instead use :relative positioning.

Note: to use with CLOG Buider Panels - use ENVELOPE-PANEL or in the builder
create a div at top:0 left:0 and size the div to be the boundaries of your panel
to be centered, then set the positioning on the panel to :relative.
Add all controls as child of that div."))

(defmethod center-children ((obj clog-element) &key (vertical t) (horizontal t))
  (set-styles obj `(("display" "flex")
                    ,(when vertical '("align-items" "center"))
                    ,(when horizontal '("justify-content" "center")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - clog-panel-box-layout
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-panel-box-layout ()
  ((center-panel
    :accessor center-panel
    :documentation "Center Panel")
   (top-panel
    :accessor top-panel
    :documentation "Top Panel")
   (left-panel
    :accessor left-panel
    :documentation "Left Panel")
   (bottom-panel
    :accessor bottom-panel
    :documentation "Bottom Panel")
   (right-panel
    :accessor right-panel
    :documentation "Right Panel"))
  (:documentation "CLOG Panel Box Layout Objects."))

;;;;;;;;;;;;;;;;;;
;; center-panel ;;
;;;;;;;;;;;;;;;;;;

(defgeneric center-panel (clog-panel-box-layout)
  (:documentation "Returns the center panel of a clog-panel-box-layout object."))

;;;;;;;;;;;;;;;
;; top-panel ;;
;;;;;;;;;;;;;;;

(defgeneric top-panel (clog-panel-box-layout)
  (:documentation "Returns the top panel of a clog-panel-box-layout object."))

;;;;;;;;;;;;;;;
;; top-panel ;;
;;;;;;;;;;;;;;;

(defgeneric top-panel (clog-panel-box-layout)
  (:documentation "Returns the top panel of a clog-panel-box-layout object."))

;;;;;;;;;;;;;;;;
;; left-panel ;;
;;;;;;;;;;;;;;;;

(defgeneric left-panel (clog-panel-box-layout)
  (:documentation "Returns the left panel of a clog-panel-box-layout object."))

;;;;;;;;;;;;;;;;;;
;; bottom-panel ;;
;;;;;;;;;;;;;;;;;;

(defgeneric bottom-panel (clog-panel-box-layout)
  (:documentation "Returns the bottom panel of a clog-panel-box-layout object."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create-panel-box-layout ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun create-panel-box-layout (clog-obj &key (top-height 50) (left-width 50)
                                           (bottom-height 50) (right-width 50)
                                           (units "px")
                                           (html-id nil))
  "Create a five panel app layout that fills entire contents of CLOG-OBJ.
HTML-ID if set is the base and top,left,right,center, bottom are added e.g.
if :HTML-ID \"myid\" then the HTML-ID for center will be: myid-center"
  (let ((panel-box (make-instance 'clog-panel-box-layout)))
    (unless html-id
      (setf html-id (generate-id)))
    (setf (top-panel panel-box)
          (create-panel clog-obj :left 0 :top 0 :right 0 :height top-height
                                 :units units
                                 :html-id (format nil "~A-top" html-id)))
    (setf (left-panel panel-box)
          (create-panel clog-obj :left 0 :top 0 :bottom 0 :width left-width
                                 :margin-top top-height
                                 :margin-bottom bottom-height
                                 :units units
                                 :html-id (format nil "~A-left" html-id)))
    (setf (right-panel panel-box)
          (create-panel clog-obj :right 0 :top 0 :bottom 0 :width right-width
                                 :margin-top top-height
                                 :margin-bottom bottom-height
                                 :units units
                                 :html-id (format nil "~A-right" html-id)))
    (setf (center-panel panel-box)
          (create-panel clog-obj :left 0 :top 0 :right 0 :bottom 0
                                 :margin-left left-width
                                 :margin-top top-height
                                 :margin-right right-width
                                 :margin-bottom bottom-height
                                 :units units
                                 :html-id (format nil "~A-center" html-id)))
    (setf (bottom-panel panel-box)
          (create-panel clog-obj :left 0 :bottom 0 :right 0
                                 :height bottom-height
                                 :units units
                                 :html-id (format nil "~A-bottom" html-id)))
    panel-box))


;;;;;;;;;;;;;;;;
;; fit-layout ;;
;;;;;;;;;;;;;;;;

(defgeneric fit-layout (clog-panel-box-layout)
  (:documentation "Recalculate layout based on size of outer panel content"))

(defmethod fit-layout ((obj clog-panel-box-layout))
  (let ((top-height (scroll-height (top-panel obj)))
        (bottom-height (scroll-height (bottom-panel obj)))
        (left-width (scroll-width (left-panel obj)))
        (right-width (scroll-width (right-panel obj))))
    (setf (height (top-panel obj)) top-height)
    (setf (height (bottom-panel obj)) bottom-height)
    (setf (width (left-panel obj)) left-width)
    (setf (width (right-panel obj)) right-width)
    (set-margin-side (left-panel obj) :top (unit :px top-height))
    (set-margin-side (right-panel obj) :top (unit :px top-height))
    (set-margin-side (left-panel obj) :bottom (unit :px bottom-height))
    (set-margin-side (right-panel obj) :bottom (unit :px bottom-height))
    (set-margin (center-panel obj)
                (unit :px top-height)
                (unit :px right-width)
                (unit :px bottom-height)
                (unit :px left-width))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - clog-panel-box
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-panel-box (clog-element)
  ((panel-box
    :accessor panel-box
    :documentation "CLOG-PANEL-BOX-LAYOUT access"))
  (:documentation "CLOG Panel-Box Objects."))

;;;;;;;;;;;;;;;;;;;;;;
;; create-panel-box ;;
;;;;;;;;;;;;;;;;;;;;;;

(defgeneric create-panel-box (clog-obj &key width height hidden class html-id auto-place)
  (:documentation "Create a new CLOG-Panel-Box, a div containg a
CLOG-PANEL-BOX-LAYOUT as child of CLOG-OBJ with and if :AUTO-PLACE
(default t) place-inside-bottom-of CLOG-OBJ. If hidden is true visiblep
is set to nil."))

(defmethod create-panel-box ((obj clog-obj) &key (width "100%") (height "100%")
                                              (hidden nil)
                                              (class nil)
                                              (html-id nil)
                                              (auto-place t))
  (let ((parent (create-child obj (format nil "<div~A~A~A~A/>"
                                          (if class
                                              (format nil " class='~A'" (escape-string class :html t))
                                              "")
                                          (if width
                                              (format nil " width='~A'" width)
                                              "")
                                          (if height
                                              (format nil " height='~A'" height)
                                              "")
                                          (if hidden
                                              " style='visibility:hidden;'"
                                              ""))
                              :clog-type  'clog-panel-box
                              :html-id    html-id
                              :auto-place auto-place)))
    (setf (panel-box parent) (create-panel-box-layout parent :html-id (html-id parent)))
    parent))

;;;;;;;;;;;;;;;
;; panel-box ;;
;;;;;;;;;;;;;;;

(defgeneric panel-box (clog-panel-box)
  (:documentation "Returns the CLOG-PANEL-BOX-LAYOUT object contained in the CLOG-PANEL-BOX."))
