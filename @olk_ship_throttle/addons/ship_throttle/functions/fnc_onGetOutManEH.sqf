/*
 * Author: Olaf
 * Ship Throttle - fnc_onGetOutManEH
 *
 * Dispatcher for the vanilla config-level "GetOutMan" EventHandler
 * (declared on CAManBase in config.cpp), which fires for every unit.
 * Filters down to "the local player just left a Ship" (any seat, not
 * just driver - fnc_onGetOutMan is idempotent/harmless if the ship
 * wasn't under our management) and hands off to fnc_onGetOutMan.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Role <STRING>
 * 2: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_role", "_vehicle"];

if (_unit != player) exitWith {};
if !(_vehicle isKindOf "Ship") exitWith {};

[_vehicle] call olk_fnc_onGetOutMan;
