/*
 * Author: Olaf
 * Ship Throttle - fnc_startBrakeLoop
 *
 * Continuous active braking while S is held past the 0.3s hold
 * threshold (fn_brakeHoldWatcher.sqf) - restores a "hold S to brake"
 * feel that stepping the throttle alone couldn't give, since W/S fully
 * replaced native accelerate/brake input on ships (see fn_keyDown.sqf).
 *
 * Fully releases cruise control for the whole hold and directly damps
 * the ship's velocity every 0.15s, instead of repeatedly retargeting
 * setCruiseControl to lower speeds - retargeting alone would just have
 * cruise control's own PID fight/mask the deceleration, since it
 * continuously tries to reach whatever target speed was last set. The
 * *stored* throttle % is walked down in step (for the HUD, and so
 * releasing S resumes from a sensible value) without calling
 * fn_setThrottle.sqf until the hold ends - at that point one clean call
 * hands off to normal forward/idle/reverse handling at wherever the
 * throttle landed.
 *
 * Idempotent: a second call while already braking is a no-op.
 *
 * ⚠️ UNVERIFIED (this whole mechanism is new, untested in a live game):
 * the 0.85 decay factor per 0.15s tick was chosen to feel brisk without
 * being jarring, but hasn't actually been driven in-game. Tune to taste
 * if it feels too weak or too sudden.
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
if (_ship getVariable ["olk_braking", false]) exitWith {};
_ship setVariable ["olk_braking", true];

_ship setCruiseControl [0, false];

[_ship] spawn {
    params ["_ship"];

    while {
        !isNull _ship && {alive _ship} && {vehicle player == _ship} && {driver _ship == player} && {_ship getVariable ["olk_braking", false]}
    } do {
        private _vel = velocity _ship;
        _ship setVelocity (_vel vectorMultiply 0.85);

        private _pct = _ship getVariable ["olk_throttlePct", 0];
        private _newPct = (_pct - 10) max -100;
        _ship setVariable ["olk_throttlePct", _newPct, true];
        [_ship, _newPct] call olk_fnc_updateHud;

        sleep 0.15;
    };

    _ship setVariable ["olk_braking", false];

    if (!isNull _ship && {alive _ship}) then {
        [_ship, (_ship getVariable ["olk_throttlePct", 0])] call olk_fnc_setThrottle;
    };
};
