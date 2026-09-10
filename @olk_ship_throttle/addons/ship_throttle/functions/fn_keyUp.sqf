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
 * For S specifically: if the hold never reached the brake threshold
 * (fn_brakeHoldWatcher.sqf never started fn_startBrakeLoop.sqf), this
 * was a tap - apply the normal -10%/-1% step here, using the shift
 * state captured at press time in fn_keyDown.sqf (KeyUp doesn't carry
 * its own shift parameter). If braking IS already active, just signal
 * it to stop - fn_startBrakeLoop.sqf notices within one tick (<=0.15s)
 * and hands off to fn_setThrottle.sqf cleanly from there.
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

private _ship = vehicle player;
private _handled = _ship isKindOf "Ship" && {driver _ship == player};

private _heldKeys = missionNamespace getVariable ["olk_ship_throttle_heldKeys", []];
_heldKeys = _heldKeys - [_key];
missionNamespace setVariable ["olk_ship_throttle_heldKeys", _heldKeys];

if (_handled && {_key == DIK_S}) then {
    if (_ship getVariable ["olk_braking", false]) then {
        _ship setVariable ["olk_braking", false];
    } else {
        private _shift = _ship getVariable ["olk_sShiftHeld", false];
        private _delta = if (_shift) then {-1} else {-10};
        [_delta] call olk_fnc_adjustThrottle;
    };
};

_handled
