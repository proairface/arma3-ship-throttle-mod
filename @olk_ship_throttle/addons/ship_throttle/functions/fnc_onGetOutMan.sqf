/*
 * Author: Olaf
 * Ship Throttle - fnc_onGetOutMan
 *
 * Called when the local player stops being a Ship's driver (got out,
 * changed seat, or died) - either from the watch loop noticing it, or
 * directly from the GetOutMan/Killed EventHandler dispatchers.
 * Idempotent: the "olk_watching" flag makes a second call a no-op, so
 * it's safe for both paths to call this on the same ship.
 *
 * Releases cruise control, zeroes the stored throttle, and hides the
 * HUD.
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
if !(_ship getVariable ["olk_watching", false]) exitWith {};
_ship setVariable ["olk_watching", false];

if (alive _ship) then {
    _ship setCruiseControl [0, false];
};
_ship setVariable ["olk_throttlePct", 0, true];

"olk_ship_throttle" cutText ["", "PLAIN"];
