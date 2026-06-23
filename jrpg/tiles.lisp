(in-package #:immortal-coil)

;;; ----------------------------------------------------------------------------
;;; Tile map for the Kenney 1-bit atlas: assets/tiles/kenney-1bit-mono.png,
;;; a 48-column x 22-row grid of 16x16 tiles (col 0..47, row 0..21).
;;;
;;; HOW TO FIX A TILE:
;;;   1. Open  assets/tiles/atlas-reference.png  -- it shows every tile scaled
;;;      up, with its column printed along the top and its row down the left.
;;;   2. Find the tile you want. Read its COLUMN (top axis) and ROW (left axis).
;;;   3. Put those two numbers in the entry below (the 2nd and 3rd values).
;;;   4. In the trailing string, write what the tile actually shows -- that tells
;;;      me which of my picks were wrong (e.g. "treasure chest, not a roof").
;;;
;;; The renderer reads this live; restart the game (or start a new game) to see
;;; changes. Each entry is (ROLE COL ROW "what it shows").
;;; ----------------------------------------------------------------------------

(defparameter *jrpg-tile-map*
  '((:floor     8  1  "")    ; ground laid faintly under the streets
    (:wall      8  0  "")    ; a building wall (interior block)
    (:wall-top 11  6  "")    ; the top edge of a building (roof / eave line)
    (:window   43  4  "")    ; a wall that fronts the street, with a window
    (:doorway  10  6  "")    ; a doorway in a building wall (a district door)
    (:gate     39  4  "")    ; the city gate on the rim (the way out)
    (:lamp     42  3  "")    ; a street lamp / torch
    (:player   29  9  "")))  ; the traveller

(defun jrpg-tile-coords (role)
  "Return (values col row) for ROLE from *jrpg-tile-map*; (0 . 0) if unset."
  (let ((entry (assoc role *jrpg-tile-map*)))
    (if entry
        (values (second entry) (third entry))
        (values 0 0))))
