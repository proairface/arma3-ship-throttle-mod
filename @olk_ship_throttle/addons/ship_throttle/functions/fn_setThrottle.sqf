/*
 * Author: Olaf
 * Ship Throttle - fnc_setThrottle
 *
 * Applies (or releases) cruise control on a ship to reach a target
 * throttle percentage, clamped to 0-100%. Only call this on a
 * throttle-change event, never every frame - repeatedly calling
 * setCruiseControl resets the vehicle's PID controller (BI wiki).
 *
 * Range is 0-100% only - no negative/reverse throttle. Earlier builds
 * tried negative throttle driven by a scripted velocity loop, since
 * setCruiseControl's speed parameter doesn't reverse a ship; real-world
 * feedback found that whole approach (plus the W/S key hijack it
 * required) clunky. Reverting to plain W/S for native
 * accelerate/brake/reverse (see fn_keyDown.sqf) and letting the throttle
 * only ever add *forward* cruise control on top of that is simpler and
 * leans on the vehicle's own well-tested physics instead of custom
 * scripted velocity manipulation.
 *
 * Arguments:
 * 0: Ship <OBJECT>
 * 1: Throttle percentage, clamped to 0-100 <NUMBER>
 *
 * Return Value:
 * New throttle percentage <NUMBER>
 *
 * Public: No
 */

params ["_ship", ["_pct", 0]];

if (isNull _ship) exitWith {0};

_pct = (_pct min 100) max 0;
_ship setVariable ["olk_throttlePct", _pct, true];

if (_pct == 0) then {
    // Idle: fully release cruise control so the hull coasts/drifts on its
    // own, rather than actively station-keeping at a dead stop. See
    // README.md "Design decisions" for why this was picked over the
    // alternative (setCruiseControl [0, true]).
    _ship setCruiseControl [0, false];
} else {
    // The engine has to be explicitly running before setCruiseControl
    // has any visible effect - confirmed in real testing that it
    // doesn't turn the engine on by itself. Also done once in
    // fn_onGetInMan.sqf, but harmless/cheap to ensure here too in case
    // the engine got switched off some other way.
    _ship engineOn true;

    private _maxSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _ship >> "maxSpeed");
    private _targetSpeed = _maxSpeed * (_pct / 100);
    _ship setCruiseControl [_targetSpeed, true];
};

[_ship, _pct] call olk_fnc_updateHud;

_pct
