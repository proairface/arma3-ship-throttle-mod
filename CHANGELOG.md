# Changelog

## 0.2.1 - fix: config EventHandlers never actually fired

- **Bug fix**: 0.2.0's `config.cpp` registered the `getInMan`/`getOutMan`/
  `killed` EventHandlers on `CAManBase` under addon-prefixed property
  names (e.g. `olk_ship_throttle_getInMan`), thinking that made them
  collision-safe. Vanilla config EventHandlers dispatch strictly by the
  literal recognized name - an unrecognized property name is inert and
  never fires, with no error. This is why the mod loaded without errors
  but never actually did anything (reported by real-world testing).
  Fixed by using the literal `getInMan`/`getOutMan`/`killed` names.
- Added a 1s postInit watchdog (`fnc_init.sqf`) that starts throttle
  tracking as soon as the local player is found driving a Ship,
  independent of whether the EventHandlers above fire - defense in
  depth against a repeat of the same class of bug.
- Hardened `fnc_onGetInManEH.sqf` to verify the driver seat via the
  `driver` command directly rather than trusting `GetInMan`'s reported
  role string, since that argument order is still an unconfirmed
  assumption (see README "Known risks").
- Moved keybind registration into its own `spawn` scope inside
  `fnc_init.sqf` rather than calling `waitUntil` directly in postInit,
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
