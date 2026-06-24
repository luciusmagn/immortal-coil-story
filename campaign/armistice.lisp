;;; The armistice: the war path's bright branch. The morning the eight
;;; o'clock bell does not ring, told as joy. The version with the
;;; all-clear in it, lived in for one morning. Entered from the fourth
;;; day; exits through waking.

(dialog-text "armistice/offer"
             "sometimes the dream gives you one more morning. eight o'clock is still ahead."
             :next "armistice/offer-choice")

(dialog-pick "armistice/offer-choice"
             "the bell will ring at eight, or it will not."
             (dialog-option "wake now" "sys/reboot")
             (dialog-option "stay for the morning it ends" "armistice/quiet"))

(dialog-scene "armistice/quiet"
              "the morning it ends."
              :next "armistice/no-bell")

(dialog-text "armistice/no-bell"
             "at eight o'clock the bell does not ring. no treaty is read aloud. no flags appear. clerks stand in the corridors and wait for the sound that does not come."
             :next "armistice/corridor")

(dialog-text "armistice/corridor"
             "the corridors fill with people who have stopped walking. clerks stand with folders against their chests and look up at the ceiling."
             :next "armistice/corridor-s2")

(dialog-text "armistice/corridor-s2"
             "somebody laughs once, high and frightened, and claps a hand over it. nobody tells them to stop."
             :next "armistice/second-minute")

(dialog-text "armistice/second-minute"
             "in the second minute, somewhere down the stairwell, a door opens that has been closed for four years. swollen wood, a shoulder, then daylight."
             :next "armistice/second-minute-s2")

(dialog-text "armistice/second-minute-s2"
             "room by room, the covered windows are opened."
             :next "armistice/tape")

(dialog-text "armistice/tape"
             "the tape comes off the glass in long ribbons."
             :next "armistice/tape-2")

(dialog-text "armistice/tape-2"
             "it leaves pale Xs in gum and dust over every view. the clerks polish them with their sleeves."
             :next "armistice/tape-3")

(dialog-text "armistice/tape-3"
             "the crosses come away. the city is behind them."
             :next "armistice/map-room")

(dialog-text "armistice/map-room"
             "in the map room, the tape line at the river has stopped. not advancing slower. stopped, with the morning's date pinned beside it in Sorel's hand."
             :next "armistice/map-room-2")

(dialog-text "armistice/map-room-2"
             "Olen stands at the map at attention, punctual to the last morning. he is weeping without noise."
             :next "armistice/sorel-line")

(dialog-say "armistice/sorel-line"
            "Sorel"
            "i have ruled a line under the casualty column. there is nothing to enter after it."
            :next "armistice/sorel-line-b")

(dialog-say "armistice/sorel-line-b"
            "Sorel"
            "chancellor, i have kept books for thirty years and i have never once ruled a line that stayed ruled."
            :next "armistice/sorel-line-2")

(dialog-say "armistice/sorel-line-2"
            "you"
            "will this one stay?"
            :next "armistice/sorel-line-3")

(dialog-say "armistice/sorel-line-3"
            "Sorel"
            "the column is closed. today the figure is final. i am going to sit down for a moment on the good chair."
            :next "armistice/sorel-questions")

(dialog-interrogation "armistice/sorel-questions"
                      "Sorel has not sat down yet. he stands by the closed column with the pen still in his hand."
                      (:next "armistice/brandt")
                      (:continue-label "let him sit down")
                      ("ask what the final figure is"
                       :id "figure"
                       :speaker "Sorel"
                       "i will not say it aloud today. you signed for most of it. read it tonight, alone, once.")
                      ("ask if he has closed such a column before"
                       :id "before"
                       :speaker "Sorel"
                       "harvests, debts, one bank. never a war. a war does not close, chancellor. this is the first line i have dared to trust.")
                      ("ask how a person closes the war inside"
                       :id "inside"
                       :speaker "Sorel"
                       "i do not know. books are easier than men. but i am told you begin by sitting on the good chair, and i intend to test the method directly."))

(dialog-say "armistice/brandt"
            "Brandt"
            "chancellor. the all-clear version. the one i said someone else would live in."
            :next "armistice/brandt-2")

(dialog-say "armistice/brandt-2"
            "you"
            "you were wrong, Brandt."
            :next "armistice/brandt-3")

(dialog-say "armistice/brandt-3"
            "Brandt"
            "i was wrong. i have never been so happy to file an error. i am going to be wrong about more things."
            :next "armistice/brandt-laugh")

(dialog-text "armistice/brandt-laugh"
             "and Brandt laughs. you have never heard it."
             :next "armistice/brandt-laugh-2")

(dialog-text "armistice/brandt-laugh-2"
             "nine years in this building and you have never heard it. it is terrible, honking, and of no administrative use."
             :next "armistice/brandt-laugh-3")

(dialog-text "armistice/brandt-laugh-3"
             "the clerks in the corridor hear it and pass it on. it reaches the stairwell ahead of him."
             :next "armistice/radio")

(dialog-text "armistice/radio"
             "in the night office the radio is on, tuned to the clear band out of four years of habit."
             :next "armistice/radio-2")

(dialog-text "armistice/radio-2"
             "the numbers are being read, group after group, the exhausted voice keeping its protocol. then, mid-group, it stops."
             :next "armistice/dead-air")

(dialog-text "armistice/dead-air"
             "dead air. a minute of it. you stand with your hand on the shelf and let it run."
             :next "armistice/dead-air-s2")

(dialog-text "armistice/dead-air-s2"
             "then the voice comes back, off protocol, unprofessional, close to the microphone, and says: go home."
             :next "armistice/dead-air-s3")

(dialog-text "armistice/dead-air-s3"
             "and the clear band, for the first time in four years, goes clear."
             :next "armistice/olen-map")

(dialog-say "armistice/olen-map"
            "Olen"
            "chancellor. i have stood at this map for four years. i find i do not know where to stand in a room that does not have one."
            :next "armistice/olen-map-2")

(dialog-say "armistice/olen-map-2"
            "you"
            "by the window, Olen. it is the new map. there is no tape on the river."
            :next "armistice/olen-map-3")

(dialog-say "armistice/olen-map-3"
            "Olen"
            "by the window. yes. i will require new habits. i am told the river is good to look at, now that it is only a river."
            :next "armistice/olen-questions")

(dialog-interrogation "armistice/olen-questions"
                      "Olen has not moved to the window yet. he stands where the map was, hands half-raised toward a thing that is no longer there."
                      (:next "armistice/vey")
                      (:continue-label "leave him to the window")
                      ("ask about leaving the map"
                       :id "map"
                       :speaker "Olen"
                       "the weight is gone. my hands keep reaching for it. i am told that fades. i am told a great many things fade, starting today.")
                      ("ask whether the window worries him"
                       :id "window"
                       :speaker "Olen"
                       "for four years a window was where a shell came through. i must learn it as where light comes through. the river has no orders on it.")
                      ("ask what new habits he will need"
                       :id "habits"
                       :speaker "Olen"
                       "to stand without a map. to plan a week instead of a front. to call the river a river."
                       "small habits, chancellor. i was only ever good at the large terrible ones."))

(dialog-text "armistice/vey"
             "you pass Vey's office. he is at his desk, writing in his even hand."
             :next "armistice/vey-2")

(dialog-text "armistice/vey-2"
             "the memorandum concerns the orderly administration of peacetime. it is dated today and addressed to whom it may concern."
             :next "armistice/vey-3")

(dialog-text "armistice/vey-3"
             "Vey has already begun the next administration. you leave him to it."
             :next "armistice/coat")

(dialog-text "armistice/coat"
             "you walk out the front entrance without your coat, which you have not done in four years. the sentries are not at attention."
             :next "armistice/coat-s2")

(dialog-text "armistice/coat-s2"
             "they are two young men standing in the sun in heavy boots. one of them has his helmet off and his face turned up to it."
             :next "armistice/sentry-cap")

(dialog-text "armistice/sentry-cap"
             "the older sentry, the one still helmeted, catches your eye. with full ceremony, he takes the helmet off."
             :next "armistice/sentry-cap-2")

(dialog-text "armistice/sentry-cap-2"
             "he holds it at arm's length and drops it. it rolls. neither of you picks it up."
             :next "armistice/sentry-cap-3")

(dialog-text "armistice/sentry-cap-3"
             "you return the salute he has not given."
             :next "armistice/street")

(dialog-text "armistice/street"
             "the street is full. nobody is going anywhere. everyone is handing everyone things: bread, news, babies, the same three facts over and over."
             :next "armistice/street-2")

(dialog-text "armistice/street-2"
             "a woman you have never met hands you a cup of something hot and keeps moving. she does not ask who takes the next one."
             :next "armistice/unrecognized")

(dialog-text "armistice/unrecognized"
             "nobody knows you without the coat. you stand in your own capital holding a borrowed cup, one face in the crowd. no one asks your name. you drink."
             :next "armistice/bells-other")

(dialog-text "armistice/bread-queue"
             "outside the baker's, the queue still holds its line, but nobody is quiet."
             :next "armistice/bread-queue-s2")

(dialog-text "armistice/bread-queue-s2"
             "people pass bread backward over their shoulders and sing the same two lines off key."
             :next "armistice/bread-queue-2")

(dialog-text "armistice/bread-queue-2"
             "the baker is giving the morning's second batch away over his wife's arithmetic. she does the arithmetic anyway and laughs at the total."
             :next "armistice/cups")

(dialog-text "armistice/bells-other"
             "from the third district, across the canal, bells. not the slow count."
             :next "armistice/bells-other-2")

(dialog-text "armistice/bells-other-2"
             "struck fast, in relays. children take turns at the rope, lifted by grown hands."
             :next "armistice/bells-other-3")

(dialog-text "armistice/bells-other-3"
             "ringing because rope and bell make a noise, and the noise is allowed."
             :next "armistice/bread-queue")

(dialog-text "armistice/cups"
             "the borrowed cup, when you look at it, is good china. somebody's sunday best."
             :next "armistice/cups-s2")

(dialog-text "armistice/cups-s2"
             "it came out into the street with eleven others and was handed to strangers."
             :next "armistice/cups-2")

(dialog-text "armistice/cups-2"
             "all over the city the kept things are coming out. the good plates. the saved sugar. the bottle at the back of the cupboard."
             :next "armistice/cups-3")

(dialog-text "armistice/cups-3"
             "nothing is being saved now."
             :next "armistice/table")

(dialog-text "armistice/table"
             "in the cabinet room, at some point in the afternoon, the map is folded."
             :next "armistice/table-2")

(dialog-text "armistice/table-2"
             "it takes four people. the folds buckle. under it the table is just a table: wood, scars, pencil marks, cup rings."
             :next "armistice/table-3")

(dialog-text "armistice/table-3"
             "ordinary furniture, returned to service."
             :next "armistice/first-choice")

(dialog-pick "armistice/first-choice"
             "the afternoon stands open. there has not been an open afternoon in four years, and nobody alive remembers the procedure."
             (dialog-option "open every window in the building" "armistice/windows")
             (dialog-option "walk to the third district" "armistice/walk-district")
             (dialog-option "sleep, at last, in a bed" "armistice/bed"))

(dialog-on-enter "armistice/windows"
                 '(setf (dialog-value "armistice-first") "windows"))

(dialog-text "armistice/windows"
             "you go floor by floor with Brandt and a master key, opening windows. it takes hours."
             :next "armistice/windows-2")

(dialog-text "armistice/windows-2"
             "drafts run the corridors, carrying dust and paper smell. by the top floor the two of you are racing. Brandt wins."
             :next "armistice/evening")

(dialog-on-enter "armistice/walk-district"
                 '(setf (dialog-value "armistice-first") "district"))

(dialog-text "armistice/walk-district"
             "you walk to the third district in your shirtsleeves, across the canal. every night you came here before, you wore a borrowed coat."
             :next "armistice/walk-district-2")

(dialog-text "armistice/walk-district-2"
             "the lists are coming down off the doors."
             :next "armistice/walk-district-3")

(dialog-text "armistice/walk-district-3"
             "not torn: taken down, folded, kept in neat stacks."
             :next "armistice/district-bell")

(dialog-text "armistice/district-bell"
             "at the parish hall they are still ringing, relay after relay. the ringer with the fingerless gloves stands aside from the rope."
             :next "armistice/district-bell-2")

(dialog-text "armistice/district-bell-2"
             "he does not know you without the coat. he hands you the rope anyway, because everyone gets a turn today, and you ring."
             :next "armistice/evening")

(dialog-on-enter "armistice/bed"
                 '(setf (dialog-value "armistice-first") "slept"))

(dialog-text "armistice/bed"
             "you go home, to the flat that has been yours all along, and sleep in a bed, in daylight, with the window open and the street noise coming in."
             :next "armistice/bed-2")

(dialog-text "armistice/bed-2"
             "nobody wakes you. for four years there was always something that could not wait. today there is nothing."
             :next "armistice/evening")

(dialog-text "armistice/evening"
             "evening comes on, and the city lights itself early. every window. four years of saved light spent in one night."
             :next "armistice/evening-2")

(dialog-text "armistice/evening-2"
             "no bell rings at dusk. the bells are rung out, resting in their towers."
             :next "armistice/last")

(dialog-text "armistice/last"
             "you stand at an open window with the day ending and let yourself have it, all of it, the one morning, the version with the all-clear in it."
             :next "armistice/last-2")

(dialog-text "armistice/last-2"
             "somewhere below, faint, Brandt is still laughing about something. the sound carries in the open air."
             :next "armistice/wake")

(dialog-text "armistice/wake"
             "sleep is easy, the first easy sleep of the whole long dream. the windows stay open."
             :next "sys/reboot")
