(in-package #:immortal-coil)

;;; The in-city grid - a distinct walk from the inter-place road. A city is
;;; blocks of connected houses with streets between; you enter a NAMED DOORWAY
;;; to reach a district, and leave by the GATE on the city's edge. It shares the
;;; overworld engine (movement, camera, the traveller, the trail); only
;;; generation, the door-finish, and the rendering differ.
;;;
;;; The night-city HUB: pick which district to enter and in which order. A door
;;; whose story is finished is dropped on the next visit (its :done flag is
;;; set), so the city is never the same twice - and the gate is always open, so
;;; a player can leave for Carcosa early and MISS the stories they skipped.
;;;
;;; A door spec is (glyph target &key name done exit). NAME is the sign over the
;;; doorway; DONE is the store flag that retires it; EXIT t marks the gate, set
;;; on the city's rim instead of a building face.

(defun jrpg-city-door-glyph (spec)
  (let ((g (first spec)))
    (if (stringp g) (char g 0) g)))

(defun jrpg-city-door-open-p (spec)
  (let ((done (getf (cddr spec) :done)))
    (or (null done) (not (jrpg-value done)))))

(defun jrpg-city-door-name (spec)
  (or (getf (cddr spec) :name) (string (jrpg-city-door-glyph spec))))

(defun jrpg-city-door-exit-p (spec)
  (and (getf (cddr spec) :exit) t))

(defun jrpg-city-parse-doors (specs)
  "Returns (values targets names glyphs exit-glyphs) for the OPEN doors:
TARGETS glyph->target, NAMES glyph->name, GLYPHS all open, EXIT-GLYPHS the
rim gates."
  (let ((targets nil) (names nil) (glyphs nil) (exits nil))
    (dolist (spec specs)
      (when (jrpg-city-door-open-p spec)
        (let ((g (jrpg-city-door-glyph spec)))
          (push (cons g (second spec)) targets)
          (push (cons g (jrpg-city-door-name spec)) names)
          (push g glyphs)
          (when (jrpg-city-door-exit-p spec) (push g exits)))))
    (values (nreverse targets) (nreverse names) (nreverse glyphs) (nreverse exits))))

(defun jrpg-city-rng (seed)
  "A small deterministic PRNG (an LCG). Generation draws only from this, never
the global RNG, so a city regenerates identically for a given SEED - the layout
does not reshuffle when you step into a door and back out, and combat rolls stay
truly random."
  (let ((state (logand (+ (* (logand seed #xffffffff) 2654435761) 1) #xffffffff)))
    (lambda (lo hi)
      (setf state (logand (+ (* state 1103515245) 12345) #xffffffff))
      (if (> hi lo)
          (+ lo (mod (ash state -15) (1+ (- hi lo))))
          lo))))

(defun jrpg-gen-city (w h interior-glyphs exit-glyphs seed)
  "Returns (values rows start-x start-y) for a town of large, separated houses.
The interior is divided into plots; most plots hold one big building set back
from wide streets (a few are left open). District doors are carved into building
faces, EXIT gates sit on the top rim. Deterministic in SEED, and each door
probes from its own seed so finishing one story never moves the others."
  (let* ((grid (make-array (list h w) :initial-element #\.)) ; all street first
         (rng (jrpg-city-rng seed))
         (buildings nil))
    (flet ((rnd (lo hi) (funcall rng lo hi))
           (street-p (x y)
             (and (<= 0 x) (< x w) (<= 0 y) (< y h)
                  (member (aref grid y x) '(#\. #\+) :test #'char=))))
      ;; plots: a coarse grid; most hold one big house, inset from the streets so
      ;; wide lanes run between them (no cramped one-cell alleys)
      (let ((plot-w 9) (plot-h 8))
        (loop for py from 1 by plot-h while (< py (- h 4))
              do (loop for px from 1 by plot-w while (< px (- w 4))
                       do (let* ((avail-w (min plot-w (- (1- w) px)))
                                 (avail-h (min plot-h (- (1- h) py)))
                                 (bw (min (- avail-w 2) (rnd 4 6)))
                                 (bh (min (- avail-h 2) (rnd 3 5))))
                            (when (and (>= bw 3) (>= bh 3) (> (rnd 0 9) 1))
                              (let* ((bx (+ px 1 (rnd 0 (max 0 (- avail-w 2 bw)))))
                                     (by (+ py 1 (rnd 0 (max 0 (- avail-h 2 bh)))))
                                     (right (+ bx bw -1))
                                     (bottom (+ by bh -1)))
                                (when (and (< right (1- w)) (< bottom (1- h)))
                                  (loop for yy from by to bottom
                                        do (loop for xx from bx to right
                                                 do (setf (aref grid yy xx) #\#)))
                                  (push (list bx by right bottom) buildings))))))))
      ;; sparse street lamps
      (dotimes (i (max 4 (floor (* w h) 80)))
        (let ((lx (rnd 1 (- w 2))) (ly (rnd 1 (- h 2))))
          (when (char= (aref grid ly lx) #\.)
            (setf (aref grid ly lx) #\+))))
      ;; exit gates spread along the top rim - the way out
      (let ((k (length exit-glyphs)))
        (loop for g in exit-glyphs
              for i from 1
              for ex = (max 1 (min (- w 2) (floor (* i w) (1+ k))))
              do (setf (aref grid 0 ex) g)))
      ;; district doors: each glyph probes building faces from its own seed, so
      ;; its spot is stable no matter which other doors are open this visit
      (dolist (g interior-glyphs)
        (let ((grng (jrpg-city-rng (logxor (logand seed #xffffffff)
                                           (* 2246822519 (char-code g)))))
              (placed nil))
          (loop repeat 800 until placed
                do (let ((x (funcall grng 1 (- w 2)))
                         (y (funcall grng 1 (- h 2))))
                     (when (and (char= (aref grid y x) #\#)
                                (or (street-p (1- x) y) (street-p (1+ x) y)
                                    (street-p x (1- y)) (street-p x (1+ y))))
                       (setf (aref grid y x) g placed t))))))
      ;; start: a street cell low and left
      (let ((sx 1) (sy (- h 2)))
        (block found
          (loop for y from (- h 2) downto 1
                do (loop for x from 1 below (1- w)
                         do (when (char= (aref grid y x) #\.)
                              (setf sx x sy y)
                              (return-from found)))))
        (values (jrpg-gen-rows grid) sx sy)))))

(defun make-fresh-jrpg-city (node)
  (jrpg-init-state)
  (let* ((w (jrpg-overworld-config-int node :gen-width 26))
         (h (jrpg-overworld-config-int node :gen-height 13))
         (prefix (minigame-config-value node :store-prefix "jrpg-city"))
         (seed-key (concatenate 'string prefix "-seed"))
         ;; one seed per playthrough, kept in the saved store, so the town is
         ;; stable across entering a door and stepping back out (only finishing
         ;; a story, which retires its door, changes the layout)
         (seed (or (jrpg-value seed-key)
                   (let ((s (get-random-value 1 1000000)))
                     (setf (jrpg-value seed-key) s)
                     s)))
         (specs (let ((v (minigame-config-value node :doors)))
                  (if (listp v) v nil))))
    (multiple-value-bind (targets names glyphs exits) (jrpg-city-parse-doors specs)
      (let ((interior (remove-if (lambda (g) (member g exits)) glyphs)))
        (multiple-value-bind (rows sx sy) (jrpg-gen-city w h interior exits seed)
          (make-jrpg-overworld
           :node-id (node-id node)
           :map (coerce rows 'vector)
           :mode :city
           :doors targets
           :door-names names
           :finish-glyphs glyphs
           :tile-messages (minigame-config-value node :tile-messages)
           :legend (minigame-config-value
                    node :legend
                    "enter a doorway; the gate on the rim is the way on.")
           :store-prefix prefix
           :x sx :y sy
           :encounter-target (minigame-config-value node :encounter-target)
           :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
           :message (minigame-config-value
                     node :start-message
                     "the night city. arrows or wasd move; the doorways are signed.")))))))

(defun ensure-jrpg-city (node)
  (ensure-jrpg-overworld-session node #'make-fresh-jrpg-city))

;;; --- city rendering: connected houses, named doorways, a rim gate ---

(defun jrpg-city-building-p (game x y)
  (char= (jrpg-overworld-cell game x y) #\#))

;; streets stay near-black so the white buildings and the traveller pop; the
;; cobble is laid faintly underneath for paved texture, not a white wash
(defvar *jrpg-city-floor-tint* (make-color 255 255 255 38))

(defun jrpg-city-tile (atlas role sx sy &optional tint)
  "Draw the tile bound to ROLE (see *jrpg-tile-map* in jrpg/tiles.lisp) into the
cell at SX,SY. Editing the tile map repoints these without touching code."
  (multiple-value-bind (col row) (jrpg-tile-coords role)
    (jrpg-draw-tile atlas col row sx sy +jrpg-overworld-tile-size+ tint)))

(defun draw-jrpg-city-building-tile (game atlas sx sy mx my)
  "A building cell: the top edge is roofed - left/middle/right pieces chosen by
where the roof run ends, exactly as the roofs are laid out in the scenes - a
cell whose front faces the street gets a window, the rest is brick wall."
  (cond
    ((not (jrpg-city-building-p game mx (1- my)))
     (jrpg-city-tile atlas
                     (cond ((not (jrpg-city-building-p game (1- mx) my)) :roof-left)
                           ((not (jrpg-city-building-p game (1+ mx) my)) :roof-right)
                           (t :roof-middle))
                     sx sy))
    ((not (jrpg-city-building-p game mx (1+ my)))
     (jrpg-city-tile atlas :window sx sy))
    (t (jrpg-city-tile atlas :wall sx sy))))

(defun draw-jrpg-city-cell-tile (game atlas cell sx sy mx my)
  (cond
    ((char= cell #\#) (draw-jrpg-city-building-tile game atlas sx sy mx my))
    ((char= cell #\+)
     (jrpg-city-tile atlas :floor sx sy *jrpg-city-floor-tint*)
     (jrpg-city-tile atlas :lamp sx sy))
    ((char= cell #\.)
     (jrpg-city-tile atlas :floor sx sy *jrpg-city-floor-tint*))
    (t                                                  ; a door glyph
     (let ((edge (or (= mx 0) (= my 0)
                     (= mx (1- (jrpg-overworld-width game)))
                     (= my (1- (jrpg-overworld-height game))))))
       (if edge
           (progn
             (jrpg-city-tile atlas :floor sx sy *jrpg-city-floor-tint*)
             (jrpg-city-tile atlas :gate sx sy))
           (jrpg-city-tile atlas :doorway sx sy))))))

(defun draw-jrpg-city-house-cell (game sx sy mx my)
  "Part of a house: a dark wall, with a lit roof eave and walls drawn only on
sides that face the street - so a whole block reads as one building, and the
inner cells just fill. A window where the wall fronts the street."
  (let* ((s +jrpg-overworld-tile-size+)
         (up (jrpg-city-building-p game mx (1- my)))
         (dn (jrpg-city-building-p game mx (1+ my)))
         (lf (jrpg-city-building-p game (1- mx) my))
         (rt (jrpg-city-building-p game (1+ mx) my)))
    (jrpg-ow-fill sx sy s s 58)                          ; wall fill
    (unless up (jrpg-ow-fill sx sy s 4 168))             ; lit roof eave
    (unless dn (jrpg-ow-fill sx (+ sy s -2) s 2 120)     ; base sill
               (jrpg-ow-fill (+ sx (/ s 2) -3) (+ sy 8) 6 6 150)) ; a window
    (unless lf (jrpg-ow-fill sx sy 2 s 112))             ; left wall
    (unless rt (jrpg-ow-fill (+ sx s -2) sy 2 s 112))))  ; right wall

(defun draw-jrpg-city-lamp (cx cy)
  (jrpg-ow-fill (- cx 5) (- cy 5) 10 10 26)              ; glow
  (jrpg-ow-fill (- cx 2) (- cy 2) 4 4 230))             ; flame

(defun jrpg-door-label-width (name)
  (+ (text-width name 12) 14))

(defun jrpg-draw-door-label (name cx top)
  "A floating name plate: white text in a SOLID black box with a white border,
so the sign reads cleanly over lit roofs."
  (when (and name (plusp (length name)))
    (let* ((w (jrpg-door-label-width name))
           (lx (- cx (/ w 2))))
      (claylib/ll:draw-rectangle (round lx) (round top) (round w) 17
                                 (claylib::c-ptr (make-color 0 0 0 255)))
      (draw-rectangle-outline lx top w 17 (make-color 255 255 255 200) :thickness 1)
      (draw-centered-text name cx (+ top 8) 12 (make-color 255 255 255 240)))))

(defun draw-jrpg-city-door (game sx sy mx my)
  "The doorway body in a building face, or - on the city rim - a wide gate. The
name plate is drawn later, in its own pass, so it always sits on top."
  (let* ((s +jrpg-overworld-tile-size+)
         (cx (+ sx (/ s 2)))
         (edge (or (= mx 0) (= my 0)
                   (= mx (1- (jrpg-overworld-width game)))
                   (= my (1- (jrpg-overworld-height game))))))
    (jrpg-ow-fill sx sy s s 58)                          ; the wall it sits in
    (jrpg-ow-fill sx sy s 4 168)                         ; lintel / roof
    (if edge
        (progn                                           ; a city gate (the way out)
          (jrpg-ow-fill (- cx 9) (+ sy 4) 18 (- s 4) 210)
          (jrpg-ow-fill (- cx 7) (+ sy 7) 14 (- s 7) 60))
        (progn                                           ; an interior doorway
          (jrpg-ow-fill (- cx 5) (+ sy 6) 10 (- s 6) 190)
          (jrpg-ow-fill (- cx 3) (+ sy 9) 6 (- s 10) 55)))))

(defun draw-jrpg-city-door-label (game sx sy mx my name)
  "The floating name plate. It sits above the door but drops below it when the
player stands anywhere under its full width, so it never hides the traveller.
Drawn in a pass after all tiles, so its solid background is never overdrawn by
the house behind it (the bug where a dodged sign read as bare text on a roof)."
  (when (and name (plusp (length name)))
    (let* ((s +jrpg-overworld-tile-size+)
           (cx (+ sx (/ s 2)))
           ;; how many columns the plate spans on either side of the door, so the
           ;; dodge covers the whole label and not just the door's own tile
           (half-cols (ceiling (/ (jrpg-door-label-width name) 2.0) s))
           (player-over (and (= (jrpg-overworld-y game) (1- my))
                             (<= (abs (- (jrpg-overworld-x game) mx)) half-cols))))
      (jrpg-draw-door-label name cx (if player-over (+ sy s 3) (- sy 17))))))

(defun jrpg-city-cell-door-name (game cell)
  (cdr (assoc cell (jrpg-overworld-door-names game) :test #'char=)))

(defun jrpg-city-visible-cells (game fn)
  "Call FN with (col row mx my cell) for each on-screen cell of the city."
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (loop for row below +jrpg-overworld-view-rows+
          do (loop for col below +jrpg-overworld-view-cols+
                   for mx = (+ cam-x col)
                   for my = (+ cam-y row)
                   when (and (< mx (jrpg-overworld-width game))
                             (< my (jrpg-overworld-height game)))
                     do (funcall fn col row mx my
                                 (jrpg-overworld-cell game mx my))))))

(defun draw-jrpg-city-cell-shape (game cell sx sy mx my)
  "The fallback renderer (no tile atlas): the original drawn rectangles."
  (let ((cx (+ sx (/ +jrpg-overworld-tile-size+ 2)))
        (cy (+ sy (/ +jrpg-overworld-tile-size+ 2))))
    (cond
      ((char= cell #\#) (draw-jrpg-city-house-cell game sx sy mx my))
      ((char= cell #\+) (draw-jrpg-city-lamp cx cy))
      ((char= cell #\.) nil)
      (t (draw-jrpg-city-door game sx sy mx my)))))

(defun draw-jrpg-city-map (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (jrpg-overworld-draw-trail game cam-x cam-y))
  (let ((atlas (jrpg-tile-atlas)))
    ;; pass 1: the ground - streets, buildings, lamps, doors (tiles if the atlas
    ;; loaded, else the drawn shapes)
    (jrpg-city-visible-cells
     game
     (lambda (col row mx my cell)
       (multiple-value-bind (sx sy) (jrpg-overworld-cell-screen col row)
         (if atlas
             (draw-jrpg-city-cell-tile game atlas cell sx sy mx my)
             (draw-jrpg-city-cell-shape game cell sx sy mx my)))))
    ;; pass 2: the name plates, on top of every tile so a dodged sign keeps its
    ;; solid background
    (jrpg-city-visible-cells
     game
     (lambda (col row mx my cell)
       (unless (member cell '(#\# #\+ #\.) :test #'char=)
         (multiple-value-bind (sx sy) (jrpg-overworld-cell-screen col row)
           (draw-jrpg-city-door-label game sx sy mx my
                                      (jrpg-city-cell-door-name game cell))))))))

(defun update-jrpg-city-minigame (node dt)
  (declare (ignore dt))
  (jrpg-overworld-step node (ensure-jrpg-city node)))

(defun draw-jrpg-city-minigame (node color)
  (declare (ignore color))
  (jrpg-overworld-render-frame (ensure-jrpg-city node) #'draw-jrpg-city-map))

(dialog-minigame-kind :jrpg-city
                      :update #'update-jrpg-city-minigame
                      :draw #'draw-jrpg-city-minigame)
