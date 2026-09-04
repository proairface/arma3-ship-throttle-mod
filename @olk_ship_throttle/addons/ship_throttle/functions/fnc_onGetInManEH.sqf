/*
 * Author: Olaf
 * Ship Throttle - fnc_onGetInManEH
 *
 * Dispatcher for the vanilla config-level "GetInMan" EventHandler
 * (declared on CAManBase in config.cpp), which fires for every unit.
 * Filters down to "the local player just became a Ship's driver" and
 * hands off to fnc_onGetInMan.
 *
 * ASSUMPTION: GetInMan's argument order is assumed to mirror the BI
 * wiki's documented GetOutMan order (unit, role, vehicle, turret, ...) -
 * this specific event's own argument order was not directly confirmed
 * against the wiki. See README.md "Known risks".
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Role ("driver"/"gunner"/"commander"/"cargo") <STRING>
 * 2: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_role", "_vehicle"];

if (_unit != player) exitWith {};
if (_role != "driver") exitWith {};
if !(_vehicle isKindOf "Ship") exitWith {};

[_vehicle] call olk_fnc_onGetInMan;
