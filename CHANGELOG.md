# Changelog

## 0.3.5 - polish pass: remove diagnostics, redesign the HUD

**First version confirmed fully working in a live game**, following the
fixes in 0.3.1-0.3.4 below.

- Removed all temporary `systemChat` diagnostic messages added while
  chasing 0.2.x/0.3.x bugs (postInit/keybind-registration/watchdog
  checkpoints, the wide per-keypress logger, the findDisplay 46 retry
  logger). The mod is silent now except for the HUD itself.
- Redesigned the HUD after feedback that the old bottom-right text box
  was small and hard to read: moved to bottom-center, enlarged, and
  restyled with `PuristaSemiBold` (Arma 3's own real UI font, confirmed
  against a working community pilot-HUD mod rather than guessed) and a
  soft cyan-white tone closer to Arma's vehicle-instrument look, instead
  of the earlier plain white-on-black box with an unverified font name.

## 0.3.1-0.3.4 - diagnosing and fixing "loads fine, does nothing for W/S"

Real-world testing after 0.3.0 showed the HUD/entry-detection working
but W/S never registering at all - not even a wide, unconditional
per-keypress logger caught anything. Root-caused across these builds:

- **`CAManBase`'s re-declared parent class was wrong.** `config.cpp` had
  `class Civilian: Man {}; class CAManBase: Civilian {...}`, but the
  real base-game hierarchy has `CAManBase` inheriting from `Man`
  directly (confirmed against a real mod's config:
  `class Man: Land {...}; class CAManBase: Man {...};`, no `Civilian`
  anywhere in it). Reopening an existing engine class with a mismatched
  parent is a known Arma config problem. Fixed to inherit directly from
  `Man`.
- **A regression introduced while fixing the above**: a review pass
  removed the HUD control's `style` property, reasoning it was an
  unverified/redundant alignment guess. `style` turned out to be a
  *required* config entry for this control type, confirmed by an
  in-game `No entry '...style'` error the moment the HUD tried to load.
  Restored with `style = 0` (`ST_LEFT`, confirmed on the BI wiki).
- The root cause of "W/S never registers" itself was never conclusively
  isolated beyond these fixes - both were real, confirmed bugs, and
  after fixing them the mod started working end to end. It's possible
  one or both were the actual cause, or that some other factor resolved
  itself; the important fact is the current build is now verified
  working in-game, not just by source review.
- Added (then, after confirmation, removed in 0.3.5) extensive
  `systemChat` diagnostics at every stage of the init/keybind/watchdog
  chain to localize exactly where execution was stopping.

## 0.3.0 - W/S jet-style throttle instead of a dedicated key

- Confirmed working end to end in real testing (postInit, keybind
  registration, GetInMan/HUD all fire correctly after the 0.2.3 fix).
- Changed the control scheme from a dedicated key (Numpad ±) to fully
  hijacking **W/S** while driving a Ship: tap W/S to step the throttle
  ±10% (Shift for ±1%), matching a real jet/plane throttle rather than
  hold-to-accelerate. Native analog accelerate/brake no longer works on
  boats at all - this is a full replacement. W/S behave normally
  everywhere else.
- Added `fn_keyUp.sqf` and a held-keys tracker in `fn_keyDown.sqf` to
  debounce the engine's key-repeat on `KeyDown` (which fires repeatedly
  while a key is held) - otherwise holding W would spam +10% every
  frame instead of stepping once per tap.
- The "brake cancels cruise control" watch-loop fallback is kept but
  now largely defensive-only, since S no longer reaches the vehicle as
  a native brake input at all.

## 0.2.3 - fix: wrong function file naming convention (the actual root cause)

- **Root-cause bug fix**: every function file in this addon was named
  `fnc_<Name>.sqf` (e.g. `fnc_setThrottle.sqf`). The real, confirmed
  (BI wiki + an in-game "Script ... fn_init.sqf not found" error)
  default `CfgFunctions` naming convention is `fn_<Name>.sqf` - no "c".
  This means **no function in this addon was ever actually found/run by
  the engine, in any previous build**, including the 0.2.1/0.2.2
  EventHandler and watchdog fixes - those were real, correct fixes, but
  they were themselves living in files the engine could never locate,
  so none of it ever had a chance to run. Renamed every `functions/fnc_*.sqf`
  file to `functions/fn_*.sqf`. The callable function names
  (`olk_fnc_setThrottle` etc.) are unchanged - only the on-disk filenames
  were wrong.
- This is a strong root-cause candidate for the whole "loads fine, does
  nothing" saga across 0.1.0-0.2.2. Rebuilt and re-verified the packed
  PBO byte-for-byte as before.

## 0.2.1 - fix: config EventHandlers never actually fired

- **Bug fix**: 0.2.0's `config.cpp` registered the `getInMan`/`getOutMan`/
  `killed` EventHandlers on `CAManBase` under addon-prefixed property
  names (e.g. `olk_ship_throttle_getInMan`), thinking that made them
  collision-safe. Vanilla config EventHandlers dispatch strictly by the
  literal recognized name - an unrecognized property name is inert and
  never fires, with no error. This is why the mod loaded without errors
  but never actually did anything (reported by real-world testing).
  Fixed by using the literal `getInMan`/`getOutMan`/`killed` names.
- Added a 1s postInit watchdog (`fn_init.sqf`) that starts throttle
  tracking as soon as the local player is found driving a Ship,
  independent of whether the EventHandlers above fire - defense in
  depth against a repeat of the same class of bug.
- Hardened `fn_onGetInManEH.sqf` to verify the driver seat via the
  `driver` command directly rather than trusting `GetInMan`'s reported
  role string, since that argument order is still an unconfirmed
  assumption (see README "Known risks").
- Moved keybind registration into its own `spawn` scope inside
  `fn_init.sqf` rather than calling `waitUntil` directly in postInit,
  after finding BI forum reports that postInit's scheduled environment
  can behave close to blocking.

## 0.2.0 - remove CBA_A3 dependency

- Removed the CBA_A3 requirement entirely, after a persistent "requires
  addon CBA_A3" error in testing that didn't resolve with CBA_A3
  installed and enabled.
- Replaced CBA XEH postInit with a vanilla `CfgFunctions` `postInit = 1`
  entry.
- Replaced `CBA_fnc_addKeybind` with `displayAddEventHandler ["KeyDown", ...]`
  and hardcoded DIK keys (Numpad +/-, Shift for fine control) - there's
  no in-game rebind menu without CBA.
- Replaced CBA's `"vehicle"` player event with vanilla config-level
  `GetInMan`/`GetOutMan`/`Killed` EventHandlers declared on `CAManBase`.
- Replaced the CBA settings checkbox with a `profileNamespace` variable,
  settable from the debug console.
- No functional/behavioral change intended vs 0.1.0 otherwise - same
  throttle logic, same HUD, same known risks around negative-speed
  reverse.

## 0.1.0 - initial scaffold

- Percentage-based, set-and-hold throttle for `Ship`-class vehicles,
  driven by `setCruiseControl`.
- Keybinds (unbound by default): ±10% and ±1% throttle steps.
- Bottom-right HUD showing current throttle % (or `REV <pct>%` when
  reversing).
- Negative throttle (-100..100%) for reverse, with a CBA settings
  toggle (`olk_ship_throttle_reverseViaCruiseControl`) to fall back to
  native S/reverse input if the negative-`setCruiseControl` approach
  doesn't hold up in testing - see README "Known risks".
- 0% releases cruise control entirely (coast/drift) rather than
  actively holding station at a dead stop.
- Not yet tested against a live game - see README "Testing checklist".
