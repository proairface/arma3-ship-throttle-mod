# Ship Throttle

An [Arma 3](https://arma3.com/) addon that replaces the default
"hold W to accelerate" control scheme for `Ship`-class vehicles (boats,
RHIBs, speedboats, etc.) with a **jet-style, set-and-hold throttle
percentage**: tap a key to step the throttle up or down, the boat
accelerates/holds that speed on its own, and a small HUD readout in the
bottom-right shows the current throttle %.

**Zero dependencies** - no CBA_A3 required. (Earlier builds used CBA for
keybinding/settings/events; that was dropped after a persistent "requires
addon CBA_A3" error in testing that didn't resolve even with CBA_A3
installed and enabled - rather than keep debugging someone else's addon
setup, the mod now only relies on vanilla Arma 3 mechanisms. See
[Design decisions](#design-decisions) for what replaced what, and the
tradeoff this brings back: no in-game rebind menu.)

> ⚠️ **Status: untested against a live game.** This addon was built and
> documented in a sandboxed environment with no access to Arma 3 itself.
> Every scripting API used below was checked against the Bohemia
> Interactive Community wiki (where reachable) or Arma's own documented
> config mechanisms - not against a live client. The packed `.pbo` has
> been verified byte-for-byte (headers, the embedded `prefix`/`author`
> properties, every file's size, and the trailing SHA1 checksum all
> round-trip correctly through an independent reader), so the *file
> format* is sound - but the *behavior* hasn't been driven in-game yet.
> Treat it as "should work" rather than "confirmed working," and go
> through [Testing checklist](#testing-checklist) before relying on it.

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

This repo ships source only (`config.cpp` + `.sqf`), not a packed
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

**W and S are fully repurposed into jet-style throttle steps while
driving a Ship** - not a supplement to native accelerate/brake, a
replacement. Native hold-to-accelerate/brake no longer works on a boat
at all once this addon is active; tap W/S to step the set throttle %
instead, exactly like the brief's jet-throttle reference. W/S behave
completely normally everywhere else (on foot, cars, aircraft,
menus/chat).

Without CBA there's no "Configure Addons" rebind menu, so the keys are
**hardcoded** (in `functions/fn_keyDown.sqf`):

| Action | Key |
|---|---|
| Throttle +10% | W |
| Throttle -10% | S |
| Throttle +1% | Shift + W |
| Throttle -1% | Shift + S |

Holding a key steps once (not once per frame) - see "W/S key-repeat
debounce" below.

To use different keys: edit the `DIK_*` constants in
`functions/fn_keyDown.sqf` and `fn_keyUp.sqf` (see
[`dikCodes.h`](https://github.com/CBATeam/CBA_A3) or the BI wiki's DIK
code table for the full list) and repack.

Keys only do anything while you're in the driver seat of a `Ship`.

## Design decisions

Answers to the brief's open questions, and choices made while building:

- **CBA_A3 dependency**: initially accepted, then **removed**. A
  from-Workshop CBA_A3 install, checked and active in the launcher,
  still produced a persistent "Addon 'olk_ship_throttle' requires addon
  'CBA_A3'" error that didn't resolve through the usual fixes (launch
  method, duplicate-install check). Rather than keep chasing an
  unreproducible environment issue, the addon was rebuilt on vanilla
  Arma 3 mechanisms only - see the replacements below.
- **Reverse handling**: **negative throttle** (-100% to 100%), rather
  than relying only on the native S/reverse key. See
  [Known risks](#known-risks--unverified-assumptions) below - this is
  the least-verified part of the mod, and there's a `profileNamespace`
  toggle to fall back to native-reverse if it doesn't pan out (see
  [Keybinds](#keybinds) note and `fn_setThrottle.sqf`).
- **Throttle step size**: 10% per tap, with Shift held for ±1% fine
  control.
- **Keys: W/S, not a dedicated key** (changed after real-world testing).
  The first build used unbound-by-default dedicated keys (Numpad ±,
  matching the brief's "don't hardcode over existing keys" instinct);
  the actual ask turned out to be "make W/S work like a jet throttle."
  `fn_keyDown.sqf`/`fn_keyUp.sqf` now fully consume W/S while driving a
  Ship - native hold-to-accelerate/brake stops working entirely on
  boats, replaced by discrete steps, same as a real jet/plane throttle.
- **W/S key-repeat debounce**: `KeyDown` fires repeatedly while a key is
  held (engine-level key-repeat, same as a text field), which would
  otherwise spam +10%/frame instead of +10%/tap. `fn_keyDown.sqf` tracks
  currently-held keys (cleared by `fn_keyUp.sqf` on release) so a held
  key steps exactly once.
- **HUD style**: simple structured-text overlay (`"<pct>% ⚙"` /
  `"REV <pct>%"`), bottom-right, shown only while driving a `Ship`. No
  custom art/dialog work - matches the brief's "happy with a simple
  text+icon overlay" fallback option. Pure vanilla `cutRsc`/`RscTitles` -
  never depended on CBA.
- **Idle (0%) behavior**: fully **releases** cruise control
  (`setCruiseControl [0, false]`) rather than actively holding station at
  0 speed (`setCruiseControl [0, true]`). At 0% the hull coasts/drifts
  like a real idling boat, rather than fighting waves/current to stay
  pinned in place. If that feels wrong in testing, swap the branch in
  `functions/fn_setThrottle.sqf`.
- **Vehicle-enter/exit detection**: vanilla config-level `GetInMan` /
  `GetOutMan` / `Killed` EventHandlers declared on `CAManBase` in
  `config.cpp` (fires for every unit; each dispatcher function in
  `functions/fn_on*EH.sqf` filters down to "this is the local player").
  These are genuine native Arma 3 unit EventHandlers, confirmed on the
  BI wiki (`GetOutMan`'s documented signature is
  `[unit, role, vehicle, turret, isEject]`) - **not** CBA player events.
  An earlier build used CBA's `"vehicle"` player event and, before that,
  the brief's proposed `"GetInMan"`/`"GetOutMan"` as if they were CBA
  event names; they aren't (CBA's real player-event list is `unit`,
  `weapon`, `turretWeapon`, `muzzle`, `weaponMode`, `loadout`, `vehicle`,
  `turret`, `featureCamera`, `cameraView`, `visionMode`, `visibleMap`,
  `group`, `leader`) - the *vanilla* engine-level `GetInMan`/`GetOutMan`
  EventHandlers the brief was actually thinking of are real, just not
  reachable through CBA's player-event wrapper.
- **Init/keybind registration without CBA XEH**: a `CfgFunctions` entry
  with `postInit = 1` (a vanilla mechanism, not CBA-specific) runs once
  at mission start and registers a `displayAddEventHandler ["KeyDown", ...]`
  handler on `findDisplay 46` - the standard pre-CBA technique for a
  global hotkey. It runs inside its own `spawn` scope rather than
  directly in postInit, since postInit's environment is scheduled but
  reportedly close to blocking (BI forums note a `waitUntil` placed
  directly in postInit can stall mission loading in some cases) -
  spawning first means postInit itself returns immediately either way.
- **Entry-detection watchdog (defense-in-depth)**: `fn_init.sqf` also
  spawns a 1s polling loop that starts throttle tracking the moment it
  finds the local player driving a Ship, independent of whether the
  `getInMan` EventHandler fired. This exists because of a real bug this
  project shipped once already (see the note below) - it means a similar
  future mistake fails soft (control starts up to ~1s late) instead of
  silently doing nothing.

## Known risks / unverified assumptions

Carried over from the original brief, plus what this build added:

- ⚠️ **UNVERIFIED - reverse via negative `setCruiseControl` speed.** The
  BI wiki only documents `setCruiseControl`'s speed parameter for
  positive km/h values; there's no documented negative-speed/reverse
  behavior, and secondhand reports found while researching this were
  inconclusive (one summary suggested a negative value might just
  prevent forward movement rather than reverse it - unconfirmed either
  way). **Test this first** (see checklist below). If it doesn't work as
  hoped, run `profileNamespace setVariable ["olk_ship_throttle_reverseViaCruiseControl", false]; saveProfileNamespace;`
  in the debug console - reverse throttle then just releases cruise
  control and expects the player to back up with the native S key, same
  as the brief's non-negative-throttle alternative.
- 🐛 **FIXED (was a real bug, not just a risk) - config EventHandlers
  need the exact literal event name.** The first zero-dependency build
  registered `class EventHandlers { olk_ship_throttle_getInMan = "..."; }`
  on `CAManBase`, thinking an addon-prefixed name kept it collision-safe
  the way CBA's XEH does. It doesn't: vanilla config EventHandlers
  dispatch strictly by the literal recognized name (`getInMan`,
  `getOutMan`, `killed`, ...) - an unrecognized property name is just an
  inert config value, never fires, and produces no error. That's why the
  mod loaded clean but did nothing at all. Fixed by using the literal
  names. The real tradeoff this brings back: without XEH, only one
  handler per event name is allowed per class - if you ever add another
  non-CBA addon that also defines `getInMan`/`getOutMan`/`killed` on
  `CAManBase`, whichever loads last silently wins.
- ⚠️ **ASSUMPTION - `GetInMan`'s argument order.** Assumed to mirror the
  BI wiki's documented `GetOutMan` order (`unit, role, vehicle, turret`)
  since `GetInMan` itself wasn't directly documented in what was
  reachable during research. `fn_onGetInManEH.sqf` only trusts `_unit`
  and `_vehicle` from this (verifying the driver seat directly via the
  `driver` command rather than the reported role string), and the
  postInit watchdog above is an independent fallback in case this
  argument order - or anything else about this specific handler - turns
  out to be wrong. If the HUD still never appears, add a `diag_log` at
  the top of `fn_onGetInManEH.sqf` to see what arguments actually
  arrive.
- ⚠️ **ASSUMPTION - `maxSpeed` as the 100% ceiling.** Throttle % maps to
  target speed via `(pct / 100) * maxSpeed` from the vehicle's
  `CfgVehicles` config. `maxSpeed` is a standard AI-driving attribute,
  not guaranteed to be an accurate top-speed ceiling for every
  vanilla/modded boat. Test against at least two differently-sized boats
  (checklist item 6).
- ⚠️ **ASSUMPTION (now largely moot) - brake cancels cruise control on
  boats.** The BI wiki states applying brakes disables Cruise Control,
  but its only worked example is a car. The watch loop in
  `fn_onGetInMan.sqf` resets the throttle to 0% if it detects
  `getCruiseControl` silently went to `autoThrust = false` while a
  nonzero throttle was still stored. Since S is now fully consumed by
  `fn_keyDown.sqf` instead of reaching the vehicle as a native brake
  input, the player can no longer trigger this path directly - the
  check is kept as a defensive fallback for any other way cruise
  control might get silently disabled (collision, damage, another mod).
- ⚠️ **UNTESTED - multiplayer locality.** `setCruiseControl` is
  documented as operating on the *local* player's vehicle, so this
  should be inherently per-client with no sync needed - but that's only
  confirmed by reading the docs, not by an actual dedicated-server +
  2-client test (checklist item 7).
- Boat runs aground / collides: the throttle value persists as
  "commanded" even though actual speed drops - this mirrors real
  throttle behavior and is intentional, not a bug.

## Testing checklist

1. Enter a vanilla RHIB as driver; confirm the throttle HUD appears at
   0% and the hull coasts/drifts rather than being held rigidly in
   place. (This alone confirms the `GetInMan` assumption above holds.)
2. Increase throttle to 50% (Numpad +); confirm the boat accelerates on
   its own without holding W, and roughly holds a mid-range speed.
3. Increase to 100%; compare against the boat's known/observed top speed
   to sanity-check the `maxSpeed` assumption.
4. **Decrease throttle below 0% (reverse, Numpad -).** This is the
   biggest unknown in the mod - confirm the boat actually backs up. If
   it doesn't (or behaves oddly, e.g. refuses to move forward again
   afterwards), set the `profileNamespace` toggle mentioned above and
   re-test - reverse should then just release cruise control and expect
   native S input.
5. Tap S (brake); confirm cruise control disengages and the HUD/throttle
   resets to 0%.
6. Exit the vehicle mid-throttle, re-enter as driver; confirm it comes
   back in a clean 0% state rather than resuming the old value.
7. Switch from driver to a gunner/cargo seat *without* exiting the
   vehicle; confirm the HUD hides and cruise control releases (should be
   immediate via `GetOutMan`, or within ~0.5s via the watch loop as a
   fallback).
8. Repeat steps 1-4 on a second, differently-sized boat class to catch
   per-class `maxSpeed` weirdness.
9. Basic MP test (2 clients, ideally a dedicated server) to confirm no
   desync/host-authority issues.

## Repository layout

```
@olk_ship_throttle/
├── mod.cpp
└── addons/
    └── ship_throttle/
        ├── $PBOPREFIX$
        ├── config.cpp          - CfgFunctions, CAManBase EventHandlers, RscTitles include
        ├── functions/
        │   ├── fn_init.sqf            - postInit=1, registers KeyDown/KeyUp handlers
        │   ├── fn_keyDown.sqf         - W/S hijack -> adjustThrottle (debounced)
        │   ├── fn_keyUp.sqf           - clears the key-repeat debounce tracker
        │   ├── fn_setThrottle.sqf     - drives setCruiseControl
        │   ├── fn_adjustThrottle.sqf  - +/- delta from a keypress
        │   ├── fn_onGetInManEH.sqf    - GetInMan EH dispatcher (filters to local player)
        │   ├── fn_onGetOutManEH.sqf   - GetOutMan EH dispatcher
        │   ├── fn_onKilledEH.sqf      - Killed EH dispatcher
        │   ├── fn_onGetInMan.sqf      - init state, show HUD, start watch loop
        │   ├── fn_onGetOutMan.sqf     - release control, hide HUD
        │   └── fn_updateHud.sqf       - repaint the HUD text
        └── ui/
            └── RscTitles.hpp   - the HUD dialog resource
```

## Non-goals

Per the original brief: this does not redo the jet HUD's look, does not
touch ground vehicles or aircraft, and does not attempt full engine
simulation (RPM, fuel burn curves, etc.) - just a usable, persistent
throttle percentage for ships.

## License

MIT - see [LICENSE](LICENSE).
