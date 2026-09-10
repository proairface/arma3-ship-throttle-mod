#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_keyDown
 *
 * W: steps throttle +10%/+1% (shift) immediately on press, same as
 * always.
 *
 * S: does NOT step immediately anymore. A fresh press starts a 0.3s
 * hold watcher (fn_brakeHoldWatcher.sqf): released before that, it's a
 * tap and fn_keyUp.sqf applies the normal -10%/-1% step; still held
 * after 0.3s, it switches into continuous active braking
 * (fn_startBrakeLoop.sqf) instead. This restores a "hold S to brake"
 * feel that plain throttle-stepping alone couldn't give - see
 * README.md "Design decisions".
 *
 * Returning true consumes the key entirely - native analog
 * accelerate/brake no longer works on a Ship at all once this is
 * active, by design (it's a full replacement, not a supplement). W/S
 * behave completely normally in every other context (on foot, other
 * vehicle types, menus/chat) since _handled is false there.
 *
 * Debounces the engine's own key-repeat: `KeyDown` fires repeatedly
 * while a key is held (like a text field) - a held-keys tracker
 * (cleared by fn_keyUp.sqf on release) means a fresh press is only
 * detected once, not every repeat frame.
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

if (_key != DIK_W && {_key != DIK_S}) exitWith {false};

private _ship = vehicle player;
private _handled = _ship isKindOf "Ship" && {driver _ship == player};
if (!_handled) exitWith {false};

private _heldKeys = missionNamespace getVariable ["olk_ship_throttle_heldKeys", []];
if (_key in _heldKeys) exitWith {true}; // auto-repeat while held

_heldKeys pushBackUnique _key;
missionNamespace setVariable ["olk_ship_throttle_heldKeys", _heldKeys];

if (_key == DIK_W) then {
    private _delta = if (_shift) then {1} else {10};
    [_delta] call olk_fnc_adjustThrottle;
};

if (_key == DIK_S) then {
    _ship setVariable ["olk_sShiftHeld", _shift];
    [_ship] spawn olk_fnc_brakeHoldWatcher;
};

true
