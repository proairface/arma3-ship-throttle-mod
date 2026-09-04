/*
 * Author: Olaf
 * Ship Throttle - fnc_setThrottle
 *
 * Applies (or releases) cruise control on a ship to reach a target
 * throttle percentage. Only call this on a throttle-change event, never
 * every frame - each call resets the vehicle's cruise-control PID
 * controller (BI wiki: setCruiseControl).
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

if (_pct == 0) then {
    // Idle: fully release cruise control so the hull coasts/drifts on its
    // own, rather than actively station-keeping at a dead stop. See
    // README.md "Design decisions" for why this was picked over the
    // alternative (setCruiseControl [0, true]).
    _ship setCruiseControl [0, false];
} else {
    // No CBA settings UI in the zero-dependency build - toggle this from
    // the debug console instead:
    //   profileNamespace setVariable ["olk_ship_throttle_reverseViaCruiseControl", false];
    //   saveProfileNamespace;
    private _reverseViaCruiseControl = profileNamespace getVariable ["olk_ship_throttle_reverseViaCruiseControl", true];

    if (_pct < 0 && {!_reverseViaCruiseControl}) then {
        // Fallback reverse mode: release control and let the player back
        // up with the native S/reverse input instead of trusting a
        // negative setCruiseControl speed. See README.md "Known risks".
        _ship setCruiseControl [0, false];
    } else {
        private _maxSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _ship >> "maxSpeed");

        // UNVERIFIED (negative branch only): setCruiseControl's speed
        // parameter is documented on the BI wiki only for positive km/h
        // values. A negative target speed here (used for reverse) has not
        // been confirmed against a live game - see README.md "Known risks".
        private _targetSpeed = _maxSpeed * (_pct / 100);
        _ship setCruiseControl [_targetSpeed, true];
    };
};

[_ship, _pct] call olk_fnc_updateHud;

_pct
