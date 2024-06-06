# tmux-check-terminal

Check what keys tmux can detect from your terminal

If your terminal binds some keys, they will not be detected by tmux!

When a key is pressed and it was identified, its name is displayed on the
status line

## Keys not tested

### Shift S-

- The shifted regular keys are not tested, instead of binding `S-a` or `S-A`
use `A`

### Control C-

- cant be bound: `~ $ % & * { } | "`
- case is ignored, binding `C-A` after `C-a` will drop the `C-a` bind
thus only binding uppercase here
- Skipped to avoid collision
  - `C-I` is the same as Tab
  - `C-M` is the same as `Enter`
  - `C-X` is not tested, that would make it impossible to exit
  - `C-[` is the same as Escape

### Control Shift C-S-

- Regular keys Not tested, same as with `S-`

### Meta Shift  M-S-

- Regular keys Not tested, same as with `S-`

### Control Meta  C-M-

- cant be bound: `~ $ % & * { } | "`
- case is ignored, binding `C-M-A` after `C-M-a` will drop the `C-M-a` bind
thus only binding uppercase letters here
- Skipped to avoid collision
  - `C-M-M` is the same as `M-Enter`
  - `C-M-[` is the same as `M-Escape`

### Control Meta Shift  C-M-S-

- cant be bound: `~ $ % & * { } | "`

## other things

Since this has a high likelyhood of

one of three things will happen

- If the key could be bound in tmux it is displayed on the staus line
- If the key sent output not recognized it will be displayed in the
This will display what key was pressed

 I have only defined US-keyb keys, contributions for other keys
 would be apreciated!

## What does your terminal generate

 To check what keys your terminal generates, here are some
 suggestions, should be run outside tmux, since it might capture keys

- showkeys -a
- xxd

 When displaying codes generated for example by the above tools,
 in most cases, this is how the mods alter the sequence:

- S       2
- M       3
- M-S     4
- C       5
- C-S     6
- C-M     7
- C-M-S   8

## If terminal cant be made to send correct sequence

 If you cant alter what your terminal generates, but it does generate
 something, you can bind that to the desired key by using user-keys.

 Remember to use octals prefixed by `\\` and always give three digits,
 so if the octal is 73 give it as `\\073`

 Octals are normally in the middle column when using `showkeys -a`

```tmux
set -s user-keys[101] "\\342\\201\\204"
bind -n User101 send-keys F1
```
