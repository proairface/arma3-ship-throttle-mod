/*
 * Author: Olaf
 * Ship Throttle - fnc_onKilledEH
 *
 * Dispatcher for the vanilla config-level "Killed" EventHandler
 * (declared on CAManBase in config.cpp). Filters down to the local
 * player dying while driving a Ship, and releases control the same way
 * fnc_onGetOutMan does.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit"];

if (_unit != player) exitWith {};

private _veh = vehicle _unit;
if (_veh isKindOf "Ship") then {
    [_veh] call olk_fnc_onGetOutMan;
};
