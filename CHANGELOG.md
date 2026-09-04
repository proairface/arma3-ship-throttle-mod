# Changelog

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
