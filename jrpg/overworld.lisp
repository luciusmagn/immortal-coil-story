(in-package #:immortal-coil)

(defconstant +jrpg-overworld-tile-size+ 24)
(defconstant +jrpg-overworld-left+ 250)
(defconstant +jrpg-overworld-top+ 160)
(defconstant +jrpg-overworld-view-cols+ 30)
(defconstant +jrpg-overworld-view-rows+ 9)

(defparameter *jrpg-overworld-map*
  #("................"
    "...^^^^.....o..."
    "..^....^.....T.."
    "..^....^........"
    ".V...B....!!...."
    ".....R........$."
    "......~~~......."))

;;; Procedural overworld. A big map with a guaranteed winding road from
;;; the west edge to the finish, the occurrence's landmarks strung along
;;; that road, and structured geography around it: rivers, lakes,
;;; mountain ranges, forest belts, and pickups. Generated fresh each time
;;; the walk is entered, so the route is never the same.

(defun jrpg-gen-rows (grid)
  (loop for y below (array-dimension grid 0)
        collect (coerce (loop for x below (array-dimension grid 1)
                              collect (aref grid y x))
                        'string)))

(defun jrpg-gen-road-route (grid w h points)
  "Carve a readable one-tile RPG road through POINTS, returning its cells in
travel order. The route favors horizontal progress but bends at authored-feeling
control points instead of wandering like noise."
  (let ((road nil)
        (x (first (first points)))
        (y (second (first points))))
    (labels ((mark-road ()
               (setf (aref grid y x) #\,)
               (unless (member (list x y) road :test #'equal)
                 (push (list x y) road)))
             (step-axis (horizontal-p tx ty)
               (if horizontal-p
                   (incf x (if (< x tx) 1 -1))
                   (incf y (if (< y ty) 1 -1)))
               (setf x (max 1 (min (- w 2) x))
                     y (max 1 (min (- h 2) y)))))
      (mark-road)
      (dolist (target (rest points))
        (destructuring-bind (tx ty) target
          (setf tx (max 1 (min (- w 2) tx))
                ty (max 1 (min (- h 2) ty)))
          (loop until (and (= x tx) (= y ty))
                do (let ((move-x (and (/= x tx)
                                      (or (= y ty)
                                          (plusp (get-random-value 0 2))))))
                     (step-axis move-x tx ty)
                     (mark-road)))))
      (nreverse road))))

(defun jrpg-gen-world-clamp-x (w x)
  (max 1 (min (- w 2) x)))

(defun jrpg-gen-world-clamp-y (h y)
  (max 1 (min (- h 2) y)))

(defun jrpg-gen-terrain-paint (grid w h x y glyph avoid)
  (when (and (< 0 x (1- w))
             (< 0 y (1- h))
             (not (member (aref grid y x) avoid :test #'char=)))
    (setf (aref grid y x) glyph)))

(defun jrpg-gen-terrain-patch (grid w h cx cy glyph avoid radius)
  (loop for dy from (- radius) to radius
        do (loop for dx from (- radius) to radius
                 when (<= (+ (abs dx) (abs dy)) radius)
                   do (jrpg-gen-terrain-paint grid w h
                                              (+ cx dx) (+ cy dy)
                                              glyph avoid))))

(defun jrpg-gen-terrain-path (grid w h points glyph avoid &key (radius 0))
  "Draw a coherent terrain feature through POINTS. Used for rivers and mountain
ranges so the map reads as geography, not scattered cells."
  (let ((x (first (first points)))
        (y (second (first points))))
    (labels ((mark ()
               (jrpg-gen-terrain-patch grid w h x y glyph avoid radius))
             (step-axis (horizontal-p tx ty)
               (if horizontal-p
                   (incf x (if (< x tx) 1 -1))
                   (incf y (if (< y ty) 1 -1)))
               (setf x (jrpg-gen-world-clamp-x w x)
                     y (jrpg-gen-world-clamp-y h y))))
      (mark)
      (dolist (target (rest points))
        (destructuring-bind (tx ty) target
          (setf tx (jrpg-gen-world-clamp-x w tx)
                ty (jrpg-gen-world-clamp-y h ty))
          (loop until (and (= x tx) (= y ty))
                do (let ((move-x (and (/= x tx)
                                      (or (= y ty)
                                          (plusp (get-random-value 0 1))))))
                     (step-axis move-x tx ty)
                     (mark))))))))

(defun jrpg-gen-region (grid w h cx cy radius-x radius-y glyph avoid)
  "Paint an oval-ish terrain region around CX,CY, sparing AVOID glyphs."
  (loop for y from (- cy radius-y) to (+ cy radius-y)
        do (loop for x from (- cx radius-x) to (+ cx radius-x)
                 when (and (< 0 x (1- w))
                           (< 0 y (1- h))
                           (<= (+ (/ (expt (- x cx) 2)
                                     (max 1 (expt radius-x 2)))
                                  (/ (expt (- y cy) 2)
                                     (max 1 (expt radius-y 2))))
                               1.25)
                           (not (member (aref grid y x) avoid :test #'char=)))
                   do (setf (aref grid y x) glyph))))

(defun jrpg-gen-road-bridge (grid w h road)
  "Draw a north-south river crossing the road once, bridged on the route."
  (let* ((bridge (nth (max 1 (min (1- (length road))
                                  (floor (* (length road) 2) 3)))
                      road))
         (bridge-x (first bridge))
         (bridge-y (second bridge)))
    (jrpg-gen-terrain-path
     grid w h
     (list (list (+ bridge-x (get-random-value -2 2)) 1)
           (list bridge-x bridge-y)
           (list (+ bridge-x (get-random-value -2 2)) (- h 2)))
     #\~ '(#\, #\B #\! #\R #\T #\S))
    (setf (aref grid bridge-y bridge-x) #\B)))

(defun jrpg-gen-road-pickups (grid w h road count)
  (let ((placed 0))
    (dolist (cell road)
      (when (< placed count)
        (destructuring-bind (rx ry) cell
          (let ((ox (max 1 (min (- w 2) (+ rx (get-random-value -2 2)))))
                (oy (max 1 (min (- h 2) (+ ry (get-random-value -1 1))))))
            (when (and (char= (aref grid oy ox) #\.)
                       (zerop (get-random-value 0 5)))
              (setf (aref grid oy ox)
                    (if (zerop (get-random-value 0 1)) #\$ #\o))
              (incf placed))))))))

(defun jrpg-gen-overworld (w h finish-glyph waypoints)
  "Returns (values rows start-x start-y). A small old-RPG overworld: readable
plains, a road with deliberate bends, one bridged river, named landmarks on the
road, and terrain regions that read as geography instead of noise."
  (let* ((grid (make-array (list h w) :initial-element #\.))
         (sx 1)
         (sy (jrpg-gen-world-clamp-y h (- h 5)))
         (fx (- w 2))
         (fy (jrpg-gen-world-clamp-y h 3))
         (lower-y (jrpg-gen-world-clamp-y h (- h 5)))
         (middle-y (jrpg-gen-world-clamp-y h (floor h 2)))
         (upper-y (jrpg-gen-world-clamp-y h 4))
         (road (jrpg-gen-road-route
                grid w h
                (list (list sx sy)
                      (list (jrpg-gen-world-clamp-x w (floor w 5)) lower-y)
                      (list (jrpg-gen-world-clamp-x w (floor w 5)) middle-y)
                      (list (jrpg-gen-world-clamp-x w (floor w 2)) middle-y)
                      (list (jrpg-gen-world-clamp-x w (floor (* 3 w) 4))
                            upper-y)
                      (list fx fy)))))
    ;; Terrain is broad and authored-looking: a river crossing, mountain ranges
    ;; against the edges, a lake off the road, and forest belts near the route.
    (jrpg-gen-road-bridge grid w h road)
    (let* ((protected '(#\, #\B #\! #\R #\T #\S))
           (mountain-avoid (append protected '(#\~)))
           (forest-avoid (append protected '(#\^ #\~))))
      (jrpg-gen-region grid w h
                       (jrpg-gen-world-clamp-x w (- (floor w 2) 5))
                       (jrpg-gen-world-clamp-y h 4)
                       3 2
                       #\~ protected)
      (jrpg-gen-terrain-path
       grid w h
       (list (list 2 2)
             (list (floor w 4) 2)
             (list (floor w 2) 3))
       #\^ mountain-avoid :radius 1)
      (jrpg-gen-terrain-path
       grid w h
       (list (list (floor w 3) (- h 3))
             (list (floor (* 2 w) 3) (- h 4))
             (list (- w 4) (- h 3)))
       #\^ mountain-avoid :radius 1)
      (jrpg-gen-region grid w h
                       (jrpg-gen-world-clamp-x w (+ (floor w 4) 2))
                       (jrpg-gen-world-clamp-y h (- middle-y 3))
                       4 2
                       #\f forest-avoid)
      (jrpg-gen-region grid w h
                       (jrpg-gen-world-clamp-x w (+ (floor w 2) 4))
                       (jrpg-gen-world-clamp-y h (+ middle-y 3))
                       5 2
                       #\f forest-avoid)
      (jrpg-gen-region grid w h
                       (jrpg-gen-world-clamp-x w (- w 7))
                       (jrpg-gen-world-clamp-y h (+ fy 4))
                       4 2
                       #\f forest-avoid))
    ;; Landmarks sit on the authored route after terrain is set.
    (let ((n (length road))
          (k (length waypoints)))
      (loop for wp in waypoints
            for i from 1
            for idx = (min (1- n) (max 1 (floor (* i n) (1+ k))))
            do (destructuring-bind (wx wy) (nth idx road)
                 (setf (aref grid wy wx) wp))))
    ;; 3. finish, start, and a few pickups near the route
    (setf (aref grid fy fx) finish-glyph
          (aref grid sy sx) #\,)
    (jrpg-gen-road-pickups grid w h road 5)
    (values (jrpg-gen-rows grid) sx sy)))

(defun jrpg-gen-street-open (grid w h x y)
  (when (and (<= 0 x) (< x w)
             (<= 0 y) (< y h))
    (setf (aref grid y x) #\.)))

(defun jrpg-gen-street-square (grid w h cx cy radius-x radius-y)
  (loop for y from (- cy radius-y) to (+ cy radius-y)
        do (loop for x from (- cx radius-x) to (+ cx radius-x)
                 do (jrpg-gen-street-open grid w h x y))))

(defun jrpg-gen-street-open-rect (grid w h left top right bottom)
  (loop for y from top to bottom
        do (loop for x from left to right
                 do (jrpg-gen-street-open grid w h x y))))

(defun jrpg-gen-street-segment (grid w h x1 y1 x2 y2 &optional (radius 1))
  (let ((x x1)
        (y y1)
        (path nil))
    (loop
      (jrpg-gen-street-square grid w h x y radius radius)
      (push (list x y) path)
      (when (and (= x x2) (= y y2))
        (return))
      (cond
        ((< x x2) (incf x))
        ((> x x2) (decf x))
        ((< y y2) (incf y))
        ((> y y2) (decf y))))
    (nreverse path)))

(defun jrpg-gen-street-carve-route (grid w h points)
  (let ((route nil))
    (loop for (from to) on points while to
          do (let ((segment (jrpg-gen-street-segment grid w h
                                                     (first from) (second from)
                                                     (first to) (second to))))
               (setf route (append route segment))))
    route))

(defun jrpg-gen-street-clamp-x (w x)
  (max 1 (min (- w 2) x)))

(defun jrpg-gen-street-clamp-y (h y)
  (max 1 (min (- h 2) y)))

(defun jrpg-gen-street-cells (grid w h)
  (let ((cells nil))
    (loop for y from 1 below (1- h)
          do (loop for x from 1 below (1- w)
                   when (char= (aref grid y x) #\.)
                     do (push (list x y) cells)))
    (nreverse cells)))

(defun jrpg-gen-street-place-pickups (grid w h count)
  (let ((open (jrpg-gen-street-cells grid w h))
        (placed 0))
    (loop while (and (< placed count) open)
          for index = (get-random-value 0 (1- (length open)))
          for cell = (nth index open)
          do (destructuring-bind (x y) cell
               (setf open (remove cell open :test #'equal :count 1))
               (when (and (char= (aref grid y x) #\.)
                          (or (char= (aref grid y (1- x)) #\#)
                              (char= (aref grid y (1+ x)) #\#)
                              (char= (aref grid (1- y) x) #\#)
                              (char= (aref grid (1+ y) x) #\#))
                          (plusp (get-random-value 0 2)))
                 (setf (aref grid y x)
                       (if (zerop (get-random-value 0 1)) #\$ #\o))
                 (incf placed))))))

(defun jrpg-gen-street-route-points (w h sx sy fx fy)
  "Control points for a readable old-RPG district route."
  (let* ((west-x (jrpg-gen-street-clamp-x w (max 7 (floor w 4))))
         (mid-x (jrpg-gen-street-clamp-x w (floor w 2)))
         (east-x (jrpg-gen-street-clamp-x w (min (- w 8) (floor (* 3 w) 4))))
         (market-y (jrpg-gen-street-clamp-y h (floor h 2)))
         (upper-y fy)
         (lower-y sy))
    (values (list (list sx lower-y)
                  (list west-x lower-y)
                  (list west-x market-y)
                  (list mid-x market-y)
                  (list mid-x upper-y)
                  (list east-x upper-y)
                  (list fx upper-y))
            west-x mid-x east-x market-y upper-y lower-y)))

(defun jrpg-gen-street-carve-district (grid w h west-x mid-x east-x
                                       market-y upper-y lower-y fx fy)
  "Cut broad streets and courts out of solid building mass."
  (let ((south-y lower-y)
        (middle-y market-y)
        (north-y upper-y))
    ;; Main old-RPG street bands. Three cells wide is enough to read as a street
    ;; in the 24px tile renderer without turning the district into open floor.
    (jrpg-gen-street-open-rect grid w h 1 (1- south-y) (- w 2) (1+ south-y))
    (jrpg-gen-street-open-rect grid w h 1 (1- middle-y) (- w 2) (1+ middle-y))
    (jrpg-gen-street-open-rect grid w h west-x (1- north-y) (- w 2) (1+ north-y))
    (dolist (x (list west-x mid-x east-x))
      (jrpg-gen-street-open-rect grid w h (1- x) north-y (1+ x) south-y))
    ;; Courts and shop fronts keep the route from being a featureless grid.
    (jrpg-gen-street-square grid w h west-x south-y 3 2)
    (jrpg-gen-street-square grid w h west-x middle-y 3 2)
    (jrpg-gen-street-square grid w h mid-x middle-y 4 3)
    (jrpg-gen-street-square grid w h mid-x north-y 3 2)
    (jrpg-gen-street-square grid w h east-x north-y 3 2)
    (jrpg-gen-street-square grid w h fx fy 4 2)
    ;; A few short side alleys, but no maze.
    (jrpg-gen-street-open-rect grid w h
                               (max 1 (- mid-x 6)) 2
                               (min (- w 2) (- mid-x 2)) (1+ north-y))
    (jrpg-gen-street-open-rect grid w h
                               (max 1 (+ mid-x 3)) (+ middle-y 2)
                               (min (- w 2) (+ mid-x 8)) (- south-y 2))))

(defun jrpg-gen-street-place-landmarks (grid route waypoints)
  (let ((n (length route))
        (k (length waypoints)))
    (loop for wp in waypoints
          for i from 1
          for idx = (min (1- n) (max 1 (floor (* i n) (1+ k))))
          do (destructuring-bind (wx wy) (nth idx route)
               (when (char= (aref grid wy wx) #\.)
                 (setf (aref grid wy wx) wp))))))

(defun jrpg-gen-street-place-lamps (grid lamps)
  (dolist (lamp lamps)
    (destructuring-bind (x y) lamp
      (when (char= (aref grid y x) #\.)
        (setf (aref grid y x) #\+)))))

(defun jrpg-gen-streets (w h finish-glyph waypoints)
  "Returns (values rows start-x start-y). A generated night-city walk: building
blocks, broad old-RPG streets, a central court, side lanes, sparse lamps, and
one guaranteed route from the lower west side to the destination."
  (let* ((grid (make-array (list h w) :initial-element #\#))
         (sx 1)
         (sy (max 2 (- h 3)))
         (fx (max 2 (- w 2)))
         (fy (jrpg-gen-street-clamp-y h (max 3 (floor h 4)))))
    (multiple-value-bind (points west-x mid-x east-x market-y upper-y lower-y)
        (jrpg-gen-street-route-points w h sx sy fx fy)
      (let ((route (jrpg-gen-street-carve-route grid w h points)))
        (jrpg-gen-street-carve-district grid w h
                                        west-x mid-x east-x
                                        market-y upper-y lower-y
                                        fx fy)
        (jrpg-gen-street-place-landmarks grid route waypoints)
        (jrpg-gen-street-place-lamps
         grid
         (list (list west-x lower-y)
               (list west-x market-y)
               (list mid-x market-y)
               (list mid-x upper-y)
               (list east-x upper-y)
               (list east-x market-y)
               (list (max 2 (- mid-x 5)) (1+ upper-y))
               (list (min (- w 3) (+ mid-x 6)) (- lower-y 2))))
        (jrpg-gen-street-place-pickups grid w h 5)))
    (setf (aref grid sy sx) #\.
          (aref grid fy fx) finish-glyph)
    (values (jrpg-gen-rows grid) sx sy)))

(defvar *jrpg-overworld* nil)

(defstruct jrpg-overworld
  (node-id          *runtime-fallback-node-id*)
  (map              *jrpg-overworld-map*)
  (finish-glyphs    '(#\!))
  (tile-messages    nil)
  (legend           "V village  = bridge  + sign  T tower  $ Hours  o tonic")
  (store-prefix     "jrpg-overworld")
  (x                1)
  (y                4)
  ;; random encounters: each step past the cooldown rolls 1-in-rate to drop
  ;; the walker into a battle. the battle returns to this same node and the
  ;; walk resumes where it left off (the session is not cleared on encounter).
  (encounter-target nil)
  (encounter-rate   0)
  (encounter-cool   6)
  (message          "arrows or wasd move.")
  ;; :city is an orthogonal street grid whose lettered doors each lead to their
  ;; own target (the DOORS alist); :road is the winding inter-place road.
  (mode             :road)
  (doors            nil)
  (door-names       nil)
  ;; facing (for the figure) and a short breadcrumb trail of recent cells
  (facing           1)
  (visited          nil)
  ;; the read-only stat card, toggled with C (pauses movement while up)
  (show-card        nil))

(defun jrpg-overworld-width (game)
  (length (aref (jrpg-overworld-map game) 0)))

(defun jrpg-overworld-height (game)
  (length (jrpg-overworld-map game)))

(defun jrpg-overworld-normalize-map (map)
  (cond
    ((null map)
     *jrpg-overworld-map*)
    ((vectorp map)
     map)
    ((listp map)
     (coerce map 'vector))
    (t
     (runtime-warn "JRPG overworld map config is not a list or vector: ~s"
                   map)
     *jrpg-overworld-map*)))

(defun jrpg-overworld-normalize-finish-glyphs (glyphs)
  (cond
    ((null glyphs)
     '(#\!))
    ((characterp glyphs)
     (list glyphs))
    ((stringp glyphs)
     (loop for glyph across glyphs collect glyph))
    ((listp glyphs)
     glyphs)
    (t
     (runtime-warn "JRPG overworld finish glyph config is invalid: ~s"
                   glyphs)
     '(#\!))))

(defun jrpg-overworld-start-coordinates (node)
  (let ((start (minigame-config-value node :start '(1 4))))
    (if (and (listp start)
             (integerp (first start))
             (integerp (second start)))
        (values (first start) (second start))
        (progn
          (runtime-warn "JRPG overworld start config is invalid: ~s"
                        start)
          (values 1 4)))))

(defun jrpg-overworld-config-int (node key default)
  (let ((value (minigame-config-value node key default)))
    (if (integerp value) value default)))

(defun make-fresh-jrpg-overworld (node)
  (jrpg-init-state)
  (let ((gen-width (minigame-config-value node :gen-width)))
    (if (and (integerp gen-width) (> gen-width 12))
        (let* ((gen-height (jrpg-overworld-config-int node :gen-height 18))
               (terrain (minigame-config-value node :terrain :world))
               (finish (let ((value (minigame-config-value node
                                                           :finish-glyph #\!)))
                         (if (characterp value) value #\!)))
               (waypoint-default (if (eq terrain :streets) nil '(#\R)))
               (waypoints (let ((value (minigame-config-value node :waypoints
                                                              waypoint-default)))
                            (if (listp value) value waypoint-default))))
          (multiple-value-bind (rows start-x start-y)
              (case terrain
                (:streets (jrpg-gen-streets gen-width gen-height finish waypoints))
                (t (jrpg-gen-overworld gen-width gen-height finish waypoints)))
            (make-jrpg-overworld
             :node-id (node-id node)
             :map (coerce rows 'vector)
             :finish-glyphs (list finish)
             :tile-messages (minigame-config-value node :tile-messages)
             :legend (minigame-config-value
                      node :legend
                      "= bridge  + sign  T tower  $ Hours  o tonic  ^~ block")
             :store-prefix (minigame-config-value node :store-prefix
                                                  "jrpg-overworld")
             :x start-x
             :y start-y
             :encounter-target (minigame-config-value node :encounter-target)
             :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
             :message (minigame-config-value
                       node :start-message
                       "the way opens out. arrows or wasd move."))))
        (multiple-value-bind (start-x start-y)
            (jrpg-overworld-start-coordinates node)
          (make-jrpg-overworld
           :node-id (node-id node)
           :map (jrpg-overworld-normalize-map
                 (minigame-config-value node :map))
           :finish-glyphs (jrpg-overworld-normalize-finish-glyphs
                           (minigame-config-value node :finish-glyphs))
           :tile-messages (minigame-config-value node :tile-messages)
           :legend (minigame-config-value
                    node :legend
                    "V village  = bridge  + sign  T tower  $ Hours  o tonic")
           :store-prefix (minigame-config-value node :store-prefix
                                                "jrpg-overworld")
           :x start-x
           :y start-y
           :encounter-target (minigame-config-value node :encounter-target)
           :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
           :message (minigame-config-value
                     node :start-message
                     "arrows or wasd move."))))))

(defun ensure-jrpg-overworld-session (node builder)
  "Build the walk with BUILDER on first entry to a node and keep it until the
node changes, so a returning walk resumes (encounters do not reset it)."
  (unless (and *jrpg-overworld*
               (equal (jrpg-overworld-node-id *jrpg-overworld*)
                      (node-id node)))
    (setf *jrpg-overworld* (funcall builder node)))
  *jrpg-overworld*)

(defun ensure-jrpg-overworld (node)
  (ensure-jrpg-overworld-session node #'make-fresh-jrpg-overworld))

(defun jrpg-overworld-cell (game x y)
  (if (and (<= 0 x)
           (< x (jrpg-overworld-width game))
           (<= 0 y)
           (< y (jrpg-overworld-height game)))
      (char (aref (jrpg-overworld-map game) y) x)
      #\^))

(defun jrpg-overworld-passable-p (cell)
  (not (member cell '(#\^ #\~ #\#) :test #'char=)))

(defun jrpg-overworld-input-direction ()
  (cond
    ((or (is-key-pressed-p +key-left+)
         (is-key-pressed-p +key-a+))
     '(-1 0))
    ((or (is-key-pressed-p +key-right+)
         (is-key-pressed-p +key-d+))
     '(1 0))
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-w+))
     '(0 -1))
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-s+))
     '(0 1))))

(defun jrpg-overworld-default-tile-message (cell)
  (case cell
    (#\V "the village gate is already behind you.")
    (#\B "the bridge guard raises the gate chain.")
    (#\R "the road sign says NORTH TOWER.")
    (#\T "the tower is still too far to touch.")
    (#\S "the roadside shrine is white stone and old pine.")
    (#\! "the grass shakes.")
    (#\$ "loose Hours dropped in the grass.")
    (#\o "a small corked bottle waits on a flat stone.")
    (#\~ "the water lies still and the colour of slate.")
    (#\# "closed fronts block the way.")
    (#\, "the road runs on, pale through the grass.")
    (#\f "trees crowd close to the road.")
    (t "open grass, and your own long shadow.")))

(defun jrpg-overworld-tile-message (game cell)
  (or (rest (assoc cell
                   (jrpg-overworld-tile-messages game)
                   :test #'char=))
      (jrpg-overworld-default-tile-message cell)))

(defun jrpg-overworld-store-key (game suffix)
  (format nil "~a-~a" (jrpg-overworld-store-prefix game) suffix))

(defun jrpg-overworld-collected (game)
  (jrpg-value (jrpg-overworld-store-key game "collected") nil))

(defun jrpg-overworld-collected-p (game x y)
  (member (list x y) (jrpg-overworld-collected game) :test #'equal))

(defun jrpg-overworld-mark-collected (game x y)
  (setf (jrpg-value (jrpg-overworld-store-key game "collected"))
        (cons (list x y) (jrpg-overworld-collected game))))

(defun jrpg-overworld-effective-cell (game x y)
  "A picked-up gold or potion tile reads as plain road afterward."
  (let ((cell (jrpg-overworld-cell game x y)))
    (if (and (member cell '(#\$ #\o) :test #'char=)
             (jrpg-overworld-collected-p game x y))
        #\.
        cell)))

(defun jrpg-overworld-tile-effects (game x y cell)
  "Sounds and pickups for the tile just entered; pickups override the
message and are taken only once."
  (case cell
    (#\$ (unless (jrpg-overworld-collected-p game x y)
           (let ((found (get-random-value 3 6)))
             (jrpg-adjust-number "jrpg-hours" found)
             (jrpg-overworld-mark-collected game x y)
             (play-jrpg-sound "coin" :volume 0.40)
             (setf (jrpg-overworld-message game)
                   (format nil "loose Hours in the grass. +~d." found)))))
    (#\o (unless (jrpg-overworld-collected-p game x y)
           (jrpg-adjust-number "jrpg-potions" 1)
           (jrpg-overworld-mark-collected game x y)
           (play-jrpg-sound "tonic" :volume 0.40)
           (setf (jrpg-overworld-message game)
                 "a corked tonic, left for travelers. you take it.")))
    (#\B (play-jrpg-sound "gate-chain" :volume 0.42))
    (#\R (play-jrpg-sound "ledger" :volume 0.30))
    (#\T (play-jrpg-sound "bell" :volume 0.30))
    (#\S (play-jrpg-sound "bell" :volume 0.24))))

(defun jrpg-record-overworld-cell (game cell)
  (declare (ignore game))
  (case cell
    (#\B (setf (jrpg-value "jrpg-crossed-bridge") t
               (jrpg-value "jrpg-route") "bridge road"))
    (#\R (setf (jrpg-value "jrpg-read-road-sign") t
               (jrpg-value "jrpg-route") "north road"))
    (#\T (setf (jrpg-value "jrpg-saw-tower") t))
    (#\S (setf (jrpg-value "jrpg-road-shrine-seen") t))
    (#\! (setf (jrpg-value "jrpg-last-terrain") "grass"))))

(defun jrpg-overworld-finish-cell-p (game cell)
  (not (null (member cell
                     (jrpg-overworld-finish-glyphs game)
                     :test #'char=))))

(defun jrpg-overworld-finish (node game cell)
  "Leave the walk. In a city, the lettered door CELL goes to its own target;
on a road the single finish glyph goes to the node's success target."
  (let ((target (or (and (eq (jrpg-overworld-mode game) :city)
                         (cdr (assoc cell (jrpg-overworld-doors game)
                                     :test #'char=)))
                    (node-success-target node))))
    (setf *jrpg-overworld* nil)
    (jump-to-dialog-target target)))

(defun jrpg-overworld-maybe-encounter (node game)
  "After a step, roll for a random encounter. On a hit, drop into the
configured battle WITHOUT clearing the session, so the walk resumes at this
spot when the battle returns to this node. A short cooldown keeps the first
steps and the steps just after a fight safe."
  (declare (ignore node))
  (let ((target (jrpg-overworld-encounter-target game))
        (rate   (jrpg-overworld-encounter-rate game)))
    (when (and target (plusp rate))
      (if (plusp (jrpg-overworld-encounter-cool game))
          (decf (jrpg-overworld-encounter-cool game))
          (when (zerop (get-random-value 0 (1- rate)))
            (setf (jrpg-overworld-encounter-cool game) 6)
            (jump-to-dialog-target target))))))

(defun jrpg-overworld-remember-visited (game x y)
  "Keep a short breadcrumb trail of recently-stepped cells, newest first."
  (let ((cell (list x y)))
    (unless (equal cell (first (jrpg-overworld-visited game)))
      (push cell (jrpg-overworld-visited game))
      (when (> (length (jrpg-overworld-visited game)) 48)
        (setf (jrpg-overworld-visited game)
              (subseq (jrpg-overworld-visited game) 0 48))))))

(defun jrpg-overworld-move (node game dx dy)
  (let* ((next-x (+ (jrpg-overworld-x game) dx))
         (next-y (+ (jrpg-overworld-y game) dy))
         (cell (jrpg-overworld-cell game next-x next-y)))
    (unless (zerop dx)
      (setf (jrpg-overworld-facing game) (if (plusp dx) 1 -1)))
    (if (jrpg-overworld-passable-p cell)
        (progn
          (jrpg-overworld-remember-visited game
                                           (jrpg-overworld-x game)
                                           (jrpg-overworld-y game))
          (setf (jrpg-overworld-x game) next-x
                (jrpg-overworld-y game) next-y
                (jrpg-overworld-message game)
                (jrpg-overworld-tile-message
                 game
                 (jrpg-overworld-effective-cell game next-x next-y)))
          (jrpg-record-overworld-cell game cell)
          (jrpg-overworld-tile-effects game next-x next-y cell)
          (cond
            ((jrpg-overworld-finish-cell-p game cell)
             (jrpg-overworld-finish node game cell))
            (t
             (jrpg-overworld-maybe-encounter node game))))
        (setf (jrpg-overworld-message game)
              (if (char= cell #\~)
                  "the water is too deep to wade."
                  (if (char= cell #\#)
                      "closed fronts block the way."
                      "you cannot get through that way."))))))

(defun jrpg-overworld-step (node game)
  "One frame of walking input; shared by the road and the city. C opens the
full character screen and returns here, like the menu key in a JRPG."
  (cond
    ((is-key-pressed-p +key-c+)
     (setf (jrpg-value "jrpg-char-return") (jrpg-overworld-node-id game))
     (jump-to-dialog-target "jrpg/character"))
    (t
     (let ((direction (jrpg-overworld-input-direction)))
       (when direction
         (destructuring-bind (dx dy) direction
           (jrpg-overworld-move node game dx dy)))))))

(defun update-jrpg-overworld-minigame (node dt)
  (declare (ignore dt))
  (jrpg-overworld-step node (ensure-jrpg-overworld node)))

(defun jrpg-overworld-camera (game)
  "Top-left viewport tile, scrolled to keep the player centered and
clamped to the map edges."
  (let ((w (jrpg-overworld-width game))
        (h (jrpg-overworld-height game)))
    (values (max 0 (min (- (jrpg-overworld-x game)
                           (floor +jrpg-overworld-view-cols+ 2))
                        (max 0 (- w +jrpg-overworld-view-cols+))))
            (max 0 (min (- (jrpg-overworld-y game)
                           (floor +jrpg-overworld-view-rows+ 2))
                        (max 0 (- h +jrpg-overworld-view-rows+)))))))

(defun jrpg-overworld-tile-label (cell)
  (case cell
    (#\^ "^")
    (#\V "V")
    (#\B "=")
    (#\R "+")
    (#\T "T")
    (#\S "S")
    (#\! "\"")
    (#\$ "$")
    (#\o "o")
    (#\~ "~")
    (#\# "")
    (t ".")))

(defun jrpg-ow-fill (x y w h alpha)
  (claylib/ll:draw-rectangle (round x) (round y)
                             (max 1 (round w)) (max 1 (round h))
                             (claylib::c-ptr (make-color 255 255 255 alpha))))

(defun jrpg-ow-fill-black (x y w h alpha)
  (claylib/ll:draw-rectangle (round x) (round y)
                             (max 1 (round w)) (max 1 (round h))
                             (claylib::c-ptr (make-color 0 0 0 alpha))))

(defun draw-jrpg-lamp (cx cy)
  "Small old-RPG street lamp drawn from primitives, not from the torch tile."
  (jrpg-ow-fill (- cx 7) (- cy 8) 14 14 22)
  (jrpg-ow-fill (- cx 4) (- cy 7) 8 2 220)
  (jrpg-ow-fill (- cx 5) (- cy 5) 10 8 235)
  (jrpg-ow-fill-black (- cx 3) (- cy 3) 6 4 255)
  (jrpg-ow-fill (- cx 1) (- cy 5) 2 8 210)
  (jrpg-ow-fill (- cx 4) (- cy 1) 8 1 210)
  (jrpg-ow-fill (- cx 1) (+ cy 3) 2 9 155)
  (jrpg-ow-fill (- cx 5) (+ cy 11) 10 2 115))

(defun jrpg-overworld-cell-screen (col row)
  "Screen x,y of the top-left of a viewport tile."
  (values (+ +jrpg-overworld-left+ (* col +jrpg-overworld-tile-size+))
          (+ +jrpg-overworld-top+ (* row +jrpg-overworld-tile-size+))))

;;; --- tile atlas (Kenney 1-bit, CC0): a 48x22 grid of 16x16 white-on-
;;; transparent tiles. One reusable texture-object whose source/dest rects are
;;; mutated per tile, so a whole map costs no per-tile allocation. nil if the
;;; PNG is absent, so callers fall back to drawn shapes.

(defconstant +jrpg-tile-px+ 16)
(defconstant +jrpg-tile-crop+ 1) ; match Scene Builder: drop atlas border pixels

(defvar *jrpg-tile-atlas* nil)

(defun clear-jrpg-tile-atlas ()
  (setf *jrpg-tile-atlas* nil))

(register-minigame-reset-hook 'clear-jrpg-tile-atlas)

(defun jrpg-tile-atlas ()
  (cond
    ((eq *jrpg-tile-atlas* :none) nil)
    (*jrpg-tile-atlas* *jrpg-tile-atlas*)
    (t
     (let ((path (project-pathname "assets/tiles/kenney-1bit-mono.png")))
       (handler-case
           (if (probe-file path)
               (let* ((asset (make-texture-asset path :load-now t))
                      (obj (make-texture asset 0.0 0.0
                                         :width 16.0 :height 16.0
                                         :tint (make-color 255 255 255 255))))
                 (setf (source obj)
                       (make-instance 'rl-rectangle
                                      :x 0.0 :y 0.0 :width 16.0 :height 16.0))
                 ;; point sampling on the actual Texture2D (texture-objects have
                 ;; no filter slot); without this the atlas is bilinear and every
                 ;; 16px tile bleeds its neighbours at the edges
                 (ignore-errors
                  (claylib/ll:set-texture-filter (claylib::c-asset obj)
                                                 +texture-filter-point+))
                 (setf *jrpg-tile-atlas* obj))
               (progn (setf *jrpg-tile-atlas* :none) nil))
         (error (condition)
           (runtime-warn "Could not load tile atlas: ~a" condition)
           (setf *jrpg-tile-atlas* :none)
           nil))))))

(defvar *jrpg-tile-white* (make-color 255 255 255 255))

(defun jrpg-draw-tile (atlas col row sx sy size &optional tint)
  "Blit the (COL,ROW) atlas tile into a SIZE-square cell at SX,SY.
TINT defaults to solid white; pass a cached colour to avoid per-tile allocation."
  (let* ((src (source atlas))
         (dst (dest atlas))
         (inner (- +jrpg-tile-px+ (* 2 +jrpg-tile-crop+))))
    (setf (x src) (float (+ (* col +jrpg-tile-px+) +jrpg-tile-crop+) 1.0)
          (y src) (float (+ (* row +jrpg-tile-px+) +jrpg-tile-crop+) 1.0)
          (width src) (float inner 1.0)
          (height src) (float inner 1.0)
          (x dst) (float sx 1.0)
          (y dst) (float sy 1.0)
          (width dst) (float size 1.0)
          (height dst) (float size 1.0))
    (setf (tint atlas) (or tint *jrpg-tile-white*))
    (draw-object atlas)))

(defun jrpg-overworld-draw-grid ()
  "Faint guide lines, so the walk reads as a grid and not floating specks."
  (let ((w (* +jrpg-overworld-view-cols+ +jrpg-overworld-tile-size+))
        (h (* +jrpg-overworld-view-rows+ +jrpg-overworld-tile-size+)))
    (loop for c from 0 to +jrpg-overworld-view-cols+
          for x = (+ +jrpg-overworld-left+ (* c +jrpg-overworld-tile-size+))
          do (jrpg-ow-fill x +jrpg-overworld-top+ 1 h 14))
    (loop for r from 0 to +jrpg-overworld-view-rows+
          for y = (+ +jrpg-overworld-top+ (* r +jrpg-overworld-tile-size+))
          do (jrpg-ow-fill +jrpg-overworld-left+ y w 1 14))))

(defun jrpg-overworld-draw-trail (game cam-x cam-y)
  "Faint marks where the traveller has lately stepped."
  (let ((s +jrpg-overworld-tile-size+))
    (dolist (cell (jrpg-overworld-visited game))
      (destructuring-bind (mx my) cell
        (let ((col (- mx cam-x)) (row (- my cam-y)))
          (when (and (<= 0 col) (< col +jrpg-overworld-view-cols+)
                     (<= 0 row) (< row +jrpg-overworld-view-rows+))
            (multiple-value-bind (sx sy) (jrpg-overworld-cell-screen col row)
              (jrpg-ow-fill (+ sx (/ s 2) -1) (+ sy (/ s 2) -1) 3 3 30))))))))

(defun draw-jrpg-overworld-cell (cell screen-x screen-y)
  "Coherent terrain, no grid: plains clean dark, the road a faint worn track,
mountains peaks, forest little trees, water a glinting pool; landmarks bold."
  (let* ((s  +jrpg-overworld-tile-size+)
         (cx (+ screen-x (/ s 2)))
         (cy (+ screen-y (/ s 2))))
    (case cell
      (#\.)                              ; plains: clean
      (#\,                               ; road: a faint worn track
       (jrpg-ow-fill (+ screen-x 4) (+ screen-y 4) (- s 8) (- s 8) 24))
      (#\+                               ; lamp beside the street
       (jrpg-ow-fill (+ screen-x 4) (+ screen-y 4) (- s 8) (- s 8) 24)
       (draw-jrpg-lamp cx cy))
      (#\^                               ; mountain: a peak (narrow up, wide down)
       (loop for r from 0 below 5
             for ww = (max 2 (round (* (- s 6) (/ (+ r 1) 5.0))))
             for rh = (max 1 (round (/ (- s 8) 5.0)))
             do (jrpg-ow-fill (- cx (/ ww 2)) (+ screen-y 4 (* r rh)) ww rh
                              (+ 95 (* r 14)))))
      (#\f                               ; forest: a little tree
       (loop for r from 0 below 3
             for ww = (+ 4 (* r 4))
             do (jrpg-ow-fill (- cx (/ ww 2)) (+ screen-y 4 (* r 4)) ww 4 135))
       (jrpg-ow-fill (- cx 1) (+ cy 4) 2 4 120))   ; trunk
      (#\~                               ; water: a glinting pool
       (jrpg-ow-fill (+ screen-x 2) (+ screen-y 2) (- s 4) (- s 4) 52)
       (jrpg-ow-fill (+ screen-x 4) (- cy 2) (- s 9) 2 110)
       (jrpg-ow-fill (+ screen-x 6) (+ cy 3) (- s 12) 2 90))
      (#\#                               ; city frontage
       (jrpg-ow-fill (+ screen-x 1) (+ screen-y 1) (- s 2) (- s 2) 72)
       (jrpg-ow-fill (+ screen-x 4) (+ screen-y 5) (- s 8) 2 126)
       (jrpg-ow-fill (+ screen-x 6) (+ screen-y 11) (- s 12) 2 96))
      (t                                 ; landmark / pickup / finish
       (draw-centered-text (jrpg-overworld-tile-label cell)
                           cx cy 20 (make-color 255 255 255 235))))))

(defun jrpg-draw-overworld-figure (cx cy &optional (facing 1))
  "The traveller. A tile from the atlas when one is loaded, else drawn from
rectangles with a short arm in the heading so the facing reads at a glance."
  (let ((atlas (jrpg-tile-atlas))
        (s +jrpg-overworld-tile-size+))
    (when atlas
      (multiple-value-bind (col row) (jrpg-tile-coords :player)
        (jrpg-draw-tile atlas col row (- cx (/ s 2)) (- cy (/ s 2)) s))
      (return-from jrpg-draw-overworld-figure)))
  (flet ((fill-rect (x y w h)
           (claylib/ll:draw-rectangle (round x) (round y)
                                      (max 1 (round w)) (max 1 (round h))
                                      (claylib::c-ptr (make-color 255 255 255 255)))))
    (fill-rect (- cx 3) (- cy 9) 6 5)     ; head
    (fill-rect (- cx 4) (- cy 3) 8 8)     ; body
    (fill-rect (- cx 4) (+ cy 5) 3 4)     ; left leg
    (fill-rect (+ cx 1) (+ cy 5) 3 4)     ; right leg
    (if (plusp facing)
        (fill-rect (+ cx 4) (- cy 2) 3 4)     ; arm, facing right
        (fill-rect (- cx 7) (- cy 2) 3 4))))  ; arm, facing left

(defun draw-jrpg-overworld-map (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (jrpg-overworld-draw-trail game cam-x cam-y)
    (loop for row below +jrpg-overworld-view-rows+
          do (loop for col below +jrpg-overworld-view-cols+
                   for mx = (+ cam-x col)
                   for my = (+ cam-y row)
                   when (and (< mx (jrpg-overworld-width game))
                             (< my (jrpg-overworld-height game)))
                     do (multiple-value-bind (sx sy)
                            (jrpg-overworld-cell-screen col row)
                          (draw-jrpg-overworld-cell
                           (jrpg-overworld-effective-cell game mx my)
                           sx sy))))))

(defun jrpg-overworld-draw-player (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (let ((s +jrpg-overworld-tile-size+))
      (jrpg-draw-overworld-figure
       (+ +jrpg-overworld-left+ (* (- (jrpg-overworld-x game) cam-x) s) (/ s 2))
       (+ +jrpg-overworld-top+ (* (- (jrpg-overworld-y game) cam-y) s) (/ s 2))
       (jrpg-overworld-facing game)))))

(defun jrpg-overworld-render-frame (game map-fn)
  "Shared chrome: the arena box, the chosen map, the player, and the HUD."
  (draw-jrpg-box 220 132 840 432 208)
  (funcall map-fn game)
  (jrpg-overworld-draw-player game)
  (draw-jrpg-box 250 392 480 92)
  (draw-jrpg-line (jrpg-overworld-message game) 270 410 17)
  ;; the legend can run long; wrap it to up to two lines inside the box
  (loop for line in (let ((ls (wrap-text-lines (jrpg-overworld-legend game) 15 444)))
                      (if (> (length ls) 2) (subseq ls 0 2) ls))
        for i from 0
        do (draw-jrpg-line line 270 (+ 438 (* i 18)) 15 194))
  (draw-jrpg-box 760 392 260 92)
  (draw-jrpg-line (format nil "hp ~d/~d"
                          (jrpg-number "jrpg-hero-hp")
                          (jrpg-number "jrpg-hero-max-hp" 18))
                  782 414 17)
  (draw-jrpg-line (format nil "~d Hours    C: menu" (jrpg-hours))
                  782 444 15))

(defun draw-jrpg-overworld-minigame (node color)
  (declare (ignore color))
  (jrpg-overworld-render-frame (ensure-jrpg-overworld node)
                               #'draw-jrpg-overworld-map))

(dialog-minigame-kind :jrpg-overworld
                      :update #'update-jrpg-overworld-minigame
                      :draw #'draw-jrpg-overworld-minigame)
