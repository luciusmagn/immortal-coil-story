(in-package #:immortal-coil)

;;; JRPG renderer roles over Hexany's roguelike sheets.
;;;
;;; The defaults below keep the route playable before the tile labeler has been
;;; filled out. A saved Hexany label with one of a role's names wins over the
;;; fallback coordinate, so changing the art does not require touching this file.

(defparameter *jrpg-tile-roles*
  '((:floor
     :default ("general" 0 1)
     :labels ("jrpg floor" "city floor" "floor" "street" "cobble"))
    (:wall
     :default ("autotile" 3 0)
     :labels ("jrpg wall" "city wall" "wall" "brick wall"))
    (:wall-top
     :default ("autotile" 1 0)
     :labels ("jrpg roof" "city roof" "roof"))
    (:roof-left
     :default ("autotile" 0 0)
     :labels ("jrpg roof left" "roof left"))
    (:roof-middle
     :default ("autotile" 1 0)
     :labels ("jrpg roof middle" "roof middle" "roof"))
    (:roof-right
     :default ("autotile" 2 0)
     :labels ("jrpg roof right" "roof right"))
    (:window
     :default ("general" 27 1)
     :labels ("jrpg window" "city window" "window"))
    (:doorway
     :default ("general" 6 0)
     :labels ("jrpg doorway" "city doorway" "doorway" "door"))
    (:gate
     :default ("general" 8 0)
     :labels ("jrpg gate" "city gate" "gate"))
    (:player
     :default ("creatures" 0 0)
     :labels ("jrpg player" "hero" "player" "traveller"))))

(defun jrpg-tile-role (role)
  (rest (assoc role *jrpg-tile-roles*)))

(defun jrpg-label-entry-tile (entry)
  (when (and (listp entry)
             (stringp (getf entry :sheet))
             (integerp (getf entry :col))
             (integerp (getf entry :row)))
    (list (getf entry :sheet)
          (getf entry :col)
          (getf entry :row))))

(defun jrpg-tile-labeled-entry (labels)
  (loop for label in labels
        for entry = (and (fboundp 'hexany-label-entry)
                         (hexany-label-entry label))
        for tile = (jrpg-label-entry-tile entry)
        when tile
          do (return tile)))

(defun jrpg-tile-entry (role)
  (let* ((data (jrpg-tile-role role))
         (labels (getf data :labels))
         (default (getf data :default)))
    (or (jrpg-tile-labeled-entry labels)
        (and default (copy-list default))
        (list "general" 0 0))))

(defun jrpg-tile-coords (role)
  "Return (values sheet col row) for ROLE."
  (destructuring-bind (sheet col row) (jrpg-tile-entry role)
    (values sheet col row)))
