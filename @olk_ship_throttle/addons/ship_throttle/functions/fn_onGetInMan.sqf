/*
 * Author: Olaf
 * Ship Throttle - fnc_onGetInMan
 *
 * Called when the local player becomes a Ship's driver. Starts the
 * engine, resets the throttle to a clean 0%, shows the throttle HUD,
 * and starts a low-frequency watch loop (a scheduled `spawn` + `sleep`,
 * the vanilla equivalent of a per-frame handler) that:
 *  - detects the player leaving the driver seat (seat change, exiting,
 *    death) and hands off to fnc_onGetOutMan;
 *  - detects cruise control silently getting cancelled some other way
 *    while throttle is positive, and resets the stored throttle to 0
 *    so the HUD doesn't show a stale value. Only checked for *positive*
 *    throttle and only while *not* actively braking - during reverse
 *    (fn_startReverseLoop.sqf) and active braking
 *    (fn_startBrakeLoop.sqf), cruise control is deliberately
 *    released/off, so autoThrust==false is expected there, not an
 *    unexpected cancellation.
 *
 * The watch loop only *reads* getCruiseControl - it never calls
 * setCruiseControl on a timer, since that would repeatedly reset the
 * vehicle's PID controller.
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
if (_ship getVariable ["olk_watching", false]) exitWith {};
_ship setVariable ["olk_watching", true];

// The engine doesn't start itself just because cruise control is set -
// confirmed in real testing (throttle % would climb with no actual
// movement until the engine was turned on).
_ship engineOn true;

[_ship, 0] call olk_fnc_setThrottle;

"olk_ship_throttle" cutRsc ["olk_ship_throttle_hud", "PLAIN"];

[_ship] spawn {
    params ["_ship"];

    while {
        !isNull _ship && {alive _ship} && {vehicle player == _ship} && {driver _ship == player}
    } do {
        private _pct = _ship getVariable ["olk_throttlePct", 0];
        if (_pct > 0 && {!(_ship getVariable ["olk_braking", false])}) then {
            (getCruiseControl _ship) params ["", "_autoThrust"];
            if (!_autoThrust) then {
                [_ship, 0] call olk_fnc_setThrottle;
            };
        };
        sleep 0.5;
    };

    if (!isNull _ship) then {
        [_ship] call olk_fnc_onGetOutMan;
    };
};
