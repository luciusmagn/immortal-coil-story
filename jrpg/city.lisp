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

(defun jrpg-city-glyphs-by-kind (specs exit-p)
  (loop for spec in specs
        when (eq (jrpg-city-door-exit-p spec) exit-p)
          collect (jrpg-city-door-glyph spec)))

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

(defun jrpg-city-fill-rect (grid left top right bottom glyph)
  (loop for y from top to bottom
        do (loop for x from left to right
                 do (setf (aref grid y x) glyph))))

(defun jrpg-city-clamp-x (w x)
  (max 1 (min (- w 2) x)))

(defun jrpg-city-clamp-y (h y)
  (max 1 (min (- h 2) y)))

(defun jrpg-city-door-slots (w h &key north-front south-front left-x mid-x right-x)
  (let ((north-front (or north-front (jrpg-city-clamp-y h (floor h 3))))
        (south-front (or south-front (jrpg-city-clamp-y h (- h 3))))
        (left-x (or left-x (jrpg-city-clamp-x w (floor w 5))))
        (mid-x (or mid-x (jrpg-city-clamp-x w (floor w 2))))
        (right-x (or right-x (jrpg-city-clamp-x w (- w (floor w 5) 1)))))
    (list (list left-x south-front)
          (list right-x north-front)
          (list left-x north-front)
          (list right-x south-front)
          (list (jrpg-city-clamp-x w (- mid-x 3)) south-front)
          (list (jrpg-city-clamp-x w (+ mid-x 3)) south-front)
          (list (jrpg-city-clamp-x w (- mid-x 3)) north-front)
          (list (jrpg-city-clamp-x w (+ mid-x 3)) north-front))))

(defun jrpg-city-street-cell-p (grid x y)
  (member (aref grid y x) '(#\. #\+) :test #'char=))

(defun jrpg-city-door-slot-spaced-p (slot used)
  "Keep signed doors from crowding each other on one frontage. Adjacent glyphs
make the city hard to read, and their labels overlap in the renderer."
  (destructuring-bind (x y) slot
    (every (lambda (other)
             (destructuring-bind (other-x other-y) other
               (or (>= (abs (- x other-x)) 3)
                   (>= (abs (- y other-y)) 2))))
           used)))

(defun jrpg-city-door-slot-valid-p (grid w h slot used)
  (and (consp slot)
       (integerp (first slot))
       (integerp (second slot))
       (destructuring-bind (x y) slot
         (and (< 0 x (1- w))
              (< 0 y (1- h))
              (char= (aref grid y x) #\#)
              (not (member slot used :test #'equal))
              (jrpg-city-door-slot-spaced-p slot used)
              (or (jrpg-city-street-cell-p grid x (1+ y))
                  (jrpg-city-street-cell-p grid x (1- y))
                  (jrpg-city-street-cell-p grid (1+ x) y)
                  (jrpg-city-street-cell-p grid (1- x) y))))))

(defun jrpg-city-extra-door-slots (grid w h used)
  (let ((slots nil))
    (loop for y from 1 below (1- h)
          do (loop for x from 1 below (1- w)
                   when (jrpg-city-door-slot-valid-p grid w h (list x y) used)
                     do (push (list x y) slots)))
    (nreverse slots)))

(defun jrpg-city-gate-x (w count index)
  (let ((center (floor w 2))
        (spacing 4)
        (offset (- index (/ (1- count) 2.0))))
    (max 1 (min (- w 2) (round (+ center (* offset spacing)))))))

(defun jrpg-city-unique-slots (slots)
  (let ((seen nil)
        (unique nil))
    (dolist (slot slots (nreverse unique))
      (unless (member slot seen :test #'equal)
        (push slot seen)
        (push slot unique)))))

(defun jrpg-city-next-door-slot (grid w h preferred used)
  (if (jrpg-city-door-slot-valid-p grid w h preferred used)
      preferred
      (find-if (lambda (slot)
                 (jrpg-city-door-slot-valid-p grid w h slot used))
               (jrpg-city-extra-door-slots grid w h used))))

(defun jrpg-city-place-open-doors (grid w h open-glyphs planned-glyphs
                                   &key slots)
  (let* ((slots (jrpg-city-unique-slots
                 (or slots (jrpg-city-door-slots w h))))
         (used nil))
    (loop for glyph in planned-glyphs
          for index from 0
          for candidate = (nth index slots)
          for slot = (jrpg-city-next-door-slot grid w h candidate used)
          do (cond
               (slot
                (push slot used)
                (when (member glyph open-glyphs :test #'char=)
                  (destructuring-bind (x y) slot
                    (setf (aref grid y x) glyph))))
               ((member glyph open-glyphs :test #'char=)
                (runtime-warn "JRPG city could not place open doorway ~s; map is too crowded."
                              glyph))))))

(defun jrpg-gen-city (w h interior-glyphs exit-glyphs seed
                      &optional all-interior-glyphs all-exit-glyphs)
  "Returns (values rows start-x start-y) for a small RPG town: north gate, main
street, square, alleys, and stable building-front door slots. The seed changes
the block shape without moving surviving doors when another district is done."
  (let* ((rng (jrpg-city-rng seed))
         (grid (make-array (list h w) :initial-element #\.))
         (mid (jrpg-city-clamp-x w (+ (floor w 2) (funcall rng -1 1))))
         (north-gap (funcall rng 5 7))
         (south-gap (funcall rng 4 6))
         (north-front (jrpg-city-clamp-y h (+ (floor h 3) (funcall rng -1 1))))
         (south-front (jrpg-city-clamp-y h (- h (funcall rng 3 4))))
         (south-top (jrpg-city-clamp-y h
                                       (max (+ north-front 2)
                                            (- south-front (funcall rng 2 4)))))
         (cross-y (jrpg-city-clamp-y h (+ (floor h 2) (funcall rng -1 1))))
         (left-x (jrpg-city-clamp-x w (floor w 5)))
         (right-x (jrpg-city-clamp-x w (- w (floor w 5) 1)))
         (square-radius-x (funcall rng 3 4))
         (square-radius-y (funcall rng 1 2))
         (north-left-x (jrpg-city-clamp-x
                        w (funcall rng 3 (max 3 (- mid north-gap 1)))))
         (north-right-x (jrpg-city-clamp-x
                         w (funcall rng (min (- w 4) (+ mid north-gap 1))
                                    (- w 4))))
         (south-left-x (jrpg-city-clamp-x
                        w (funcall rng 3 (max 3 (- mid south-gap 1)))))
         (south-right-x (jrpg-city-clamp-x
                         w (funcall rng (min (- w 4) (+ mid south-gap 1))
                                    (- w 4))))
         (door-slots (append (list (list south-left-x south-front)
                                   (list north-right-x north-front)
                                   (list north-left-x north-front)
                                   (list south-right-x south-front))
                             (jrpg-city-door-slots
                              w h
                              :north-front north-front
                              :south-front south-front
                              :left-x left-x
                              :mid-x mid
                              :right-x right-x)))
         (planned-interior (or all-interior-glyphs interior-glyphs))
         (planned-exits (or all-exit-glyphs exit-glyphs)))
    (loop for x below w do (setf (aref grid 0 x) #\#))
    (jrpg-city-fill-rect grid 2 1 (max 3 (- mid north-gap)) north-front #\#)
    (jrpg-city-fill-rect grid (min (- w 4) (+ mid north-gap)) 1
                         (- w 3) north-front #\#)
    (jrpg-city-fill-rect grid 2 south-top (max 3 (- mid south-gap))
                         south-front #\#)
    (jrpg-city-fill-rect grid (min (- w 4) (+ mid south-gap)) south-top
                         (- w 3) south-front #\#)
    (jrpg-city-fill-rect grid (max 2 (- mid (funcall rng 4 5))) (- h 4)
                         (max 3 (- mid 2)) south-front #\#)
    (jrpg-city-fill-rect grid (min (- w 4) (+ mid 2)) (- h 4)
                         (min (- w 3) (+ mid (funcall rng 4 5)))
                         south-front #\#)
    (loop for y from 1 below (1- h)
          do (setf (aref grid y mid) #\.))
    (jrpg-city-fill-rect grid (max 1 (- mid square-radius-x))
                         (jrpg-city-clamp-y h (- cross-y square-radius-y))
                         (min (- w 2) (+ mid square-radius-x))
                         (jrpg-city-clamp-y h (+ cross-y square-radius-y))
                         #\.)
    (loop for x from 1 to (- w 2)
          do (setf (aref grid cross-y x) #\.))
    (loop repeat 2
          for alley-y = (jrpg-city-clamp-y
                         h (+ north-front (funcall rng 1 (max 1 (- south-top
                                                                  north-front)))))
          do (loop for x from (max 1 (- mid (funcall rng 7 9)))
                   to (min (- w 2) (+ mid (funcall rng 7 9)))
                   do (setf (aref grid alley-y x) #\.)))
    (dolist (lamp (list (list left-x (floor h 2))
                        (list right-x (floor h 2))
                        (list (max 1 (- mid 3)) (jrpg-city-clamp-y h (1+ north-front)))
                        (list (min (- w 2) (+ mid 3)) (jrpg-city-clamp-y h (1+ north-front)))))
      (destructuring-bind (x y) lamp
        (when (char= (aref grid y x) #\.)
          (setf (aref grid y x) #\+))))
    (let ((count (max 1 (length planned-exits))))
      (loop for glyph in planned-exits
            for index from 0
            when (member glyph exit-glyphs :test #'char=)
              do (setf (aref grid 0 (jrpg-city-gate-x w count index)) glyph)))
    (jrpg-city-place-open-doors grid w h interior-glyphs planned-interior
                                :slots door-slots)
    (values (jrpg-gen-rows grid) mid (- h 2))))

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
      (let ((interior (remove-if (lambda (g) (member g exits)) glyphs))
            (all-interior (jrpg-city-glyphs-by-kind specs nil))
            (all-exits (jrpg-city-glyphs-by-kind specs t)))
        (multiple-value-bind (rows sx sy)
            (jrpg-gen-city w h interior exits seed all-interior all-exits)
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
