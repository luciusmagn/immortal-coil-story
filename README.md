# Immortal Coil — story graph

This is the narrative content for [Immortal Coil](https://github.com/luciusmagn/immortal-coil):
the dialog graph, the minigame scripts, and the campaign that hangs off them. The
engine lives in the main repository; this repository is the *story*.

It is consumed as a git submodule, mounted at `game/` in the main repo, so the
engine loads it by the same relative paths it always has (`game/manifest.lisp`,
`game/campaign/...`). Nothing in the Lisp engine changes when this content moves
in or out of a submodule.

## Layout

- `manifest.lisp` — the bundle: the ordered list of scripts to load, the start
  node, and where assets live (`../assets/`, in the main repo).
- `campaign/` — the dialog graph, one file per arc, written in the dialog DSL.
- `opening.lisp` — the shared opening and the ship-captain branch.
- `jrpg/`, `maze/`, `flight/`, `rogue/`, `war/`, `forest/`, `sys/` — minigame
  scripts (CLOS sessions or function-based kinds) registered for `dialog-minigame`.

## Writing

The prose follows one voice: plain, concrete, declarative. See `WRITING.md` in
the main repo. The King-in-Yellow path quotes Chambers (public domain) verbatim
where it fits; use Project Gutenberg ebook #8492 as the text source.

## Authoring

- [`MODDING.md`](MODDING.md) — make a mod, or edit this story.
- [`NODE-TYPES.md`](NODE-TYPES.md) — every node type the DSL gives you.
