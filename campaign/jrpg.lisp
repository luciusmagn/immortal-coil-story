;;; The King in Yellow path, Act I - the ordinary city.
;;;
;;; Rebuilt from Chambers, no JRPG skeleton kept. The player begins ALONE with
;;; the banned Play and the Yellow Sign already half on them, and walks the
;;; night city of the stories: the painter Scott and his model Tessie of THE
;;; YELLOW SIGN, the churchyard watchman, and the pursuing organist of IN THE
;;; COURT OF THE DRAGON, which is the crossing into Carcosa. JRPG mechanics are
;;; kept (overworld travel, turn battles against the human menace of the city,
;;; stats, items, composure); the village, the quest, and the demon lord are
;;; gone. Companions, if any, are picked up later and only if they fit.

(dialog-particles "jrpg/inn" :ash :fade-seconds 2.0)
;; the music turns over the moment the crown flashes - the path has its own air
(dialog-music "jrpg/crown-flash" "audio/jrpg-opening.mp3" :volume 0.22)
(dialog-music "jrpg/inn" "audio/jrpg-opening.mp3" :volume 0.22)
(dialog-sound "jrpg/the-book" "audio/jrpg/ledger.wav" :volume 0.22)
(dialog-sound "jrpg/clasp" "audio/jrpg/coin.wav" :volume 0.26)
(dialog-sound "jrpg/watchman-combat" "audio/jrpg/sword.wav" :volume 0.32)

;; Lyria ambient beds (generated via scripts/gen-lyria-music.sh) and the
;; night-city sound effects (scripts/gen-jrpg-sfx.lisp).
(dialog-music "jrpg/studio" "audio/jrpg-studio.mp3" :volume 0.20)
(dialog-music "jrpg/city-hub" "audio/jrpg-city-night.mp3" :volume 0.20)
(dialog-music "jrpg/flight" "audio/jrpg-court.mp3" :volume 0.22)
(dialog-music "jrpg/dys-meet" "audio/jrpg-dys.mp3" :volume 0.20)
(dialog-sound "jrpg/studio-door" "audio/jrpg/door.wav" :volume 0.30)
(dialog-sound "jrpg/church" "audio/jrpg/organ.wav" :volume 0.32)
(dialog-sound "jrpg/dys-viper" "audio/jrpg/viper.wav" :volume 0.40)
(dialog-sound "jrpg/marble-fluid" "audio/jrpg/chime.wav" :volume 0.34)

(dialog-on-enter "jrpg/inn"
                 '(jrpg-init-state))

(dialog-text "jrpg/inn"
             "a rented room, the lamp low: one window on a courtyard, your coat over the back of the chair."
             :next "jrpg/inn-s2")

(dialog-text "jrpg/inn-s2"
             "on the table is a slim book in pale cloth. you have kept to it for days, and seen no one."
             :next "jrpg/the-book")

(dialog-on-enter "jrpg/the-book"
                 '(jrpg-mark-yellow-sign)
                 '(jrpg-grant-item "jrpg-play-scraps")
                 '(jrpg-start-quest :sign))

(dialog-text "jrpg/the-book"
             "the book is THE KING IN YELLOW. you have read its first act only. you set it down at the second, as everyone does."
             :next "jrpg/the-book-s2")

(dialog-text "jrpg/the-book-s2"
             "inside the cover a small sign is stamped in yellow, the one colour in the room."
             :next "jrpg/name")

(dialog-string "jrpg/name"
               "a name is written on the flyleaf, in your own hand. what is it?"
               :response-key "player-name"
               :max-length 24
               :target "jrpg/window")

(dialog-text "jrpg/window"
             "{player-name}. you put the book in your coat. across the courtyard a studio skylight is lit."
             :next "jrpg/window-s2")

(dialog-text "jrpg/window-s2"
             "a man paints late and someone poses for him. in the churchyard below them a figure stands very still, its face turned up."
             :next "jrpg/street")


;;; The night city - travel and the ordinary menace of it (overworld + battle)

(dialog-text "jrpg/street"
             "after dark the street is dangerous in the usual ways. gas lamps far apart. a man in a doorway. footsteps behind you, then none."
             :next "jrpg/street-walk")

(dialog-minigame "jrpg/street-walk"
                 "arrows or wasd move. cross the square to the lit studio."
                 :game :jrpg-overworld
                 :success "jrpg/studio-door"
                 :failure "jrpg/studio-door"
                 :config (list :gen-width 34
                               :gen-height 18
                               :terrain :streets
                               :finish-glyph #\!
                               :waypoints '(#\R)
                               :store-prefix "kiy-street"
                               :encounter-target "jrpg/ruffian-combat"
                               :encounter-rate 16
                               :start-message "the square at night. arrows or wasd move."
                               :legend "! studio stair    $ Hours    o tonic"
                               :tile-messages
                               '((#\R . "a gas lamp, guttering low.")
                                 (#\! . "the studio's stair door stands ajar.")
                                 (#\. . "wet cobbles, and your own echo."))))

(dialog-minigame "jrpg/ruffian-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/street-walk"
                 :failure "jrpg/ruffian-down"
                 :config (list :enemy-pool :city
                               :enemy-name "RUFFIAN"
                               :enemy-kind "ruffian"
                               :enemy-hp 15
                               :enemy-attack-min 3
                               :enemy-attack-max 6
                               :victory-xp 4
                               :victory-gold 6
                               :message "a man comes out of a doorway with his hands low and open."))

(dialog-on-enter "jrpg/ruffian-down"
                 '(jrpg-heal 6))

(dialog-text "jrpg/ruffian-down"
             "you come to against a wall with your pockets lighter and your head ringing. the studio light is still on across the square. you go on."
             :next "jrpg/street-walk")


;;; THE YELLOW SIGN - the studio

(dialog-particles "jrpg/studio" :motes :fade-seconds 3.0)
(dialog-on-enter "jrpg/studio" '(jrpg-lean-class :painter 1))

(dialog-text "jrpg/studio-door"
             "the stair smells of turpentine and cold stone. at the top, a studio: a man at an easel, a woman in a robe on the model stand."
             :next "jrpg/studio-door-s2")

(dialog-text "jrpg/studio-door-s2"
             "the stove is out. the man is scraping at his own canvas with a knife."
             :next "jrpg/studio")

(dialog-say "jrpg/studio"
            "the painter"
            "i can't hold the flesh tones. they go to mud the moment i look away. you are the third person tonight to come up that stair i did not hear."
            :next "jrpg/studio-2")

(dialog-say "jrpg/studio-2"
            "you"
            "who were the other two?"
            :next "jrpg/studio-3")

(dialog-say "jrpg/studio-3"
            "the painter"
            "i don't know. that is the trouble. Scott, by the way. the model is Tessie. sit down; mind the wet paint."
            :next "jrpg/studio-questions")

(dialog-interrogation "jrpg/studio-questions"
                      "Scott wipes the knife. Tessie keeps her eyes on the window, away from the churchyard."
                      (:next "jrpg/clasp")
                      (:continue-label "let it lie")
                      ("ask about the canvas"
                       :id "canvas"
                       :speaker "Scott"
                       "i can't hold the flesh tones. sound flesh goes to gangrene under the brush, in an afternoon. i scrape it back and it comes again.")
                      ("ask Tessie about the watchman"
                       :id "watchman"
                       :speaker "Tessie"
                       "i dreamed a hearse went by, and the driver turned and looked up at me. his face was white, and soft."
                       "it looked long dead. that man in the churchyard has his face.")
                      ("ask about the book on the shelf"
                       :id "play"
                       :speaker "Scott"
                       "the first act is harmless. beautiful, even. the second damns you. we read the first, the three of us. i will not open the second."))

(dialog-on-enter "jrpg/clasp"
                 '(jrpg-grant-item "jrpg-mask-shard")
                 '(jrpg-add-item :sign-clasp))

(dialog-text "jrpg/clasp"
             "Tessie unpins it from her robe and presses it on you: a clasp of black onyx, a symbol inlaid in gold."
             :next "jrpg/clasp-s2")

(dialog-text "jrpg/clasp-s2"
             "it is neither Arabic nor Chinese, nor does it belong to any human script. it is colder than metal should be, and she wants it out of the room."
             :next "jrpg/read-choice")

(dialog-pick "jrpg/read-choice"
             "Scott's copy of the Play lies open at the end of the first act. the second act begins on the next page."
             (dialog-option "read on into the second act" "jrpg/read-second")
             (dialog-option "read the strange middle pages first" "jrpg/prophets")
             (dialog-option "close the book" "jrpg/watchman-comes"))

(dialog-on-enter "jrpg/read-second"
                 '(jrpg-spend-composure 3)
                 '(jrpg-grant-item "jrpg-second-act")
                 '(jrpg-lean-class :reader 2))

(dialog-text "jrpg/read-second"
             "you read a few lines of the second act before Scott takes the book from your hands. he is too late for you."
             :next "jrpg/read-second-s2")

(dialog-text "jrpg/read-second-s2"
             "the words are clear as crystal, limpid and musical. they stay in your mouth after the book closes. the stove has gone cold."
             :next "jrpg/watchman-comes")

(dialog-text "jrpg/watchman-comes"
             "a step on the stair. then another, wet and heavy. Scott bolted the door. it is opening."
             :next "jrpg/watchman-comes-s2")

(dialog-text "jrpg/watchman-comes-s2"
             "the smell that comes up is churchyard. Tessie grips the stove rail and does not scream."
             :next "jrpg/watchman-combat")

(dialog-minigame "jrpg/watchman-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/after-watchman"
                 :failure "jrpg/watchman-takes"
                 :config (list :enemy-name "THE WATCHMAN"
                               :enemy-kind "watchman"
                               :enemy-hp 30
                               :enemy-attack-min 4
                               :enemy-attack-max 8
                               :victory-xp 12
                               :victory-gold 0
                               :message "the watchman comes in soft and white, one hand out for the clasp: have you found the Yellow Sign."))

(dialog-on-enter "jrpg/after-watchman" '(jrpg-lean-class :watchman 1))

(dialog-text "jrpg/after-watchman"
             "the watchman drops to the boards. the coat splits at the seams. inside are wet cloth, churchyard mud, and one soft white finger."
             :next "jrpg/after-watchman-s2")

(dialog-text "jrpg/after-watchman-s2"
             "Scott is down with the Play shut under his hand. Tessie holds your sleeve and says nothing."
             :next "jrpg/after-watchman-s3")

(dialog-text "jrpg/after-watchman-s3"
             "you keep the clasp. you did not mean to."
             :next "jrpg/leave-studio")

(dialog-text "jrpg/watchman-takes"
             "the watchman is stronger than you. when you can stand, he is gone, and so is Tessie."
             :next "jrpg/watchman-takes-s2")

(dialog-text "jrpg/watchman-takes-s2"
             "Scott says she has gone to find the Yellow Sign, and will not say it again. you still have the clasp. it is warm now."
             :next "jrpg/leave-studio")

(dialog-on-enter "jrpg/leave-studio" '(jrpg-add-item :palette-knife))

(dialog-text "jrpg/leave-studio"
             "you go down the stair and out. the night street opens on a square, the gas burning low, and a handful of doors still lit around it."
             :next "jrpg/city-hub")


;;; THE REPAIRER OF REPUTATIONS - Hawberk's, and the room above it

(dialog-minigame "jrpg/wilde-street"
                 "arrows or wasd move. reach the lit armourer's shop."
                 :game :jrpg-overworld
                 :success "jrpg/hawberk"
                 :failure "jrpg/hawberk"
                 :config (list :gen-width 32
                               :gen-height 16
                               :terrain :streets
                               :finish-glyph #\!
                               :store-prefix "kiy-wilde"
                               :encounter-target "jrpg/thief-combat"
                               :encounter-rate 16
                               :start-message "a side street. arrows or wasd move."
                               :legend "! the armourer's    $ Hours    o tonic"
                               :tile-messages
                               '((#\! . "the armourer's lit window, the mail white in it.")
                                 (#\. . "narrow cobbles underfoot."))))

(dialog-minigame "jrpg/thief-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/wilde-street"
                 :failure "jrpg/thief-down"
                 :config (list :enemy-pool :city
                               :enemy-name "THIEF"
                               :enemy-kind "ruffian"
                               :enemy-hp 13
                               :enemy-attack-min 3
                               :enemy-attack-max 5
                               :victory-xp 4
                               :victory-gold 7
                               :message "a thin hand goes for the clasp in your coat before you see the rest of him."))

(dialog-on-enter "jrpg/thief-down"
                 '(jrpg-heal 5))

(dialog-text "jrpg/thief-down"
             "he gets a coin and not the clasp, and is gone down an alley. the armourer's window is still lit ahead."
             :next "jrpg/wilde-street")

(dialog-say "jrpg/hawberk"
            "Constance"
            "father is riveting and will not look up. you want the stair. everyone who wants the stair has your look."
            :next "jrpg/hawberk-2")

(dialog-say "jrpg/hawberk-2"
            "you"
            "what look is that?"
            :next "jrpg/hawberk-3")

(dialog-say "jrpg/hawberk-3"
            "Constance"
            "you have not slept. go up, then. Mr. Wilde is expecting you. he expects everyone."
            :next "jrpg/wilde")

(dialog-on-enter "jrpg/wilde" '(jrpg-lean-class :repairer 2))

(dialog-text "jrpg/wilde"
             "up the stair, a low room. a small scarred man sits in a chair too high for him."
             :next "jrpg/wilde-s2")

(dialog-text "jrpg/wilde-s2"
             "his ears are wax and painted shell-pink, for he has none of his own. his left hand has no fingers."
             :next "jrpg/wilde-s3")

(dialog-text "jrpg/wilde-s3"
             "a cat in his lap, a ledger on his knee, a locked cabinet behind."
             :next "jrpg/wilde-s4")

(dialog-text "jrpg/wilde-s4"
             "he repairs reputations, he says. makes names and unmakes them, for a fee. he has been expecting you."
             :next "jrpg/wilde-questions")

(dialog-interrogation "jrpg/wilde-questions"
                      "the cat opens one eye. Mr. Wilde keeps a finger in the ledger."
                      (:next "jrpg/register-choice")
                      (:continue-label "the cabinet, then")
                      ("ask about the ledger of names"
                       :id "register"
                       :speaker "Mr. Wilde"
                       "every man whose name is in it has received the Yellow Sign, which no living soul dares disregard. yours is here."
                       "it is here twice. the second entry is dated after today. the handwriting matches yours.")
                      ("ask about the locked cabinet"
                       :id "crown"
                       :speaker "Mr. Wilde"
                       "a crown: a diadem fit for a king among kings. the scalloped tatters of the King in Yellow hide Yhtill forever."
                       "you may try it on; they all do. woe to you who are crowned with the crown of the King in Yellow.")
                      ("ask who the King is"
                       :id "king"
                       :speaker "Mr. Wilde"
                       "the son of Hastur. in Carcosa black stars hang in the heavens; the shadows of men's thoughts lengthen when the twin suns sink into the lake of Hali."
                       "he was a man once, the manuscript holds. now there is the Pallid Mask."))

(dialog-pick "jrpg/register-choice"
             "Mr. Wilde turns the ledger to a blank line beneath your name. the second entry is yours to write, in a hand you have not used yet."
             (dialog-option "add your name in the Sign's own hand" "jrpg/trace-sign")
             (dialog-option "leave the ledger as it lies" "jrpg/castaigne"))

(dialog-text "jrpg/castaigne"
             "a man rises from a dark corner you had not searched. he gives his name as Hildred and his title as Rex."
             :next "jrpg/castaigne-s2")

(dialog-text "jrpg/castaigne-s2"
             "the crown is promised to him, he says, and a rival claimant must be exiled or die."
             :next "jrpg/castaigne-s3")

(dialog-text "jrpg/castaigne-s3"
             "he has read further than you. he comes for the Sign with a clean razor and a writ already signed."
             :next "jrpg/castaigne-combat")

(dialog-minigame "jrpg/castaigne-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/after-castaigne"
                 :failure "jrpg/castaigne-down"
                 :config (list :enemy-name "HILDRED-REX"
                               :enemy-kind "ruffian"
                               :enemy-hp 26
                               :enemy-attack-min 4
                               :enemy-attack-max 8
                               :victory-xp 12
                               :victory-gold 8
                               :message "Hildred-Rex advances, crowning himself with both empty hands as he comes."))

(dialog-on-enter "jrpg/after-castaigne"
                 '(setf (jrpg-value "kiy-did-repairer") t)
                 '(jrpg-lean-class :watchman 1))

(dialog-text "jrpg/after-castaigne"
             "Hildred sits down hard and cries that the cat has got Mr. Wilde."
             :next "jrpg/after-castaigne-s2")

(dialog-text "jrpg/after-castaigne-s2"
             "the cat has. the small scarred man bleeds from the throat in his high chair. the ledger lies open at your name, twice."
             :next "jrpg/after-castaigne-s3")

(dialog-text "jrpg/after-castaigne-s3"
             "you go before the noise brings anyone. the cabinet you leave shut, this time."
             :next "jrpg/city-hub")

(dialog-on-enter "jrpg/castaigne-down"
                 '(jrpg-heal 6)
                 '(setf (jrpg-value "kiy-did-repairer") t)
                 '(jrpg-lean-class :watchman 1))

(dialog-text "jrpg/castaigne-down"
             "he has your collar and the razor at it when the cat takes Mr. Wilde's throat instead."
             :next "jrpg/castaigne-down-s2")

(dialog-text "jrpg/castaigne-down-s2"
             "Hildred lets go of you and turns on the man who promised him a crown. you leave them to it. the ledger lies open at your name, twice."
             :next "jrpg/city-hub")


;;; THE MASK - Boris's studio and the marble pool

(dialog-particles "jrpg/boris" :motes :fade-seconds 3.0)
(dialog-on-enter "jrpg/boris" '(jrpg-lean-class :painter 1))

(dialog-text "jrpg/mask-street"
             "the streets give onto a court. one door stands open on white light. the light comes from marble: walls, floor, busts, hands, faces."
             :next "jrpg/boris")

(dialog-say "jrpg/boris"
            "Boris"
            "mind the pool - it is clear, and it is not water. i found a fluid that turns the living to marble, every pore. i meant it for lilies."
            :next "jrpg/boris-2")

(dialog-say "jrpg/boris-2"
            "you"
            "and the woman by the pool?"
            :next "jrpg/boris-3")

(dialog-say "jrpg/boris-3"
            "Boris"
            "Geneviève. my wife. ask, if you must; everyone who comes through asks."
            :next "jrpg/boris-questions")

(dialog-interrogation "jrpg/boris-questions"
                      "Boris stands between you and the pool."
                      (:next "jrpg/marble-fluid")
                      (:continue-label "to the pool")
                      ("ask what the fluid does to a person"
                       :id "fluid"
                       :speaker "Boris"
                       "it keeps them in the pose they were in. destroyed, preserved; how can you tell? i found it by accident. it was simple.")
                      ("ask about Geneviève"
                       :id "genevieve"
                       :speaker "Boris"
                       "she loved another man, and could not bear it, and she is in the pool now."
                       "they tell me she will soften and step out again, in time. i would like to believe them.")
                      ("ask why he is telling you"
                       :id "why"
                       :speaker "Boris"
                       "you carry the Sign. take some of the fluid, then; it is a kinder way to stop than most, and you may be glad of it."))

(dialog-on-enter "jrpg/marble-fluid"
                 '(jrpg-grant-item "jrpg-mask-shard")
                 '(jrpg-add-item :marble-phial)
                 '(jrpg-lean-class :painter 1))

(dialog-text "jrpg/marble-fluid"
             "you fill a small phial from the pool, clear and heavy and faintly warm. Boris watches you do it, and says nothing."
             :next "jrpg/marble-combat")

(dialog-minigame "jrpg/marble-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/after-marble"
                 :failure "jrpg/after-marble"
                 :config (list :enemy-name "THE MARBLE-TOUCHED"
                               :enemy-kind "phantom"
                               :enemy-hp 24
                               :enemy-attack-min 3
                               :enemy-attack-max 7
                               :victory-xp 10
                               :victory-gold 4
                               :message "the marble by the wall moves first at the fingers, then at the jaw. it steps down off its base."))

(dialog-on-enter "jrpg/after-marble"
                 '(setf (jrpg-value "kiy-did-mask") t))

(dialog-text "jrpg/after-marble"
             "the marble-touched goes still mid-step. Boris does not look up from the pool. you leave him there and find your way back to the square."
             :next "jrpg/city-hub")


;;; IN THE COURT OF THE DRAGON - the pursuit and the crossing

(dialog-text "jrpg/church"
             "inside, vespers are over. the organist comes down from behind his pipes."
             :next "jrpg/church-s2")

(dialog-text "jrpg/church-s2"
             "a slender man, his face as white as his coat is black. as he passes, he sends a look of hate straight into your eyes."
             :next "jrpg/church-s3")

(dialog-text "jrpg/church-s3"
             "when you leave, he leaves. when you stop, he stops, nearer."
             :next "jrpg/organ-game")

(dialog-minigame "jrpg/flight"
                 "arrows or wasd move. lose the organist in the streets."
                 :game :jrpg-overworld
                 :success "jrpg/threshold"
                 :failure "jrpg/threshold"
                 :config (list :gen-width 38
                               :gen-height 20
                               :terrain :streets
                               :finish-glyph #\!
                               :waypoints '(#\R)
                               :store-prefix "kiy-flight"
                               :start-message "side streets and courts. arrows or wasd move."
                               :legend "! the way out"
                               :tile-messages
                               '((#\R . "a corner with a broken lamp glass.")
                                 (#\! . "the covered arch opens beyond the last row of shops.")
                                 (#\. . "slick stones and your own breath."))))

(dialog-text "jrpg/threshold"
             "you pass under the covered arch. black stars hang in the heavens. wet wind comes off the lake of Hali."
             :next "jrpg/threshold-s2")

(dialog-text "jrpg/threshold-s2"
             "beyond it, the towers of Carcosa rise behind the moon. the organ has stopped."
             :next "carcosa/title")


;;; ===========================================================================
;;; Discoverable episodes - the rest of Chambers, off the spine but in depth.
;;; Each is an optional detour that rejoins the main road, and each turns on the
;;; same engine as the King: time that will not move on, people kept in a last
;;; gesture. THE DEMOISELLE D'YS (a Breton moor, five centuries back), THE
;;; PROPHETS' PARADISE (the Play's middle pages), and the four Paris street
;;; stories (an old quarter caught before loss).
;;; ===========================================================================


;;; THE DEMOISELLE D'YS - a green lane off the thinned city drops the player
;;; five centuries back onto the Breton moor, into a love that has already
;;; happened and a death already on the stone. The falconer is named Hastur,
;;; the same name a scarred man gave a god an hour ago.

;;; THE NIGHT-CITY HUB (in-city grid). The player chooses which district to
;;; enter and in what order; a finished district drops its door on re-entry; the
;;; church door is always open and is the crossing - leave by it early and you
;;; miss the stories you did not walk into. The flyleaf's "again" brings you
;;; back to find them.

(dialog-particles "jrpg/city-hub" :snow :fade-seconds 2.5)
(dialog-on-enter "jrpg/city-hub" '(jrpg-start-quest :cross))

(dialog-minigame "jrpg/city-hub"
                 "arrows or wasd move. each doorway is signed; step into one."
                 :game :jrpg-city
                 :success "jrpg/church"
                 :failure "jrpg/church"
                 :config (list :gen-width 35
                               :gen-height 17
                               :store-prefix "kiy-hub"
                               :doors '(("A" "jrpg/wilde-street" :name "armoury"      :done "kiy-did-repairer")
                                        ("M" "jrpg/mask-street"  :name "marble court" :done "kiy-did-mask")
                                        ("Q" "jrpg/old-quarter"  :name "old quarter"  :done "kiy-did-quarter")
                                        ("D" "jrpg/dys-lane"     :name "green lane"   :done "kiy-did-dys")
                                        ("S" "jrpg/character"    :name "yourself")
                                        ("P" "jrpg/shop"         :name "pawnbroker")
                                        ("C" "jrpg/church"       :name "the church"   :exit t))
                               :legend "the doorways are signed; the church-gate on the rim is the way on."))

(dialog-particles "jrpg/dys-meet" :motes :fade-seconds 3.0)

(dialog-text "jrpg/dys-lane"
             "the lane gives out onto open moor at sundown. gorse and heath cover the valleys. granite boulders stand in the grass."
             :next "jrpg/dys-lane-s2")

(dialog-text "jrpg/dys-lane-s2"
             "you carry a fowling-piece, and the sea-wind is in your face."
             :next "jrpg/dys-meet")

(dialog-text "jrpg/dys-meet"
             "out of the gorse come falconers in old dress, hooded hawks on their wrists. a girl rides at their head, gloved, grave, young."
             :next "jrpg/dys-meet-s2")

(dialog-text "jrpg/dys-meet-s2"
             "she asks whether you came from Kerselec. she is the Demoiselle Jeanne d'Ys."
             :next "jrpg/dys-questions")

(dialog-interrogation "jrpg/dys-questions"
                      "Jeanne d'Ys waits, a gloved hand on a hooded bird. her falconers hold off a little. the chief of them she calls Hastur."
                      (:next "jrpg/dys-hawk")
                      (:continue-label "ride on with her")
                      ("ask what year it is"
                       :id "year"
                       :speaker "Jeanne"
                       "she gives a year five centuries gone, as plainly as you would give this one, and does not understand the question. here it is the only year there is.")
                      ("ask after the falconer Hastur"
                       :id "hastur"
                       :speaker "Jeanne"
                       "her master of hawks; incomparable, she says, on the green. you heard the name once tonight from a scarred man, said of a god."
                       "she has never left this moor to hear it said so.")
                      ("ask how far Kerselec is"
                       :id "expected"
                       :speaker "Jeanne"
                       "to come is easy and takes hours, she says. to go is different, and may take centuries. then she looks at the bird, not at you."))

(dialog-text "jrpg/dys-hawk"
             "she teaches you the lure. swing it. let the hawk taste the quarry. faire courtoisie a l'oiseau. the sun stays above the gorse until your arm aches."
             :next "jrpg/dys-viper")

(dialog-on-enter "jrpg/dys-viper"
                 '(jrpg-spend-composure 2)
                 '(jrpg-lean-class :mourner 2))

(dialog-text "jrpg/dys-viper"
             "by the stream the hawks scream. a grey snake lies on the warm rock, a black V on its neck."
             :next "jrpg/dys-viper-s2")

(dialog-text "jrpg/dys-viper-s2"
             "she clings to your arm. don't, i am afraid. for me? for you, she says. i love you."
             :next "jrpg/dys-viper-s3")

(dialog-text "jrpg/dys-viper-s3"
             "then a sting at the ankle. your legs fail, and the stream fills your ear."
             :next "jrpg/dys-wake")

(dialog-text "jrpg/dys-wake"
             "you wake among ivied ruins, great trees grown through the floor."
             :next "jrpg/dys-wake-s2")

(dialog-text "jrpg/dys-wake-s2"
             "a falcon climbs the sky in narrowing circles until it is gone. where the manor stood, a crumbling shrine to our Lady of Sorrows."
             :next "jrpg/dys-tomb")

(dialog-on-enter "jrpg/dys-tomb"
                 '(jrpg-grant-item "jrpg-play-scraps")
                 '(setf (jrpg-value "jrpg-dys-seen") t)
                 '(jrpg-add-item :dys-glove))

(dialog-text "jrpg/dys-tomb"
             "carved beneath her: PRAY FOR THE SOUL OF JEANNE D'YS, WHO DIED IN HER YOUTH FOR LOVE OF {player-name}, A STRANGER."
             :next "jrpg/dys-tomb-s2")

(dialog-text "jrpg/dys-tomb-s2"
             "A.D. 1573. and upon the icy slab lies a woman's glove, still warm and fragrant."
             :next "jrpg/dys-out")

(dialog-on-enter "jrpg/dys-out"
                 '(setf (jrpg-value "kiy-did-dys") t))

(dialog-text "jrpg/dys-out"
             "you leave the shrine by a stone path. it ends in the city square, with the lit doors ahead."
             :next "jrpg/dys-out-s2")

(dialog-text "jrpg/dys-out-s2"
             "your foot still drags from the bite. the glove is in your coat now, warm as the Sign."
             :next "jrpg/city-hub")


;;; THE FOUR PARIS STREETS - an old quarter the Sign has reached the way it
;;; reaches the city: by keeping it. Four small human stories, each stopped
;;; before loss. Discoverable, then left alone.

(dialog-particles "jrpg/old-quarter" :snow :fade-seconds 3.0)

(dialog-on-enter "jrpg/old-quarter"
                 '(jrpg-spend-composure 1))

(dialog-text "jrpg/old-quarter"
             "the old quarter, where the gas still burns warm and yellow. students crowd the cafes. lovers stand under doors."
             :next "jrpg/old-quarter-s2")

(dialog-text "jrpg/old-quarter-s2"
             "four streets repeat the hour before loss; you walk them."
             :next "jrpg/old-quarter-streets")

(dialog-interrogation "jrpg/old-quarter-streets"
                      "four corners, four stories. walk each, or leave them be."
                      (:next "jrpg/old-quarter-out")
                      (:continue-label "leave the quarter")
                      ("the Street of the Four Winds"
                       :id "winds"
                       :speaker "the quarter"
                       "a grey cat brings a dead woman's ribbon up the stair to the painter Severn."
                       "he finds Sylvia cold, kisses her; the cat purrs on his knee toward a dawn that never comes.")
                      ("the Street of the First Shell"
                       :id "shell"
                       :speaker "the quarter"
                       "a plaque reads HERE FELL THE FIRST SHELL. the siege of '70: a girl at a window, and the shell in the air above her, not falling.")
                      ("the Street of Our Lady of the Fields"
                       :id "lady"
                       :speaker "the quarter"
                       "the quietest street. a young man calls 'a demain, Valentine' to a girl at a gate - see you tomorrow - and tomorrow never comes.")
                      ("Rue Barree"
                       :id "rue"
                       :speaker "the quarter"
                       "the students named a girl Rue Barree - street closed - because none could reach her."
                       "Selby loves her and never says it. she passes with a cold smile. he opens his mouth and stops."))

(dialog-on-enter "jrpg/old-quarter-out"
                 '(setf (jrpg-value "kiy-did-quarter") t))

(dialog-text "jrpg/old-quarter-out"
             "you leave the four streets. the warm gas dims behind you. the square is ahead."
             :next "jrpg/city-hub")


;;; THE PROPHETS' PARADISE - the Play's middle pages, between the acts.
;;; Eight short visions that return to their first image. The Green Room's white
;;; mask is his.

(dialog-particles "jrpg/prophets" :ash :fade-seconds 2.5)

(dialog-on-enter "jrpg/prophets"
                 '(jrpg-spend-composure 2)
                 '(jrpg-grant-item "jrpg-play-scraps")
                 '(jrpg-lean-class :reader 1))

(dialog-interrogation "jrpg/prophets"
                      "the middle pages - not the first act, not the second. eight short visions. you read until the same page returns."
                      (:next "jrpg/read-choice")
                      (:continue-label "shut the middle pages")
                      ("The Studio"
                       :id "p-studio"
                       :speaker "the Play"
                       "a man waits in his studio for a woman he will know when she comes. seek her throughout the world, says Death."
                       "my world is here, he answers. the footsteps in the street below have already passed.")
                      ("The Phantom"
                       :id "p-phantom"
                       :speaker "the Play"
                       "the Phantom of the Past will go no further. if you find in me a friend, let us turn back together, she sighs."
                       "he seizes her, white with anger; she resists. she will always resist.")
                      ("The Sacrifice"
                       :id "p-sacrifice"
                       :speaker "the Play"
                       "a field of flowers whiter than snow. a woman pours blood on them from a jar marked with a thousand names."
                       "i have killed him i loved, she cries. the world's athirst; now let it drink.")
                      ("Destiny"
                       :id "p-destiny"
                       :speaker "the Play"
                       "the bridge which few may pass. pass! cries the keeper. there is time, you laugh - and he smiles and shuts the gates."
                       "young and old are refused. you laugh: there is time.")
                      ("The Throng"
                       :id "p-throng"
                       :speaker "the Play"
                       "you stand with Pierrot in the thick of the crowd; all eyes on you. he has robbed your purse!"
                       "Truth holds up a mirror. arrest Truth, you cry, forgetting what it was you lost.")
                      ("The Jester"
                       :id "p-jester"
                       :speaker "the Play"
                       "was she fair? you ask. the jester only listens to his cap-bells. stabbed, he titters."
                       "she kissed him at the gate; in the hall, his brother's welcome touched his heart.")
                      ("The Green Room"
                       :id "p-green"
                       :speaker "the Play"
                       "the Clown turns his powdered face to the mirror. who can compare with me in my white mask?"
                       "who can compare? you ask Death beside you. i am paler still, says Death.")
                      ("The Love Test"
                       :id "p-love"
                       :speaker "the Play"
                       "if you love, wait no longer, says Love; give her these jewels that would dishonour her."
                       "she treads them down, sobbing: teach me to wait - i love you. then wait, says Love."))
