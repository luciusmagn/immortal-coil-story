;;; The tribunal: the war's second dark branch. Years later, the
;;; signature returns as evidence and the numbers transcripts are read
;;; into the record. Entered by keeping a private record on the fourth
;;; morning; exits through the verdict.

(dialog-text "tribunal/keep"
             "you keep the pencil."
             :next "tribunal/keep-2")

(dialog-text "tribunal/keep-2"
             "that evening you buy a tin box from a hardware stall with your own coins. it is the first thing you have paid for in months."
             :next "tribunal/keep-2-s2")

(dialog-text "tribunal/keep-2-s2"
             "the pencil copies go into it. the box goes where boxes go when the right people must find them."
             :next "tribunal/keep-3")

(dialog-text "tribunal/keep-3"
             "keeping the record is the part of the day you do with your whole attention."
             :next "tribunal/seasons")

(dialog-text "tribunal/seasons"
             "the war ends the way the map said it would, only slower. the tape lines walk to the river, stand at the river for a winter, and cross it coming the other way."
             :next "tribunal/seasons-2")

(dialog-text "tribunal/seasons-2"
             "one morning the eight o'clock bell does not ring. the armistice is no treaty, no bell, people standing in the corridor."
             :next "tribunal/years")

(dialog-scene "tribunal/years"
              "three years later."
              :next "tribunal/letter")

(dialog-text "tribunal/letter"
             "the letter comes on good paper. it is from the commission for the clarification of wartime administration."
             :next "tribunal/letter-s2")

(dialog-text "tribunal/letter-s2"
             "the victors gave that name to the room where your war is being reread."
             :next "tribunal/letter-2")

(dialog-text "tribunal/letter-2"
             "it invites you to assist. in a poorer country they would use handcuffs and mean the same thing."
             :next "tribunal/arrival")

(dialog-text "tribunal/arrival"
             "the courtroom is a school gymnasium, because the courthouse burned in the last winter of the war."
             :next "tribunal/arrival-2")

(dialog-text "tribunal/arrival-2"
             "the lines of old ball games are still painted on the floor. the commission's tables sit inside them."
             :next "tribunal/arrival-3")

(dialog-text "tribunal/arrival-3"
             "clerks step around the painted lines. nobody has told them to. nobody needs to."
             :next "tribunal/oath")

(dialog-say "tribunal/oath"
            "the presiding judge"
            "you were chancellor from the spring of the second year. you held the seals. you will be heard as a witness."
            :next "tribunal/oath-s2")

(dialog-say "tribunal/oath-s2"
            "the presiding judge"
            "whether you remain a witness is a matter for the evidence, not for me, and not for you. do you understand this?"
            :next "tribunal/oath-2")

(dialog-say "tribunal/oath-2"
            "you"
            "better than anything else i have been told in three years."
            :next "tribunal/oath-3")

(dialog-say "tribunal/oath-3"
            "the presiding judge"
            "then you are sworn. sit. the commission reads slowly and the chairs are hard. both of these are deliberate."
            :next "tribunal/gallery-look")

(defun tribunal-gallery-target ()
  (if (dialog-value "district-train")
      "tribunal/gallery-known"
      "tribunal/gallery-strangers"))

(dialog-text "tribunal/gallery-look"
             "you sit. behind the rail: sixty faces. coats hang over their arms because the gymnasium is warm."
             :next "tribunal/gallery-look-2")

(dialog-text "tribunal/gallery-look-2"
             "every face is from the districts. every face is here for the lists."
             :next #'tribunal-gallery-target)

(dialog-text "tribunal/gallery-strangers"
             "you know none of them. for two years you governed these faces from behind glass and tape."
             :next "tribunal/gallery-strangers-2")

(dialog-text "tribunal/gallery-strangers-2"
             "there is not one face you can put to a street."
             :next "tribunal/charge")

(dialog-text "tribunal/gallery-known"
             "in the second row sits an old woman with her hands folded on a folded paper. you know her."
             :next "tribunal/gallery-known-s2")

(dialog-text "tribunal/gallery-known-s2"
             "the canal district. the bell. the candle. Vasik, with one s. she does not look away when you find her."
             :next "tribunal/gallery-known-2")

(dialog-text "tribunal/gallery-known-2"
             "she has been waiting three years for you to find her, and her face says that the waiting was the easy part."
             :next "tribunal/charge")

(dialog-say "tribunal/charge"
            "the prosecutor"
            "exhibit one. a rerouting order, dated tuesday, oh two hundred, moving the third district's winter allocation to kilometer nine."
            :next "tribunal/charge-s2")

(dialog-say "tribunal/charge-s2"
            "the prosecutor"
            "the commission will hear that nothing about this order is what it says. for now, one question. is this your signature?"
            :next "tribunal/charge-2")

(dialog-say "tribunal/charge-2"
            "you"
            "may i see it closer?"
            :next "tribunal/charge-3")

(dialog-say "tribunal/charge-3"
            "the prosecutor"
            "you may hold it. it has been three years. take your time. the commission is interested in your hands as well as your answer."
            :next "tribunal/signature-look")

(dialog-text "tribunal/signature-look"
             "you hold the order. the hand is small and even, slanted left at the line ends, steadier than your hand was that week, steadier than your hand is now."
             :next "tribunal/signature-look-2")

(dialog-text "tribunal/signature-look-2"
             "you signed a decree once and were glad of the shaking because the shaking proved the hand was yours. this does not shake anywhere."
             :next "tribunal/signature-look-3")

(dialog-text "tribunal/signature-look-3"
             "the signature is the best you have ever seen. it is yours. it is not your hand."
             :next "tribunal/signature-choice")

(dialog-pick "tribunal/signature-choice"
             "the gymnasium is quiet. somewhere behind you a chair creaks as the gallery leans."
             (dialog-option "claim it. the office was yours" "tribunal/claimed")
             (dialog-option "deny it. the hand is not yours" "tribunal/denied")
             (dialog-option "say you no longer know" "tribunal/unknown"))

(dialog-on-enter "tribunal/claimed"
                 '(setf (dialog-value "tribunal-signature") "claimed"))

(dialog-text "tribunal/claimed"
             "it is my signature, you say, because the office was mine, and what the office signed, i signed, whether my hand was in the room or not."
             :next "tribunal/claimed-2")

(dialog-text "tribunal/claimed-2"
             "the prosecutor blinks once. he had been prepared to force the answer and did not have to."
             :next "tribunal/claimed-2-s2")

(dialog-text "tribunal/claimed-2-s2"
             "behind you, sixty people make no sound."
             :next "tribunal/vey")

(dialog-on-enter "tribunal/denied"
                 '(setf (dialog-value "tribunal-signature") "denied"))

(dialog-text "tribunal/denied"
             "the hand is not mine, you say. it is true. it sounds false."
             :next "tribunal/denied-s2")

(dialog-text "tribunal/denied-s2"
             "every man in every gymnasium has said it since the bells stopped."
             :next "tribunal/denied-2")

(dialog-text "tribunal/denied-2"
             "the prosecutor nods. you have answered a different and more useful question. he asks the clerk to mark that the witness disputes exhibit one."
             :next "tribunal/vey")

(dialog-on-enter "tribunal/unknown"
                 '(setf (dialog-value "tribunal-signature") "unknown"))

(dialog-text "tribunal/unknown"
             "i no longer know, you say. i signed so much. they brought the folders at eight and took them at six."
             :next "tribunal/unknown-s2")

(dialog-text "tribunal/unknown-s2"
             "somewhere in the third winter i stopped being able to tell my hand from the war's."
             :next "tribunal/unknown-2")

(dialog-text "tribunal/unknown-2"
             "it is true. you watch it land as the worst possible answer."
             :next "tribunal/unknown-3")

(dialog-text "tribunal/unknown-3"
             "the commission has a column for guilt and a column for innocence. it has no column for this."
             :next "tribunal/vey")

(dialog-say "tribunal/vey"
            "Vey"
            "the chancellor was thorough. i wish to be exact about this. nothing moved in that building without the chancellor's office."
            :next "tribunal/vey-s2")

(dialog-say "tribunal/vey-s2"
            "Vey"
            "i served the office. the office served the chancellor. the commission may draw the arrows itself."
            :next "tribunal/vey-2")

(dialog-say "tribunal/vey-2"
            "you"
            "you wrote the decree, Vey."
            :next "tribunal/vey-3")

(dialog-say "tribunal/vey-3"
            "Vey"
            "i drafted many documents. drafting is a clerk's act. signing is a sovereign's. the commission has the signature."
            :next "tribunal/vey-3-s2")

(dialog-say "tribunal/vey-3-s2"
            "Vey"
            "i am only here to confirm the office was orderly, and it was. it was the most orderly office i ever served."
            :next "tribunal/vey-press")

(dialog-choice-path "tribunal/vey-press"
                    "Vey waits with his hands folded, a man who has never once been late with a document."
                    ("the words were yours. the words were the crime."
                     :id "words"
                     "words are proposals, he says. a proposal harms no one until a sovereign adopts it. i proposed orderliness. the adoption was above my desk."
                     :next "tribunal/vey-after")
                    ("name one man under you who refused."
                     :id "refused"
                     "i cannot, he says, and that is to my credit. a refused order is a failure of administration. my office had none, and the commission has noted that it had none."
                     :next "tribunal/vey-after")
                    ("how do you sleep, Vey."
                     :id "sleep"
                     "soundly, he says, and resents the question. a man who only kept records can always show that he only kept records. he wishes you good health."
                     :next "tribunal/vey-after"))

(dialog-text "tribunal/vey-after"
             "Vey is being heard by a smaller commission in a smaller room, where his memory is excellent and his file is thin."
             :next "tribunal/vey-after-2")

(dialog-text "tribunal/vey-after-2"
             "cooperation has a price and he paid it early. he paid in other men's orderliness. he always kept that ready."
             :next "tribunal/vey-after-3")

(dialog-text "tribunal/vey-after-3"
             "he passes you in the corridor at the recess and wishes you good health, and the terrible thing is that he means it."
             :next "tribunal/transcripts")

(dialog-text "tribunal/transcripts"
             "in the afternoon the commission reads the broadcasts into the record."
             :next "tribunal/transcripts-2")

(dialog-text "tribunal/transcripts-2"
             "a clerk stands at a lectern with three years of intercept flimsies. he reads the numbers aloud, in groups, hour after hour."
             :next "tribunal/transcripts-3")

(dialog-text "tribunal/transcripts-3"
             "the rules of evidence say the record must contain what the exhibit contains. the exhibit is the numbers."
             :next "tribunal/transcripts-listen")

(dialog-text "tribunal/transcripts-listen"
             "by the second hour the gymnasium has learned to read them. this group is car weights. this group is departures. this group is heads."
             :next "tribunal/transcripts-listen-2")

(dialog-text "tribunal/transcripts-listen-2"
             "when the clerk reads the head counts the gallery goes still. in the second row, the old woman counts along with him."
             :next "tribunal/transcripts-listen-3")

(dialog-text "tribunal/transcripts-listen-3"
             "her lips move. she is waiting for the night her number went by."
             :next "tribunal/clerk-voice")

(dialog-text "tribunal/clerk-voice"
             "in the third hour the clerk's voice gives out on a four."
             :next "tribunal/clerk-voice-2")

(dialog-text "tribunal/clerk-voice-2"
             "he stands holding the flimsy. his mouth works. nothing comes."
             :next "tribunal/clerk-voice-2-s2")

(dialog-text "tribunal/clerk-voice-2-s2"
             "a second clerk rises from the recording table, takes the page, finds the four, and reads on."
             :next "tribunal/clerk-voice-3")

(dialog-text "tribunal/clerk-voice-3"
             "the rules say the count must be read. the rules do not say by whom."
             :next "tribunal/clerk-voice-4")

(dialog-text "tribunal/clerk-voice-4"
             "the station read these same numbers to the empty air for three years because a protocol asked it."
             :next "tribunal/clerk-voice-5")

(dialog-text "tribunal/clerk-voice-5"
             "now the same obedience wears the victors' coat. the numbers have outlived the war."
             :next "tribunal/recess")

(dialog-scene "tribunal/recess"
              "the recess."
              :next "tribunal/sorel")

(dialog-say "tribunal/sorel"
            "Sorel"
            "they have had my ledgers since the spring. both sets. the ink for the building and the pencil for the truth."
            :next "tribunal/sorel-s2")

(dialog-say "tribunal/sorel-s2"
            "Sorel"
            "i am told i am a witness for the prosecution, a witness for the defense, and an unindicted question, depending on the day."
            :next "tribunal/sorel-2")

(dialog-say "tribunal/sorel-2"
            "you"
            "which are you today?"
            :next "tribunal/sorel-3")

(dialog-say "tribunal/sorel-3"
            "Sorel"
            "today i am the person who taught the commission to read the numbers. somebody had to. it went faster than teaching you, chancellor. they wanted to learn."
            :next "tribunal/sorel-questions")

(dialog-interrogation "tribunal/sorel-questions"
                      "the recess has its own quiet. Sorel folds his hands on the rail and waits."
                      (:next "tribunal/audit-ask")
                      (:continue-label "let the recess end")
                      ("ask about the two sets of books"
                       :id "books"
                       :speaker "Sorel"
                       "the ink set balances. it was built to. the pencil set does not, and was not. the commission wants the balanced one to be the lie. it is not. it is incomplete on purpose.")
                      ("ask what he told the prosecution"
                       :id "told"
                       :speaker "Sorel"
                       "the arithmetic. only the arithmetic. the prosecution does not need my conscience, and would not know which drawer to file it in.")
                      ("ask whether the commission wants the truth"
                       :id "truth"
                       :speaker "Sorel"
                       "it wants a number it can sentence. truth is harder to imprison. they are trying, chancellor, and they are quicker students than we ever were."))

(dialog-text "tribunal/audit-ask"
             "after the recess the prosecutor places the kilometer nine manifests on the witness table."
             :next "tribunal/audit-ask-s2")

(dialog-text "tribunal/audit-ask-s2"
             "loading figures. arrival figures. he asks whether the witness will reconcile them for the commission."
             :next "tribunal/audit-ask-2")

(dialog-text "tribunal/audit-ask-2"
             "now. aloud. in his own time. the gallery leans again. most of them approve."
             :next "tribunal/audit")

(dialog-minigame "tribunal/audit"
                 "w/s or arrows move. space flags the line that does not match."
                 :game :war-audit
                 :success "tribunal/audit-found"
                 :failure "tribunal/audit-lost")

(dialog-text "tribunal/audit-found"
             "car four. eight hundred short between loading and arrival."
             :next "tribunal/audit-found-2")

(dialog-text "tribunal/audit-found-2"
             "you find it in under a minute, in front of everyone. you found it this fast the first time."
             :next "tribunal/audit-found-2-s2")

(dialog-text "tribunal/audit-found-2-s2"
             "your fluency is the exhibit. the commission watches the chancellor read the inventory of the third district."
             :next "tribunal/audit-found-3")

(dialog-text "tribunal/audit-found-3"
             "no further questions are necessary on the subject of what the chancellor was capable of knowing."
             :next "tribunal/brandt")

(dialog-text "tribunal/audit-lost"
             "the figures swim. three years, and they swim the same way, and your finger stops above the columns and will not come down."
             :next "tribunal/audit-lost-2")

(dialog-text "tribunal/audit-lost-2"
             "in the silence, Sorel rises from the witness bench and crosses the painted lines."
             :next "tribunal/audit-lost-2-s2")

(dialog-text "tribunal/audit-lost-2-s2"
             "he sets one finger on car four without being asked. the commission watches the chancellor be helped."
             :next "tribunal/brandt")

(dialog-text "tribunal/brandt"
             "Brandt is not in the gymnasium."
             :next "tribunal/brandt-2")

(dialog-text "tribunal/brandt-2"
             "Brandt is a deposition, read by a clerk with a cold."
             :next "tribunal/brandt-2-s2")

(dialog-text "tribunal/brandt-2-s2"
             "Brandt went back for the bottom drawer in the last winter. the building was no longer his to walk through."
             :next "tribunal/brandt-3")

(dialog-text "tribunal/brandt-3"
             "the deposition ends: the pencil copy is filed where things are found again. signed, dated, and found as filed."
             :next "tribunal/brandt-4")

(dialog-text "tribunal/brandt-4"
             "you would give the rest of your life to tell him so, and the rest of your life is currently under discussion."
             :next "tribunal/verdict-eve")

(dialog-text "tribunal/verdict-eve"
             "the night before the verdict you are kept in a borrowed room above the gymnasium with a cot and a basin and one window."
             :next "tribunal/verdict-eve-2")

(dialog-text "tribunal/verdict-eve-2"
             "in the city the bells ring at dusk, struck slow and uneven, and you know the unevenness now: a tired arm, a list being read back into the world, name by recovered name."
             :next "tribunal/verdict-eve-3")

(dialog-text "tribunal/verdict-eve-3"
             "they are ringing the lists the other way. it takes hours. you stand at the window for all of it."
             :next "tribunal/statement-choice")

(dialog-pick "tribunal/statement-choice"
             "in the morning the presiding judge asks whether the witness wishes to make a statement before the commission rules."
             (dialog-option "read the names you kept" "tribunal/statement-names")
             (dialog-option "say you were the one they asked" "tribunal/statement-asked")
             (dialog-option "offer no statement" "tribunal/statement-none"))

(dialog-on-enter "tribunal/statement-names"
                 '(setf (dialog-value "tribunal-statement") "names"))

(dialog-text "tribunal/statement-names"
             "you open the tin box. it is an exhibit now, lent back to you for this."
             :next "tribunal/statement-names-s2")

(dialog-text "tribunal/statement-names-s2"
             "you read the pencil pages aloud: dates, car weights, head counts, and the names you matched to counts."
             :next "tribunal/statement-names-2")

(dialog-text "tribunal/statement-names-2"
             "you read for forty minutes. nobody stops you. it is not a defense. it was never going to be a defense."
             :next "tribunal/statement-names-3")

(dialog-text "tribunal/statement-names-3"
             "it is a bell rung the other way by the man who let it ring the first way."
             :next "tribunal/verdict-scene")

(dialog-on-enter "tribunal/statement-asked"
                 '(setf (dialog-value "tribunal-statement") "asked"))

(dialog-text "tribunal/statement-asked"
             "you say: the war was there every morning. the most anyone could do was lose it slowly. i was the one they asked."
             :next "tribunal/statement-asked-s2")

(dialog-text "tribunal/statement-asked-s2"
             "i thought if i stayed, the asking would at least pass through a man who hated the answer."
             :next "tribunal/statement-asked-2")

(dialog-text "tribunal/statement-asked-2"
             "i have had three years to consider whether that belief was a service or an alibi. i have not finished."
             :next "tribunal/statement-asked-3")

(dialog-text "tribunal/statement-asked-3"
             "the judge writes one line. the gallery does not move."
             :next "tribunal/verdict-scene")

(dialog-on-enter "tribunal/statement-none"
                 '(setf (dialog-value "tribunal-statement") "none"))

(dialog-text "tribunal/statement-none"
             "no statement, you say. the words have all been used."
             :next "tribunal/statement-none-s2")

(dialog-text "tribunal/statement-none-s2"
             "every one of them was used in that building, on good paper, to move what was moved. you will not ask them to move you back."
             :next "tribunal/statement-none-2")

(dialog-text "tribunal/statement-none-2"
             "the judge studies you. it is not sympathy. it is not contempt."
             :next "tribunal/verdict-scene")

(defun tribunal-verdict-target ()
  (let ((sig (dialog-value "tribunal-signature" "unknown")))
    (cond
      ((string= sig "claimed") "tribunal/verdict-claimed")
      ((string= sig "denied") "tribunal/verdict-denied")
      (t "tribunal/verdict-unknown"))))

(dialog-scene "tribunal/verdict-scene"
              "the verdict."
              :next #'tribunal-verdict-target)

(dialog-text "tribunal/verdict-claimed"
             "the commission finds the office responsible and the man inseparable from the office, his own statement having closed the distance between them."
             :next "tribunal/verdict-claimed-2")

(dialog-text "tribunal/verdict-claimed-2"
             "the sentence is read slowly, in the gymnasium, inside the painted lines."
             :next "tribunal/verdict-claimed-3")

(dialog-text "tribunal/verdict-claimed-3"
             "custody of years. forfeiture of honors. his name entered in ink on the consolidated list, by street and not by rank."
             :next "tribunal/verdict-claimed-2-s2")

(dialog-text "tribunal/verdict-claimed-2-s2"
             "you asked for the office. the office is what you get."
             :next "tribunal/after")

(dialog-text "tribunal/verdict-denied"
             "the commission finds that the hand on exhibit one cannot be established."
             :next "tribunal/verdict-denied-s2")

(dialog-text "tribunal/verdict-denied-s2"
             "the only man who could have drafted it is being heard elsewhere, in the smaller room, where his memory is excellent."
             :next "tribunal/verdict-denied-s3")

(dialog-text "tribunal/verdict-denied-s3"
             "you are released as a witness, with thanks."
             :next "tribunal/verdict-denied-2")

(dialog-text "tribunal/verdict-denied-2"
             "outside the gymnasium the gallery files past you on the steps. nobody touches you. nobody speaks to you."
             :next "tribunal/verdict-denied-3")

(dialog-text "tribunal/verdict-denied-3"
             "you have been acquitted into a city that has reached its own verdict."
             :next "tribunal/after")

(dialog-text "tribunal/verdict-unknown"
             "the commission finds the question of the signature unresolved and the man before it diminished in a manner the statutes do not provide for."
             :next "tribunal/verdict-unknown-2")

(dialog-text "tribunal/verdict-unknown-2"
             "it orders supervision in place of custody: a registered address, a weekly signature at the district office, in your own hand, witnessed, forever."
             :next "tribunal/verdict-unknown-3")

(dialog-text "tribunal/verdict-unknown-3"
             "you will sign your name once a week for the rest of your life while a clerk watches your hand."
             :next "tribunal/verdict-unknown-4")

(dialog-text "tribunal/verdict-unknown-4"
             "it is the gentlest sentence the regulations contain. the commission closes its folder."
             :next "tribunal/after")

(dialog-text "tribunal/after"
             "that night, wherever they have put you, the bells ring the recovered names until past midnight, uneven, patient."
             :next "tribunal/after-2")

(dialog-text "tribunal/after-2"
             "you lie listening with your eyes open, keeping your own count. between one name and the next, the count turns backward from ten."
             :next "sys/reboot")
