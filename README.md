# Ship Throttle

An [Arma 3](https://arma3.com/) addon that adds a **jet-style,
set-and-hold throttle percentage** to `Ship`-class vehicles (boats,
RHIBs, speedboats, etc.): a modifier-key combo steps the throttle up or
down, the boat accelerates/holds that speed on its own via
`setCruiseControl`, and a HUD readout at the bottom-center of the screen
shows the current throttle %. Native W/S/A/D (accelerate, brake,
reverse, steer) are untouched - this addon adds cruise-control-style
throttle *on top of* normal driving, it doesn't replace it.

**Zero dependencies** - no CBA_A3 required, and its own small in-game
settings menu (Ctrl+Shift+T) replaces the need for CBA's "Configure
Addons" screen for rebinding. See [Design decisions](#design-decisions)
for the history of why (CBA gave persistent, unreproducible errors;
fully hijacking W/S for throttle - tried in 0.3.0-0.4.1 - broke native
braking and felt clunky even after patching around it).

> ✅ **Status: confirmed working in a live game** as of 0.4.x (engine
> auto-start, forward cruise control, HUD). **0.5.0's changes - the
> modifier-key scheme and the settings menu - are new and not yet
> field-tested.** See [Known risks](#known-risks--unverified-assumptions)
> and [Changelog](CHANGELOG.md) for the full history of what's been
> found and fixed through real testing so far.

## Requirements

- Arma 3 **v2.06+** (for `setCruiseControl`)
- Nothing else. No CBA_A3, no other addons.

## Installation

1. Build the PBO (see [Building](#building) below) so you have
   `@olk_ship_throttle/addons/ship_throttle.pbo`.
2. Drop the whole `@olk_ship_throttle` folder next to your other Arma 3
   mod folders (e.g. in your Arma 3 installation directory, or wherever
   you keep workshop/manually-installed mods).
3. Enable `@olk_ship_throttle` in the Arma 3 launcher. That's it - no
   other mod needs to be active alongside it.

## Building

This repo ships source only (`config.cpp` + `.sqf`/`.hpp`), not a packed
`.pbo` (build artifacts aren't committed - see `.gitignore`). A few ways
to pack it:

- **`scripts/build-pbo/`** (included in this repo, no Windows/Steam
  needed - just Node.js):
  ```bash
  cd scripts/build-pbo
  npm install
  npm run build
  ```
  This uses [`gulp-armapbo`](https://www.npmjs.com/package/gulp-armapbo),
  a pure-JS Arma PBO packer, and writes
  `@olk_ship_throttle/addons/ship_throttle.pbo`. It also embeds the
  `prefix` property directly (from `$PBOPREFIX$`'s contents) rather than
  relying on the loose `$PBOPREFIX$` file at runtime.
- **[HEMTT](https://github.com/BrettMayson/HEMTT)** (the community's
  standard Rust-based build tool) - run `hemtt build` from the repo root
  once you've added a `.hemtt/project.toml`; or
- **Arma 3 Tools' Addon Builder** (from Steam, under Arma 3 Tools); or
- **[PBO Manager](http://www.armaholic.com/page.php?id=16369)**.

Whichever tool you use, point it at `@olk_ship_throttle/addons/ship_throttle/`
and have it output `ship_throttle.pbo` into `@olk_ship_throttle/addons/`.

## Keybinds

| Action | Default | Rebindable? |
|---|---|---|
| Throttle +10% | Ctrl + W | Yes, in-game |
| Throttle -10% | Ctrl + S | Yes, in-game |
| Throttle +1% (fine) | Ctrl + Shift + W | Same binding as above, + Shift |
| Throttle -1% (fine) | Ctrl + Shift + S | Same binding as above, + Shift |
| **Open settings menu** | **Ctrl + Shift + T** | No (fixed - it's how you rebind everything else) |

Throttle keys only do anything while you're in the driver seat of a
`Ship`, and only consume the keypress when they do - plain W/A/S/D
always behave completely normally (native accelerate/brake/reverse/
steer), in a Ship or anywhere else.

**To rebind:** press Ctrl+Shift+T to open the settings dialog, press
`1` or `2` to select "Increase Throttle" or "Decrease Throttle", then
press whatever key (with or without Ctrl held) you want to use -
whatever you press becomes the new binding immediately, saved to your
Arma profile (`profileNamespace`/`saveProfileNamespace` - survives
mod updates and reinstalls, no file editing needed). Esc cancels a
capture in progress, or closes the menu.

The settings dialog is deliberately keyboard-only (no clickable
buttons) - see [Design decisions](#design-decisions) for why.

## Design decisions

Answers to the brief's open questions, and choices made while building
(see [Changelog](CHANGELOG.md) for the full blow-by-blow):

- **CBA_A3 dependency**: initially accepted, then **removed** after a
  persistent, unreproducible "requires addon CBA_A3" error. The addon
  is built entirely on vanilla Arma 3 mechanisms.
- **Control scheme: Ctrl+W/Ctrl+S, not a hijacked W/S** (changed twice).
  The brief's original idea was dedicated unbound keys; that became
  "make W/S themselves work like a jet throttle" (0.3.0), fully
  consuming W/S while driving a Ship - which broke native braking
  entirely, patched around with a custom hold-to-brake mechanism
  (0.4.1) that still felt clunky in real testing. 0.5.0 instead frees
  W/S completely and moves throttle control to a Ctrl modifier combo,
  so native accelerate/brake/reverse "just work" via the vehicle's own
  well-tested physics, and the mod only ever *adds* forward cruise
  control on top - closer to the original brief's own assumption that
  "manually accelerating [above cruise control's set speed] is
  possible... leaving W available as a manual boost is arguably fine
  UX."
- **Reverse: back to native S, not scripted.** 0.4.0 added negative
  throttle with a custom scripted velocity loop, since
  `setCruiseControl` doesn't support negative speeds (confirmed in
  testing). Freeing native S in 0.5.0 made that whole mechanism
  unnecessary - reversing is just native boat physics again, which is
  simpler and better-tested than anything this addon could script.
  Throttle is 0-100% only now.
- **A real settings menu, not just hardcoded keys.** Since there's no
  CBA "Configure Addons" screen, 0.5.0 adds a small in-game dialog
  (Ctrl+Shift+T) instead. Considered a `userconfig`-folder/`.ini`-style
  approach first, but that requires the player to launch with
  `-filePatching` enabled (off by default since Arma 3 v1.50) for an
  *addon* (as opposed to a mission) to read it at all - not something a
  typical player would know to do. `profileNamespace` has no such
  requirement and already persists other addon-local settings, so it's
  the more robust choice for something meant to actually work for
  players who aren't editing config files.
- **Settings menu is keyboard-only, no clickable buttons.** Building it
  with `CT_BUTTON` controls would need inheriting from the vanilla
  `RscButton` base class (many required sub-properties - colors, sounds,
  etc. - that aren't safe to guess), and the exact include path for
  those BIS base classes outside a mission context wasn't something
  this project could pin down with confidence. Given the `style`
  required-field mistake earlier in this project's history (see
  Changelog 0.3.4), guessing at a bigger, less-documented control type
  without the ability to test visually felt like a worse bet than a
  functionally complete keyboard-driven menu using only
  `CT_STRUCTURED_TEXT` - the one control type already proven to work
  correctly, for the HUD.
- **Throttle step size**: 10% per tap, Shift for ±1% fine control -
  unchanged since the original brief.
- **HUD style**: structured-text overlay (`"<pct>% ⚙"`), bottom-center,
  shown only while driving a `Ship`. Pure vanilla `cutRsc`/`RscTitles` -
  never depended on CBA. Styled with `PuristaSemiBold` (Arma 3's own UI
  font, confirmed against a real community pilot-HUD mod's config
  rather than guessed) and a soft cyan-white tone closer to Arma's
  vehicle-instrument look, after an earlier, smaller/plainer version.
- **Idle (0%) behavior**: fully **releases** cruise control
  (`setCruiseControl [0, false]`) rather than actively holding station at
  0 speed. At 0% the hull coasts/drifts like a real idling boat, rather
  than fighting waves/current to stay pinned in place.
- **Vehicle-enter/exit detection**: vanilla config-level `GetInMan` /
  `GetOutMan` / `Killed` EventHandlers declared on `CAManBase` in
  `config.cpp` (fires for every unit; each dispatcher function in
  `functions/fn_on*EH.sqf` filters down to "this is the local player").
  These are genuine native Arma 3 unit EventHandlers, confirmed on the
  BI wiki (`GetOutMan`'s documented signature is
  `[unit, role, vehicle, turret, isEject]`) - not CBA player events (an
  earlier build's mistake - see Changelog).
- **Init/keybind registration without CBA XEH**: a `CfgFunctions` entry
  with `postInit = 1` (vanilla, not CBA-specific) runs once at mission
  start and registers a `displayAddEventHandler ["KeyDown", ...]`
  handler on `findDisplay 46` - the standard pre-CBA technique for a
  global hotkey.
- **Entry-detection watchdog (defense-in-depth)**: `fn_init.sqf` also
  spawns a 1s polling loop that starts throttle tracking the moment it
  finds the local player driving a Ship, independent of whether the
  `getInMan` EventHandler fired - insurance against a repeat of a real
  bug this project shipped once already (see Changelog).

## Known risks / unverified assumptions

- ⚠️ **UNVERIFIED - the whole 0.5.0 rework.** Nothing about the
  Ctrl-modifier scheme or the settings menu has been driven in a live
  game yet. Specific things that could plausibly be wrong:
  - Whether `displayAddEventHandler`'s `_ctrl` parameter behaves exactly
    as assumed (mirrors the already-confirmed `_shift` parameter).
  - Whether a bare top-level `class olk_ship_throttle_settings {...}`
    (not nested under a `Dialogs` wrapper) is really enough for
    `createDialog` to find it - the BI wiki says it searches `configFile`
    by class name without mentioning a required wrapper, but this
    hasn't been confirmed against a live game.
  - Whether `enableSimulation = 1` and the dialog's general behavior
    (does it pause anything? does Esc correctly close it without also
    opening Arma's own pause menu underneath?) work as expected.
  - Whether capturing a *shifted* key (e.g. binding "Increase Throttle"
    to plain Shift+something) breaks the separate coarse/fine Shift
    convention in a confusing way - not specifically handled, just not
    expected to come up.
  - Whether Ctrl+W/Ctrl+S collide with anything else bound by default
    in vanilla Arma (not checked exhaustively).

  Go through the [Testing checklist](#testing-checklist) below before
  relying on this build.
- 🐛 **FIXED - the engine didn't start itself.** Real testing showed
  throttle % climbing with no actual boat movement: `setCruiseControl`
  doesn't turn a ship's engine on by itself. Fixed with `engineOn true`
  in `fn_onGetInMan.sqf` (once, right when the player becomes driver)
  and again defensively in `fn_setThrottle.sqf` whenever throttle is
  positive.
- 🐛 **FIXED - `CAManBase`'s re-declared parent class was wrong.**
  `config.cpp` re-opened `CAManBase` as `class CAManBase: Civilian`, but
  the real base game hierarchy has `CAManBase` inheriting from `Man`
  directly (confirmed against a real working mod's config). Reopening an
  existing class with a mismatched parent is a real, documented Arma
  config problem. Fixed to inherit directly from `Man`.
- 🐛 **FIXED (a regression, caught and fixed same day) - `style` is a
  required config entry**, not just an alignment value. Removing it
  entirely (thinking it was an unverified/redundant guess) broke the
  HUD outright, confirmed by an in-game `No entry '...style'` error.
  Restored with `style = 0` (`ST_LEFT`, confirmed on the BI wiki as a
  safe baseline) - the same lesson applied when building the new
  settings menu (see Design decisions above).
- 🐛 **CONFIRMED BROKEN, then simplified away - reverse via negative
  `setCruiseControl` speed.** Flagged as the mod's single biggest
  unverified risk from the original brief onward; real testing
  confirmed a negative speed does not reverse a ship. 0.4.0 replaced it
  with a scripted velocity loop; 0.5.0 removed that entirely in favor
  of native S (see Design decisions) now that W/S are free again.
- 🐛 **FIXED - config EventHandlers need the exact literal event
  name.** An early build registered custom-prefixed property names on
  `CAManBase`'s `EventHandlers`, thinking that kept them collision-safe
  the way CBA's XEH does. It doesn't: vanilla config EventHandlers
  dispatch strictly by the literal recognized name - an unrecognized
  property name is inert and never fires, with no error. Fixed by using
  the literal `getInMan`/`getOutMan`/`killed` names. The real tradeoff
  this brings back: without XEH, only one handler per event name is
  allowed per class - if you ever add another non-CBA addon that also
  defines these on `CAManBase`, whichever loads last silently wins.
- ⚠️ **ASSUMPTION - `GetInMan`'s argument order.** Assumed to mirror the
  BI wiki's documented `GetOutMan` order (`unit, role, vehicle, turret`)
  since `GetInMan` itself wasn't directly documented in what was
  reachable during research. `fn_onGetInManEH.sqf` only trusts `_unit`
  and `_vehicle` from this (verifying the driver seat directly via the
  `driver` command rather than the reported role string), and the
  postInit watchdog is an independent fallback in case this argument
  order - or anything else about this specific handler - turns out to
  be wrong.
- ⚠️ **ASSUMPTION - `maxSpeed` as the 100% ceiling.** Throttle % maps to
  target speed via `(pct / 100) * maxSpeed` from the vehicle's
  `CfgVehicles` config. `maxSpeed` is a standard AI-driving attribute,
  not guaranteed to be an accurate top-speed ceiling for every
  vanilla/modded boat. Test against at least two differently-sized boats.
- ⚠️ **ASSUMPTION - brake cancels cruise control on boats.** The BI wiki
  states applying brakes disables Cruise Control, but its only worked
  example is a car. The watch loop in `fn_onGetInMan.sqf` resets the
  throttle to 0% if it detects `getCruiseControl` silently went to
  `autoThrust = false` while a nonzero throttle was still stored. This
  is relevant again in 0.5.0 now that native S (brake) works normally.
- ⚠️ **UNTESTED - multiplayer locality.** `setCruiseControl` is
  documented as operating on the *local* player's vehicle, so this
  should be inherently per-client with no sync needed - but that's only
  confirmed by reading the docs, not by an actual dedicated-server +
  2-client test.
- Boat runs aground / collides: the throttle value persists as
  "commanded" even though actual speed drops - this mirrors real
  throttle behavior and is intentional, not a bug.

## Testing checklist

1. Enter a vanilla RHIB as driver; confirm the throttle HUD appears at
   0% and the engine is audibly/visibly running.
2. Hold Ctrl and tap W a few times; confirm throttle increases in the
   HUD and the boat accelerates on its own without holding W, roughly
   holding a mid-range speed at ~50%. Confirm plain W (no Ctrl) still
   works as normal native acceleration too, on top of whatever cruise
   control is doing.
3. Increase to 100% (Ctrl+W); compare against the boat's known/observed
   top speed to sanity-check the `maxSpeed` assumption.
4. **With cruise control holding a forward speed, tap plain S (no
   Ctrl)** - confirm this behaves like normal braking (not a throttle
   step) and doesn't get immediately overridden back to speed by cruise
   control. This exercises the "brake cancels cruise control" assumption
   for the first time since 0.3.0.
5. Hold Ctrl and tap S a few times to decrease throttle to 0%; confirm
   it stops adding forward cruise control and the boat coasts down
   normally (no reverse - throttle floors at 0% now).
6. Test plain S alone (no Ctrl) for reverse - confirm native boat
   reverse works normally, since nothing should be intercepting it
   anymore.
7. Exit the vehicle mid-throttle, re-enter as driver; confirm it comes
   back in a clean 0% state, and that the engine starts again.
8. Switch from driver to a gunner/cargo seat *without* exiting the
   vehicle; confirm the HUD hides and cruise control releases (should be
   immediate via `GetOutMan`, or within ~0.5s via the watch loop as a
   fallback).
9. **Press Ctrl+Shift+T; confirm the settings menu opens** and shows the
   current Increase/Decrease bindings. Press `1`, then press a different
   key (e.g. plain `E`, no Ctrl); confirm the menu updates to show the
   new binding, Esc closes the menu, and that key now actually controls
   throttle in-game (while old Ctrl+W no longer does). Repeat for
   Decrease. Test that Esc *during* a capture cancels without changing
   the binding. Re-open the menu on a later mission/restart to confirm
   the binding persisted via `profileNamespace`.
10. Repeat steps 1-6 on a second, differently-sized boat class to catch
    per-class `maxSpeed` weirdness.
11. Basic MP test (2 clients, ideally a dedicated server) to confirm no
    desync/host-authority issues - `setCruiseControl` is typically
    local-only, so this should be per-client with no sync needed, but
    that's not yet confirmed live.

## Repository layout

```
@olk_ship_throttle/
├── mod.cpp
└── addons/
    └── ship_throttle/
        ├── $PBOPREFIX$
        ├── config.cpp          - CfgFunctions, CAManBase EventHandlers, RscTitles/SettingsMenu includes
        ├── functions/
        │   ├── fn_init.sqf              - postInit=1, registers KeyDown/KeyUp handlers
        │   ├── fn_keyDown.sqf           - Ctrl+Shift+T opens settings; configurable Ctrl+W/Ctrl+S -> adjustThrottle
        │   ├── fn_keyUp.sqf             - clears the key-repeat debounce tracker
        │   ├── fn_setThrottle.sqf       - drives setCruiseControl, 0-100% only
        │   ├── fn_adjustThrottle.sqf    - +/- delta from a keypress
        │   ├── fn_onGetInManEH.sqf      - GetInMan EH dispatcher (filters to local player)
        │   ├── fn_onGetOutManEH.sqf     - GetOutMan EH dispatcher
        │   ├── fn_onKilledEH.sqf        - Killed EH dispatcher
        │   ├── fn_onGetInMan.sqf        - init state, show HUD, start watch loop
        │   ├── fn_onGetOutMan.sqf       - release control, hide HUD
        │   ├── fn_updateHud.sqf         - repaint the HUD text
        │   ├── fn_onSettingsMenuLoad.sqf   - settings dialog onLoad entry point
        │   ├── fn_refreshSettingsMenu.sqf  - repaints the settings dialog's text
        │   ├── fn_settingsMenuKeyDown.sqf  - settings dialog interaction/key-capture logic
        │   └── fn_bindingToText.sqf        - DIK code -> human-readable key name
        └── ui/
            ├── RscTitles.hpp     - the HUD dialog resource
            └── SettingsMenu.hpp  - the settings dialog resource
```

## Non-goals

Per the original brief: this does not redo the jet HUD's look, does not
touch ground vehicles or aircraft, and does not attempt full engine
simulation (RPM, fuel burn curves, etc.) - just a usable, persistent
throttle percentage for ships.

## License

MIT - see [LICENSE](LICENSE).
