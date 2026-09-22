/*
 * Author: Olaf
 * Ship Throttle - fnc_keyUp
 *
 * Clears the held-key tracker fn_keyDown.sqf uses to debounce the
 * engine's key-repeat for the (configurable) throttle-step keys.
 *
 * Arguments:
 * 0: DIK key code <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_key"];

private _heldKeys = missionNamespace getVariable ["olk_ship_throttle_heldKeys", []];
if (_key in _heldKeys) then {
    _heldKeys = _heldKeys - [_key];
    missionNamespace setVariable ["olk_ship_throttle_heldKeys", _heldKeys];
};

false
