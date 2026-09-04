# Changelog

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
