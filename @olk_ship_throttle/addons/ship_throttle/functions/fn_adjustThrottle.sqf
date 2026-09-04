/*
 * Author: Olaf
 * Ship Throttle - fnc_adjustThrottle
 *
 * Steps the local player's current ship throttle by a delta and applies
 * it. No-op if the player isn't currently driving a Ship.
 *
 * Arguments:
 * 0: Delta to apply to the current throttle percentage <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_delta", 0]];

private _ship = vehicle player;

if !(_ship isKindOf "Ship" && {driver _ship == player}) exitWith {};

private _current = _ship getVariable ["olk_throttlePct", 0];
[_ship, _current + _delta] call olk_fnc_setThrottle;
