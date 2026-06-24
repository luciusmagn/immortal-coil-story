;;; Inside the house: the forest's first dark branch. Going down to the
;;; open door and through it. Rooms that match the bedroom, a second cot
;;; recently used, and the keeper's care, which is the trap stated
;;; plainly. Entered from the porch; exits through sleep.

(dialog-music "house/inside" "audio/forest-lyria-drone.mp3" :volume 0.22)

(dialog-text "house/inside"
             "the hall is lamplit. it smells of woodsmoke and wax. the floor is swept. paper tags hang on a nail by the door."
             :next "house/tags")

(dialog-text "house/tags"
             "four tags. below them is a fifth nail, empty. its head is polished by use."
             :next "house/pegs")

(dialog-text "house/pegs"
             "along the wall are five coat pegs. four hold coats: two work coats, a sunday coat, and a child's slicker."
             :next "house/pegs-2")

(dialog-text "house/pegs-2"
             "the fifth peg is empty. it sits at your shoulder height. the wood is worn pale."
             :next "house/clock")

(dialog-text "house/clock"
             "the hall clock is stopped at six. it was stopped at six when you came down the stairs the first night."
             :next "house/clock-correction")

(dialog-text "house/clock-correction"
             "then the correction comes: when you came in the door just now."
             :next "house/clock-2")

(dialog-text "house/clock-2"
             "the keeper winds it every evening anyway, eight turns, so the winding gets done. the hands never move. nothing here needs them to."
             :next "house/kitchen")

(dialog-text "house/kitchen"
             "in the kitchen there is bread cooling on a rack, and someone humming low through a door. two notes. you have been in this kitchen before."
             :next "house/kitchen-2")

(dialog-text "house/kitchen-2"
             "you saw it from the store bench, in one of the sleep pieces. you woke warm and frightened. here is the warmth again."
             :next "house/keeper")

(dialog-say "house/keeper"
            "the keeper"
            "you found your way back. they mostly do, off the hill. sit. soup first. questions keep, soup doesn't."
            :next "house/keeper-2")

(dialog-say "house/keeper-2"
            "you"
            "you were the one on the trail. with the lantern."
            :next "house/keeper-3")

(dialog-say "house/keeper-3"
            "the keeper"
            "somebody has to walk the trail when one of ours is out in the dark. eat. you can hate me warm as easy as cold."
            :next "house/keeper-first-word")

(dialog-choice-path "house/keeper-first-word"
                    "the spoon is in your hand. the keeper waits for your first words."
                    ("i'm not staying."
                     :id "leaving"
                     "say it again in spring, the keeper says. if the door stays open all winter and you are still at this table, i will believe you then."
                     :next "house/soup")
                    ("you've done this before."
                     :id "before"
                     "more times than there are chairs, the keeper says. fewer than there are plates. eat. the counting is mine."
                     :next "house/soup")
                    ("thank you."
                     :id "thanks"
                     "don't thank me, the keeper says. thank the soup. i carried it down the trail. carrying is work, not mercy."
                     :next "house/soup"))

(dialog-text "house/soup"
             "the soup is barley and carrot. it is hot and salted right. you resent that. you eat anyway."
             :next "house/soup-s2")

(dialog-text "house/soup-s2"
             "the keeper does not watch you eat. they wipe the counter and hum the two notes and leave the bread where your eyes keep going."
             :next "house/grace-fork")

(defun house-grace-target ()
  (if (equal (dialog-value "forest-letter") "read")
      "house/grace-known"
      "house/grace"))

(dialog-text "house/grace-fork"
             "when the bowl is empty, the keeper refills it. then they speak to the stove in the tone of family news."
             :next #'house-grace-target)

(dialog-text "house/grace"
             "the garden came in, the keeper says. the dog found her way home, thinner but unworried."
             :next "house/grace-2")

(dialog-text "house/grace-2"
             "you nod along to a stranger's news. the nodding feels practiced."
             :next "house/upstairs")

(dialog-text "house/grace-known"
             "the garden came in, the keeper says. the dog found her way home, thinner but unworried. word for word."
             :next "house/grace-known-2")

(dialog-text "house/grace-known-2"
             "the same round hand wrote it in the letter. eleven years in a mailbox. now the words come from the stove."
             :next "house/grace-known-3")

(dialog-text "house/grace-known-3"
             "either the letter was dictation, or the news in this house never changes. you keep eating."
             :next "house/upstairs")

(dialog-text "house/upstairs"
             "you have been up these stairs. your hand finds the smooth place on the rail without looking."
             :next "house/upstairs-2")

(dialog-text "house/upstairs-2"
             "on the landing there are four doors. the keeper opens the second and stands aside. they do not name the room."
             :next "house/room")

(dialog-text "house/room"
             "the room is your room. the bed is under the window. the night stand holds a glass of water."
             :next "house/room-desk")

(dialog-text "house/room-desk"
             "the desk has one drawer. you know the sound before it is opened."
             :next "house/room-2")

(dialog-text "house/room-2"
             "it is the room you wake in, built here from plank and quilt. the keeper says, supper's at the bell, and leaves you with it."
             :next "house/cot")

(dialog-text "house/cot"
             "against the far wall, where your room has empty floor, this one has a cot. the blankets are thrown back. the pillow still holds a head dent."
             :next "house/cot-2")

(dialog-text "house/cot-2"
             "on the floor beside it: one broken boot lace and a wrist tag. one corner is chewed soft."
             :next "house/cot-tag")

(dialog-text "house/cot-tag"
             "the tag's ink has run. yours did too. RETURN IF FOUND. under it is a name that is not {forest-tag-name}."
             :next "house/cot-tag-number")

(dialog-text "house/cot-tag-number"
             "under the name is the same number. the one that answers on the second ring."
             :next "house/night-choice")

(dialog-pick "house/night-choice"
             "downstairs, a bell rings once, softly."
             (dialog-option "go down and ask about the cot" "house/ask-cot")
             (dialog-option "say nothing. eat. sleep" "house/quiet-night")
             (dialog-option "wait, then search the house" "house/search"))

(dialog-on-enter "house/ask-cot"
                 '(setf (dialog-value "house-night") "asked"))

(dialog-say "house/ask-cot"
            "the keeper"
            "the cot. yes. that one is out on the hill tonight. second winter running. some of ours take longer to come back than others."
            :next "house/ask-cot-2")

(dialog-say "house/ask-cot-2"
            "you"
            "ours."
            :next "house/ask-cot-3")

(dialog-say "house/ask-cot-3"
            "the keeper"
            "you slept on that cot your first winter, before you earned the bed. the memory is gone. that is why the tags."
            :next "house/ask-cot-4")

(dialog-say "house/ask-cot-4"
            "the keeper"
            "the hill is hard on memory. eat your supper."
            :next "house/supper")

(dialog-on-enter "house/quiet-night"
                 '(setf (dialog-value "house-night") "quiet"))

(dialog-text "house/quiet-night"
             "you say nothing."
             :next "house/quiet-night-2")

(dialog-text "house/quiet-night-2"
             "supper is set for two. the second place stays empty. the keeper serves it anyway."
             :next "house/quiet-night-plate")

(dialog-text "house/quiet-night-plate"
             "a full plate goes under a cloth on the windowsill. the cold will keep it."
             :next "house/quiet-night-3")

(dialog-text "house/quiet-night-3"
             "for the one on the hill, the keeper says, in case. you sleep in the bed because the bed is yours. you keep that fact with you until morning."
             :next "house/listening")

(dialog-text "house/listening"
             "you lie awake and list sounds. the door has no lock on your side. stove ticking down. wind in the pines."
             :next "house/listening-2")

(dialog-text "house/listening-2"
             "the two notes move once through the rooms below. then the house goes quiet."
             :next "house/listening-3")

(dialog-text "house/listening-3"
             "the stove has stopped ticking. the wind has stopped in the pines. every sound stopped at once."
             :next "house/morning")

(dialog-on-enter "house/search"
                 '(setf (dialog-value "house-night") "searched"))

(dialog-text "house/search"
             "you lie still until the house settles, then walk it in sock feet."
             :next "house/search-2")

(dialog-text "house/search-2"
             "the first door on the landing opens on the same bedroom. the third door opens on it too."
             :next "house/search-3")

(dialog-text "house/search-3"
             "four doors, one room. each has its bed under its window and its glass poured. two beds have been slept in tonight. you stop counting cots."
             :next "house/under-stairs")

(dialog-text "house/under-stairs"
             "under the stairs is a low door, half height. you know it before your hand reaches it."
             :next "house/under-stairs-2")

(dialog-text "house/under-stairs-2"
             "plank for plank, it is the root cellar door in the woods. oiled hinges. matches on the second step."
             :next "house/under-stairs-3")

(dialog-text "house/under-stairs-3"
             "you do not open it."
             :next "house/album")

(dialog-text "house/album"
             "downstairs, in the dresser the lamp keeps lit, is a photograph album. the porch appears in every picture, summer and winter."
             :next "house/album-2")

(dialog-text "house/album-2"
             "decades of coats and haircuts. the keeper is in every picture, unchanged, holding the broom."
             :next "house/album-old")

(dialog-text "house/album-old"
             "the oldest picture is cracked and brown. a thin figure stands at the porch rail."
             :next "house/album-old-2")

(dialog-text "house/album-old-2"
             "the figure looks at the woods, not the camera. it has your stance. under the picture, in pencil: came back."
             :next "house/album-after")

(dialog-text "house/album-after"
             "you put the album back. on the stairs, the third step takes your weight without a sound. you stepped over the creak."
             :next "house/morning")

(dialog-say "house/supper"
            "the keeper"
            "you want to know how long. they all want the number."
            :next "house/supper-2")

(dialog-say "house/supper-2"
            "you"
            "how long?"
            :next "house/supper-3")

(dialog-say "house/supper-3"
            "the keeper"
            "long enough that the county stopped writing. long enough that the boxes went quiet."
            :next "house/supper-4")

(dialog-say "house/supper-4"
            "the keeper"
            "you are not kept here. the door stands open. look how that has gone."
            :next "house/keeper-questions")

(dialog-interrogation "house/keeper-questions"
                      "the keeper lets the kettle tick and waits. they have answered these questions before."
                      (:next "house/washing")
                      (:continue-label "take up the dish-cloth")
                      ("ask about the names on the mailboxes"
                       :id "boxes"
                       :speaker "the keeper"
                       "every one came off the hill and stayed. the boxes outlived the letters. i keep them painted. it is a small honest job and i am short of those.")
                      ("ask what the letters said, before they stopped"
                       :id "letters"
                       :speaker "the keeper"
                       "come home. they all said come home, in the hands of people who meant it. then the county went quiet and the meaning stayed in the boxes with nowhere to go.")
                      ("ask how many have left and not come back"
                       :id "left"
                       :speaker "the keeper"
                       "two. one in rain season. one in frost. i still set a plate when weather turns."))

(dialog-text "house/washing"
             "after supper you dry while the keeper washes. the cloth was put in your hand."
             :next "house/washing-basin")

(dialog-text "house/washing-basin"
             "the two of you stand at the basin in the lamplight, passing plates one by one."
             :next "house/washing-2")

(dialog-text "house/washing-2"
             "your dread does not go anywhere. it goes quiet enough that you can dry plates."
             :next "house/morning")

(dialog-scene "house/morning"
              "morning in the house."
              :next "house/round")

(dialog-text "house/round"
             "the keeper is up before the frost is off, making the morning round: stove, lamps, porch, sill. the covered plate on the windowsill is gone, cloth and all."
             :next "house/round-2")

(dialog-text "house/round-2"
             "the keeper does not check where it went. taken, weathered, or worse. the work is to leave it there."
             :next "house/breakfast")

(dialog-text "house/breakfast"
             "morning is porridge with cream and the smell of the stove and frost going off the windows in lines. it is the best morning you can remember."
             :next "house/breakfast-s2")

(dialog-text "house/breakfast-s2"
             "you make yourself hold that thought still and look at it. the memory it sits on is shallow, and you know that. the porridge is warm anyway."
             :next "house/chores")

(dialog-say "house/chores"
            "the keeper"
            "the wood wants splitting. only if you like. the hill brings down weather early this year."
            :next "house/chores-2")

(dialog-say "house/chores-2"
            "you"
            "and if i don't like?"
            :next "house/chores-3")

(dialog-say "house/chores-3"
            "the keeper"
            "then the wood stays whole and you stay warm. nobody pays their way here. my work is to keep you fed."
            :next "house/woodpile")

(dialog-text "house/woodpile"
             "you split wood until noon because your hands wanted it. the maul is the right weight. the rounds stand the right height."
             :next "house/woodpile-2")

(dialog-text "house/woodpile-2"
             "the work empties your head. the split rounds pile up clean. you know you should stop. you keep splitting."
             :next "house/bread")

(dialog-text "house/bread"
             "at noon the keeper sets the sponge for tomorrow's bread. they put your hands in the bowl without asking."
             :next "house/bread-2")

(dialog-text "house/bread-2"
             "fold and quarter-turn. fold and quarter-turn. your hands take the rhythm before your head does."
             :next "house/bread-3")

(dialog-text "house/bread-3"
             "hands remember faster than heads, the keeper says. yours are quick. you do not ask when."
             :next "house/far-field")

(dialog-text "house/far-field"
             "after noon the keeper shoulders a sack and goes up toward the far field."
             :next "house/far-field-2")

(dialog-text "house/far-field-2"
             "they leave you the house, the open door, and the road below. no one watches from the porch."
             :next "house/door-test")

(dialog-pick "house/door-test"
             "from the porch you can see the road going down and the trail going up. the broom leans on the rail where it always leans."
             (dialog-option "walk out. now. down the road" "house/leave")
             (dialog-option "stay the day. set the table" "house/stay")
             (dialog-option "go up the trail after the cot's owner" "house/follow"))

(dialog-on-enter "house/leave"
                 '(setf (dialog-value "house-day") "left"))

(dialog-text "house/leave"
             "you walk out the open door and down the road and nobody stops you, because nobody has ever needed to. you make the mailboxes by dusk."
             :next "house/leave-2")

(dialog-text "house/leave-2"
             "at the mailboxes, your hand finds the house key in your coat pocket. the brass is warm."
             :next "house/leave-key")

(dialog-text "house/leave-key"
             "you do not remember taking it. you stand there a long time with it in your palm."
             :next "house/leave-count")

(dialog-text "house/leave-count"
             "five boxes on the rack. four names weathered off, one readable. four tags on the nail in the hall, and a fifth nail, empty, polished."
             :next "house/leave-count-2")

(dialog-text "house/leave-count-2"
             "four coats on the pegs, and a fifth peg, worn pale, at your height."
             :next "house/leave-count-3")

(dialog-text "house/leave-count-3"
             "you stand at the boxes and count fives: boxes, tags, pegs. all of them end with you."
             :next "house/leave-night")

(dialog-text "house/leave-night"
             "you sleep that night in the tree line within sight of the boxes, and it can be told plainly: you sleep facing the hill."
             :next "house/leave-night-2")

(dialog-text "house/leave-night-2"
             "in the morning there is frost, and on the flat of the newest mailbox, the one with the readable name, someone has stood a covered plate, still faintly warm."
             :next "house/last-notes")

(dialog-on-enter "house/stay"
                 '(setf (dialog-value "house-day") "stayed"))

(dialog-text "house/stay"
             "you stay the day. you sweep the porch because the broom was there."
             :next "house/stay-table")

(dialog-text "house/stay-table"
             "at dusk you set the table, two plates. you cover one and put it on the windowsill for the one on the hill."
             :next "house/stay-2")

(dialog-text "house/stay-2"
             "the keeper comes down from the far field and looks at the sill, then at you. they say nothing. you eat in the warm."
             :next "house/stay-bell")

(dialog-text "house/stay-bell"
             "after the meal, drying plates, you run the day backward. the bell rang at dusk, one soft stroke."
             :next "house/stay-bell-2")

(dialog-text "house/stay-bell-2"
             "the bell rang. your hands were already wet."
             :next "house/stay-bell-3")

(dialog-text "house/stay-bell-3"
             "you stand with the cloth in your hands until the keeper takes it from you and finishes the plate."
             :next "house/stay-night")

(dialog-text "house/stay-night"
             "in the night the two notes move through the house below you, room to room."
             :next "house/stay-night-s2")

(dialog-text "house/stay-night-s2"
             "it is the sound of a house being checked: room by room, person by person. the count includes you."
             :next "house/stay-night-s3")

(dialog-text "house/stay-night-s3"
             "you lie in your bed under your window and let it."
             :next "house/last-notes")

(dialog-on-enter "house/follow"
                 '(setf (dialog-value "house-day") "followed"))

(dialog-text "house/follow"
             "you take the trail up, past the far field, into the pines, walking the way the keeper walks, unhurried, and it works."
             :next "house/follow-2")

(dialog-text "house/follow-2"
             "the creek cuts under the roots. there, you find the cot's owner."
             :next "house/follow-found")

(dialog-text "house/follow-found"
             "he is grey-faced. his tag is on his wrist. he is pressed under the boughs where you hid two nights ago."
             :next "house/mirror")

(dialog-say "house/mirror"
            "the man from the cot"
            "stay back. stay where you are."
            :next "house/mirror-2")

(dialog-say "house/mirror-2"
            "you"
            "i'm not with the house. i ran too. two nights ago i was under these same trees."
            :next "house/mirror-3")

(dialog-say "house/mirror-3"
            "the man from the cot"
            "look at your hands. they're scrubbed. there's a key on your belt and bread on your breath."
            :next "house/mirror-4")

(dialog-say "house/mirror-4"
            "the man from the cot"
            "you walked up here the way they walk. two nights. it took you two nights."
            :next "house/mirror-after")

(dialog-text "house/mirror-after"
             "he goes off through the pines, quiet and practiced, and does not look back. you stand by the creek with your scrubbed hands held away from your sides."
             :next "house/mirror-after-2")

(dialog-text "house/mirror-after-2"
             "relief comes when the cold starts working into you. the cold is on nobody's side."
             :next "house/mirror-walk")

(dialog-text "house/mirror-walk"
             "you walk back down at dusk because down is where the warm is, and you say it to yourself that flatly on purpose, to feel the size of it."
             :next "house/mirror-walk-2")

(dialog-text "house/mirror-walk-2"
             "at the porch the keeper has left the lamp lit, the door open, your plate covered, and has gone to bed."
             :next "house/last-notes")

(dialog-text "house/last-notes"
             "last of all, whether you are in bed, under needles, or at the tree line, the two notes come faint from the house."
             :next "house/last-notes-2")

(dialog-text "house/last-notes-2"
             "you count breaths between them."
             :next "house/end")

(dialog-text "house/end"
             "sleep takes you all at once. you do not wake before morning."
             :next "sys/reboot")
