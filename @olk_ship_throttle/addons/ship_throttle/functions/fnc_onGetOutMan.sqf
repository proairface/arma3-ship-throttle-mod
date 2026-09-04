/*
 * Author: Olaf
 * Ship Throttle - fnc_onGetOutMan
 *
 * Called when the local player stops being a Ship's driver (got out,
 * changed seat, or died). Releases cruise control, zeroes the stored
 * throttle, stops the watch loop, and hides the HUD.
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

private _handle = _ship getVariable ["olk_watchHandle", -1];
if (_handle != -1) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    _ship setVariable ["olk_watchHandle", -1];
};

if (alive _ship) then {
    _ship setCruiseControl [0, false];
};
_ship setVariable ["olk_throttlePct", 0, true];

"olk_ship_throttle" cutText ["", "PLAIN"];
