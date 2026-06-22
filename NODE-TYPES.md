# Node types

A story is a graph of nodes. Each node has an id (a string, namespaced like
`"jrpg/inn"`), a kind, and usually a `:next` (the node it advances to). You build
the graph by calling these functions at load time; order does not matter, links
are resolved by id.

`:next` (and an option's target) is normally a node-id string. It may also be a
function of no arguments that returns a node-id string — use that for a branch
the engine should compute when the player arrives (e.g. pick a destination from
store state).

Any body string may contain `{key}` placeholders. At display time each `{key}`
is replaced with the matching value from the dialog store (see
`dialog-store-get`); an unknown key is left as the literal `{key}`.

## Linear nodes

```lisp
(dialog-start "ns/first")                    ; mark the graph's entry node

(dialog-text "ns/intro"
             "narration, shown as body text."
             :next "ns/next")

(dialog-say  "ns/line"
             "the clerk"                     ; a speaker label
             "spoken line, attributed to the speaker."
             :next "ns/next")

(dialog-scene "ns/establish"
              "a scene/establishing beat."
              :next "ns/next")
```

`dialog-say` is also how the **player** speaks: use the speaker `"you"`. A fixed
player beat with no choice is a single `dialog-say "..." "you" "..."`.

## Choices — the player decides

```lisp
(dialog-pick "ns/fork"
             "the prompt the player answers."
             (dialog-option "say yes" "ns/yes")
             (dialog-option "say no"  "ns/no")
             (dialog-option "a hidden-until-earned reply" "ns/secret"
                            :unless '(dialog-store-get "told-already"))
             (dialog-option "a visible-but-locked reply" "ns/locked"
                            :enabled-unless '(too-poor-p)))
```

`dialog-option (label target &key when unless enabled-when enabled-unless
direction preview)`:

- `:when` / `:unless` — a quoted form; the option is *shown* only when `:when` is
  true and `:unless` is false. Hide options the player has not earned.
- `:enabled-when` / `:enabled-unless` — show the option but render it locked
  (struck through) when disabled.
- `:direction` — `:north`/`:south`/`:east`/`:west` for a compass-layout pick.
- `:preview` — extra text revealed under the option when it is selected.

Layouts: picks render vertical, horizontal, list, or compass depending on the
node's layout. `dialog-pick` is the general form; `dialog-pick-path` /
`dialog-list-path` are convenience macros for a straight chain of beats.

## Conversations — the player OVERHEARS

```lisp
(dialog-conversation "ns/overheard"
  (dialog-left  "Voss"  "a line, on the left.")
  (dialog-right "Imari" "a reply, on the right.")
  (dialog-left  "Voss"  "another line.")
  :next "ns/after")
```

The two-column layout is for the player **eavesdropping on two other people**.
Both speakers are other characters. **Never** seat the player as a `dialog-right`
speaker — when the player is in the exchange, write each turn as a `dialog-say`
(`"you"` for the player), not a conversation.

## Interrogation — ask in any order

```lisp
(dialog-interrogation "ns/quiz"
  "the intro line."
  (:next "ns/after")
  (:continue-label "let them go on")
  (:require-all t)                 ; must ask everything before continuing
  ("ask about the auditors"
   :id "auditors" :speaker "the clerk"
   "first answer line."
   "a second answer line.")
  ("ask why the door was ajar"
   :id "ajar" :speaker "the clerk"
   "the answer."))
```

A hub of optional questions, each asked once. Good for a character who answers
several things before you move on.

## Minigames

```lisp
(dialog-minigame "ns/battle"
                 "fallback text if the minigame cannot run."
                 :game :jrpg-combat
                 :config (list :enemy "ruffian" :enemy-pool :city)
                 :success "ns/won"
                 :failure "ns/lost")
```

`:game` is a registered kind keyword. Built-in kinds include `:jrpg-overworld`,
`:jrpg-city`, `:jrpg-combat`, `:jrpg-character`, `:jrpg-shop`, `:crown-flash`,
`:title-card`, `:sign-trace`, `:organ-tune`, `:dream-maze`, `:lispm-reboot`.
`:config` is a plist the kind reads. `:success`/`:failure` (or `:outcomes`) are
the nodes to jump to when it ends. New kinds are registered in engine/script Lisp
(a CLOS `minigame-session` subclass, or `dialog-minigame-kind` with `:update`/
`:draw` functions).

## Attaching effects to a node

These decorate an existing node by id (call them after the node is defined):

```lisp
(dialog-on-enter "ns/intro" '(some-effect-form) '(another-form)) ; run on arrival
(dialog-particles "ns/intro" :tatters :fade-seconds 4.0)          ; a particle mode
(dialog-music "ns/intro" "audio/jrpg-city-night.mp3" :volume 0.3) ; set the track
(dialog-sound "ns/intro" "audio/jrpg/door.wav" :volume 0.5)       ; a one-shot
(dialog-set-next "ns/intro" "ns/somewhere-else")                  ; rewrite :next
```

Particle modes include `:rising`, `:stars`, `:warp`, `:snow`, `:ash`, `:motes`,
`:rogue-glyphs`, `:tatters`, and `:field`. Asset paths are resolved against the
bundle's `:assets` directory (`../assets/`).
