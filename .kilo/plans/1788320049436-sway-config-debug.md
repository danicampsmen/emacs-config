# Sway Config Debug Plan

## Context
- User reports Sway fails to start due to config errors.
- Config file: `/home/fayfer/.config/sway/config`
- Latest session confirmed Sway packages and config files are in place.

## Current findings
Two issues already identified in the config:

1. **Line 141** — `bindsym Print exec grim -g "$(slurp)" - | wl-copy && notify-send ...`
   Sway `exec` does not use shell, so `|` and `&&` are passed literally. Fix: wrap in `sh -c`.

2. **Line 12** — `set $editor emacsclient -c -a 'emacs'`
   Single quotes are literal here; if this variable is ever used in `exec`, the quotes break it. Safer form:
   `set $editor emacsclient -c -a emacs`

## Debug plan
1. Reproduce the exact startup failure:
   - If in TTY: run `sway --config ~/.config/sway/config` from a tty and capture stderr.
   - If already in a Sway session: run `swaymsg -t get_version` and `swaymsg -t get_config` to see current loaded config, then check logs at `~/.local/share/sway/*`.
2. If the exact error message is not known, collect it from the display manager greeter or `~/.local/share/sway/`.
3. Apply the two fixes above.
4. Validate with `sway --validate --config ~/.config/sway/config`.
5. Test binding `Print` to confirm grim/slurp pipeline works.

## Validation
- Config must pass `sway --validate`.
- `swaymsg -t get_config` must show corrected lines.
- Pressing `Print` must open slurp, copy to clipboard, and show notification.

## Open question
What is the exact error text Sway prints on startup? This determines whether the two known issues are the only blockers or if additional config errors exist.
