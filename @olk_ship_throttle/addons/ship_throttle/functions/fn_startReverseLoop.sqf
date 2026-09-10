/*
 * Author: Olaf
 * Ship Throttle - fnc_startReverseLoop
 *
 * Drives reverse motion via a scripted velocity loop, since a negative
 * setCruiseControl speed does not reverse a ship (confirmed in real
 * testing - see fn_setThrottle.sqf). Idempotent: a second call while
 * already reversing is a no-op, since the loop itself reads the
 * current throttle percentage fresh every tick rather than capturing
 * it once.
 *
 * Every 0.05s while the local player is still driving this ship with a
 * negative throttle: computes the ship's horizontal forward direction,
 * and sets its velocity to move opposite that direction at a speed
 * proportional to |throttle%| of maxSpeed - preserving the existing
 * vertical velocity component so wave bobbing isn't fought. Stops
 * itself (and lets fn_setThrottle.sqf's normal forward/idle branch take
 * back over) the moment throttle is no longer negative, the driver
 * changes, or the ship is gone.
 *
 * Arguments:
 * 0: Ship <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_ship"];

if (isNull _ship) exitWith {};
if (_ship getVariable ["olk_reversing", false]) exitWith {};
_ship setVariable ["olk_reversing", true];

[_ship] spawn {
    params ["_ship"];

    while {
        !isNull _ship && {alive _ship} && {vehicle player == _ship} && {driver _ship == player} && {(_ship getVariable ["olk_throttlePct", 0]) < 0}
    } do {
        private _pct = _ship getVariable ["olk_throttlePct", 0];
        private _maxSpeed = getNumber (configFile >> "CfgVehicles" >> typeOf _ship >> "maxSpeed");
        private _reverseSpeedMS = (abs(_pct) / 100) * (_maxSpeed / 3.6);

        private _fwd = vectorDir _ship;
        private _horizFwd = vectorNormalized [_fwd select 0, _fwd select 1, 0];
        private _curVel = velocity _ship;
        private _newVel = (_horizFwd vectorMultiply (-_reverseSpeedMS)) vectorAdd [0, 0, (_curVel select 2)];

        _ship setVelocity _newVel;

        sleep 0.05;
    };

    if (!isNull _ship) then {
        _ship setVariable ["olk_reversing", false];
    };
};
