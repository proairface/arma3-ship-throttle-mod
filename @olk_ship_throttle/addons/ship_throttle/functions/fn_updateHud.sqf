/*
 * Author: Olaf
 * Ship Throttle - fnc_updateHud
 *
 * Refreshes the throttle HUD text. Called only on throttle-change events
 * (including once, automatically, when the HUD resource first loads) -
 * there's no live engine RPM to poll here, so this is never run on a
 * per-frame timer.
 *
 * Arguments:
 * 0: Ship <OBJECT>
 * 1: Throttle percentage <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_ship", "_pct"];

private _display = uiNamespace getVariable ["olk_ship_throttle_display", displayNull];
if (isNull _display) exitWith {};

private _ctrl = _display displayCtrl 62100;
if (isNull _ctrl) exitWith {};

// 0-100 only - see fn_setThrottle.sqf for why there's no negative/reverse
// throttle anymore.
private _label = format ["<t align='center'>%1%% ⚙</t>", round _pct];

_ctrl ctrlSetStructuredText parseText _label;
