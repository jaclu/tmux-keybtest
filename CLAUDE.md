# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A diagnostic tool for identifying which key sequences a terminal passes to tmux. Running
`keybtest.sh` generates a version-appropriate `keybtest.conf` and starts an isolated tmux
session; pressing any key shows its tmux name on the status line.

## Running

```bash
./keybtest.sh        # generate keybtest.conf and start session
./keybtest.sh -m     # same, with mouse event capture
./keybtest.sh -q     # skip config regeneration, reuse existing keybtest.conf
./asdf_tmux.sh <version> [opts]  # test against a specific tmux version via asdf
```

Exit the session with `C-x` then `C-c`. Kill stray sessions with `pkill -f ' \-L keybtest'`.

## Linting

Run `olint` after any source change. A non-zero exit is a blocker — fix before committing.

Linter config files in this repo:

- `.shellcheckrc` — shellcheck settings (all checks enabled except SC2250, SC2312)
- `.markdownlint.yaml` — line length 92, allows `<nbsp>` and `<prefix>` HTML tags
- `pyproject.toml` — pymarkdown line length 92
- `.olint.conf` — skips `codespell` on Debian 10; overrides codespell to ignore "DoubleClick"

## Architecture

Scripts load in a fixed chain:

```text
keybtest.sh
  └── utils.sh          (sets TMUX_BIN, tmux_conf path, f_mouse_event path)
        └── tmux-plugin-tools.sh   (provides tmux_vers_ok, tpt_dependency_check)

generate_tmux_conf.sh
  └── utils.sh          (same as above)
```

**`generate_tmux_conf.sh`** is the core of the project. It writes `keybtest.conf` by calling
`writeln` in sequence. The logic is:

1. `setup_tmux_server` — writes base tmux settings and status bar config, gated by
   `tmux_vers_ok` for compatibility with tmux 1.0+.
2. `process_mod <modifier>` — called once per modifier (`""`, `S-`, `C-`, `C-S-`, `M-`,
   `M-S-`, `C-M-`, `C-M-S-`). Each call writes all key bindings for that modifier group
   via `bind_char`.
3. `bind_char` — constructs a `bind -n` line. Skips or comments out keys that are invalid
   for the current modifier/version combination, controlled by `$skip_message`,
   `$no_shift`, `$no_ctrl`, `$no_meta` flags.

**`tmux-plugin-tools.sh`** is a reusable library (used by other tmux plugin projects too).
Key public API:

- `tmux_vers_ok <version>` — returns 0 if running tmux ≥ specified version; handles
  suffixes like `3.3a`.
- `tpt_dependency_check <space-separated tools>` — checks that tools exist; supports `|`
  for alternatives.
- `tpt_retrieve_running_tmux_vers` — populates `$tpt_current_vers`,
  `$tpt_current_vers_i`, `$tpt_current_vers_suffix`.

**`tools/mouse_event.sh`** — currently not used (noted with "Not used ATM"). It was
designed to debounce rapid mouse events (double/triple click) using a tmp-file timer.

**`asdf_tmux.sh`** — wrapper for testing against a specific tmux version via
`asdf set tmux <version>`.

## Version compatibility notes

- `keybtest.conf` is regenerated each run to match the installed tmux version.
- Many `bind_char` calls are wrapped in `tmux_vers_ok` guards; the version matrix is the
  primary complexity in `generate_tmux_conf.sh`.
- `TMUX_BIN` defaults to `tmux` but can be overridden; if a `.tool-versions` file is
  present in the project root, the local asdf version is used unconditionally.
- Do not run inside an existing tmux session — it interferes with key detection.
