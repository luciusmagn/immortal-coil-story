;;; The King in Yellow path, Act II - Carcosa under the King.
;;;
;;; Entered from jrpg/threshold via carcosa/cross. The King is the ship-captain
;;; (the captain path) gone cosmically, irretrievably insane, his power over
;;; repeated failure swollen out of suffering into rule and demand. The
;;; captain-truth surfaces only in shards through the raving. The Yellow Sign on
;;; the player means he may be claimed. Dreadful, never cozy.

(dialog-particles "carcosa/cross" :motes :fade-seconds 5.0)
(dialog-particles "carcosa/causeway-intro" :motes :fade-seconds 3.0)
(dialog-particles "carcosa/court" :tatters :fade-seconds 3.0)
(dialog-particles "carcosa/king-hall" :tatters :fade-seconds 4.0)
(dialog-particles "carcosa/throne-choice" :tatters :fade-seconds 2.0)
(dialog-sound "carcosa/courtier-combat" "audio/jrpg/sword.wav" :volume 0.32)
(dialog-sound "carcosa/king-stutter" "audio/jrpg/bell.wav" :volume 0.24)

;; Lyria's Carcosa drone bed, the lake of Hali, the crown's shimmer.
(dialog-music "carcosa/cross" "audio/jrpg-carcosa.mp3" :volume 0.20)
(dialog-sound "carcosa/causeway-intro" "audio/jrpg/lake.wav" :volume 0.30)
(dialog-sound "carcosa/take-crown" "audio/jrpg/crown.wav" :volume 0.40)

(dialog-minigame "carcosa/title"
                 ""
                 :game :title-card
                 :success "carcosa/cross"
                 :failure "carcosa/cross"
                 :config (list :title "CARCOSA"
                               :subtitle "where the black stars hang"
                               :seconds 2.8
                               :accent :crown))

(dialog-on-enter "carcosa/cross"
                 '(jrpg-complete-quest :cross)
                 '(jrpg-start-quest :king)
                 '(jrpg-add-item :hali-water)
                 '(jrpg-refresh-class))

(dialog-text "carcosa/cross"
             "you cross without a step in between. the night city is behind you. a still lake, two suns caught half under it."
             :next "carcosa/cross-s2")

(dialog-text "carcosa/cross-s2"
             "the air smells of wet stone and old paper. the Yellow Sign in your coat is warm against you."
             :next "carcosa/causeway-intro")

(dialog-text "carcosa/causeway-intro"
             "a causeway runs from the shore into the mist, toward towers that do not agree on how far off they are. this is Hali."
             :next "carcosa/causeway-intro-s2")

(dialog-text "carcosa/causeway-intro-s2"
             "you are alone on the stone, which is more than the lake usually allows."
             :next "carcosa/causeway")

(dialog-minigame "carcosa/causeway"
                 "w/s or up/down move. a/d or left/right turn. cross the causeway through the mist."
                 :game :dream-maze
                 :success "carcosa/causeway-cross"
                 :failure "carcosa/causeway-cross"
                 :config (list :doors '(("=" "carcosa/causeway-cross"))
                               :size 1.0)
                 :outcomes (list "carcosa/causeway-cross"))

(dialog-text "carcosa/causeway-cross"
             "halfway over, a figure stands in the mist: a pale robe, a mask, both wet. one of the kept. it does not move aside."
             :next "carcosa/courtier-combat")

(dialog-minigame "carcosa/courtier-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "carcosa/court"
                 :failure "carcosa/courtier-limp"
                 :config (list :enemy-name "PALLID COURTIER"
                               :enemy-kind "courtier"
                               :enemy-hp 24
                               :enemy-attack-min 4
                               :enemy-attack-max 7
                               :victory-xp 10
                               :victory-gold 0
                               :message "the courtier lifts a hand to its mask, as if to offer it to you."))

(dialog-on-enter "carcosa/courtier-limp"
                 '(jrpg-heal 7))

(dialog-text "carcosa/courtier-limp"
             "you go down on the wet stone. when you rise, the courtier is gone. its mask lies pale and empty. you step over it to the far shore."
             :next "carcosa/court")


;;; The court - Cassilda and Camilla, overheard, then asked

(dialog-text "carcosa/court"
             "before the high doors, two women keep a court of their own: one at a cold harp, one at a window on the lake."
             :next "carcosa/court-s2")

(dialog-text "carcosa/court-s2"
             "both are dressed for a masque, though no music plays and no one has come."
             :next "carcosa/cassilda-song-1")

;; Cassilda's Song, verbatim from Chambers (public domain), sung at the harp.
(dialog-particles "carcosa/cassilda-song-1" :tatters :fade-seconds 3.0)
(dialog-particles "carcosa/cassilda-song-1b" :tatters :fade-seconds 3.0)
(dialog-particles "carcosa/cassilda-song-2" :tatters :fade-seconds 3.0)
(dialog-particles "carcosa/cassilda-song-2b" :tatters :fade-seconds 3.0)

(dialog-say "carcosa/cassilda-song-1"
            "Cassilda"
            "Along the shore the cloud waves break, the twin suns sink behind the lake, the shadows lengthen in Carcosa."
            :next "carcosa/cassilda-song-1b")

(dialog-say "carcosa/cassilda-song-1b"
            "Cassilda"
            "Strange is the night where black stars rise, and strange moons circle through the skies, but stranger still is lost Carcosa."
            :next "carcosa/cassilda-song-2")

(dialog-say "carcosa/cassilda-song-2"
            "Cassilda"
            "Songs that the Hyades shall sing, where flap the tatters of the King, must die unheard in dim Carcosa."
            :next "carcosa/cassilda-song-2b")

(dialog-say "carcosa/cassilda-song-2b"
            "Cassilda"
            "Song of my soul, my voice is dead; die thou, unsung, as tears unshed shall dry and die in lost Carcosa."
            :next "carcosa/court-overheard")

(dialog-on-enter "carcosa/court-overheard" '(jrpg-lean-class :mourner 1))

(dialog-conversation "carcosa/court-overheard"
                     (dialog-left "Cassilda"
                                  "you, sir, should unmask. we have all laid aside disguise but him.")
                     (dialog-right "Camilla"
                                   "i told him so, once. 'i wear no mask,' he said - and i saw that it was true. i have not been warm since.")
                     (dialog-left "Cassilda"
                                  "and still we dress for the masque. someone must, or it is only a lake and a man who will not stop talking.")
                     :next "carcosa/court-questions")

(dialog-interrogation "carcosa/court-questions"
                      "Cassilda sets the harp aside. Camilla does not turn from the lake."
                      (:next "carcosa/cloister")
                      (:continue-label "go to the high doors")
                      ("ask what the King was"
                       :id "before"
                       :speaker "Cassilda"
                       "a man, we think, once. he came across the lake with the crown already on him and no memory of the hand that set it there."
                       "now there is too much of him, spread through too much time, to be a man.")
                      ("ask why he repeats himself"
                       :id "repeat"
                       :speaker "Camilla"
                       "he cannot finish the crossing. every sentence goes back to it. mind your own while you still have it.")
                      ("ask about the songs"
                       :id "songs"
                       :speaker "Cassilda"
                       "they die in the third line, everywhere his Sign reaches. it reached your city before you left it."))


;;; The keeper of kept things - a pallid vendor at the cloister, on the way in

(dialog-text "carcosa/cloister"
             "before the high doors a stall is kept: a pallid figure with kept things laid out."
             :next "carcosa/cloister-s2")

(dialog-text "carcosa/cloister-s2"
             "a flask of the lake. a mask with no face. a shred of the King's own yellow. he takes Hours, like everyone here."
             :next "carcosa/vendor")

(dialog-minigame "carcosa/vendor"
                 ""
                 :game :jrpg-shop
                 :success "carcosa/king-hall"
                 :failure "carcosa/king-hall"
                 :config (list :title "THE KEEPER OF KEPT THINGS"
                               :stock '((:hali-water 16)
                                        (:pallid-mask 70)
                                        (:tatter-shroud 92))))


;;; The King - insane, fragmentary; the captain-truth only in shards

(dialog-text "carcosa/king-hall"
             "the throne room is long and bare. you pass two doors you already passed. on the throne, in tatters the colour of the Sign, sits the King."
             :next "carcosa/king-hall-s2")

(dialog-text "carcosa/king-hall-s2"
             "he wears no mask. or the mask is his face. he is talking to the empty hall."
             :next "carcosa/king-1")

(dialog-say "carcosa/king-1"
            "the KING"
            "again. good. you always come in again. i kept the crossing this time, did you see, clean, the whole bridge, every man, watch --"
            :next "carcosa/king-2")

(dialog-say "carcosa/king-2"
            "the KING"
            "-- and again, and the count is wrong, the count is always wrong by everyone, and they thanked me --"
            :next "carcosa/king-2b")

(dialog-say "carcosa/king-2b"
            "the KING"
            "-- with the good chair and the soft pill and their hands, and the dark put me HERE, here is not the ship, HERE --"
            :next "carcosa/king-stutter")

(dialog-text "carcosa/king-stutter"
             "the bell answers him. his mouth begins the same phrase again. the twin suns lower another inch."
             :next "carcosa/king-stutter-s2")

(dialog-text "carcosa/king-stutter-s2"
             "you are still in the hall. the Sign in your coat is very warm."
             :next "carcosa/king-named")

(dialog-on-enter "carcosa/king-named" '(jrpg-refresh-class))
(dialog-say "carcosa/king-named"
            "the KING"
            "i know what you are. {jrpg-class-title}. you have always been it; every choice only told you so. it will not save you here."
            :next "carcosa/king-3")

(dialog-on-enter "carcosa/king-3" '(jrpg-complete-quest :sign))
(dialog-say "carcosa/king-3"
            "the KING"
            "you have the Sign. i sent it. i keep the ones i send it to. sit in the good chair, the relieved chair --"
            :next "carcosa/king-3b")

(dialog-say "carcosa/king-3b"
            "the KING"
            "-- and i will show you the crossing, and you will keep it for me, and i will rest, i have not --"
            :next "carcosa/throne-choice")

(dialog-on-enter "carcosa/throne-choice" '(jrpg-complete-quest :king))

(dialog-pick "carcosa/throne-choice"
             "the crown sits on the throne beside him, yellow, the one colour. the King has reached the end of the same sentence again."
             ;; the one action only your inferred class can take
             (dialog-option "unmake his name, as you have unmade others" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :repairer)))
             (dialog-option "set down his true face, as you set down the rot" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :painter)))
             (dialog-option "read him the last line of his own Play" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :reader)))
             (dialog-option "put him down, the way you put down the watchman" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :watchman)))
             (dialog-option "stay with him, since someone must mourn" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :mourner)))
             (dialog-option "take the crown" "carcosa/take-crown")
             (dialog-option "refuse, and keep your own face" "carcosa/refuse-crown"
                            :unless '(not (jrpg-composed-p)))
             (dialog-option "ask him the year" "carcosa/ask-year"))

(dialog-on-enter "carcosa/class-end"
                 '(setf (jrpg-value "jrpg-vane-answer") "class"))

(dialog-text "carcosa/class-end"
             "you meet him the only way a {jrpg-class-title} can. the King has no answer prepared for it."
             :next "carcosa/class-end-s2")

(dialog-text "carcosa/class-end-s2"
             "the suns hang. he stops speaking. the Sign in your coat goes quiet."
             :next "carcosa/out")

(dialog-on-enter "carcosa/take-crown"
                 '(setf (jrpg-value "jrpg-vane-answer") "crown")
                 '(jrpg-add-item :crown))

(dialog-text "carcosa/take-crown"
             "you take it up. the crown weighs nothing. the King stops mid-word. he steps down from the throne, pale and empty-handed."
             :next "carcosa/take-crown-s2")

(dialog-text "carcosa/take-crown-s2"
             "the crossing is yours now. the count will be wrong. you keep it anyway."
             :next "carcosa/king-end")

(dialog-text "carcosa/king-end"
             "far down the shore, one tune reaches its fourth line while you hold the crown."
             :next "sys/reboot")

(dialog-on-enter "carcosa/refuse-crown"
                 '(setf (jrpg-value "jrpg-vane-answer") "refused"))

(dialog-text "carcosa/refuse-crown"
             "you keep your own face and step backward. the King keeps talking. you leave through a door with one sun beyond it. the Sign in your coat is cold."
             :next "carcosa/out")

(dialog-on-enter "carcosa/ask-year"
                 '(jrpg-spend-composure 2)
                 '(setf (jrpg-value "jrpg-vane-answer") "year"))

(dialog-text "carcosa/ask-year"
             "you ask him the year. the question stops him. for one second the tatters are a coat and the throne is a chair."
             :next "carcosa/ask-year-s2")

(dialog-text "carcosa/ask-year-s2"
             "the face under the mask is a tired man's. he gives a number, then a name that is not the King's. you keep both."
             :next "carcosa/out")

(dialog-text "carcosa/out"
             "you wake. the book is shut, the lamp out, the courtyard grey."
             :next "carcosa/out-s2")

(dialog-text "carcosa/out-s2"
             "on the flyleaf, under your name, a second line has been added today in your own hand. you do not remember writing it. it reads only: again."
             :next "sys/reboot")
