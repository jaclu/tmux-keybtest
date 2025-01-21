# tmux-keybtest

**tmux-keybtest** is a utility for identifying which key sequences tmux can
detect in your terminal. When you press a key, its tmux name, like `C-M-Up`,
will be displayed on the status line if recognized.

Teminals are often rather limited in what keys they implement supported beyond the basics.

In some cases missing keys can be configured, but especiallly on tablets this is
usually fairly limited.

Terminals can sometimes misinterpret key presses, generating the wrong sequence
or nothing at all. **tmux-keybtest** helps you evaluate which keys are
available in your current terminal and can assist in selecting a terminal with
better support for key sequences.

Note: If your operating system or terminal has already bound certain keys,
tmux may not detect them. It may be possible to reconfigure your system or
terminal to free up these keys for tmux use.

## Usage

1. Clone this repository and navigate to its directory.
2. Run `keybtest.sh` this generates a `keybtest.conf` for the version of tmux found and starts a tmux session that will display the tmux notation for any recognized key press.

### Important Notes

- Some keys might not send the intended sequence, causing tmux to interpret
  them differently.
- Avoid running this script inside an existing tmux session, as this may
  interfere with key detection.
- To exit the session, press `C-x C-c`. The exit sequence is displayed in
  the status line for convenience.

### tmux Key Name Prefixes

- `S-` : Shift key is pressed.
- `C-` : Control key is pressed.
- `M-` : Alt (Meta) key is pressed.

Use the key names displayed to customize your `tmux.conf` according to your
terminal's capabilities.

## Keys Not Tested

### Shift `S-`

- Shifted regular keys are not tested. Instead of binding `S-a` or `S-A`,
  use `A`.

### Control `C-`

- Prior to 3.5 - Cannot be bound: `~ $ % & * { } | "`
- Prior to 3.3 - Cannot be bound: `` ` /``
- Prior to 3.0 - Cannot be bound: `;`
- Case is ignored: Binding `C-A` after `C-a` will override `C-a`, so only
  lowercase is bound.
- Keys skipped due to collision:
  - `C-i` is the same as `Tab`
  - `C-m` is the same as `Enter`
  - `C-[` is the same as `Escape`

### Control Shift `C-S-`

- Regular keys not tested, same as with `S-`.

### Meta Shift `M-S-`

- Regular keys not tested, same as with `S-`.

### Control Meta `C-M-`

- Same limitations as under `C-`
- Case is ignored: Binding `C-M-A` after `C-M-a` will override `C-M-a`, so
  only lowercase is bound.

### Control Meta Shift `C-M-S-`

- Same limitations as under `C-`
- No lowercase keys are bound due to the use of Shift.

## Additional Information

- **Insert** is referred to as `IC` and **Delete** as `DC` in tmux. If you see
  these, the terminal is functioning correctly.
- If a key generates an unrecognized code, the terminal might beep. Consider
  muting your sound before running this in public spaces.
- Unrecognized keys will be printed. Please submit such outputs as an issue,
  including the key/sequence and, if possible, your keyboard type.

## When Terminal Generates the wrong key

If a terminal generates a sequence that tmux recognizes but is not the
intended one (e.g., `M-Up` generates `S-F3`), bind the desired action for `M-Up` to `S-F3`.

## When tmux doesn't recognize what the key sends

If a terminal generates an unrecognized but unique sequence, you can bind it
to an action using user-keys. Tmux requires octal notation for user-keys,
formatted as three digit values (0 padded) and prefixed with `\`.

`showkey -a` can be used to find the octals, examine the middle column.

Example:

    set -g user-keys[200] "\302\247"
    bind -n User200 send Escape

Be aware that the `send Escape` in this case is only sent to apps running inside tmux. It is not picked up by tmux itself. For that `User200` must be used.

This is probably amongst the least intuitive features in tmux

- assign a key (sequence) using `user-key[200]`
- when using it inside tmux refer to it as `User200`

## Checking Terminal Key Sequences

To determine what sequence a key generates, use the following commands outside
of tmux:

- `showkeys -a`
- `xxd`
