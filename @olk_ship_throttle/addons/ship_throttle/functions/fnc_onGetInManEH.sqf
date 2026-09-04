/*
 * Author: Olaf
 * Ship Throttle - fnc_onGetInManEH
 *
 * Dispatcher for the vanilla config-level "getInMan" EventHandler
 * (declared on CAManBase in config.cpp), which fires for every unit.
 * Filters down to "the local player just became a Ship's driver" and
 * hands off to fnc_onGetInMan.
 *
 * Checks the driver seat directly via the `driver` command rather than
 * trusting the EH's own reported role string, since GetInMan's exact
 * argument order wasn't directly confirmed (assumed to mirror the BI
 * wiki's documented GetOutMan order: unit, role, vehicle, turret) -
 * see README.md "Known risks". This function only needs _unit and
 * _vehicle to be right, not _role.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Role (assumed) <STRING>
 * 2: Vehicle (assumed) <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_role", "_vehicle"];

if (_unit != player) exitWith {};
if !(_vehicle isKindOf "Ship") exitWith {};
if (driver _vehicle != _unit) exitWith {};

[_vehicle] call olk_fnc_onGetInMan;
