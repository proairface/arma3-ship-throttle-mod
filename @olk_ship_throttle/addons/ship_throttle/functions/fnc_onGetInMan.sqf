/*
 * Author: Olaf
 * Ship Throttle - fnc_onGetInMan
 *
 * Called when the local player becomes a Ship's driver. Resets the
 * throttle to a clean 0%, shows the throttle HUD, and starts a
 * low-frequency watch loop (a scheduled `spawn` + `sleep`, the vanilla
 * equivalent of a per-frame handler) that:
 *  - detects the player leaving the driver seat (seat change, exiting,
 *    death) and hands off to fnc_onGetOutMan;
 *  - detects the vehicle's native brake/S input silently cancelling
 *    cruise control, and resets the stored throttle to 0 so the HUD
 *    doesn't show a stale value (BI wiki: "applying brakes disables
 *    Cruise Control" - ASSUMPTION, not confirmed for boats specifically,
 *    see README.md "Known risks").
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

[_ship, 0] call olk_fnc_setThrottle;

"olk_ship_throttle" cutRsc ["olk_ship_throttle_hud", "PLAIN"];

[_ship] spawn {
    params ["_ship"];

    while {
        !isNull _ship && {alive _ship} && {vehicle player == _ship} && {driver _ship == player}
    } do {
        private _pct = _ship getVariable ["olk_throttlePct", 0];
        if (_pct != 0) then {
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
