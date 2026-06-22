# Modding Immortal Coil

A mod is a folder with a `manifest.lisp` and one or more script files that add
nodes to the graph with the dialog DSL (see [`NODE-TYPES.md`](NODE-TYPES.md)).
This is the same machinery the base game uses — `manifest.lisp` here is just the
base bundle.

## The shortest possible mod

Put this under the game's `mods/` directory, e.g. `mods/hello/`:

`mods/hello/manifest.lisp`
```lisp
(:id "hello"
 :name "Hello, Carcosa"
 :version "0.1.0"
 :description "A one-room detour."
 :author "you"
 :depends-on ("immortal-coil/base")
 :scripts ("story.lisp")
 :assets "assets/")
```

`mods/hello/story.lisp`
```lisp
(in-package #:immortal-coil)

(dialog-text "hello/room"
             "a small room you do not remember. one window has bars on the inside."
             :next "hello/leave")

(dialog-say "hello/leave" "you" "you leave it for later." :next "base/awake")
```

Enable it from the title screen: **MODS -> MOD LIST -> RET to toggle**. The base
game ships an in-engine editor too (MODS -> CREATE MOD / EDIT MOD), which writes
these same files for you.

## Manifest fields

| key | meaning |
|-----|---------|
| `:id` | unique id, e.g. `"hello"`. Namespace your node ids with it. |
| `:name`, `:version`, `:description`, `:author` | shown in the mod list. |
| `:depends-on` | list of bundle ids that must load first. Use `("immortal-coil/base")` to build on the main story. |
| `:scripts` | ordered list of `.lisp` files (relative to the mod folder) to load. |
| `:assets` | a folder (relative to the mod folder) holding audio/images this mod references. |
| `:start` | (base bundle only) the entry node. A mod usually omits this and links into existing nodes instead. |

## Hooking into the base story

Because your scripts load after the base graph, you can branch off it:

- Point a new option or `:next` at an existing base node (`"base/awake"`,
  `"jrpg/city-hub"`, ...).
- Rewrite a base node's exit with `(dialog-set-next "base/some-node" "yourmod/x")`.
- Add a choice to an existing pick with `(dialog-add-choice "base/fork" "..." "yourmod/x")` (takes the same `:when`/`:unless`/`:direction`/`:preview` keys as `dialog-option`).

Keep every id namespaced (`hello/...`) so two mods never collide, and hold to the
plain, concrete voice in `WRITING.md`. Run the engine's `scripts/graph-lint.lisp`
to confirm every link resolves before you ship.
