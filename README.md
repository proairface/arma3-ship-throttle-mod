# Ship Throttle

An [Arma 3](https://arma3.com/) addon that replaces the default
"hold W to accelerate" control scheme for `Ship`-class vehicles (boats,
RHIBs, speedboats, etc.) with a **jet-style, set-and-hold throttle
percentage**: tap a key to step the throttle up or down, the boat
accelerates/holds that speed on its own, and a small HUD readout in the
bottom-right shows the current throttle %.

> ⚠️ **Status: untested against a live game.** This addon was built and
> documented in a sandboxed environment with no access to Arma 3 itself.
> Every scripting API used below was checked against CBA_A3's own source
> and (where reachable) the Bohemia Interactive Community wiki. The
> packed `.pbo` has been verified byte-for-byte (headers, the embedded
> `prefix`/`author` properties, every file's size, and the trailing
> SHA1 checksum all round-trip correctly through an independent reader),
> so the *file format* is sound - but nothing here has actually been
> loaded and driven in-game. Treat it as "should work" rather than
> "confirmed working," and go through
> [Testing checklist](#testing-checklist) before relying on it.

## Requirements

- Arma 3 **v2.06+** (for `setCruiseControl`)
- [CBA_A3](https://github.com/CBATeam/CBA_A3) (for keybinding, settings,
  and player-vehicle-change events)

## Installation

1. Build the PBO (see [Building](#building) below) so you have
   `@olk_ship_throttle/addons/ship_throttle.pbo`.
2. Drop the whole `@olk_ship_throttle` folder next to your other Arma 3
   mod folders (e.g. in your Arma 3 installation directory, or wherever
   you keep workshop/manually-installed mods).
3. Enable both `@CBA_A3` and `@olk_ship_throttle` in the Arma 3 launcher.

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

All keybinds are **unbound by default** (per the original brief - don't
hardcode over a player's existing keys). Bind them yourself in
**Arma 3 Options → Controls → Configure Addons → Ship Throttle**:

| Action | Default step |
|---|---|
| Increase Ship Throttle | +10% |
| Decrease Ship Throttle | -10% |
| Increase Ship Throttle, fine | +1% |
| Decrease Ship Throttle, fine | -1% |

Keys only do anything while you're in the driver seat of a `Ship`.

## Design decisions

Answers to the brief's open questions, and choices made while building:

- **CBA_A3 dependency**: accepted. Keeps keybinding, settings, and
  vehicle-change detection simple and standard.
- **Reverse handling**: **negative throttle** (-100% to 100%), rather
  than relying only on the native S/reverse key. See
  [Known risks](#known-risks--unverified-assumptions) below - this is
  the least-verified part of the mod, and there's a settings toggle to
  fall back to native-reverse if it doesn't pan out.
- **Throttle step size**: 10% per tap, with a Shift-free "fine" pair of
  keybinds for ±1% (bound separately, not a modifier key, to avoid
  fighting CBA's own modifier handling on hold-vs-tap keybinds).
- **HUD style**: simple structured-text overlay (`"<pct>% ⚙"` /
  `"REV <pct>%"`), bottom-right, shown only while driving a `Ship`. No
  custom art/dialog work - matches the brief's "happy with a simple
  text+icon overlay" fallback option.
- **Idle (0%) behavior**: fully **releases** cruise control
  (`setCruiseControl [0, false]`) rather than actively holding station at
  0 speed (`setCruiseControl [0, true]`). At 0% the hull coasts/drifts
  like a real idling boat, rather than fighting waves/current to stay
  pinned in place. If that feels wrong in testing, swap the branch in
  `functions/fnc_setThrottle.sqf`.
- **Vehicle-enter/exit detection**: uses CBA's `"vehicle"` player event
  (`CBA_fnc_addPlayerEventHandler`), **not** `"GetInMan"`/`"GetOutMan"` as
  the original brief suggested - those aren't real CBA player event
  names (verified against CBA_A3's current source and wiki; the actual
  event list is `unit`, `weapon`, `turretWeapon`, `muzzle`, `weaponMode`,
  `loadout`, `vehicle`, `turret`, `featureCamera`, `cameraView`,
  `visionMode`, `visibleMap`, `group`, `leader`). `"vehicle"` fires
  whenever the player's occupied vehicle changes and covers both getting
  in and out; a driver-to-gunner seat switch within the *same* vehicle
  doesn't fire it, so that case is instead caught by a 0.5s watch loop
  (see below).

## Known risks / unverified assumptions

Carried over from the original brief, plus what this build added:

- ⚠️ **UNVERIFIED - reverse via negative `setCruiseControl` speed.** The
  BI wiki only documents `setCruiseControl`'s speed parameter for
  positive km/h values; there's no documented negative-speed/reverse
  behavior, and secondhand reports found while researching this were
  inconclusive (one summary suggested a negative value might just
  prevent forward movement rather than reverse it - unconfirmed either
  way). **Test this first** (see checklist below). If it doesn't work as
  hoped, flip the `olk_ship_throttle_reverseViaCruiseControl` CBA
  setting off (Arma 3 Options → General → Configure Addons → Ship
  Throttle) - reverse throttle then just releases cruise control and
  expects the player to back up with the native S key, same as the
  brief's non-negative-throttle alternative.
- ⚠️ **ASSUMPTION - `maxSpeed` as the 100% ceiling.** Throttle % maps to
  target speed via `(pct / 100) * maxSpeed` from the vehicle's
  `CfgVehicles` config. `maxSpeed` is a standard AI-driving attribute,
  not guaranteed to be an accurate top-speed ceiling for every
  vanilla/modded boat. Test against at least two differently-sized boats
  (checklist item 6).
- ⚠️ **ASSUMPTION - brake cancels cruise control on boats.** The BI wiki
  states applying brakes disables Cruise Control, but its only worked
  example is a car. The watch loop in `fnc_onGetInMan.sqf` assumes the
  same holds for ships and resets the throttle to 0% when it detects
  `getCruiseControl` silently went to `autoThrust = false` while a
  nonzero throttle was still stored.
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
   place.
2. Increase throttle to 50%; confirm the boat accelerates on its own
   without holding W, and roughly holds a mid-range speed.
3. Increase to 100%; compare against the boat's known/observed top speed
   to sanity-check the `maxSpeed` assumption.
4. **Decrease throttle below 0% (reverse).** This is the biggest unknown
   in the mod - confirm the boat actually backs up. If it doesn't (or
   behaves oddly, e.g. refuses to move forward again afterwards), turn
   off "Reverse via setCruiseControl" in the addon's CBA settings and
   re-test - reverse should then just release cruise control and expect
   native S input.
5. Tap S (brake); confirm cruise control disengages and the HUD/throttle
   resets to 0%.
6. Exit the vehicle mid-throttle, re-enter as driver; confirm it comes
   back in a clean 0% state rather than resuming the old value.
7. Switch from driver to a gunner/cargo seat *without* exiting the
   vehicle; confirm the HUD hides and cruise control releases within
   ~0.5s (the watch-loop interval).
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
        ├── config.cpp
        ├── XEH_preInit.sqf     - registers the CBA reverse-mode setting
        ├── XEH_postInit.sqf    - registers the "vehicle" event + keybinds
        ├── functions/
        │   ├── fnc_setThrottle.sqf     - drives setCruiseControl
        │   ├── fnc_adjustThrottle.sqf  - +/- delta from a keybind
        │   ├── fnc_onGetInMan.sqf      - init state, show HUD, start watch loop
        │   ├── fnc_onGetOutMan.sqf     - release control, hide HUD
        │   └── fnc_updateHud.sqf       - repaint the HUD text
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
