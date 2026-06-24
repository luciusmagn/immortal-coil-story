;;; Below: the rogue path's first dark branch. The bookkeeping floors
;;; beneath the tally, a darker crawl with two hunters, and the clerk
;;; met in person. Entered through the bottom room's far door; rejoins
;;; at the landing.

(dialog-text "below/door"
             "the far door opens on oiled hinges. behind it, stairs go down. the air coming up is warm and smells of paper."
             :next "below/stairs")

(dialog-text "below/stairs"
             "the white lines of the dungeon run down the stairwell with you. by the first turning they are ruled lines, faint blue, margin-red at the left hand."
             :next "below/stairs-2")

(dialog-text "below/stairs-2"
             "the dungeon is drawn on graph paper down here. it always was. upstairs is just the cover."
             :next "below/shelves")

(dialog-text "below/shelves"
             "shelving lines the walls: ledgers, spine out, floor to dark. each spine is chalked in the tidy clerk's hand. the shelves pass the torch in both directions."
             :next "below/tally-wall")

(dialog-text "below/tally-wall"
             "one wall is the tally wall. every chalk mark you have ever seen upstairs is here in master: rows of four struck with a fifth, floor by floor, years deep."
             :next "below/tally-wall-s2")

(dialog-text "below/tally-wall-s2"
             "under each tally, a shelf mark. the marks upstairs are totals. the books are down here."
             :next "below/your-shelf")

(dialog-text "below/your-shelf"
             "you find your floor's shelf because your hand finds it, the way hands do now. one ledger stands prouder than its row, recently used."
             :next "below/your-shelf-s2")

(dialog-text "below/your-shelf-s2"
             "the spine chalk is the name carved into the first step, letter for letter. the carving was never a warning. it is a spine label."
             :next "below/reading")

(dialog-text "below/reading"
             "you pull the book and open it on the shelf edge. last night, in the clerk's hand: bar lifted, third watch, lifted quiet. slept."
             :next "below/reading-s2")

(dialog-text "below/reading-s2"
             "tin balanced against door, dungeon custom, noted with approval. woke below. read the tally. left the fresh mark alone."
             :next "below/ink-wet")

(dialog-text "below/ink-wet"
             "the latest line says: reads own page. the ink is wet. you stand very still, and from somewhere in the stacks, unhurried, comes the sound of a pen keeping up."
             :next "below/reading-stand")

(dialog-text "below/reading-stand"
             "farther down the row, a reading stand holds another book open mid-line, ink wet on that one too. the spine chalk is nobody you know."
             :next "below/reading-stand-2")

(dialog-text "below/reading-stand-2"
             "somewhere overhead, right now, a stranger is lifting a bar, or counting doors, or balancing a tin, and the line is arriving here as they do it."
             :next "below/active-accounts")

(dialog-text "below/active-accounts"
             "you count nine reading stands down the row. each book is open. each line is wet. yours is one of them. the row was working before you arrived."
             :next "below/two-walls")

(dialog-text "below/two-walls"
             "the pacing finds you again in the left wall. it keeps pace."
             :next "below/two-walls-s2")

(dialog-text "below/two-walls-s2"
             "then, for the first time, an answer to it: a second pacing in the right wall, half a step offset. one on each side of the stacks."
             :next "below/two-walls-s3")

(dialog-text "below/two-walls-s3"
             "two auditors walk the stacks down here."
             :next "below/descent-choice")

(dialog-text "below/descent-choice"
             "the stacks descend by ramps, floor under floor, and the lower floors are older: the ruled lines go brown, the spines go to leather, then to wood, then to clay."
             :next "below/descent-choice-s2")

(dialog-text "below/descent-choice-s2"
             "somewhere below all of it, a lamp is burning. you can smell the warm oil of it between the paper."
             :next "below/clay")

(dialog-text "below/clay"
             "on the last ramp you pass the oldest shelf: no books, one clay tablet, fired hard, holding a single ruled line in a hand that is the tidy hand's grandmother."
             :next "below/clay-s2")

(dialog-text "below/clay-s2"
             "you cannot read it. the clerk can. he has copied one word under it in chalk: EXPECTED."
             :next "below/delve")

(dialog-minigame "below/delve"
                 "wasd or arrow keys step. find the lamp at the bottom of the stacks."
                 :game :rogue-delve
                 :success "below/lamp-floor"
                 :failure "below/turned-back"
                 :config (list :save-prefix "below"
                               :caught-target "below/audited"
                               :leave-target "below/turned-back"
                               :step-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/step.wav"))
                               :bump-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/bump.wav"))
                               :menu-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/menu.wav"))
                               :class-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/class.wav"))
                               :pickup-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/pickup.wav"))
                               :hit-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/hit.wav"))
                               :kill-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/kill.wav"))
                               :stairs-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/stairs.wav"))
                               :gen-floors 5
                               :gen-width 27
                               :gen-height 17
                               :gen-hunters 2
                               :gen-monsters 6
                               :gen-items 5
                               :gen-traps 3))

(dialog-text "below/audited"
             "one of the pair steps out of its wall. you do not quite see it. the torch will not hold its light on it. the floor files you."
             :next "below/audited-2")

(dialog-text "below/audited-2"
             "you wake one ramp up, sitting against your own shelf, your book back in its place, one line newer: audited. found correct. carried up."
             :next "below/lamp-floor")

(dialog-text "below/turned-back"
             "you lose the ramps twice and come back against the tally wall. when you stop, the lamp smell is closer anyway."
             :next "below/turned-back-2")

(dialog-text "below/turned-back-2"
             "new chalk arrows mark the lower ramp. they point down. somebody has made the route plain."
             :next "below/lamp-floor")

(dialog-text "below/lamp-floor"
             "the bottom floor is one room wide: desk, lamp, visitor chair, clerk. he finishes the line before looking up. the line is about you arriving."
             :next "below/clerk")

(dialog-say "below/clerk"
            "the clerk"
            "sit. you found the door ajar. i leave it ajar once a tenure, on instinct, and the instinct has never yet been wrong about who comes down."
            :next "below/clerk-2")

(dialog-say "below/clerk-2"
            "you"
            "you keep all of it. every floor. every step."
            :next "below/clerk-3")

(dialog-say "below/clerk-3"
            "the clerk"
            "somebody has to. a dungeon runs on minutes. these are the minutes. sit, i said. the chair is for sitting, not for symbolism."
            :next "below/clerk-questions")

(dialog-interrogation "below/clerk-questions"
                      "the clerk leaves the pen uncapped, point resting on a blotter cut to the size of a cell."
                      (:next "below/ribbon-book")
                      (:continue-label "let the clerk continue")
                      (:require-all t)
                      ("ask about the auditors"
                       :id "auditors"
                       :speaker "the clerk"
                       "the pair in the walls check my figures against the floors, step against entry, breath against margin. there were not always two."
                       "once, one delver went a single hour unlogged. the third-floor book has blank lines, then three pages in another hand. never again. hence the pair.")
                      ("ask why the door was ajar"
                       :id "ajar-door"
                       :speaker "the clerk"
                       "once a tenure i leave one door ajar. the building chooses which. if nobody comes, the hinge gets oiled and the entry is voided."
                       "if someone comes, i receive them. down here, a door opens first. the summons comes after.")
                      ("ask what the ledger wants"
                       :id "ledger-wants"
                       :speaker "the clerk"
                       "wanting is expensive language. the ledger records. i keep the recording correct. the people inside it want to leave with something carried out."
                       "i sit between those jobs. it is not dignified work. it is necessary work."))

(dialog-text "below/ribbon-book"
             "on the desk's far corner lies one ledger apart from all the others, closed, tied shut with a ribbon gone grey. the discrepancy's book."
             :next "below/ribbon-book-s2")

(dialog-text "below/ribbon-book-s2"
             "the clerk does not look at it, with the particular skill of someone who has practiced not looking at one thing for a very long time."
             :next "below/your-book")

(dialog-text "below/your-book"
             "your book is already on the desk. the clerk fetched it before you arrived."
             :next "below/your-book-s2")

(dialog-text "below/your-book-s2"
             "the clerk turns it around and opens the first page: the inn before the stairs, the stairs before the name, the name carved fresh, the dust not yet on it."
             :next "below/first-line")

(dialog-text "below/first-line"
             "the first line of your account predates your first step. it says: expected. the clerk taps it once. everyone's says that, the clerk says."
             :next "below/first-line-s2")

(dialog-text "below/first-line-s2"
             "it is the only line i am given. everything after it, you write and i take down. people get the order wrong and it costs them years."
             :next "below/ask-choice")

(dialog-pick "below/ask-choice"
             "the lamp hisses gently. in the walls, the pair holds still."
             (dialog-option "ask to be unlogged" "below/unlogged")
             (dialog-option "ask to read your ending" "below/ending")
             (dialog-option "take the book and go" "below/take-book"))

(dialog-on-enter "below/unlogged"
                 '(setf (dialog-value "below-asked") "unlogged"))

(dialog-say "below/unlogged"
            "the clerk"
            "i did that once. you saw the ribbon. you asked, and the asking is entered. the rules let me offer one hour unlogged. it starts when you stand."
            :next "below/unlogged-2")

(dialog-say "below/unlogged-2"
            "you"
            "and then?"
            :next "below/unlogged-3")

(dialog-say "below/unlogged-3"
            "the clerk"
            "and then you will come back and sit down and ask me to resume. i will not say anything unkind. nobody has lasted the hour. trying is honorable."
            :next "below/unlogged-hour")

(dialog-text "below/unlogged-hour"
             "you stand, and the pen stops, and the walls go silent, both of them, total, and you walk the stacks unkept. no pacing. no pen. your steps land and are not received."
             :next "below/unlogged-hour-2")

(dialog-text "below/unlogged-hour-2"
             "your steps sound wrong without a line following them. by your own count, you last eleven minutes."
             :next "below/resume")

(dialog-text "below/resume"
             "you sit back down. resume, you say. the pen takes you up mid-line. the clerk writes the relief in the margin. the totals do not need it."
             :next "below/margin")

(dialog-on-enter "below/ending"
                 '(setf (dialog-value "below-asked") "ending"))

(dialog-text "below/ending"
             "the clerk turns to the last page without hunting for it. the page is ruled and blank except for one line at the bottom, undated: climbed out. kept moving."
             :next "below/ending-2")

(dialog-say "below/ending-2"
            "the clerk"
            "we enter the ending first, for some. it is not a prediction. the floors do not predict. it is a vote."
            :next "below/ending-3")

(dialog-say "below/ending-3"
            "you"
            "whose vote?"
            :next "below/ending-4")

(dialog-say "below/ending-4"
            "the clerk"
            "the building's. one per account. rare. it does not explain the vote to me, and i have stopped asking."
            :next "below/margin")

(dialog-on-enter "below/take-book"
                 '(setf (dialog-value "below-asked") "took"))

(dialog-text "below/take-book"
             "you pick the book up. the clerk does not stop you. his pen rests uncapped by his hand."
             :next "below/take-book-s2")

(dialog-text "below/take-book-s2"
             "the book is heavier than pages. each step adds to it. at the third step both walls go silent. your hours have nowhere to go while the book is in your hands."
             :next "below/take-book-2")

(dialog-text "below/take-book-2"
             "you stand in the silence with your own account dead weight in your arms. you carry it one more step, just to have done it, and put it back on the desk."
             :next "below/take-book-2-2")

(dialog-text "below/take-book-2-2"
             "the pen resumes. the clerk rules off the incident with one clean line. he adds no comment."
             :next "below/margin")

(dialog-text "below/margin"
             "while the clerk rules the visit off, you look once more at your page. the margin is wider than the entries need."
             :next "below/margin-2")

(dialog-text "below/margin-2"
             "the margin is where the clerk keeps what the totals do not see: slept well, for once. left the mark alone. asked the honorable thing."
             :next "below/receipt")

(dialog-text "below/receipt"
             "the clerk writes you a slip and folds it once: CARRIED OUT: WHAT THEY KNOW NOW. no weight entered. no slot named. keep it or lose it, the clerk says."
             :next "below/receipt-2")

(dialog-text "below/receipt-2"
             "it is honored either way. it is the only receipt this desk issues, and everyone leaves with one."
             :next "below/escort")

(dialog-text "below/escort"
             "when it is time, the clerk stands, caps the pen, and the pair in the walls falls in, one each side. he takes a service ramp you did not see on the descent."
             :next "below/escort-s2")

(dialog-text "below/escort-s2"
             "at your shelf, the book goes back in its place, prouder than its row."
             :next "below/escort-pace")

(dialog-text "below/escort-pace"
             "you climb between the pair. this time you match their steps instead of the other way around."
             :next "below/stand-closed")

(dialog-text "below/stand-closed"
             "passing the reading stands you count without meaning to: eight books open now."
             :next "below/stand-closed-2")

(dialog-text "below/stand-closed-2"
             "the ninth stands closed, ribbon fresh and grey. the pair slows there for one step. for auditors, that is notice enough. somewhere, the pen keeps writing yours."
             :next "below/tag-truth")

(dialog-text "below/tag-truth"
             "at the bottom room the tag still lies on the made bed, ink fresh, first line legible. RETURN IF FOUND."
             :next "below/tag-truth-s2")

(dialog-text "below/tag-truth-s2"
             "you understand it now, from the shelving side: it is not a plea. it is processing language."
             :next "below/tag-truth-s3")

(dialog-text "below/tag-truth-s3"
             "everything down here is logged out, and back in, and the tag is the slip."
             :next "below/close-door")

(dialog-text "below/close-door"
             "you close the far door until the latch takes. then you close the room's other door, quietly. the stair ends at furniture again. your hours are logged the whole way."
             :next "below/receipt-pocket")

(dialog-text "below/receipt-pocket"
             "on the landing you check your pocket once. the receipt is there, folded and weightless. you leave your hand on it a moment, then climb on."
             :next "rogue/landing-return")
