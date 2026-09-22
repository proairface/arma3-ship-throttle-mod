#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_refreshSettingsMenu
 *
 * Repaints the settings dialog's text controls from current bindings
 * (profileNamespace) and capture state (stored on the display itself
 * via setVariable/getVariable - see fn_onSettingsMenuLoad.sqf).
 *
 * Arguments:
 * 0: Settings dialog's display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display"];

private _increaseBinding = profileNamespace getVariable ["olk_ship_throttle_increaseKey", [DIK_W, true]];
private _decreaseBinding = profileNamespace getVariable ["olk_ship_throttle_decreaseKey", [DIK_S, true]];
private _captureMode = _display getVariable ["olk_captureMode", ""];

private _increaseText = if (_captureMode == "increase") then {
    "1) Increase Throttle: press a key..."
} else {
    format ["1) Increase Throttle: %1", [_increaseBinding] call olk_fnc_bindingToText]
};

private _decreaseText = if (_captureMode == "decrease") then {
    "2) Decrease Throttle: press a key..."
} else {
    format ["2) Decrease Throttle: %1", [_decreaseBinding] call olk_fnc_bindingToText]
};

(_display displayCtrl 62201) ctrlSetStructuredText parseText format ["<t align='center'>%1</t>", _increaseText];
(_display displayCtrl 62202) ctrlSetStructuredText parseText format ["<t align='center'>%1</t>", _decreaseText];
(_display displayCtrl 62203) ctrlSetStructuredText parseText "<t align='center'>Shift+key = fine (+-1%). Press 1 or 2 to rebind, Esc to close/cancel.</t>";
