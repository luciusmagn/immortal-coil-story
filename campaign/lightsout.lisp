;;; Lights out: the rogue path's second dark branch. The torch fails and
;;; the delve goes sight-starved. Entered by pressing on past the torch's
;;; reach; rejoins at the stair hunt.

(dialog-text "lightsout/press"
             "you press on past the torch's reach. it gutters brown, then goes out."
             :next "lightsout/dies")

(dialog-text "lightsout/dies"
             "you keep one hand on the wall and count doorframes by touch. another set of steps keeps half a pace behind yours."
             :next "lightsout/hide-setup")

(dialog-text "lightsout/hide-setup"
             "something comes down the middle of the corridor. you stop breathing."
             :next "lightsout/hold-still")

(dialog-minigame "lightsout/hold-still"
                 "space, w, or up arrow lets a breath out. stay quiet until it passes."
                 :game :forest-hide
                 :success "lightsout/passed"
                 :failure "lightsout/brushed"
                 :config '(:duration 9.0 :breath-rise 0.09))

(dialog-text "lightsout/passed"
             "it passes close enough to stir your coat. cold wax. old fur. the floor carries your heartbeat. then the draft resumes. the wall is warm under your hand. you go on."
             :next "lightsout/middles")

(dialog-text "lightsout/brushed"
             "it slows beside you. something at coat height takes one breath of you, files the result, and moves on. you are known and released."
             :next "lightsout/brushed-2")

(dialog-text "lightsout/brushed-2"
             "you pay it standing very still. after it passes, the corridor gives you your lungs back."
             :next "lightsout/middles")

(dialog-text "lightsout/middles"
             "you understand the lanes now. the walls have their tenants and the brackets have their feeders, and the middle of a corridor is the lane left over, walked by whatever the rota could not cover. you keep to the wall."
             :next "lightsout/lamplighter-glow")

(dialog-text "lightsout/lamplighter-glow"
             "farther on, the black thins. not light. almost-light, the kind your eyes make after a lamp goes out. then a sound from upstairs: a taper carried with care."
             :next "lightsout/lamplighter")

(dialog-say "lightsout/lamplighter"
            "the lamplighter"
            "mind the bracket. wet oil. you are the one whose torch was levied. that was not mine. i light fair, whatever the season."
            :next "lightsout/lamplighter-2")

(dialog-say "lightsout/lamplighter-2"
            "you"
            "you light torches you cannot see, in the dark, to feed the dark."
            :next "lightsout/lamplighter-3")

(dialog-say "lightsout/lamplighter-3"
            "the lamplighter"
            "i light by touch, to a rota, and what the dark does with the light afterward is the dark's business and the ledger's. you want it to be sinister. it is groceries."
            :next "lightsout/lamplighter-questions")

(dialog-interrogation "lightsout/lamplighter-questions"
                      "the lamplighter waits at the bracket with the taper unlit, in no apparent hurry to explain himself further unless asked."
                      (:next "lightsout/etiquette")
                      (:continue-label "learn the rules")
                      ("ask how long he has walked the round"
                       :id "round"
                       :speaker "the lamplighter"
                       "longer than the torches last, shorter than the dark. you do not count a round in years. you count it in brackets, and i have lit a great many brackets.")
                      ("ask what happens if a bracket is missed"
                       :id "missed"
                       :speaker "the lamplighter"
                       "the dark goes hungry there and takes the difference from the next warm thing. usually a rat. once a lamplighter who argued the rota. i do not argue the rota.")
                      ("ask whether the dark ever refuses the light"
                       :id "refuse"
                       :speaker "the lamplighter"
                       "never. it is the most grateful thing i tend. a mouth that says thank you is not a monster. it is a guest, and i keep it fed like one."))

(dialog-say "lightsout/etiquette"
            "the lamplighter"
            "since you are walking my round: rules. never strike a light without offering it. announce yourself at the crossings. and if you feed it by hand, feed it small and feed it finished. the dark keeps what it is given. give it nothing you want back."
            :next "lightsout/etiquette-2")

(dialog-say "lightsout/etiquette-2"
            "you"
            "has it ever given anything back?"
            :next "lightsout/etiquette-3")

(dialog-say "lightsout/etiquette-3"
            "the lamplighter"
            "once. a candle, spent, returned to the upper shrine, stood back in its socket, guttered. nobody knows whose. the dark kept the burning and returned the wax. that is the dark being generous. study it."
            :next "lightsout/one-dark")

(dialog-say "lightsout/one-dark"
            "the lamplighter"
            "you are wondering if it is one dark or many. everyone walks a round wondering that."
            :next "lightsout/one-dark-2")

(dialog-say "lightsout/one-dark-2"
            "you"
            "which is it?"
            :next "lightsout/one-dark-3")

(dialog-say "lightsout/one-dark-3"
            "the lamplighter"
            "one. the brackets share a draught. feed one, and the pull eases along the run. somewhere else, a bracket goes quiet because you stood here."
            :next "lightsout/round")

(dialog-text "lightsout/round"
             "you walk the round with the lamplighter, bracket to bracket, and learn the work by sound: the scrape of the taper, the catch of the wick."
             :next "lightsout/round-flame")

(dialog-text "lightsout/round-flame"
             "then, each time, the new flame bends into the dark. the pull is steady. the wick shortens by visible degrees."
             :next "lightsout/round-attending")

(dialog-text "lightsout/round-attending"
             "the lamplighter waits by each torch while it is taken. one hand on the bracket. he does not guard it. he attends it."
             :next "lightsout/round-company")

(dialog-text "lightsout/round-company"
             "he says the dark eats better with company. no one nearby can argue."
             :next "lightsout/taper")

(dialog-text "lightsout/taper"
             "the taper itself is never offered. it rides cupped in the lamplighter's off hand, fed first at every stop, shielded with a shoulder when the dark leans in."
             :next "lightsout/taper-s2")

(dialog-text "lightsout/taper-s2"
             "the one protected flame on the round. the dark leaves it alone because the rota says so."
             :next "lightsout/taper-2")

(dialog-text "lightsout/taper-2"
             "lit, the lamplighter says, from the lamp at the bottom of the stacks. the clerk's lamp. the building's first fire."
             :next "lightsout/taper-2-2")

(dialog-text "lightsout/taper-2-2"
             "if the taper goes out, the round starts again from the bottom, in the dark, on the ramps, and the lamplighter has done that walk twice in a tenure and aged a shelf-mark each time."
             :next "lightsout/your-turn")

(dialog-text "lightsout/your-turn"
             "halfway down the round, without ceremony, the lamplighter puts the taper in your hand. wet oil, two brackets, i will say when."
             :next "lightsout/your-turn-2")

(dialog-text "lightsout/your-turn-2"
             "you light two torches by touch. your shoulder shields the mother flame. the dark presses close around your hands. they do not shake. both of you notice. neither says so."
             :next "lightsout/ration-manners")

(dialog-text "lightsout/ration-manners"
             "somewhere on the round your stomach states its business, and your hand finds the ration in your pocket and stops there."
             :next "lightsout/ration-manners-s2")

(dialog-text "lightsout/ration-manners-s2"
             "never eat in front of it, you remember, before the rule was given. the lamplighter, not turning: you will do, for a surface person."
             :next "lightsout/shrine-maps")

(dialog-text "lightsout/shrine-maps"
             "you understand the upper shrine correctly now. the candles are the table. the maps nailed under them are reading matter."
             :next "lightsout/shrine-maps-2")

(dialog-text "lightsout/shrine-maps-2"
             "what the candles light, the dark reads while it eats. it likes to know its own shape, the lamplighter says. everyone does."
             :next "lightsout/licked-bracket")

(dialog-text "lightsout/licked-bracket"
             "one bracket on the round you find by touch before the lamplighter names it. the stone around it is polished smooth, a full arm's reach in every direction."
             :next "lightsout/licked-bracket-2")

(dialog-text "lightsout/licked-bracket-2"
             "the bad winter, is all the lamplighter says, and feeds that bracket first, and stands with it longest."
             :next "lightsout/short-rota")

(dialog-text "lightsout/short-rota"
             "two brackets on the round are empty. the rota is short, the lamplighter says, in the voice of a person rationing a household. the levies make up some of it."
             :next "lightsout/short-rota-2")

(dialog-text "lightsout/short-rota-2"
             "the rest, the dark goes without, and a dark that goes without gets ideas, and the ideas walk the middles of corridors."
             :next "lightsout/feed-choice")

(dialog-pick "lightsout/feed-choice"
             "at the round's last bracket the lamplighter pauses with the taper lowered. the dark gathers close around the two of you."
             (dialog-option "feed it your dead torch stub" "lightsout/feed-stub")
             (dialog-option "feed it the ring" "lightsout/feed-ring"
                            :when '(not (dialog-value "rogue-ring-worn")))
             (dialog-option "give it nothing" "lightsout/feed-nothing"))

(dialog-on-enter "lightsout/feed-stub"
                 '(setf (dialog-value "lightsout-fed") "stub"))

(dialog-text "lightsout/feed-stub"
             "you hold out the dead stub and the lamplighter lights it one last time from the taper, because the dark takes its meals lit."
             :next "lightsout/feed-stub-2")

(dialog-text "lightsout/feed-stub-2"
             "the flame pulls long, bends, and is drunk to the wood. the stub goes light in your fingers, then absent."
             :next "lightsout/fed-after")

(dialog-on-enter "lightsout/feed-ring"
                 '(setf (dialog-value "lightsout-fed") "ring"))

(dialog-text "lightsout/feed-ring"
             "you hold out the unidentified ring. the dark pauses over it, then takes it slowly, silver, curse and all."
             :next "lightsout/feed-ring-2")

(dialog-text "lightsout/feed-ring-2"
             "somewhere in the walls, the pacing makes a short low sound you have never heard from it."
             :next "lightsout/fed-after")

(dialog-text "lightsout/fed-after"
             "the pressure eases off your ears at once. the warm wall settles under your hand."
             :next "lightsout/fed-after-s2")

(dialog-text "lightsout/fed-after-s2"
             "fed, the lamplighter says, approvingly. then, to the dark: there now. the dark stays close and leaves you alone."
             :next "lightsout/fed-after-2")

(dialog-text "lightsout/fed-after-2"
             "a fed dark has its own feel. not unwatched. unbothered. you stand in it and understand the lamplighter's tenure a little. it is good to be left alone here."
             :next "lightsout/walked-up")

(dialog-text "lightsout/walked-up"
             "you start back with one hand on the warm wall."
             :next "lightsout/walked-up-2")

(dialog-text "lightsout/walked-up-2"
             "a second warmth keeps pace on your other side. you count the doors by touch and miss none. the draft stays on the same cheek the whole way."
             :next "lightsout/bracket-relit")

(dialog-on-enter "lightsout/feed-nothing"
                 '(setf (dialog-value "lightsout-fed") "nothing"))

(dialog-text "lightsout/feed-nothing"
             "you keep your pockets. the lamplighter does not judge. he has rationed households too. the dark does not punish you. it stops attending you."
             :next "lightsout/feed-nothing-2")

(dialog-text "lightsout/feed-nothing-2"
             "the dark stops attending you. the corridor goes from a place you are in to a distance you must cover."
             :next "lightsout/long-count")

(dialog-text "lightsout/long-count"
             "you cover it by arithmetic: doors counted, drafts banked, the warm wall your one rail. it takes what it takes."
             :next "lightsout/long-count-arrival")

(dialog-text "lightsout/long-count-arrival"
             "when you misstep, nothing catches you, and when you arrive, nothing congratulates you. you have never been this proud, or this alone."
             :next "lightsout/long-count-knock")

(dialog-text "lightsout/long-count-knock"
             "you will remember the warm wall."
             :next "lightsout/long-count-knock-s2")

(dialog-text "lightsout/long-count-knock-s2"
             "unfed, unobliged, the pacing held its half step the whole way, and at the last crossing it knocked once, low, level with your hand, and you knocked back."
             :next "lightsout/bracket-relit")

(dialog-text "lightsout/bracket-relit"
             "at the row's end, behind you, a bracket catches: the lamplighter, on the rota, restoring your stretch of corridor."
             :next "lightsout/bracket-relit-2")

(dialog-text "lightsout/bracket-relit-2"
             "the light reaches your ankles and stops there. your eyes hurt at even this much. that is how far in you went."
             :next "lightsout/goodbye")

(dialog-text "lightsout/goodbye"
             "the lamplighter does not say goodbye, exactly."
             :next "lightsout/goodbye-s2")

(dialog-text "lightsout/goodbye-s2"
             "the taper dips once in your direction. then the round goes on, bracket by bracket, into the dark it keeps back."
             :next "lightsout/rota-board")

(dialog-text "lightsout/rota-board"
             "at the junction by the stairs, the rota is chalked on the wall, bracket by bracket, in the lamplighter's square hand."
             :next "lightsout/rota-board-2")

(dialog-text "lightsout/rota-board-2"
             "your bracket's line has been amended tonight: levied, struck through, restored. the books balance. down here they always balance."
             :next "lightsout/torch-handed")

(dialog-text "lightsout/torch-handed"
             "a fresh torch stands in the next bracket, already half spent. you read it correctly now: half for you, half for the dark."
             :next "lightsout/torch-handed-2")

(dialog-text "lightsout/torch-handed-2"
             "you take it. tithe is the word that comes. the flame leans once toward the dark. the dark declines."
             :next "lightsout/sight-back")

(dialog-text "lightsout/sight-back"
             "sight returns in pieces: torch bracket, floor line, door edge, your hand on stone."
             :next "lightsout/sight-back-2")

(dialog-text "lightsout/sight-back-2"
             "the row of doors stands where your count put it. you crossed it blind. you know it now by hand."
             :next "rogue/stair-hunt")
