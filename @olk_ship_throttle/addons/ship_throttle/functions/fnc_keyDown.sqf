#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_keyDown
 *
 * Hardcoded default keybinds (no CBA = no in-game rebind UI):
 *   Numpad +        throttle +10%
 *   Numpad -        throttle -10%
 *   Shift+Numpad +  throttle +1%
 *   Shift+Numpad -  throttle -1%
 *
 * To use different keys: change the DIK_* constants compared against
 * below (see dikCodes.h for the full list) and repack the addon.
 *
 * Arguments:
 * 0: DIK key code <NUMBER>
 * 1: Shift held <BOOLEAN>
 *
 * Return Value:
 * True if the key was consumed <BOOLEAN>
 *
 * Public: No
 */

params ["_key", "_shift"];

private _handled = (vehicle player) isKindOf "Ship" && {driver (vehicle player) == player};
if (!_handled) exitWith {false};

private _delta = 0;
if (_key == DIK_ADD) then { _delta = if (_shift) then {1} else {10} };
if (_key == DIK_SUBTRACT) then { _delta = if (_shift) then {-1} else {-10} };

if (_delta == 0) exitWith {false};

[_delta] call olk_fnc_adjustThrottle;
true
