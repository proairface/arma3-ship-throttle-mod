#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_keyDown
 *
 * Hijacks W/S while driving a Ship into discrete, jet-style throttle
 * steps instead of native hold-to-accelerate/brake:
 *   W          throttle +10%
 *   S          throttle -10%
 *   Shift+W    throttle +1%
 *   Shift+S    throttle -1%
 *
 * Returning true consumes the key entirely - native analog
 * accelerate/brake no longer works on a Ship at all once this is
 * active, by design (it's a full replacement, not a supplement). W/S
 * behave completely normally in every other context (on foot, other
 * vehicle types, menus/chat) since _handled is false there.
 *
 * Debounces the engine's own key-repeat: `KeyDown` fires repeatedly
 * while a key is held (like a text field), so a naive implementation
 * would spam +10%/tap into +10%/frame while W is held. A small
 * held-keys tracker (cleared on KeyUp - see fn_keyUp.sqf) makes a held
 * key step exactly once, matching a real jet throttle tap.
 *
 * To use different keys: change the DIK_* constants below (see
 * dikCodes.h for the full list) and repack the addon.
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

// TEMPORARY WIDE DIAGNOSTIC - logs every single keypress the handler
// ever sees, regardless of key or context, to establish ground truth
// about whether/what this handler receives at all. Remove once the
// W/S detection is confirmed working.
systemChat format ["[ShipThrottle] KeyDown seen: key=%1 shift=%2 vehShip=%3 driver=%4", _key, _shift, (vehicle player) isKindOf "Ship", (vehicle player) isKindOf "Ship" && {driver (vehicle player) == player}];

if (_key != DIK_W && {_key != DIK_S}) exitWith {false};

private _handled = (vehicle player) isKindOf "Ship" && {driver (vehicle player) == player};
if (!_handled) exitWith {false};

private _heldKeys = missionNamespace getVariable ["olk_ship_throttle_heldKeys", []];
if (_key in _heldKeys) exitWith {true}; // auto-repeat while held - already stepped on the initial press

_heldKeys pushBackUnique _key;
missionNamespace setVariable ["olk_ship_throttle_heldKeys", _heldKeys];

private _delta = 0;
if (_key == DIK_W) then { _delta = if (_shift) then {1} else {10} };
if (_key == DIK_S) then { _delta = if (_shift) then {-1} else {-10} };

// TEMPORARY DIAGNOSTIC BREADCRUMB - remove once confirmed working.
systemChat format ["[ShipThrottle] key handled, delta=%1", _delta];

[_delta] call olk_fnc_adjustThrottle;
true
