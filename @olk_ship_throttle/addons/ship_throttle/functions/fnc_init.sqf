/*
 * Author: Olaf
 * Ship Throttle - fnc_init (CfgFunctions postInit = 1)
 *
 * Runs once, automatically, at the start of every mission (vanilla
 * CfgFunctions postInit mechanism - no CBA XEH needed). Registers the
 * throttle keybind handler on the main game display.
 *
 * There's no in-game "Configure Addons" rebind menu without CBA - see
 * fnc_keyDown.sqf / README.md "Keybinds" for the hardcoded defaults and
 * how to change them.
 *
 * Arguments:
 * 0: "postInit" <STRING>
 * 1: didJIP <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _display = displayNull;
waitUntil { !isNull (_display = findDisplay 46) };

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift"];
    [_key, _shift] call olk_fnc_keyDown
}];
