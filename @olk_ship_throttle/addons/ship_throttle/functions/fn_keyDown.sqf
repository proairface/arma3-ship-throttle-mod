#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_keyDown
 *
 * Two independent things:
 *
 * 1. Ctrl+Shift+T (fixed, not user-configurable - opens the menu that
 *    configures everything else) opens the throttle settings dialog
 *    (fn_onSettingsMenuLoad.sqf) if no dialog is already open.
 *
 * 2. The throttle-step keys (default Ctrl+W / Ctrl+S, rebindable via
 *    that settings menu and stored in profileNamespace) step throttle
 *    +-10%/+-1% (Shift for fine) while driving a Ship. Plain W/S are
 *    NOT touched anymore - they're native accelerate/brake/reverse,
 *    same as any other vehicle. Earlier builds fully hijacked W/S
 *    (0.3.0-0.4.1); real-world feedback found that clunky (no working
 *    brake) even after adding a hold-to-brake mechanism, so this
 *    reverts to a modifier combo instead, freeing native controls
 *    entirely - see README.md "Design decisions".
 *
 * Debounces the engine's own key-repeat: `KeyDown` fires repeatedly
 * while a key is held (like a text field) - a held-keys tracker
 * (cleared by fn_keyUp.sqf on release) means a fresh press is only
 * detected once, not every repeat frame.
 *
 * Arguments:
 * 0: DIK key code <NUMBER>
 * 1: Shift held <BOOLEAN>
 * 2: Ctrl held <BOOLEAN>
 *
 * Return Value:
 * True if the key was consumed <BOOLEAN>
 *
 * Public: No
 */

params ["_key", "_shift", "_ctrl"];

if (_key == DIK_T && _shift && _ctrl) exitWith {
    if (!dialog) then {
        createDialog "olk_ship_throttle_settings";
    };
    true
};

private _ship = vehicle player;
private _handled = _ship isKindOf "Ship" && {driver _ship == player};
if (!_handled) exitWith {false};

private _increaseBinding = profileNamespace getVariable ["olk_ship_throttle_increaseKey", [DIK_W, true]];
private _decreaseBinding = profileNamespace getVariable ["olk_ship_throttle_decreaseKey", [DIK_S, true]];

private _isIncrease = _key == (_increaseBinding select 0) && {_ctrl == (_increaseBinding select 1)};
private _isDecrease = _key == (_decreaseBinding select 0) && {_ctrl == (_decreaseBinding select 1)};
if (!_isIncrease && !_isDecrease) exitWith {false};

private _heldKeys = missionNamespace getVariable ["olk_ship_throttle_heldKeys", []];
if (_key in _heldKeys) exitWith {true}; // auto-repeat while held

_heldKeys pushBackUnique _key;
missionNamespace setVariable ["olk_ship_throttle_heldKeys", _heldKeys];

private _delta = 0;
if (_isIncrease) then { _delta = if (_shift) then {1} else {10} };
if (_isDecrease) then { _delta = if (_shift) then {-1} else {-10} };

[_delta] call olk_fnc_adjustThrottle;
true
