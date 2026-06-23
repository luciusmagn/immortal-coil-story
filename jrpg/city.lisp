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
  "Returns (values rows start-x start-y) for a town of rectangular blocks on a
near-regular street grid: a central plaza, lamps at the crossings, district
doors set on building faces that front a street, and EXIT gates on the top rim.
Deterministic in SEED (see jrpg-city-rng); each door's position depends only on
SEED and its glyph, so finishing one story never moves the others."
  (let* ((grid (make-array (list h w) :initial-element #\#))
         (rng (jrpg-city-rng seed))
         (cols nil) (rows nil))
    (flet ((rnd (lo hi) (funcall rng lo hi))
           (street-p (x y)
             (and (<= 0 x) (< x w) (<= 0 y) (< y h)
                  (member (aref grid y x) '(#\. #\+) :test #'char=))))
      ;; rim street
      (dotimes (i w) (setf (aref grid 0 i) #\. (aref grid (1- h) i) #\.))
      (dotimes (i h) (setf (aref grid i 0) #\. (aref grid i (1- w)) #\.))
      ;; avenue grid: streets at near-regular spacing, so blocks are tidy
      ;; rectangles of connected houses rather than noise
      (let ((x (rnd 3 4)))
        (loop while (< x (1- w))
              do (push x cols)
                 (dotimes (yy h) (setf (aref grid yy x) #\.))
                 (incf x (rnd 4 5))))
      (let ((y (rnd 2 3)))
        (loop while (< y (1- h))
              do (push y rows)
                 (dotimes (xx w) (setf (aref grid y xx) #\.))
                 (incf y (rnd 3 4))))
      ;; a central plaza: open a small square at the middle crossing
      (let* ((cs (sort (copy-list cols) #'<))
             (rs (sort (copy-list rows) #'<))
             (px (if cs (nth (floor (length cs) 2) cs) (floor w 2)))
             (py (if rs (nth (floor (length rs) 2) rs) (floor h 2))))
        (loop for yy from (max 1 (1- py)) to (min (- h 2) (1+ py))
              do (loop for xx from (max 1 (- px 2)) to (min (- w 2) (+ px 2))
                       do (setf (aref grid yy xx) #\.))))
      ;; lamps at about half the street crossings (a lit corner, not scatter)
      (dolist (cx cols)
        (dolist (ry rows)
          (when (and (char= (aref grid ry cx) #\.) (zerop (rnd 0 1)))
            (setf (aref grid ry cx) #\+))))
      ;; exit gates spread along the top rim - the way out
      (let ((k (length exit-glyphs)))
        (loop for g in exit-glyphs
              for i from 1
              for ex = (max 1 (min (- w 2) (floor (* i w) (1+ k))))
              do (setf (aref grid 0 ex) g)))
      ;; interior doors: each glyph probes from its OWN seed, so it always lands
      ;; in the same place no matter which other doors are open this visit
      (dolist (g interior-glyphs)
        (let ((grng (jrpg-city-rng (logxor (logand seed #xffffffff)
                                           (* 2246822519 (char-code g))))))
          (loop repeat 600
                do (let ((x (funcall grng 1 (- w 2)))
                         (y (funcall grng 1 (- h 2))))
                     (when (and (char= (aref grid y x) #\#)
                                (or (street-p (1- x) y) (street-p (1+ x) y)
                                    (street-p x (1- y)) (street-p x (1+ y))))
                       (setf (aref grid y x) g)
                       (return))))))
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

(defun draw-jrpg-city-map (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (jrpg-overworld-draw-trail game cam-x cam-y))
  (let ((s +jrpg-overworld-tile-size+))
    ;; pass 1: the ground - houses, lamps, and door bodies
    (jrpg-city-visible-cells
     game
     (lambda (col row mx my cell)
       (multiple-value-bind (sx sy) (jrpg-overworld-cell-screen col row)
         (let ((cx (+ sx (/ s 2))) (cy (+ sy (/ s 2))))
           (cond
             ((char= cell #\#) (draw-jrpg-city-house-cell game sx sy mx my))
             ((char= cell #\+) (draw-jrpg-city-lamp cx cy))
             ((char= cell #\.) nil)
             (t (draw-jrpg-city-door game sx sy mx my)))))))
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
