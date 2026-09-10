/*
 * Author: Olaf
 * Ship Throttle - fnc_setThrottle
 *
 * Applies (or releases) propulsion on a ship to reach a target throttle
 * percentage. Only call this on a throttle-change event, never every
 * frame - repeatedly calling setCruiseControl resets the vehicle's PID
 * controller (BI wiki).
 *
 * Forward/idle (pct >= 0) uses native setCruiseControl. Reverse
 * (pct < 0) does NOT - confirmed in real-game testing that a negative
 * setCruiseControl speed does not reverse the vehicle (the BI wiki only
 * ever documented positive values here, and this was flagged as the
 * mod's single biggest unverified risk from the start). Reverse is
 * instead driven by a scripted velocity loop (fn_startReverseLoop.sqf) -
 * the "release control, let the player use native S" fallback this
 * addon originally had for that case no longer applies either, since
 * S is now fully consumed by fn_keyDown.sqf for throttle-down, not
 * available as a native reverse input anymore.
 *
 * Arguments:
 * 0: Ship <OBJECT>
 * 1: Throttle percentage, clamped to -100..100 <NUMBER>
 *
 * Return Value:
 * New throttle percentage <NUMBER>
 *
 * Public: No
 */

params ["_ship", ["_pct", 0]];

if (isNull _ship) exitWith {0};

_pct = (_pct min 100) max -100;
_ship setVariable ["olk_throttlePct", _pct, true];

if (_pct >= 0) then {
    if (_pct == 0) then {
        // Idle: fully release cruise control so the hull coasts/drifts
        // on its own, rather than actively station-keeping at a dead
        // stop. See README.md "Design decisions" for why this was
        // picked over the alternative (setCruiseControl [0, true]).
        _ship setCruiseControl [0, false];
    } else {
        // The engine has to be explicitly running before
        // setCruiseControl has any visible effect - confirmed in real
        // testing that it doesn't turn the engine on by itself. Also
        // done once in fn_onGetInMan.sqf, but harmless/cheap to ensure
        // here too in case the engine got switched off some other way.
        _ship engineOn true;

        private _maxSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _ship >> "maxSpeed");
        private _targetSpeed = _maxSpeed * (_pct / 100);
        _ship setCruiseControl [_targetSpeed, true];
    };
} else {
    _ship setCruiseControl [0, false];
    _ship engineOn true;
    [_ship] call olk_fnc_startReverseLoop;
};

[_ship, _pct] call olk_fnc_updateHud;

_pct
