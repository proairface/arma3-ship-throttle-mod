# Changelog

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
