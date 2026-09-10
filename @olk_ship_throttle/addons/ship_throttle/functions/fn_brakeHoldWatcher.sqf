#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_brakeHoldWatcher
 *
 * Started by fn_keyDown.sqf on every fresh S press. Waits 0.3s, then
 * starts continuous active braking (fn_startBrakeLoop.sqf) only if S
 * is still physically held at that point - a quicker release is a tap,
 * handled instead by fn_keyUp.sqf's normal -10%/-1% step.
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

sleep 0.3;

private _stillHeld = DIK_S in (missionNamespace getVariable ["olk_ship_throttle_heldKeys", []]);
if (_stillHeld && {!isNull _ship} && {vehicle player == _ship} && {driver _ship == player}) then {
    [_ship] call olk_fnc_startBrakeLoop;
};
