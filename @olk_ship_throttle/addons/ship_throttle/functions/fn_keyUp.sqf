#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_keyUp
 *
 * Clears the held-key tracker fn_keyDown.sqf uses to debounce the
 * engine's key-repeat, and consumes the KeyUp for W/S while driving a
 * Ship (mirroring fn_keyDown.sqf's consumption of the KeyDown) so no
 * stray native release behavior sneaks through.
 *
 * Arguments:
 * 0: DIK key code <NUMBER>
 *
 * Return Value:
 * True if the key was consumed <BOOLEAN>
 *
 * Public: No
 */

params ["_key"];

if (_key != DIK_W && {_key != DIK_S}) exitWith {false};

private _heldKeys = missionNamespace getVariable ["olk_ship_throttle_heldKeys", []];
_heldKeys = _heldKeys - [_key];
missionNamespace setVariable ["olk_ship_throttle_heldKeys", _heldKeys];

(vehicle player) isKindOf "Ship" && {driver (vehicle player) == player}
